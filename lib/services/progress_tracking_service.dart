import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as Math;

class ProgressTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Track study activity (notes, videos, games)
  Future<void> trackActivity({
    required String userId,
    required String subject,
    required String chapterName,
    required String activityType, // 'note', 'video', 'game'
    required int studyMinutes,
    int points = 0,
    String? gameType,
  }) async {
    try {
      // First, check if this is a default userId and try to get the real userId from profiles
      String actualUserId = userId;
      String userName = '';
      
      if (userId == 'default_user' || userId.isEmpty) {
        // Try to get the current authenticated user
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          actualUserId = currentUser.uid;
          print('Using authenticated user ID instead of default_user: $actualUserId');
        }
      }
      
      // Try to get the real user name from profiles collection
      try {
        final profileDoc = await _firestore.collection('profiles').doc(actualUserId).get();
        if (profileDoc.exists) {
          final data = profileDoc.data();
          if (data != null) {
            // Check if the profile has a studentName field
            if (data.containsKey('studentName') && data['studentName'] is String && data['studentName'].toString().isNotEmpty) {
              userName = data['studentName'];
            } else if (data.containsKey('name') && data['name'] is String && data['name'].toString().isNotEmpty) {
              userName = data['name'];
            }
          }
        }
      } catch (e) {
        print('Error fetching user profile: $e');
      }
      
      // If we couldn't find a name, use a generic one
      if (userName.isEmpty) {
        userName = 'Student ${actualUserId.substring(0, Math.min(4, actualUserId.length))}';
      }
      
      final progressData = {
        'userId': actualUserId, // Use the actual user ID, not default_user
        'userName': userName, // Include the real user name
        'subject': subject,
        'chapterName': chapterName,
        'points': points,
        'studyMinutes': studyMinutes,
        'timestamp': Timestamp.now(),
        'activityType': activityType,
      };
      
      // Add gameType if it's a game activity
      if (activityType == 'game' && gameType != null) {
        progressData['gameType'] = gameType;
      }
      
      // Save to progress collection
      await _firestore.collection('progress').add(progressData);
      
      print('Progress tracked for user $userName ($actualUserId): $subject - $activityType for $studyMinutes minutes');
    } catch (e) {
      print('Error tracking progress: $e');
    }
  }
  
  // Get total study time for a user
  Future<Map<String, dynamic>> getUserStudyStats(String userId, {DateTime? startDate}) async {
    try {
      Query query = _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId);
      
      // Apply date filter if provided
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      
      final snapshot = await query.get();
      
      // Calculate statistics
      int totalStudyMinutes = 0;
      int totalPoints = 0;
      Map<String, int> subjectMinutes = {};
      Map<String, int> activityTypeMinutes = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final minutes = data['studyMinutes'] as int? ?? 0;
        final points = data['points'] as int? ?? 0;
        final subject = data['subject'] as String? ?? 'Unknown';
        final activityType = data['activityType'] as String? ?? 'Unknown';
        
        totalStudyMinutes += minutes;
        totalPoints += points;
        
        // Track minutes by subject
        subjectMinutes[subject] = (subjectMinutes[subject] ?? 0) + minutes;
        
        // Track minutes by activity type
        activityTypeMinutes[activityType] = (activityTypeMinutes[activityType] ?? 0) + minutes;
      }
      
      return {
        'totalStudyMinutes': totalStudyMinutes,
        'totalPoints': totalPoints,
        'subjectMinutes': subjectMinutes,
        'activityTypeMinutes': activityTypeMinutes,
        'daysActive': _calculateUniqueDays(snapshot.docs),
      };
    } catch (e) {
      print('Error getting user study stats: $e');
      return {
        'totalStudyMinutes': 0,
        'totalPoints': 0,
        'subjectMinutes': {},
        'activityTypeMinutes': {},
        'daysActive': 0,
      };
    }
  }
  
  // Calculate number of unique days the user was active
  int _calculateUniqueDays(List<QueryDocumentSnapshot> docs) {
    final Set<String> uniqueDays = {};
    
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final timestamp = data['timestamp'] as Timestamp?;
      
      if (timestamp != null) {
        final date = timestamp.toDate();
        final dateString = '${date.year}-${date.month}-${date.day}';
        uniqueDays.add(dateString);
      }
    }
    
    return uniqueDays.length;
  }
  
  // Get daily activity data for charts
  Future<Map<String, dynamic>> getDailyActivityData(String userId, {int days = 7}) async {
    try {
      // Calculate start date
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));
      
      final snapshot = await _firestore
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();
      
      // Prepare data structure for each day
      final Map<String, Map<String, dynamic>> dailyData = {};
      
      // Initialize data for each day in the range
      for (int i = 0; i < days; i++) {
        final date = startDate.add(Duration(days: i));
        final dateString = '${date.year}-${date.month}-${date.day}';
        
        dailyData[dateString] = {
          'date': dateString,
          'studyMinutes': 0,
          'points': 0,
          'activities': 0,
        };
      }
      
      // Fill in actual data
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final timestamp = data['timestamp'] as Timestamp?;
        
        if (timestamp != null) {
          final date = timestamp.toDate();
          final dateString = '${date.year}-${date.month}-${date.day}';
          
          if (dailyData.containsKey(dateString)) {
            dailyData[dateString]!['studyMinutes'] += data['studyMinutes'] as int? ?? 0;
            dailyData[dateString]!['points'] += data['points'] as int? ?? 0;
            dailyData[dateString]!['activities'] += 1;
          }
        }
      }
      
      return {
        'dailyData': dailyData.values.toList(),
      };
    } catch (e) {
      print('Error getting daily activity data: $e');
      return {
        'dailyData': [],
      };
    }
  }
}
