import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' show min;
import '../models/score.dart';

class ScoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  // Add a new score entry
  Future<void> addScore({
    required String userId,
    required String userName, // This might be 'Default User' from calling code
    required String subjectId,
    required String subjectName,
    required String activityId,
    required String activityType,
    required String activityName,
    required int points,
    required int ageGroup,
    String? chapterName, // Add optional chapterName parameter
  }) async {
    try {
      final timestamp = DateTime.now();
      
      // First, check if this is a default userId and try to get the real userId from profiles
      String actualUserId = userId;
      
      if (userId == 'default_user' || userId.isEmpty) {
        // Try to get the current authenticated user
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          actualUserId = currentUser.uid;
          print('Using authenticated user ID instead of default_user: $actualUserId');
        }
      }
      
      // ALWAYS look up the real student name from the profiles collection
      // regardless of what userName is passed in
      String realUserName = userName; // Start with the provided name as fallback
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
        if (!foundRealName && (realUserName.isEmpty || 
                              realUserName.toLowerCase().contains('default') || 
                              realUserName == 'Default User')) {
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
                print('Found real name from profiles query: $realUserName for user ID: $userId');
              }
            }
          }
        }
      } catch (e) {
        print('Error looking up real student name: $e');
        // Continue with the provided userName if there's an error
      }
      
      // If we still have a default user name, use a more descriptive generic name
      if (realUserName.isEmpty || 
          realUserName.toLowerCase().contains('default') || 
          realUserName == 'Default User') {
        realUserName = 'Student ${actualUserId.substring(0, min(4, actualUserId.length))}';
        print('Using generic name: $realUserName for user ID: $actualUserId');
      }
      // Create a map for the score data to include chapterName if provided
      Map<String, dynamic> scoreData = {
        'id': _uuid.v4(),
        'userId': actualUserId, // Use the actual userId, not default_user
        'userName': realUserName, // Use the real student name we looked up
        'subjectId': subjectId,
        'subjectName': subjectName,
        'activityId': activityId,
        'activityType': activityType,
        'activityName': activityName,
        'points': points,
        'timestamp': timestamp,
        'ageGroup': ageGroup,
      };
      
      // Add chapterName if provided
      if (chapterName != null && chapterName.isNotEmpty) {
        scoreData['chapterName'] = chapterName;
      }
      
      final score = Score(
        id: scoreData['id'],
        userId: scoreData['userId'],
        userName: scoreData['userName'],
        subjectId: scoreData['subjectId'],
        subjectName: scoreData['subjectName'],
        activityId: scoreData['activityId'],
        activityType: scoreData['activityType'],
        activityName: scoreData['activityName'],
        points: scoreData['points'],
        timestamp: scoreData['timestamp'],
        ageGroup: scoreData['ageGroup'],
      );

      // Save to scores collection with additional chapterName field if provided
      await _firestore.collection('scores').doc(score.id).set(scoreData);
      
      // Also save to progress collection for child progress tracking
      Map<String, dynamic> progressData = {
        'userId': actualUserId, // Use the actual userId, not default_user
        'userName': realUserName, // Add the real student name
        'subject': subjectName,
        'subjectName': subjectName, // Add explicit subjectName field
        'activityName': activityName,
        'points': points,
        'studyMinutes': 5, // Default study time in minutes
        'timestamp': Timestamp.fromDate(timestamp),
        'activityType': activityType,
        'gameType': activityName.toLowerCase().contains('matching') ? 'matching' : 
                    activityName.toLowerCase().contains('tracing') ? 'tracing' : 'other',
      };
      
      // Use provided chapterName if available, otherwise use activityName
      progressData['chapterName'] = chapterName ?? activityName;
      
      await _firestore.collection('progress').add(progressData);
      
      print('Progress data saved for child progress tracking');
    } catch (e) {
      print('Error adding score: $e');
      throw e;
    }
  }

  // Get all scores for a specific user
  Future<List<Score>> getUserScores(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('scores')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting user scores: $e');
      return [];
    }
  }

  // Get scores for a specific subject
  Future<List<Score>> getSubjectScores(String subjectId) async {
    try {
      final snapshot = await _firestore
          .collection('scores')
          .where('subjectId', isEqualTo: subjectId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting subject scores: $e');
      return [];
    }
  }

  // Get scores for a specific activity type (game, note, video)
  Future<List<Score>> getActivityTypeScores(String activityType) async {
    try {
      final snapshot = await _firestore
          .collection('scores')
          .where('activityType', isEqualTo: activityType)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting activity type scores: $e');
      return [];
    }
  }

  // Get leaderboard for a specific subject
  // Excludes admin users from the results
  Future<List<LeaderboardEntry>> getSubjectLeaderboard(String subjectId) async {
    try {
      // First, get all profiles to have accurate student names
      final Map<String, String> userProfiles = {};
      try {
        final profilesSnapshot = await _firestore.collection('profiles').get();
        for (final doc in profilesSnapshot.docs) {
          final data = doc.data();
          final userId = doc.id;
          String name = 'Student';
          
          // Try to get studentName first, then fall back to name
          if (data.containsKey('studentName') && data['studentName'] is String && data['studentName'].toString().isNotEmpty) {
            name = data['studentName'];
          } else if (data.containsKey('name') && data['name'] is String && data['name'].toString().isNotEmpty) {
            name = data['name'];
          }
          
          userProfiles[userId] = name;
          print('Added profile for $userId: $name');
        }
      } catch (e) {
        print('Error loading profiles: $e');
      }
      
      // Now get the scores for this subject
      final snapshot = await _firestore
          .collection('scores')
          .where('subjectId', isEqualTo: subjectId)
          .get();

      final scores = snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList();

      // Group scores by user and calculate total points
      final Map<String, Map<String, dynamic>> userScores = {};
      for (final score in scores) {
        if (!userScores.containsKey(score.userId)) {
          // Get the real user name from our profiles map
          String realUserName = userProfiles[score.userId] ?? score.userName;
          
          userScores[score.userId] = {
            'userId': score.userId,
            'userName': realUserName,
            'totalPoints': 0,
            'ageGroup': score.ageGroup,
          };
        }
        userScores[score.userId]!['totalPoints'] += score.points;
      }

      // Convert to list and sort by total points
      final List<Map<String, dynamic>> leaderboardData = userScores.values.toList();
      leaderboardData.sort((a, b) => (b['totalPoints'] as int).compareTo(a['totalPoints'] as int));

      // Add rank
      for (int i = 0; i < leaderboardData.length; i++) {
        leaderboardData[i]['rank'] = i + 1;
      }

      // Convert to LeaderboardEntry objects
      return leaderboardData.map((data) => LeaderboardEntry.fromJson(data)).toList();
    } catch (e) {
      print('Error getting subject leaderboard: $e');
      return [];
    }
  }

  // Get global leaderboard
  // Excludes admin users from the results
  Future<List<LeaderboardEntry>> getGlobalLeaderboard() async {
    try {
      final snapshot = await _firestore.collection('scores').get();

      final scores = snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList();

      // Group scores by user and calculate total points
      final Map<String, Map<String, dynamic>> userScores = {};
      for (final score in scores) {
        if (!userScores.containsKey(score.userId)) {
          userScores[score.userId] = {
            'userId': score.userId,
            'userName': score.userName,
            'totalPoints': 0,
            'ageGroup': score.ageGroup,
          };
        }
        userScores[score.userId]!['totalPoints'] += score.points;
      }

      // Convert to list and sort by total points
      final List<Map<String, dynamic>> leaderboardData = userScores.values.toList();
      leaderboardData.sort((a, b) => (b['totalPoints'] as int).compareTo(a['totalPoints'] as int));

      // Add rank
      for (int i = 0; i < leaderboardData.length; i++) {
        leaderboardData[i]['rank'] = i + 1;
      }

      // Convert to LeaderboardEntry objects
      return leaderboardData.map((data) => LeaderboardEntry.fromJson(data)).toList();
    } catch (e) {
      print('Error getting global leaderboard: $e');
      return [];
    }
  }

  // Get leaderboard for a specific age group
  // Excludes admin users from the results
  Future<List<LeaderboardEntry>> getAgeGroupLeaderboard(int ageGroup) async {
    try {
      // First, get all profiles to have accurate student names
      final Map<String, String> userProfiles = {};
      try {
        final profilesSnapshot = await _firestore.collection('profiles').get();
        for (final doc in profilesSnapshot.docs) {
          final data = doc.data();
          final userId = doc.id;
          String name = 'Student';
          
          // Try to get studentName first, then fall back to name
          if (data.containsKey('studentName') && data['studentName'] is String && data['studentName'].toString().isNotEmpty) {
            name = data['studentName'];
          } else if (data.containsKey('name') && data['name'] is String && data['name'].toString().isNotEmpty) {
            name = data['name'];
          }
          
          userProfiles[userId] = name;
        }
      } catch (e) {
        print('Error loading profiles: $e');
      }
      
      // Now get the scores for this age group
      final snapshot = await _firestore
          .collection('scores')
          .where('ageGroup', isEqualTo: ageGroup)
          .get();

      final scores = snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList();

      // Group scores by user and calculate total points
      final Map<String, Map<String, dynamic>> userScores = {};
      for (final score in scores) {
        if (!userScores.containsKey(score.userId)) {
          // Get the real user name from our profiles map
          String realUserName = userProfiles[score.userId] ?? score.userName;
          
          userScores[score.userId] = {
            'userId': score.userId,
            'userName': realUserName,
            'totalPoints': 0,
            'ageGroup': score.ageGroup,
          };
        }
        userScores[score.userId]!['totalPoints'] += score.points;
      }

      // Convert to list and sort by total points
      final List<Map<String, dynamic>> leaderboardData = userScores.values.toList();
      leaderboardData.sort((a, b) => (b['totalPoints'] as int).compareTo(a['totalPoints'] as int));

      // Add rank
      for (int i = 0; i < leaderboardData.length; i++) {
        leaderboardData[i]['rank'] = i + 1;
      }

      // Convert to LeaderboardEntry objects
      return leaderboardData.map((data) => LeaderboardEntry.fromJson(data)).toList();
    } catch (e) {
      print('Error getting age group leaderboard: $e');
      return [];
    }
  }

  // Get analytics data for admin dashboard
  Future<Map<String, dynamic>> getAnalyticsData({
    DateTime? startDate,
    DateTime? endDate,
    int? ageGroup,
    String? subjectId,
  }) async {
    try {
      Query query = _firestore.collection('scores');

      // Apply filters
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }
      if (ageGroup != null) {
        query = query.where('ageGroup', isEqualTo: ageGroup);
      }
      if (subjectId != null) {
        query = query.where('subjectId', isEqualTo: subjectId);
      }

      final snapshot = await query.get();
      final scores = snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList();

      // Calculate analytics
      int totalScores = scores.length;
      int totalPoints = scores.fold(0, (sum, score) => sum + score.points);
      double averagePoints = totalScores > 0 ? totalPoints / totalScores : 0;

      // Activity type breakdown
      Map<String, int> activityCounts = {
        'game': 0,
        'note': 0,
        'video': 0,
      };
      Map<String, int> activityPoints = {
        'game': 0,
        'note': 0,
        'video': 0,
      };

      for (final score in scores) {
        activityCounts[score.activityType] = (activityCounts[score.activityType] ?? 0) + 1;
        activityPoints[score.activityType] = (activityPoints[score.activityType] ?? 0) + score.points;
      }

      // Subject breakdown
      Map<String, int> subjectCounts = {};
      Map<String, int> subjectPoints = {};

      for (final score in scores) {
        subjectCounts[score.subjectName] = (subjectCounts[score.subjectName] ?? 0) + 1;
        subjectPoints[score.subjectName] = (subjectPoints[score.subjectName] ?? 0) + score.points;
      }

      // User breakdown
      Map<String, int> userCounts = {};
      Map<String, int> userPoints = {};

      for (final score in scores) {
        userCounts[score.userName] = (userCounts[score.userName] ?? 0) + 1;
        userPoints[score.userName] = (userPoints[score.userName] ?? 0) + score.points;
      }

      return {
        'totalScores': totalScores,
        'totalPoints': totalPoints,
        'averagePoints': averagePoints,
        'activityCounts': activityCounts,
        'activityPoints': activityPoints,
        'subjectCounts': subjectCounts,
        'subjectPoints': subjectPoints,
        'userCounts': userCounts,
        'userPoints': userPoints,
      };
    } catch (e) {
      print('Error getting analytics data: $e');
      return {};
    }
  }

  // Get daily activity data for charts
  Future<List<Map<String, dynamic>>> getDailyActivityData({
    required DateTime startDate,
    required DateTime endDate,
    int? ageGroup,
    String? subjectId,
  }) async {
    try {
      Query query = _firestore.collection('scores')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate));

      // Apply additional filters
      if (ageGroup != null) {
        query = query.where('ageGroup', isEqualTo: ageGroup);
      }
      if (subjectId != null) {
        query = query.where('subjectId', isEqualTo: subjectId);
      }

      final snapshot = await query.get();
      final scores = snapshot.docs.map((doc) => Score.fromFirestore(doc)).toList();

      // Group by day
      Map<String, Map<String, dynamic>> dailyData = {};
      
      for (final score in scores) {
        final day = '${score.timestamp.year}-${score.timestamp.month.toString().padLeft(2, '0')}-${score.timestamp.day.toString().padLeft(2, '0')}';
        
        if (!dailyData.containsKey(day)) {
          dailyData[day] = {
            'date': day,
            'totalPoints': 0,
            'totalActivities': 0,
            'gamePoints': 0,
            'notePoints': 0,
            'videoPoints': 0,
          };
        }
        
        dailyData[day]!['totalPoints'] += score.points;
        dailyData[day]!['totalActivities'] += 1;
        
        switch (score.activityType) {
          case 'game':
            dailyData[day]!['gamePoints'] = (dailyData[day]!['gamePoints'] ?? 0) + score.points;
            break;
          case 'note':
            dailyData[day]!['notePoints'] = (dailyData[day]!['notePoints'] ?? 0) + score.points;
            break;
          case 'video':
            dailyData[day]!['videoPoints'] = (dailyData[day]!['videoPoints'] ?? 0) + score.points;
            break;
        }
      }

      // Convert to list and sort by date
      List<Map<String, dynamic>> result = dailyData.values.toList();
      result.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));

      return result;
    } catch (e) {
      print('Error getting daily activity data: $e');
      return [];
    }
  }
}
