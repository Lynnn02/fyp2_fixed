import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContentFilterService {
  static final ContentFilterService _instance = ContentFilterService._internal();
  factory ContentFilterService() => _instance;
  ContentFilterService._internal();
  
  // Cache for quick access
  Map<String, bool> _subjectAccessCache = {};
  DateTime? _lastCacheUpdate;
  
  // Check if a subject is allowed for the current user
  Future<bool> isSubjectAllowed(String subjectId) async {
    // Get the current user's ID
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // If no user is logged in, default to allowed
      return true;
    }
    
    final String userId = currentUser.uid;
    
    // Check if we need to refresh the cache (every 5 minutes)
    final now = DateTime.now();
    if (_lastCacheUpdate == null || 
        now.difference(_lastCacheUpdate!).inMinutes >= 5 ||
        _subjectAccessCache.isEmpty) {
      await _refreshCache(userId);
    }
    
    // Check if the subject is in the cache
    return _subjectAccessCache[subjectId] ?? true;
  }
  
  // Refresh the cache from Firestore
  Future<void> _refreshCache(String userId) async {
    try {
      // Get content filter settings from Firestore
      final settingsDoc = await FirebaseFirestore.instance
          .collection('contentFilters')
          .doc(userId)
          .get();
      
      if (settingsDoc.exists) {
        final data = settingsDoc.data()!;
        final Map<String, dynamic>? subjectAccess = data['subjectAccess'] as Map<String, dynamic>?;
        
        if (subjectAccess != null) {
          // Convert from Map<String, dynamic> to Map<String, bool>
          _subjectAccessCache = subjectAccess.map((key, value) => MapEntry(key, value as bool));
        }
      }
      
      // Also store in SharedPreferences for offline access
      final prefs = await SharedPreferences.getInstance();
      for (var entry in _subjectAccessCache.entries) {
        await prefs.setBool('contentFilter_${entry.key}', entry.value);
      }
      
      _lastCacheUpdate = DateTime.now();
    } catch (e) {
      print('Error refreshing content filter cache: $e');
      
      // If there's an error, try to load from SharedPreferences
      await _loadFromPreferences(userId);
    }
  }
  
  // Load content filter settings from SharedPreferences
  Future<void> _loadFromPreferences(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get all subjects from Firestore
      final subjectsSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .get();
      
      for (var doc in subjectsSnapshot.docs) {
        final subjectId = doc.id;
        final prefKey = 'contentFilter_$subjectId';
        
        // If the preference exists, use it; otherwise default to allowed
        final isAllowed = prefs.getBool(prefKey) ?? true;
        _subjectAccessCache[subjectId] = isAllowed;
      }
      
      _lastCacheUpdate = DateTime.now();
    } catch (e) {
      print('Error loading content filters from preferences: $e');
      // If all else fails, default to allowing all subjects
      _subjectAccessCache = {};
    }
  }
  
  // Check if a subject is allowed from SharedPreferences (for quick checks)
  Future<bool> isSubjectAllowedOffline(String subjectId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('contentFilter_$subjectId') ?? true;
    } catch (e) {
      print('Error checking subject access offline: $e');
      return true; // Default to allowed if there's an error
    }
  }
  
  // Clear the cache (useful when logging out)
  void clearCache() {
    _subjectAccessCache.clear();
    _lastCacheUpdate = null;
  }
}
