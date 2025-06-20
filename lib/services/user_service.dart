import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as Math;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache for user names to avoid repeated lookups
  static final Map<String, String> _userNameCache = {};
  
  // Get a real user name from the profiles collection
  Future<String> getRealUserName(String userId) async {
    // Check if this is a default userId and try to get the real userId
    String actualUserId = userId;
    
    if (userId == 'default_user' || userId.isEmpty) {
      // Try to get the current authenticated user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        actualUserId = currentUser.uid;
        print('Using authenticated user ID instead of default_user: $actualUserId');
      }
    }
    
    // Check cache first
    if (_userNameCache.containsKey(actualUserId)) {
      return _userNameCache[actualUserId]!;
    }
    
    String realUserName = "";
    bool foundRealName = false;
    
    try {
      print('Looking up real name for user ID: $actualUserId');
      
      // First check the profiles collection for the real student name
      final profileDoc = await _firestore.collection('profiles').doc(actualUserId).get();
      if (profileDoc.exists) {
        final profileData = profileDoc.data();
        if (profileData != null) {
          // Try studentName field first (as shown in your Firebase screenshot)
          if (profileData.containsKey('studentName')) {
            final studentName = profileData['studentName'];
            if (studentName is String && studentName.isNotEmpty) {
              realUserName = studentName;
              foundRealName = true;
              print('Found real student name from profiles.studentName: $realUserName for user ID: $actualUserId');
            }
          }
          // Also try name field as fallback
          else if (profileData.containsKey('name')) {
            final name = profileData['name'];
            if (name is String && name.isNotEmpty) {
              realUserName = name;
              foundRealName = true;
              print('Found real student name from profiles.name: $realUserName for user ID: $actualUserId');
            }
          }
        }
      }
      
      // If still no real name found, check the users collection as a fallback
      if (!foundRealName) {
        final userDoc = await _firestore.collection('users').doc(actualUserId).get();
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
                print('Found real name from users.displayName: $realUserName for user ID: $actualUserId');
              }
            } else if (userData.containsKey('name')) {
              final name = userData['name'];
              if (name is String && name.isNotEmpty && 
                  !name.toLowerCase().contains('default') && 
                  name != 'Default User') {
                realUserName = name;
                foundRealName = true;
                print('Found real name from users.name: $realUserName for user ID: $actualUserId');
              }
            }
          }
        }
      }
      
      // If we still have a default user name, try one more approach - query by userId
      if (!foundRealName) {
        // Query profiles collection where userId field equals our userId
        final profilesQuery = await _firestore.collection('profiles')
            .where('userId', isEqualTo: actualUserId)
            .limit(1)
            .get();
        
        if (profilesQuery.docs.isNotEmpty) {
          final profileData = profilesQuery.docs.first.data();
          if (profileData.containsKey('studentName')) {
            final studentName = profileData['studentName'];
            if (studentName is String && studentName.isNotEmpty) {
              realUserName = studentName;
              foundRealName = true;
              print('Found real name from profiles query: $realUserName for user ID: $actualUserId');
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
      final int firstNameIndex = actualUserId.hashCode.abs() % firstNames.length;
      final int lastNameIndex = (actualUserId.hashCode >> 4).abs() % lastNames.length;
      
      realUserName = '${firstNames[firstNameIndex]} ${lastNames[lastNameIndex]}';
      print('Generated consistent name: $realUserName for user ID: $actualUserId');
    }
    
    // Cache the result
    _userNameCache[actualUserId] = realUserName;
    return realUserName;
  }
  
  // Get a real user name synchronously (uses cache or returns a placeholder)
  String getRealUserNameSync(String userId) {
    // Check if this is a default userId and try to get the real userId
    String actualUserId = userId;
    
    if (userId == 'default_user' || userId.isEmpty) {
      // Try to get the current authenticated user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        actualUserId = currentUser.uid;
        print('Using authenticated user ID instead of default_user in sync method: $actualUserId');
      }
    }
    
    // Check cache first
    if (_userNameCache.containsKey(actualUserId)) {
      return _userNameCache[actualUserId]!;
    }
    
    // If not in cache, return a temporary name and trigger an async lookup
    String tempName = 'Student ${actualUserId.substring(0, Math.min(4, actualUserId.length))}';
    
    // Trigger async lookup to populate cache for future calls
    getRealUserName(actualUserId).then((realName) {
      // Cache will be updated by the async method
      print('Async lookup completed for $actualUserId: $realName');
    });
    
    return tempName;
  }
}
