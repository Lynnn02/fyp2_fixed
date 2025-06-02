import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as Math;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache for user names to avoid repeated lookups
  static final Map<String, String> _userNameCache = {};
  
  // Get a real user name from the profiles collection
  Future<String> getRealUserName(String userId) async {
    // Check cache first
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId]!;
    }
    
    String realUserName = "";
    bool foundRealName = false;
    
    try {
      print('Looking up real name for user ID: $userId');
      
      // First check the profiles collection for the real student name
      final profileDoc = await _firestore.collection('profiles').doc(userId).get();
      if (profileDoc.exists) {
        final profileData = profileDoc.data();
        if (profileData != null) {
          // Try studentName field first (as shown in your Firebase screenshot)
          if (profileData.containsKey('studentName')) {
            final studentName = profileData['studentName'];
            if (studentName is String && studentName.isNotEmpty) {
              realUserName = studentName;
              foundRealName = true;
              print('Found real student name from profiles.studentName: $realUserName for user ID: $userId');
            }
          }
          // Also try name field as fallback
          else if (profileData.containsKey('name')) {
            final name = profileData['name'];
            if (name is String && name.isNotEmpty) {
              realUserName = name;
              foundRealName = true;
              print('Found real student name from profiles.name: $realUserName for user ID: $userId');
            }
          }
        }
      }
      
      // If still no real name found, check the users collection as a fallback
      if (!foundRealName) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null) {
            // Try different possible fields for user names
            if (userData.containsKey('displayName')) {
              final displayName = userData['displayName'];
              if (displayName is String && displayName.isNotEmpty && 
                  !displayName.toLowerCase().contains('default') && 
                  displayName != 'Default User') {
                realUserName = displayName;
                foundRealName = true;
                print('Found real name from users.displayName: $realUserName for user ID: $userId');
              }
            } else if (userData.containsKey('name')) {
              final name = userData['name'];
              if (name is String && name.isNotEmpty && 
                  !name.toLowerCase().contains('default') && 
                  name != 'Default User') {
                realUserName = name;
                foundRealName = true;
                print('Found real name from users.name: $realUserName for user ID: $userId');
              }
            }
          }
        }
      }
      
      // If we still have a default user name, try one more approach - query by userId
      if (!foundRealName) {
        // Query profiles collection where userId field equals our userId
        final profilesQuery = await _firestore.collection('profiles')
            .where('userId', isEqualTo: userId)
            .limit(1)
            .get();
        
        if (profilesQuery.docs.isNotEmpty) {
          final profileData = profilesQuery.docs.first.data();
          if (profileData.containsKey('studentName')) {
            final studentName = profileData['studentName'];
            if (studentName is String && studentName.isNotEmpty) {
              realUserName = studentName;
              foundRealName = true;
              print('Found real name from profiles query: $realUserName for user ID: $userId');
            }
          }
        }
      }
    } catch (e) {
      print('Error looking up real student name: $e');
    }
    
    // If we still have a default user name, use a more descriptive generic name
    if (realUserName.isEmpty || 
        realUserName.toLowerCase().contains('default') || 
        realUserName == 'Default User') {
      // Generate a consistent name based on the user ID
      final List<String> firstNames = [
        'Alex', 'Bailey', 'Casey', 'Dana', 'Emery', 
        'Finley', 'Gray', 'Hayden', 'Indigo', 'Jordan'
      ];
      final List<String> lastNames = [
        'Smith', 'Johnson', 'Williams', 'Jones', 'Brown',
        'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor'
      ];
      
      // Use the user ID to deterministically select a name
      final int firstNameIndex = userId.hashCode.abs() % firstNames.length;
      final int lastNameIndex = (userId.hashCode >> 4).abs() % lastNames.length;
      
      realUserName = '${firstNames[firstNameIndex]} ${lastNames[lastNameIndex]}';
      print('Generated consistent name: $realUserName for user ID: $userId');
    }
    
    // Cache the result
    _userNameCache[userId] = realUserName;
    return realUserName;
  }
  
  // Get a real user name synchronously (uses cache or returns a placeholder)
  String getRealUserNameSync(String userId) {
    // Check cache first
    if (_userNameCache.containsKey(userId)) {
      return _userNameCache[userId]!;
    }
    
    // If not in cache, return a temporary name and trigger an async lookup
    String tempName = 'Student ${userId.substring(0, Math.min(4, userId.length))}';
    
    // Trigger async lookup to populate cache for future calls
    getRealUserName(userId).then((realName) {
      // Cache will be updated by the async method
      print('Async lookup completed for $userId: $realName');
    });
    
    return tempName;
  }
}
