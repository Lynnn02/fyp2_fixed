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
  String? _lastUserId; // Track which user's data we've cached
  
  // Check if a subject is allowed for the current user
  Future<bool> isSubjectAllowed(String subjectIdOrName) async {
    // Get the current user's ID
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // If no user is logged in, default to allowed
      return true;
    }
    
    final String userId = currentUser.uid;
    
    // Force refresh if user has changed
    if (_lastUserId != userId) {
      print('User changed from $_lastUserId to $userId - forcing cache refresh');
      await _refreshCache(userId);
    } else {
      // Check if we need to refresh the cache
      // Reduced cache time to 1 minute for more responsive updates
      final now = DateTime.now();
      if (_lastCacheUpdate == null || 
          now.difference(_lastCacheUpdate!).inMinutes >= 1 ||
          _subjectAccessCache.isEmpty) {
        await _refreshCache(userId);
      } else {
        // Check for updates in SharedPreferences that may have been made elsewhere
        await _checkForPreferenceUpdates(userId);
      }
    }
    
    // IMPORTANT: We need to check both by ID and by name since filters may be stored with either
    bool isAllowed;
    
    // First check by exact ID match
    if (_subjectAccessCache.containsKey(subjectIdOrName)) {
      isAllowed = _subjectAccessCache[subjectIdOrName] ?? true;
      print('Subject ID "$subjectIdOrName" found in cache, allowed: $isAllowed');
      return isAllowed;
    } 
    
    // Try to find the subject by looking up the document in Firestore
    try {
      final subjectDoc = await FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectIdOrName)
          .get();
      
      if (subjectDoc.exists) {
        final data = subjectDoc.data();
        if (data != null) {
          final subjectName = data['name'] as String?;
          if (subjectName != null && _subjectAccessCache.containsKey(subjectName)) {
            isAllowed = _subjectAccessCache[subjectName] ?? true;
            print('Found subject name "$subjectName" in cache for ID "$subjectIdOrName", allowed: $isAllowed');
            return isAllowed;
          }
        }
      }
      
      // If we reach here, try a reverse lookup in all subjects to find the ID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .where('name', isEqualTo: subjectIdOrName)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        final foundId = querySnapshot.docs.first.id;
        if (_subjectAccessCache.containsKey(foundId)) {
          isAllowed = _subjectAccessCache[foundId] ?? true;
          print('Found ID "$foundId" for subject name "$subjectIdOrName", allowed: $isAllowed');
          return isAllowed;
        }
      }
      
      // Default to BLOCKED if we can't find the setting
      // This ensures only explicitly allowed subjects are shown
      print('No content filter setting found for "$subjectIdOrName", defaulting to BLOCKED');
      return false;
    } catch (e) {
      print('Error checking subject access: $e');
      return false; // Default to BLOCKED on error for security
    }
  }
  
  // Refresh the cache from Firestore
  Future<void> _refreshCache(String userId) async {
    try {
      print('Refreshing content filter cache for user $userId');
      
      // Get content filter settings from Firestore
      final settingsDoc = await FirebaseFirestore.instance
          .collection('contentFilters')
          .doc(userId)
          .get();
      
      Map<String, bool> newCache = {};
      if (settingsDoc.exists) {
        final data = settingsDoc.data()!;
        final Map<String, dynamic>? subjectAccess = data['subjectAccess'] as Map<String, dynamic>?;
        
        if (subjectAccess != null) {
          // Convert from Map<String, dynamic> to Map<String, bool>
          newCache = subjectAccess.map((key, value) => MapEntry(key, value as bool));
          print('Loaded ${newCache.length} content filter settings from Firestore');
        }
      }
      
      // Also store in SharedPreferences for offline access
      final prefs = await SharedPreferences.getInstance();
      for (var entry in newCache.entries) {
        await prefs.setBool('contentFilter_${entry.key}', entry.value);
      }
      
      // Save timestamp of update
      await prefs.setString('contentFilter_lastUpdated', DateTime.now().toIso8601String());
      
      _subjectAccessCache = newCache;
      _lastCacheUpdate = DateTime.now();
      _lastUserId = userId;
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
      Map<String, bool> newCache = {};
      
      // Get all subjects from Firestore
      final subjectsSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .get();
      
      print('Loading content filters from preferences for ${subjectsSnapshot.docs.length} subjects');
      
      for (var doc in subjectsSnapshot.docs) {
        final subjectId = doc.id;
        final subjectName = doc.data()['name'] as String? ?? '';
        final idPrefKey = 'contentFilter_$subjectId';
        final namePrefKey = 'contentFilter_name_$subjectName';
        
        // Check for ID-based preference
        if (prefs.containsKey(idPrefKey)) {
          final isAllowed = prefs.getBool(idPrefKey) ?? true;
          newCache[subjectId] = isAllowed;
          print('Loaded ID filter for "$subjectId" = $isAllowed');
        }
        
        // Check for name-based preference
        if (subjectName.isNotEmpty && prefs.containsKey(namePrefKey)) {
          final isAllowed = prefs.getBool(namePrefKey) ?? true;
          newCache[subjectName] = isAllowed;
          print('Loaded name filter for "$subjectName" = $isAllowed');
        }
      }
      
      // Apply the loaded preferences to our cache
      _subjectAccessCache = newCache;
      _lastCacheUpdate = DateTime.now();
      print('Updated filter cache with ${_subjectAccessCache.length} entries');
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
  
  // Check if there have been updates in SharedPreferences
  Future<void> _checkForPreferenceUpdates(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdatedStr = prefs.getString('contentFilter_lastUpdated');
      
      if (lastUpdatedStr != null) {
        final lastUpdated = DateTime.parse(lastUpdatedStr);
        
        // If SharedPreferences were updated more recently than our cache
        if (_lastCacheUpdate == null || lastUpdated.isAfter(_lastCacheUpdate!)) {
          print('SharedPreferences content filters are newer than cache - updating from preferences');
          await _loadFromPreferences(userId);
        }
      }
    } catch (e) {
      print('Error checking for preference updates: $e');
    }
  }

  // Clear the cache (useful when logging out or force refreshing)
  void clearCache() {
    print('Clearing content filter cache');
    _subjectAccessCache.clear();
    _lastCacheUpdate = null;
    _lastUserId = null;
  }
}
