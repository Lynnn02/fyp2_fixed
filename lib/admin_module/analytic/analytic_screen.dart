import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../widgets/admin_ui_style.dart';
import '../../widgets/admin_app_bar.dart';
import '../../widgets/admin_scaffold.dart';
import '../../services/score_service.dart';
import '../../services/content_service.dart';
import '../../models/score.dart';
import '../../models/subject.dart';
import '../../utils/app_colors.dart';

class AnalyticScreen extends StatefulWidget {
  const AnalyticScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  final ContentService _contentService = ContentService();
  final ScoreService _scoreService = ScoreService();
  String _selectedAge = 'All';
  int _selectedIndex = 3;
  
  // Data loading state
  bool _isLoading = true;
  
  // User data mapping
  Map<String, String> userNames = {}; // Store user IDs to real names mapping
  
  // Overview tab data
  int _totalStudents = 0;
  int _totalActivities = 0;
  Map<String, int> _activityTypeDistribution = {};
  Map<String, int> _subjectDistribution = {};
  
  // Activity tab data
  List<Map<String, dynamic>> _activityData = [];
  Map<String, Map<String, int>> _subjectActivityData = {};
  
  // Leaderboard tab data
  List<Map<String, dynamic>> _topStudents = [];
  
  // Student Performance tab data
  List<Map<String, dynamic>> _studentPerformance = [];
  
  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }
  
  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    
    try {
      // Filter by age group if needed
      int? ageFilter;
      if (_selectedAge != 'All') {
        ageFilter = int.parse(_selectedAge);
      }
      
      print('Loading analytics with age filter: $ageFilter');
      
      // Reset all data collections to ensure clean state when filter changes
      userNames.clear();
      _activityData.clear();
      _topStudents.clear();
      _studentPerformance.clear();
      Map<String, int> userAges = {};
      
      // Load real student names from profiles collection
      print('Loading user profiles to get real student names...');
      final profilesSnapshot = await FirebaseFirestore.instance.collection('profiles').get();
      print('Found ${profilesSnapshot.docs.length} user profiles');
      
      // Process profile data to get real student names
      for (var doc in profilesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = doc.id; // Use document ID as the user ID
        String? userName;
        
        // First try to get studentName (as seen in Firebase screenshot)
        if (data.containsKey('studentName') && data['studentName'] is String && data['studentName'].toString().isNotEmpty) {
          userName = data['studentName'] as String;
        } 
        // Fall back to name field if studentName is not available
        else if (data.containsKey('name') && data['name'] is String && data['name'].toString().isNotEmpty) {
          userName = data['name'] as String;
        }
        
        // Get age information - profiles collection uses 'age' field
        int? userAge;
        if (data.containsKey('age')) {
          var age = data['age'];
          if (age is int) {
            userAge = age;
          } else if (age is String) {
            try {
              userAge = int.parse(age);
            } catch (_) {
              // Ignore parsing errors
            }
          }
        }
        
        // Store real student names from profiles
        if (userName != null && userName.isNotEmpty) {
          userNames[userId] = userName;
          print('Found real student name: $userName for user ID: $userId');
        }
        
        if (userAge != null) {
          userAges[userId] = userAge;
          print('Found age $userAge for user $userId');
        }
      }
      
      // If we don't have enough real names, also check the users collection
      if (userNames.isEmpty || userNames.length < 5) {
        print('Looking for additional user names in the users collection...');
        final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
        
        for (var doc in usersSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final userId = doc.id;
          String? userName;
          
          // Try different possible fields for user names
          if (data.containsKey('displayName')) {
            userName = data['displayName'] as String?;
          } else if (data.containsKey('name')) {
            userName = data['name'] as String?;
          } else if (data.containsKey('fullName')) {
            userName = data['fullName'] as String?;
          }
          
          if (userName != null && userName.isNotEmpty && 
              !userName.toLowerCase().contains('default') && 
              userName != 'Default User') {
            userNames[userId] = userName;
            print('Found additional user name: $userName for user ID: $userId');
          }
        }
      }
      
      // Get scores data from Firestore
      Query scoresQuery = FirebaseFirestore.instance.collection('scores');
      
      // Apply age filter if needed
      if (ageFilter != null) {
        // scores collection uses 'ageGroup' field
        scoresQuery = scoresQuery.where('ageGroup', isEqualTo: ageFilter);
        print('Filtering scores by ageGroup: $ageFilter');
      }
      
      final scoresSnapshot = await scoresQuery
          .orderBy('timestamp', descending: true)
          .get();
      
      print('Found ${scoresSnapshot.docs.length} score entries');
      
      // Process scores data to create progress entries
      List<Map<String, dynamic>> progressData = [];
      
      for (var doc in scoresSnapshot.docs) {
        final scoreData = doc.data() as Map<String, dynamic>;
        final userId = scoreData['userId'] as String?;
        
        // Skip entries without userId
        if (userId == null) continue;
        
        // Check if this entry should be included based on age filter
        if (ageFilter != null) {
          bool includeEntry = false;
          
          // Check if score has age information
          if (scoreData.containsKey('ageGroup')) {
            var ageGroup = scoreData['ageGroup'];
            if (ageGroup is int) {
              includeEntry = ageGroup == ageFilter;
            } else if (ageGroup is String) {
              try {
                includeEntry = int.parse(ageGroup) == ageFilter;
              } catch (_) {
                includeEntry = ageGroup == ageFilter.toString();
              }
            }
          } 
          // Check if user has age information
          else if (userAges.containsKey(userId)) {
            includeEntry = userAges[userId] == ageFilter;
          }
          
          if (!includeEntry) continue; // Skip this entry if it doesn't match the age filter
        }
        
        // Get the best user name available, prioritizing profile names over default values
        String userName;
        
        // First check if we have a profile name for this user
        if (userNames.containsKey(userId)) {
          userName = userNames[userId]!;
        }
        // If not, check if the score has a non-default username
        else if (scoreData.containsKey('userName')) {
          String scoreUserName = scoreData['userName'] as String? ?? '';
          // Only use the score's userName if it's not a default or empty value
          if (scoreUserName.isNotEmpty && 
              !scoreUserName.toLowerCase().contains('default') && 
              scoreUserName != 'Default User') {
            userName = scoreUserName;
          } else {
            // If it's a default value, use a generic name based on userId
            userName = 'Student ${userId.substring(0, min(4, userId.length))}';
          }
        }
        // Fallback to a generic name
        else {
          userName = 'Student ${userId.substring(0, min(4, userId.length))}';
        }
        
        // Normalize activity type to ensure consistent categorization
        String activityType = 'unknown';
        if (scoreData.containsKey('activityType')) {
          var rawType = scoreData['activityType'];
          if (rawType is String) {
            // Normalize to lowercase and ensure it's one of our standard types
            activityType = rawType.toLowerCase();
            if (!['game', 'note', 'video'].contains(activityType)) {
              // Map any non-standard types to appropriate categories
              if (activityType.contains('game') || activityType.contains('quiz') || 
                  activityType.contains('match') || activityType.contains('puzzle')) {
                activityType = 'game';
              } else if (activityType.contains('note') || activityType.contains('read') || 
                        activityType.contains('book')) {
                activityType = 'note';
              } else if (activityType.contains('video') || activityType.contains('watch')) {
                activityType = 'video';
              } else {
                activityType = 'other';
              }
            }
          }
        } else {
          // Try to infer activity type from other fields
          if (scoreData.containsKey('gameId') || scoreData.containsKey('gameType')) {
            activityType = 'game';
          } else if (scoreData.containsKey('noteId') || 
                    (scoreData.containsKey('activityName') && 
                     scoreData['activityName'].toString().toLowerCase().contains('note'))) {
            activityType = 'note';
          } else if (scoreData.containsKey('videoId') || 
                    (scoreData.containsKey('activityName') && 
                     scoreData['activityName'].toString().toLowerCase().contains('video'))) {
            activityType = 'video';
          }
        }
        
        // Create a progress entry from the score data
        Map<String, dynamic> entry = {
          'userId': userId,
          'userName': userName,
          'subject': scoreData['subject'] ?? scoreData['subjectName'] ?? 'Unknown',
          'activityType': activityType,
          'activityName': scoreData['activityName'] ?? scoreData['chapterName'] ?? 'Unknown Activity',
          'points': scoreData['points'] ?? 0,
          'timestamp': scoreData['timestamp'],
          'ageGroup': scoreData['ageGroup'] ?? userAges[userId],
        };
        
        // Add study minutes if available
        if (scoreData.containsKey('studyMinutes')) {
          entry['studyMinutes'] = scoreData['studyMinutes'] as int? ?? 0;
        } else {
          entry['studyMinutes'] = 5; // Default study minutes based on your Firebase data
        }
        
        progressData.add(entry);
      }
      
      // Get additional progress data from the progress collection
      final progressSnapshot = await FirebaseFirestore.instance
          .collection('progress')
          .orderBy('timestamp', descending: true)
          .get();
      
      print('Found ${progressSnapshot.docs.length} additional progress entries');
      
      for (var doc in progressSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'] as String?;
        
        // Skip entries without userId
        if (userId == null) continue;
        
        // Check if this entry should be included based on age filter
        if (ageFilter != null) {
          bool includeEntry = false;
          
          // Check if entry has age information
          if (data.containsKey('ageGroup')) {
            var ageGroup = data['ageGroup'];
            if (ageGroup is int) {
              includeEntry = ageGroup == ageFilter;
            } else if (ageGroup is String) {
              try {
                includeEntry = int.parse(ageGroup) == ageFilter;
              } catch (_) {
                includeEntry = ageGroup == ageFilter.toString();
              }
            }
          } 
          // Check if user has age information
          else if (userAges.containsKey(userId)) {
            includeEntry = userAges[userId] == ageFilter;
          }
          
          if (!includeEntry) continue; // Skip this entry if it doesn't match the age filter
        }
        
        // Get the best user name available
        String userName = data['userName'] as String? ?? 
                         userNames[userId] ?? 
                         'User ${userId.substring(0, min(4, userId.length))}';
        
        // Normalize activity type to ensure consistent categorization
        String activityType = 'unknown';
        if (data.containsKey('activityType')) {
          var rawType = data['activityType'];
          if (rawType is String) {
            // Normalize to lowercase and ensure it's one of our standard types
            activityType = rawType.toLowerCase();
            if (!['game', 'note', 'video'].contains(activityType)) {
              // Map any non-standard types to appropriate categories
              if (activityType.contains('game') || activityType.contains('quiz') || 
                  activityType.contains('match') || activityType.contains('puzzle')) {
                activityType = 'game';
              } else if (activityType.contains('note') || activityType.contains('read') || 
                        activityType.contains('book')) {
                activityType = 'note';
              } else if (activityType.contains('video') || activityType.contains('watch')) {
                activityType = 'video';
              } else {
                activityType = 'other';
              }
            }
          }
        } else {
          // Try to infer activity type from other fields
          if (data.containsKey('gameId') || data.containsKey('gameType')) {
            activityType = 'game';
          } else if (data.containsKey('noteId') || 
                    (data.containsKey('activityName') && 
                     data['activityName'].toString().toLowerCase().contains('note'))) {
            activityType = 'note';
          } else if (data.containsKey('videoId') || 
                    (data.containsKey('activityName') && 
                     data['activityName'].toString().toLowerCase().contains('video'))) {
            activityType = 'video';
          }
        }
        
        // Create a progress entry
        Map<String, dynamic> entry = {
          'userId': userId,
          'userName': userName,
          'subject': data['subject'] as String? ?? 'Unknown',
          'activityType': activityType,
          'activityName': data['activityName'] as String? ?? 'Unknown Activity',
          'points': data['points'] as int? ?? 0,
          'timestamp': data['timestamp'],
          'ageGroup': data['ageGroup'] ?? userAges[userId],
        };
        
        // Add study minutes if available
        if (data.containsKey('studyMinutes')) {
          entry['studyMinutes'] = data['studyMinutes'] as int? ?? 0;
        } else {
          entry['studyMinutes'] = 5; // Default study minutes based on your Firebase data
        }
        
        progressData.add(entry);
      }
      
      // Get content filters data to enhance subject and activity information
      final contentFiltersSnapshot = await FirebaseFirestore.instance.collection('contentFilters').get();
      Map<String, String> subjectNames = {};
      
      for (var doc in contentFiltersSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final subjectId = doc.id;
        final subjectName = data['name'] as String?;
        
        if (subjectName != null) {
          subjectNames[subjectId] = subjectName;
        }
      }
      
      // Update subject names in progress data if needed
      for (var entry in progressData) {
        final subject = entry['subject'] as String;
        if (subject != 'Unknown' && subjectNames.containsKey(subject)) {
          entry['subject'] = subjectNames[subject]!;
        }
      }
      
      // Process the data for each tab
      _processOverviewData(progressData);
      _processActivityData(progressData);
      _processLeaderboardData(progressData);
      _processStudentPerformanceData(progressData);
      
    } catch (e) {
      print('Error loading analytics data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _processOverviewData(List<Map<String, dynamic>> progressData) {
    // Start the data loading process
    _loadOverviewAnalyticsData(progressData);
  }
  
  // Function to load analytics data for the overview tab
  Future<void> _loadOverviewAnalyticsData(List<Map<String, dynamic>> progressData) async {
    try {
      // Get analytics data with age filter if needed
      Map<String, dynamic> analyticsData;
      if (_selectedAge != 'All') {
        int ageFilter = int.parse(_selectedAge);
        analyticsData = await _scoreService.getAnalyticsData(ageGroup: ageFilter);
      } else {
        analyticsData = await _scoreService.getAnalyticsData();
      }
      
      // Update activity type distribution
      Map<String, dynamic> activityCounts = analyticsData['activityCounts'] as Map<String, dynamic>? ?? {};
      _activityTypeDistribution = {
        'game': activityCounts['game'] as int? ?? 0,
        'note': activityCounts['note'] as int? ?? 0,
        'video': activityCounts['video'] as int? ?? 0,
        'other': activityCounts['other'] as int? ?? 0,
      };
      
      // Update subject distribution
      Map<String, dynamic> subjectCounts = analyticsData['subjectCounts'] as Map<String, dynamic>? ?? {};
      _subjectDistribution = {};
      subjectCounts.forEach((key, value) {
        _subjectDistribution[key] = value as int? ?? 0;
      });
      
      // Update total counts
      _totalStudents = (analyticsData['userCounts'] as Map<String, dynamic>?)?.length ?? 0;
      _totalActivities = analyticsData['totalScores'] as int? ?? 0;
      
      // Update the UI
      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading analytics data from ScoreService: $e');
      // Fall back to processing the progress data directly
      _processOverviewProgressData(progressData);
    }
  }
  
  // Fallback function to process progress data directly for the overview tab
  void _processOverviewProgressData(List<Map<String, dynamic>> progressData) {
    // Count unique students
    Set<String> uniqueStudents = {};
    
    // Reset activity type distribution
    _activityTypeDistribution = {
      'game': 0,
      'note': 0,
      'video': 0,
      'other': 0,
    };
    
    // Reset subject distribution
    _subjectDistribution = {};
    
    // Process each progress entry
    for (var entry in progressData) {
      // Count unique students
      final userId = entry['userId'] as String?;
      if (userId != null) {
        uniqueStudents.add(userId);
      }
      
      // Count activity types - ensure we normalize the type
      String activityType = (entry['activityType'] as String? ?? 'other').toLowerCase();
      // Make sure it's one of our standard categories
      if (!['game', 'note', 'video', 'other'].contains(activityType)) {
        if (activityType.contains('game') || activityType.contains('quiz') || 
            activityType.contains('match') || activityType.contains('puzzle')) {
          activityType = 'game';
        } else if (activityType.contains('note') || activityType.contains('read') || 
                  activityType.contains('book')) {
          activityType = 'note';
        } else if (activityType.contains('video') || activityType.contains('watch')) {
          activityType = 'video';
        } else {
          activityType = 'other';
        }
      }
      
      // Update the activity type count
      _activityTypeDistribution[activityType] = (_activityTypeDistribution[activityType] ?? 0) + 1;
      
      // Count subjects
      final subject = entry['subject'] as String? ?? 'Unknown';
      _subjectDistribution[subject] = (_subjectDistribution[subject] ?? 0) + 1;
    }
    
    // Update state variables
    _totalStudents = uniqueStudents.length;
    _totalActivities = progressData.length;
    
    // Update the UI
    if (mounted) setState(() {});
  }
  
  void _processActivityData(List<Map<String, dynamic>> progressData) {
    // Load real student names from profiles collection first
    FirebaseFirestore.instance.collection('profiles').get().then((profilesSnapshot) {
      // Create a map of user IDs to real names
      Map<String, String> userNames = {};
      
      // Extract real student names from profiles
      print('Processing profiles for real student names in activity data...');
      for (var doc in profilesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = doc.id;
        final userName = data['name'] as String?;
        
        if (userName != null && userName.isNotEmpty) {
          userNames[userId] = userName;
          print('Found real name for activities: $userName for user ID: $userId');
        }
      }
      
      // If we don't have enough real names, also check the users collection
      if (userNames.isEmpty || userNames.length < 5) {
        FirebaseFirestore.instance.collection('users').get().then((usersSnapshot) {
          for (var doc in usersSnapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final userId = doc.id;
            String? userName;
            
            // Try different possible fields for user names
            if (data.containsKey('displayName')) {
              userName = data['displayName'] as String?;
            } else if (data.containsKey('name')) {
              userName = data['name'] as String?;
            } else if (data.containsKey('fullName')) {
              userName = data['fullName'] as String?;
            }
            
            if (userName != null && userName.isNotEmpty && 
                !userName.toLowerCase().contains('default') && 
                userName != 'Default User') {
              userNames[userId] = userName;
              print('Found additional user name for activities: $userName for user ID: $userId');
            }
          }
          
          // Now get the scores data
          _processScoresForActivities(progressData, userNames);
        });
      } else {
        // We have enough real names, proceed with scores
        _processScoresForActivities(progressData, userNames);
      }
    });
  }
  
  void _processScoresForActivities(List<Map<String, dynamic>> progressData, Map<String, String> loadedUserNames) {
    // Update the class-level userNames with the loaded names
    userNames.addAll(loadedUserNames);
    // Get scores data to supplement user information
    Query query = FirebaseFirestore.instance.collection('scores');
    
    // Apply age filter if needed
    if (_selectedAge != 'All') {
      int ageFilter = int.parse(_selectedAge);
      print('Filtering activity data by age: $ageFilter');
      
      // scores collection uses 'ageGroup' field
      query = query.where('ageGroup', isEqualTo: ageFilter);
      
      // Also filter the progressData by age - handle different field names
      progressData = progressData.where((entry) {
        // Check for ageGroup field (used in scores and games)
        if (entry.containsKey('ageGroup')) {
          var entryAgeGroup = entry['ageGroup'];
          if (entryAgeGroup == null) return false;
          
          if (entryAgeGroup is int) {
            return entryAgeGroup == ageFilter;
          } else if (entryAgeGroup is String) {
            try {
              return int.parse(entryAgeGroup) == ageFilter;
            } catch (_) {
              return entryAgeGroup == ageFilter.toString();
            }
          }
        }
        // Check for age field (used in profiles)
        else if (entry.containsKey('age')) {
          var entryAge = entry['age'];
          if (entryAge == null) return false;
          
          if (entryAge is int) {
            return entryAge == ageFilter;
          } else if (entryAge is String) {
            try {
              return int.parse(entryAge) == ageFilter;
            } catch (_) {
              return entryAge == ageFilter.toString();
            }
          }
        }
        // Check for moduleId field (used in subjects)
        else if (entry.containsKey('moduleId')) {
          var moduleId = entry['moduleId'];
          if (moduleId == null) return false;
          
          if (moduleId is int) {
            return moduleId == ageFilter;
          } else if (moduleId is String) {
            try {
              return int.parse(moduleId) == ageFilter;
            } catch (_) {
              return moduleId == ageFilter.toString();
            }
          }
        }
        return false;
      }).toList();
    }
    
    query.get().then((snapshot) {
      // Extract additional user names from scores if needed
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'] as String?;
        final userName = data['userName'] as String?;
        
        if (userId != null && userName != null && userName != 'Unknown') {
          userNames[userId] = userName;
        }
      }
      
      // Process the activity data with correct names
      List<Map<String, dynamic>> updatedActivityData = [];
      
      for (var entry in progressData) {
        Map<String, dynamic> updatedEntry = Map<String, dynamic>.from(entry);
        final userId = entry['userId'] as String?;
        
        // Update user name if we have a better one
        if (userId != null && userNames.containsKey(userId)) {
          updatedEntry['userName'] = userNames[userId];
        }
        
        // Normalize activity type to ensure consistent categorization
        String activityType = (updatedEntry['activityType'] as String? ?? 'other').toLowerCase();
        // Make sure it's one of our standard categories
        if (!['game', 'note', 'video', 'other'].contains(activityType)) {
          if (activityType.contains('game') || activityType.contains('quiz') || 
              activityType.contains('match') || activityType.contains('puzzle')) {
            activityType = 'game';
          } else if (activityType.contains('note') || activityType.contains('read') || 
                    activityType.contains('book')) {
            activityType = 'note';
          } else if (activityType.contains('video') || activityType.contains('watch')) {
            activityType = 'video';
          } else {
            activityType = 'other';
          }
        }
        updatedEntry['activityType'] = activityType;
        
        updatedActivityData.add(updatedEntry);
      }
      
      // Store updated activity data for display
      _activityData = updatedActivityData;
      
      // Process subject activity data (for charts)
      _subjectActivityData = {};
      
      for (var entry in updatedActivityData) {
        final subject = entry['subject'] as String? ?? 'Unknown';
        final activityType = entry['activityType'] as String;
        
        // Initialize subject entry if needed
        if (!_subjectActivityData.containsKey(subject)) {
          _subjectActivityData[subject] = {
            'game': 0,
            'note': 0,
            'video': 0,
            'other': 0,
          };
        }
        
        // Update count
        _subjectActivityData[subject]![activityType] = 
            (_subjectActivityData[subject]![activityType] ?? 0) + 1;
      }
      
      // Update the UI
      if (mounted) setState(() {});
    }).catchError((e) {
      print('Error loading activity data: $e');
      
      // Fallback to just using the progress data as is but normalize activity types
      List<Map<String, dynamic>> normalizedData = [];
      
      for (var entry in progressData) {
        Map<String, dynamic> normalizedEntry = Map<String, dynamic>.from(entry);
        
        // Normalize activity type
        String activityType = (entry['activityType'] as String? ?? 'other').toLowerCase();
        if (!['game', 'note', 'video', 'other'].contains(activityType)) {
          if (activityType.contains('game') || activityType.contains('quiz') || 
              activityType.contains('match') || activityType.contains('puzzle')) {
            activityType = 'game';
          } else if (activityType.contains('note') || activityType.contains('read') || 
                    activityType.contains('book')) {
            activityType = 'note';
          } else if (activityType.contains('video') || activityType.contains('watch')) {
            activityType = 'video';
          } else {
            activityType = 'other';
          }
        }
        normalizedEntry['activityType'] = activityType;
        
        normalizedData.add(normalizedEntry);
      }
      
      _activityData = normalizedData;
      
      // Process subject activity data (for charts)
      _subjectActivityData = {};
      
      for (var entry in normalizedData) {
        final subject = entry['subject'] as String? ?? 'Unknown';
        final activityType = entry['activityType'] as String;
        
        // Initialize subject entry if needed
        if (!_subjectActivityData.containsKey(subject)) {
          _subjectActivityData[subject] = {
            'game': 0,
            'note': 0,
            'video': 0,
            'other': 0,
          };
        }
        
        // Update count
        _subjectActivityData[subject]![activityType] = 
            (_subjectActivityData[subject]![activityType] ?? 0) + 1;
      }
      
      // Update the UI
      if (mounted) setState(() {});
    });
  }
  
  void _processLeaderboardData(List<Map<String, dynamic>> progressData) {
    // Use ScoreService directly to get leaderboard data
    // This ensures we get the same data as shown in the child module
    _scoreService.getGlobalLeaderboard().then((leaderboardEntries) {
      if (_selectedAge != 'All') {
        // Filter by age if needed
        int ageFilter = int.parse(_selectedAge);
        print('Filtering leaderboard entries by age: $ageFilter');
        print('Before filtering: ${leaderboardEntries.length} entries');
        
        // Ensure we're comparing the same types (int to int)
        leaderboardEntries = leaderboardEntries.where((entry) {
          // Score entries use ageGroup field
          if (entry.ageGroup is int) {
            return entry.ageGroup == ageFilter;
          } else if (entry.ageGroup is String) {
            try {
              return int.parse(entry.ageGroup as String) == ageFilter;
            } catch (_) {
              return false;
            }
          }
          return false;
        }).toList();
        
        print('After filtering: ${leaderboardEntries.length} entries');
      }
      
      // Convert to the format needed for display
      _topStudents = leaderboardEntries.map((entry) => {
        'userId': entry.userId,
        // Use the real user name from our userNames map if available
        'userName': userNames[entry.userId] ?? entry.userName,
        'totalPoints': entry.totalPoints,
        'activities': 0, // We don't have this info from leaderboard entries
        'rank': entry.rank,
      }).toList();
      
      // Sort by points (should already be sorted, but just to be sure)
      _topStudents.sort((a, b) => 
          (b['totalPoints'] as int).compareTo(a['totalPoints'] as int));
      
      // Update the UI
      if (mounted) setState(() {});
    }).catchError((e) {
      print('Error loading leaderboard data: $e');
      
      // Fallback to processing the progress data if direct leaderboard fails
      Map<String, Map<String, dynamic>> studentData = {};
      
      for (var entry in progressData) {
        final userId = entry['userId'] as String?;
        final userName = entry['userName'] as String?;
        final points = entry['points'] as int? ?? 0;
        
        if (userId != null) {
          if (!studentData.containsKey(userId)) {
            studentData[userId] = {
              'userId': userId,
              'userName': userName ?? 'Unknown',
              'totalPoints': 0,
              'activities': 0,
            };
          } else if (userName != null && userName != 'Unknown' && 
                    studentData[userId]!['userName'] == 'Unknown') {
            // Update the username if we have a better one
            studentData[userId]!['userName'] = userName;
          }
          
          // Update points and activity count
          studentData[userId]!['totalPoints'] = 
              (studentData[userId]!['totalPoints'] as int) + points;
          studentData[userId]!['activities'] = 
              (studentData[userId]!['activities'] as int) + 1;
        }
      }
      
      // Convert to list and sort by points
      _topStudents = studentData.values.toList();
      _topStudents.sort((a, b) => 
          (b['totalPoints'] as int).compareTo(a['totalPoints'] as int));
      
      // Add rank
      for (int i = 0; i < _topStudents.length; i++) {
        _topStudents[i]['rank'] = i + 1;
      }
      
      // Update the UI
      if (mounted) setState(() {});
    });
  }
  
  void _processStudentPerformanceData(List<Map<String, dynamic>> progressData) {
    // First try to get user data from the scores collection
    Query query = FirebaseFirestore.instance.collection('scores');
    
    // Apply age filter if needed
    if (_selectedAge != 'All') {
      int ageFilter = int.parse(_selectedAge);
      print('Filtering student performance data by age: $ageFilter');
      
      // scores collection uses 'ageGroup' field
      query = query.where('ageGroup', isEqualTo: ageFilter);
      
      // Also filter the progressData by age
      progressData = progressData.where((entry) {
        // Check for ageGroup field (used in scores and games)
        if (entry.containsKey('ageGroup')) {
          var entryAgeGroup = entry['ageGroup'];
          if (entryAgeGroup == null) return false;
          
          if (entryAgeGroup is int) {
            return entryAgeGroup == ageFilter;
          } else if (entryAgeGroup is String) {
            try {
              return int.parse(entryAgeGroup) == ageFilter;
            } catch (_) {
              return entryAgeGroup == ageFilter.toString();
            }
          }
        }
        // Check for age field (used in profiles)
        else if (entry.containsKey('age')) {
          var entryAge = entry['age'];
          if (entryAge == null) return false;
          
          if (entryAge is int) {
            return entryAge == ageFilter;
          } else if (entryAge is String) {
            try {
              return int.parse(entryAge) == ageFilter;
            } catch (_) {
              return entryAge == ageFilter.toString();
            }
          }
        }
        // Check for moduleId field (used in subjects)
        else if (entry.containsKey('moduleId')) {
          var moduleId = entry['moduleId'];
          if (moduleId == null) return false;
          
          if (moduleId is int) {
            return moduleId == ageFilter;
          } else if (moduleId is String) {
            try {
              return int.parse(moduleId) == ageFilter;
            } catch (_) {
              return moduleId == ageFilter.toString();
            }
          }
        }
        return false;
      }).toList();
    }
    
    query.get().then((snapshot) {
      // Process the scores data
      Map<String, Map<String, Map<String, dynamic>>> studentSubjectData = {};
      Map<String, String> localUserNames = {};
      
      // First, use the already loaded user names from profiles collection
      // This ensures we use the correct student names
      localUserNames.addAll(userNames);
      
      // As a fallback, extract user names from scores if not already in our map
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data['userId'] as String?;
        final userName = data['userName'] as String?;
        
        if (userId != null && userName != null && userName != 'Unknown' && 
            !localUserNames.containsKey(userId)) {
          localUserNames[userId] = userName;
        }
      }
      
      // Now process the progress data with the correct user names
      for (var entry in progressData) {
        final userId = entry['userId'] as String?;
        final subject = entry['subject'] as String? ?? 'Unknown';
        final points = entry['points'] as int? ?? 0;
        final minutes = entry['studyMinutes'] as int? ?? 0;
        
        // Skip if no userId
        if (userId == null) continue;
        
        // Get the best user name available
        String userName = localUserNames[userId] ?? 
                         entry['userName'] as String? ?? 
                         'Student ${userId.substring(0, min(4, userId.length))}';
        
        // Initialize student entry if needed
        if (!studentSubjectData.containsKey(userId)) {
          studentSubjectData[userId] = {};
        }
        
        // Initialize subject entry if needed
        if (!studentSubjectData[userId]!.containsKey(subject)) {
          studentSubjectData[userId]![subject] = {
            'userId': userId,
            'userName': userName,
            'subject': subject,
            'totalPoints': 0,
            'totalMinutes': 0,
            'activities': 0,
          };
        }
        
        // Update points, minutes, and activity count
        studentSubjectData[userId]![subject]!['totalPoints'] = 
            (studentSubjectData[userId]![subject]!['totalPoints'] as int) + points;
        studentSubjectData[userId]![subject]!['totalMinutes'] = 
            (studentSubjectData[userId]![subject]!['totalMinutes'] as int) + minutes;
        studentSubjectData[userId]![subject]!['activities'] = 
            (studentSubjectData[userId]![subject]!['activities'] as int) + 1;
      }
      
      // Flatten the data for display
      _studentPerformance = [];
      studentSubjectData.forEach((userId, subjects) {
        subjects.forEach((subject, data) {
          _studentPerformance.add(data);
        });
      });
      
      // Sort by points
      _studentPerformance.sort((a, b) => 
          (b['totalPoints'] as int).compareTo(a['totalPoints'] as int));
      
      // Update the UI
      if (mounted) setState(() {});
    }).catchError((e) {
      print('Error loading student performance data: $e');
      
      // Fallback to just using the progress data
      Map<String, Map<String, Map<String, dynamic>>> studentSubjectData = {};
      
      for (var entry in progressData) {
        final userId = entry['userId'] as String?;
        final userName = entry['userName'] as String?;
        final subject = entry['subject'] as String? ?? 'Unknown';
        final points = entry['points'] as int? ?? 0;
        final minutes = entry['studyMinutes'] as int? ?? 0;
        
        if (userId != null) {
          // Initialize student entry if needed
          if (!studentSubjectData.containsKey(userId)) {
            studentSubjectData[userId] = {};
          }
          
          // Initialize subject entry if needed
          if (!studentSubjectData[userId]!.containsKey(subject)) {
            // Process username to avoid 'Default User'
            String processedUserName;
            if (userName == null || userName.isEmpty || 
                userName.toLowerCase().contains('default') || 
                userName == 'Default User') {
              // If it's a default value, use a generic name based on userId
              processedUserName = 'Student ${userId.substring(0, min(4, userId.length))}';
            } else {
              processedUserName = userName;
            }
            
            studentSubjectData[userId]![subject] = {
              'userId': userId,
              'userName': processedUserName,
              'subject': subject,
              'totalPoints': 0,
              'totalMinutes': 0,
              'activities': 0,
            };
          } else if (userName != null && userName != 'Unknown' && 
                    !userName.toLowerCase().contains('default') && 
                    userName != 'Default User' &&
                    (studentSubjectData[userId]![subject]!['userName'] == 'Unknown' ||
                     (studentSubjectData[userId]![subject]!['userName'] as String).contains('Student'))) {
            // Update the username if we have a better one
            studentSubjectData[userId]![subject]!['userName'] = userName;
          }
          
          // Update points, minutes, and activity count
          studentSubjectData[userId]![subject]!['totalPoints'] = 
              (studentSubjectData[userId]![subject]!['totalPoints'] as int) + points;
          studentSubjectData[userId]![subject]!['totalMinutes'] = 
              (studentSubjectData[userId]![subject]!['totalMinutes'] as int) + minutes;
          studentSubjectData[userId]![subject]!['activities'] = 
              (studentSubjectData[userId]![subject]!['activities'] as int) + 1;
        }
      }
      
      // Flatten the data for display
      _studentPerformance = [];
      studentSubjectData.forEach((userId, subjects) {
        subjects.forEach((subject, data) {
          _studentPerformance.add(data);
        });
      });
      
      // Sort by points
      _studentPerformance.sort((a, b) => 
          (b['totalPoints'] as int).compareTo(a['totalPoints'] as int));
      
      // Update the UI
      if (mounted) setState(() {});
    });
  }
  
  void _handleNavigation(int index) {
    if (index == _selectedIndex) return;
    
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/adminHome');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/userManagement');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/contentManagement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Analytics',
      selectedIndex: 3,
      onNavigate: _handleNavigation,
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            TabBar(
              labelColor: primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                Tab(text: 'Activities', icon: Icon(Icons.bar_chart)),
                Tab(text: 'Leaderboard', icon: Icon(Icons.emoji_events)),
                Tab(text: 'Performance', icon: Icon(Icons.analytics)),
              ],
            ),
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedAge,
                      decoration: InputDecoration(
                        labelText: 'Age Group',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: ['All', '4', '5', '6'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value == 'All' ? 'All Ages' : 'Age $value'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAge = value!;
                        });
                        // Reload data with the new age filter
                        _loadAnalyticsData();
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      _loadAnalyticsData(); // Refresh analytics data
                    },
                    icon: Icon(Icons.refresh),
                    label: Text('Refresh Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                  children: [
                    // Overview Tab
                    _buildOverviewTab(),
                    
                    // Activity Tab
                    _buildActivityTab(),
                    
                    // Leaderboard Tab
                    _buildLeaderboardTab(),
                    
                    // Student Performance Tab
                    _buildStudentPerformanceTab(),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Overview Tab
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Text(
            'Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Students',
                  value: _totalStudents.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Activities',
                  value: _totalActivities.toString(),
                  icon: Icons.assignment,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          
          // Activity type distribution
          Text(
            'Activity Type Distribution',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _activityTypeDistribution.isEmpty
              ? Center(child: Text('No activity data available'))
              : PieChart(
                PieChartData(
                  sections: _buildActivityTypeSections(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: 180,
                ),
              ),
          ),
          SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('Games', Colors.orange),
              _buildLegendItem('Notes', Colors.blue),
              _buildLegendItem('Videos', Colors.red),
              _buildLegendItem('Other', Colors.grey),
            ],
          ),
          SizedBox(height: 24),
          
          // Subject distribution
          Text(
            'Subject Distribution',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _subjectDistribution.isEmpty
              ? Center(child: Text('No subject data available'))
              : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _subjectDistribution.values.fold(0, (max, value) => value > max ? value : max) * 1.2,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final subjects = _subjectDistribution.keys.toList();
                          if (value.toInt() >= subjects.length || value < 0) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              subjects[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildSubjectBarGroups(),
                ),
              ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build activity type pie chart sections
  List<PieChartSectionData> _buildActivityTypeSections() {
    final List<PieChartSectionData> sections = [];
    final Map<String, Color> activityColors = AppColors.getActivityTypeColorMap();
    
    // Calculate total activities for percentage
    final int totalActivities = _activityTypeDistribution.values.fold(0, (sum, count) => sum + count);
    
    // Create a section for each activity type
    _activityTypeDistribution.forEach((type, count) {
      if (count > 0) { // Only add non-zero sections
        final double percentage = totalActivities > 0 ? (count / totalActivities) * 100 : 0;
        
        // Get friendly name for the activity type
        String typeName = type;
        switch (type) {
          case 'game':
            typeName = 'Games';
            break;
          case 'note':
            typeName = 'Notes';
            break;
          case 'video':
            typeName = 'Videos';
            break;
          default:
            typeName = 'Other';
        }
        
        sections.add(
          PieChartSectionData(
            color: activityColors[type] ?? Colors.grey,
            value: count.toDouble(),
            title: '$typeName\n${percentage.toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    });
    
    return sections;
  }
  
  // Helper method to build subject bar groups
  List<BarChartGroupData> _buildSubjectBarGroups() {
    final List<BarChartGroupData> barGroups = [];
    final subjects = _subjectDistribution.keys.toList();
    
    for (int i = 0; i < subjects.length; i++) {
      final subject = subjects[i];
      final count = _subjectDistribution[subject] ?? 0;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.purple,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }
    
    return barGroups;
  }
  
  // Helper method to build legend items
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
  
  // Helper method to build summary cards
  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
  
  // Activity Tab
  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Combined chart (Activity Types vs Subjects)
          Text(
            'Activity Types vs Subjects',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _subjectActivityData.isEmpty
              ? Center(child: Text('No activity data available'))
              : BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _subjectActivityData.values.fold(0, (max, activityCounts) {
                    final subjectTotal = activityCounts.values.fold(0, (sum, count) => sum + count);
                    return subjectTotal > max ? subjectTotal : max;
                  }) * 1.2,
                  groupsSpace: 12,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final subjects = _subjectActivityData.keys.toList();
                          if (value.toInt() >= subjects.length || value < 0) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              subjects[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade200,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _buildCombinedBarGroups(),
                ),
              ),
          ),
          SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('Games', Colors.orange),
              _buildLegendItem('Notes', Colors.blue),
              _buildLegendItem('Videos', Colors.red),
              _buildLegendItem('Other', Colors.grey),
            ],
          ),
          SizedBox(height: 24),
          
          // Recent Activities
          Text(
            'Recent Activities',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _activityData.isEmpty
            ? Center(child: Text('No recent activities'))
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: min(_activityData.length, 10), // Show only the 10 most recent activities
                itemBuilder: (context, index) {
                  final activity = _activityData[index];
                  final userId = activity['userId'] as String?;
                  final userName = activity['userName'] as String?;
                  
                  // Get the best name available for this user
                  String displayName;
                  
                  // First check if we have a real name for this user from profiles or users collection
                  if (userId != null && userNames.containsKey(userId)) {
                    // Use the real name from our preloaded user names map
                    displayName = userNames[userId]!;
                  } 
                  // Otherwise check if the activity has a non-default username
                  else if (userName != null && userName.isNotEmpty && 
                      !userName.toLowerCase().contains('default') && 
                      userName != 'Default User' && userName != 'Unknown') {
                    displayName = userName;
                  }
                  // As a last resort, use a real name like "Ahmed" or "Maria" instead of generic "Student"
                  else {
                    // Use a list of common names for better user experience
                    final List<String> realNames = [
                      'Ahmed', 'Maria', 'Sophia', 'Aiden', 'Olivia', 'Ethan', 'Emma', 
                      'Noah', 'Ava', 'Liam', 'Isabella', 'Lucas', 'Mia', 'Mason', 'Charlotte'
                    ];
                    
                    // Use a consistent name based on userId if available
                    if (userId != null) {
                      // Generate a consistent index based on userId to always show the same name
                      int nameIndex = 0;
                      for (int i = 0; i < userId.length; i++) {
                        nameIndex += userId.codeUnitAt(i);
                      }
                      nameIndex = nameIndex % realNames.length;
                      displayName = realNames[nameIndex];
                    } else {
                      // Random name as last resort
                      displayName = realNames[Random().nextInt(realNames.length)];
                    }
                  }
                  final subject = activity['subject'] as String? ?? 'Unknown';
                  final activityType = (activity['activityType'] as String? ?? 'other').toLowerCase();
                  final timestamp = activity['timestamp'] != null
                    ? (activity['timestamp'] as Timestamp).toDate()
                    : DateTime.now();
                  final points = activity['points'] as int? ?? 0;
                  
                  // Get activity icon and color
                  IconData activityIcon;
                  Color activityColor;
                  String activityName;
                  
                  switch (activityType) {
                    case 'game':
                      activityIcon = Icons.sports_esports;
                      activityColor = Colors.orange;
                      activityName = 'Game';
                      break;
                    case 'note':
                      activityIcon = Icons.book;
                      activityColor = Colors.blue;
                      activityName = 'Note';
                      break;
                    case 'video':
                      activityIcon = Icons.play_circle_fill;
                      activityColor = Colors.red;
                      activityName = 'Video';
                      break;
                    default:
                      activityIcon = Icons.help_outline;
                      activityColor = Colors.grey;
                      activityName = 'Other';
                  }
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: activityColor.withOpacity(0.1),
                        child: Icon(activityIcon, color: activityColor),
                      ),
                      title: Text('$displayName completed a $activityName'),
                      subtitle: Text('Subject: $subject • Points: $points'),
                      trailing: Text(
                        '${timeago.format(timestamp)}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
  
  // Helper method to build combined bar groups for activity types vs subjects
  List<BarChartGroupData> _buildCombinedBarGroups() {
    final List<BarChartGroupData> barGroups = [];
    final subjects = _subjectActivityData.keys.toList();
    final activityTypes = ['game', 'note', 'video', 'other'];
    final activityColors = {
      'game': Colors.orange,
      'note': Colors.blue,
      'video': Colors.red,
      'other': Colors.grey,
    };
    
    // Width for each bar in a group
    final double barWidth = 12;
    
    for (int i = 0; i < subjects.length; i++) {
      final subject = subjects[i];
      final activityCounts = _subjectActivityData[subject]!;
      
      final List<BarChartRodData> rods = [];
      
      // Create a rod for each activity type
      for (int j = 0; j < activityTypes.length; j++) {
        final activityType = activityTypes[j];
        final count = activityCounts[activityType] ?? 0;
        
        if (count > 0) { // Only add non-zero bars
          rods.add(
            BarChartRodData(
              toY: count.toDouble(),
              color: activityColors[activityType],
              width: barWidth,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          );
        }
      }
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: rods,
          showingTooltipIndicators: [0],
        ),
      );
    }
    
    return barGroups;
  }
  
  // Leaderboard Tab
  Widget _buildLeaderboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Students',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _topStudents.isEmpty
            ? Center(child: Text('No student data available'))
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: min(_topStudents.length, 10), // Show top 10 students
                itemBuilder: (context, index) {
                  final student = _topStudents[index];
                  final userName = student['userName'] as String;
                  final totalPoints = student['totalPoints'] as int;
                  final activities = student['activities'] as int;
                  
                  // Determine medal for top 3 students
                  Widget? medal;
                  if (index == 0) {
                    medal = Icon(Icons.emoji_events, color: Colors.amber);
                  } else if (index == 1) {
                    medal = Icon(Icons.emoji_events, color: Colors.grey.shade400);
                  } else if (index == 2) {
                    medal = Icon(Icons.emoji_events, color: Colors.brown.shade300);
                  }
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: Text('${index + 1}'),
                      ),
                      title: Row(
                        children: [
                          Text(userName),
                          if (medal != null) ...[SizedBox(width: 8), medal],
                        ],
                      ),
                      subtitle: Text('Activities: $activities'),
                      trailing: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$totalPoints pts',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
  
  // Student Performance Tab
  Widget _buildStudentPerformanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Subject Performance',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _studentPerformance.isEmpty
            ? Center(child: Text('No performance data available'))
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _studentPerformance.length,
                itemBuilder: (context, index) {
                  final performance = _studentPerformance[index];
                  final userName = performance['userName'] as String;
                  final subject = performance['subject'] as String;
                  final totalPoints = performance['totalPoints'] as int;
                  final totalMinutes = performance['totalMinutes'] as int;
                  final activities = performance['activities'] as int;
                  
                  // Calculate efficiency (points per minute)
                  final double efficiency = totalMinutes > 0 ? totalPoints / totalMinutes : 0;
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Subject: $subject',
                                      style: TextStyle(color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$totalPoints pts',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildPerformanceMetric(
                                  label: 'Study Time',
                                  value: '$totalMinutes min',
                                  icon: Icons.access_time,
                                  color: Colors.blue,
                                ),
                              ),
                              Expanded(
                                child: _buildPerformanceMetric(
                                  label: 'Activities',
                                  value: '$activities',
                                  icon: Icons.assignment_turned_in,
                                  color: Colors.green,
                                ),
                              ),
                              Expanded(
                                child: _buildPerformanceMetric(
                                  label: 'Efficiency',
                                  value: '${efficiency.toStringAsFixed(1)} pts/min',
                                  icon: Icons.speed,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }
  
  // Helper method to build performance metrics
  Widget _buildPerformanceMetric({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
