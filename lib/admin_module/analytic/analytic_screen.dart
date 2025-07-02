import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../../widgets/admin_scaffold.dart';
import '../../utils/app_colors.dart';

// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}

class AnalyticScreen extends StatefulWidget {
  final int selectedIndex;
  final void Function(int) onNavigate;

  const AnalyticScreen({
    Key? key,
    required this.selectedIndex,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _progressData = [];
  double _totalPoints = 0;
  double _totalStudyMinutes = 0;
  int _daysActive = 0;
  bool _showBySubject = true;
  String? _selectedAgeGroup;
  String? _selectedStudentId;
  String _selectedFilter = 'Last 7 Days'; // Default time filter
  Map<String, String> _studentOptions = {};
  Map<String, int> _studentAges = {};

  // Data variables
  Map<String, double> _subjectScores = {};
  Map<String, double> _studyMinutes = {};
  Map<String, int> _activityTypeCounts = {'game': 0, 'video': 0, 'note': 0, 'other': 0};
  Map<String, Map<String, int>> _subjectActivityData = {};
  Map<String, Map<String, int>> _activityTypeSubjectData = {
    'game': {},
    'video': {},
    'note': {},
    'other': {},
  };

  // Labels for activity types
  final Map<String, String> _activityTypeLabels = {
    'game': 'Games & Quizzes',
    'note': 'Notes & Reading',
    'video': 'Videos',
    'other': 'Other Activities',
  };

  // Color mapping for consistent colors
  final Map<String, Color> _subjectColors = {};
  final Map<String, Color> _activityTypeColors = {
    'game': Colors.green,
    'note': Colors.blue,
    'video': Colors.orange,
    'other': Colors.purple,
  };
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final profilesSnapshot = await _firestore.collection('profiles').get();
      final Map<String, String> students = {};
      final Map<String, int> studentAges = {};

      for (var doc in profilesSnapshot.docs) {
        final data = doc.data();
        if (doc.id != 'admin' && !(data['isAdmin'] == true)) {
          final userId = doc.id;
          String name;
          if (data.containsKey('studentName')) {
            name = data['studentName'];
          } else if (data.containsKey('name')) {
            name = data['name'];
          } else {
            name = 'Student ${doc.id.substring(0, 4)}';
          }

          // Store student name
          students[userId] = name;

          // Extract and store age
          if (data.containsKey('age')) {
            int age = 0;
            if (data['age'] is int) {
              age = data['age'];
            } else if (data['age'] is String) {
              age = int.tryParse(data['age']) ?? 0;
            }
            studentAges[userId] = age;
          } else {
            studentAges[userId] = 0; // Default age if not found
          }
        }
      }

      setState(() {
        _studentOptions = students;
        _studentAges = studentAges;
      });

      // After loading students, load progress data
      await _loadProgressData();
    } catch (e) {
      print('Error loading students: $e');
      setState(() {
        _studentOptions = {'user1': 'John Doe', 'user2': 'Jane Smith', 'user3': 'Alice Johnson'};
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);
    
    try {
      // Reset statistics
      _totalPoints = 0;
      _totalStudyMinutes = 0;
      _daysActive = 0;
      _progressData = [];
      
      // Determine the date range based on the selected filter
      DateTime startDate;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      switch (_selectedFilter) {
        case 'Today':
          startDate = today;
          break;
        case 'Last 7 Days':
          startDate = today.subtract(const Duration(days: 7));
          break;
        case 'Last 30 Days':
          startDate = today.subtract(const Duration(days: 30));
          break;
        default:
          startDate = today;
      }
      
      print('Filter date range: $startDate to $now');
      
      // Filter students by age group
      List<String> targetStudentIds = [];
      if (_selectedAgeGroup != null) {
        int targetAge = 0;
        // Extract age number from the string (e.g., "4 years old" -> 4)
        if (_selectedAgeGroup!.startsWith('4')) targetAge = 4;
        else if (_selectedAgeGroup!.startsWith('5')) targetAge = 5;
        else if (_selectedAgeGroup!.startsWith('6')) targetAge = 6;
        
        targetStudentIds = _studentAges.entries
            .where((entry) => entry.value == targetAge)
            .map((entry) => entry.key)
            .toList();
        
        print('Filtered to ${targetStudentIds.length} students with age $targetAge');
      } else {
        // Use all students if no age filter (All Ages)
        targetStudentIds = _studentOptions.keys.toList();
        print('Using all ${targetStudentIds.length} students');
      }
      
      // Use a specific student if selected
      if (_selectedStudentId != null && _selectedStudentId!.isNotEmpty) {
        // Check if student ID is valid and in the list
        if (_studentOptions.containsKey(_selectedStudentId)) {
          targetStudentIds = [_selectedStudentId!];
          print('Using selected student: $_selectedStudentId');
        } else {
          print('Selected student ID not found in student options');
          setState(() => _isLoading = false);
          return;
        }
      }
      
      if (targetStudentIds.isEmpty) {
        print('No students match the filter criteria');
        setState(() => _isLoading = false);
        return;
      }
      
      // Map to track which students have data
      Map<String, bool> studentsWithData = {};
      for (var id in targetStudentIds) {
        studentsWithData[id] = false;
      }
      
      List<Map<String, dynamic>> progressData = [];
      
      // ====== PART 1: Query Firestore for scores ====== 
      try {
        // Handle Firebase limits - can only query 'in' with max 10 values
        for (int i = 0; i < targetStudentIds.length; i += 10) {
          int end = (i + 10 < targetStudentIds.length) ? i + 10 : targetStudentIds.length;
          List<String> batchIds = targetStudentIds.sublist(i, end);
          
          final scoresSnapshot = await _firestore
            .collection('scores')
            .where('userId', whereIn: batchIds)
            .get();
            
          print('Batch ${i ~/ 10 + 1}: Found ${scoresSnapshot.docs.length} score entries');
          
          // Process score documents
          for (var doc in scoresSnapshot.docs) {
            final data = doc.data();
            final timestamp = data['timestamp'];
            final userId = data['userId'];
            
            if (timestamp == null || userId == null) continue;
            
            // Mark this student as having data
            if (targetStudentIds.contains(userId)) {
              studentsWithData[userId] = true;
            }
            
            DateTime date;
            if (timestamp is Timestamp) {
              date = timestamp.toDate();
            } else if (timestamp is DateTime) {
              date = timestamp;
            } else if (timestamp is String) {
              try {
                date = DateTime.parse(timestamp);
              } catch (e) {
                continue;
              }
            } else {
              continue;
            }
            
            // Filter by date
            bool includeData = false;
            if (_selectedFilter == 'Today') {
              includeData = date.year == today.year && 
                          date.month == today.month && 
                          date.day == today.day;
            } else if (_selectedFilter == 'Last 7 Days') {
              includeData = date.isAfter(startDate) || 
                          (date.year == startDate.year && 
                           date.month == startDate.month && 
                           date.day == startDate.day);
            } else { // Last 30 Days
              includeData = date.isAfter(startDate) || 
                          (date.year == startDate.year && 
                           date.month == startDate.month && 
                           date.day == startDate.day);
            }
            
            if (!includeData) {
              print('Skipping entry: Date ${date.toString()} outside range');
              continue;
            }
            
            // Create standardized progress entry
            String subjectName = data['subjectName'] ?? data['subject'] ?? 'General';
            String activityName = data['activityName'] ?? data['chapterName'] ?? 'Activity';
            
            // Get points - check multiple possible field names
            double points = 0.0;
            if (data['points'] != null) {
              points = (data['points'] is num) ? (data['points'] as num).toDouble() : 0.0;
            } else if (data['score'] != null) {
              points = (data['score'] is num) ? (data['score'] as num).toDouble() : 0.0;
            }
            
            // Get duration - check multiple possible field names
            double duration = 0.0;
            if (data['studyMinutes'] != null) {
              duration = (data['studyMinutes'] is num) ? (data['studyMinutes'] as num).toDouble() : 0.0;
            } else if (data['duration'] != null) {
              duration = (data['duration'] is num) ? (data['duration'] as num).toDouble() : 0.0;
            } else {
              duration = 5.0; // Default study minutes if not specified
            }
            
            // Create standardized data entry
            final processedData = {
              'userId': data['userId'],
              'subject': subjectName,
              'score': points,
              'duration': duration,
              'activityType': _normalizeActivityType(data),
              'timestamp': date,
              'activityName': activityName,
            };
            
            progressData.add(processedData);
          }
        }
      } catch (e) {
        print('Error loading scores data: $e');
      }
      
      // ====== PART 2: Query Firestore for progress data ======
      try {
        // Handle Firebase limits - can only query 'in' with max 10 values
        for (int i = 0; i < targetStudentIds.length; i += 10) {
          int end = (i + 10 < targetStudentIds.length) ? i + 10 : targetStudentIds.length;
          List<String> batchIds = targetStudentIds.sublist(i, end);
          
          final progressSnapshot = await _firestore
            .collection('progress')
            .where('userId', whereIn: batchIds)
            .get();
            
          print('Batch ${i ~/ 10 + 1}: Found ${progressSnapshot.docs.length} progress entries');
          
          // Process progress documents
          for (var doc in progressSnapshot.docs) {
            final data = doc.data();
            final timestamp = data['timestamp'];
            
            if (timestamp == null) continue;
            
            DateTime date;
            if (timestamp is Timestamp) {
              date = timestamp.toDate();
            } else if (timestamp is DateTime) {
              date = timestamp;
            } else if (timestamp is String) {
              try {
                date = DateTime.parse(timestamp);
              } catch (e) {
                continue;
              }
            } else {
              continue;
            }
            
            // Filter by date - be strict about the date range
            bool includeData = false;
            if (_selectedFilter == 'Today') {
              includeData = date.year == today.year && 
                          date.month == today.month && 
                          date.day == today.day;
            } else if (_selectedFilter == 'Last 7 Days') {
              includeData = date.isAfter(startDate) || 
                          (date.year == startDate.year && 
                           date.month == startDate.month && 
                           date.day == startDate.day);
            } else { // Last 30 Days
              includeData = date.isAfter(startDate) || 
                          (date.year == startDate.year && 
                           date.month == startDate.month && 
                           date.day == startDate.day);
            }
            
            if (!includeData) {
              print('Skipping entry: Date ${date.toString()} outside range');
              continue;
            }
            
            // Create standardized progress entry
            String subjectName = data['subjectName'] ?? data['subject'] ?? 'General';
            String activityName = data['activityName'] ?? 'Activity';
            
            // Get points - check multiple possible field names
            double points = 0.0;
            if (data['points'] != null) {
              points = (data['points'] is num) ? (data['points'] as num).toDouble() : 0.0;
            } else if (data['score'] != null) {
              points = (data['score'] is num) ? (data['score'] as num).toDouble() : 0.0;
            }
            
            // Get duration - check multiple possible field names
            double duration = 0.0;
            if (data['studyMinutes'] != null) {
              duration = (data['studyMinutes'] is num) ? (data['studyMinutes'] as num).toDouble() : 0.0;
            } else if (data['duration'] != null) {
              duration = (data['duration'] is num) ? (data['duration'] as num).toDouble() : 0.0;
            }
            
            // Apply default study minutes for activities without duration
            if (duration == 0) {
              // Assign a reasonable default based on activity type
              if (data.containsKey('gameId')) {
                duration = 5.0; // Default 5 minutes for games
              } else if (data.containsKey('noteId')) {
                duration = 7.0; // Default 7 minutes for notes
              } else if (data.containsKey('videoId')) {
                duration = 10.0; // Default 10 minutes for videos
              }
            }
            
            // Add to standardized data
            progressData.add({
              'userId': data['userId'] ?? '',
              'subjectName': subjectName,
              'activityName': activityName,
              'points': points,
              'studyMinutes': duration,
              'timestamp': date,
              'type': _normalizeActivityType(data),
            });
          }
        }
      } catch (e) {
        print('Error loading progress data: $e');
      }
      
      // Check if there's any data for the selected filters
      if (progressData.isEmpty) {
        print('No data available for the selected filters');
        setState(() {
          _isLoading = false;
          // Keep the progress data empty so the UI shows "No data available"
          _progressData = [];
        });
        return;
      }
      
      // Filter out data from students who have no data in this period
      progressData = progressData.where((entry) {
        String userId = entry['userId'] ?? '';
        return userId.isNotEmpty && studentsWithData[userId] == true;
      }).toList();
      
      // Calculate statistics from the filtered data
      _calculateStatistics(progressData);
      
    } catch (e) {
      print('Error loading progress data: ${e.toString()}');
      setState(() {
        _isLoading = false;
        _progressData = []; // Show no data available
      });
    }
  }
  
  String _normalizeActivityType(Map<String, dynamic> data) {
    // Start with 'other' as default
    String activityType = 'other';
    
    // First check for explicit activityType field
    if (data.containsKey('activityType')) {
      String type = (data['activityType']?.toString().toLowerCase() ?? '');
      if (type.isNotEmpty) {
        activityType = type;
      }
    }
    
    // Try to infer from other fields if no explicit type or if it's 'unknown'
    if (activityType == 'other' || activityType == 'unknown') {
      // Check for game indicators
      if (data.containsKey('gameId') || 
          data.containsKey('gameType') || 
          (data.containsKey('activityName') && 
           data['activityName'].toString().toLowerCase().contains('game')) || 
          (data.containsKey('type') && 
           data['type'].toString().toLowerCase().contains('game'))) {
        activityType = 'game';
      } 
      // Check for note indicators
      else if (data.containsKey('noteId') || 
               (data.containsKey('activityName') && 
                data['activityName'].toString().toLowerCase().contains('note')) || 
               (data.containsKey('type') && 
                data['type'].toString().toLowerCase().contains('note'))) {
        activityType = 'note';
      } 
      // Check for video indicators
      else if (data.containsKey('videoId') || 
               (data.containsKey('activityName') && 
                data['activityName'].toString().toLowerCase().contains('video')) || 
               (data.containsKey('type') && 
                data['type'].toString().toLowerCase().contains('video'))) {
        activityType = 'video';
      }
    }
    
    // Final normalization to standard categories
    if (activityType.contains('game') || activityType.contains('quiz') || 
        activityType.contains('match') || activityType.contains('puzzle')) {
      return 'game';
    } else if (activityType.contains('note') || activityType.contains('read') || 
              activityType.contains('book')) {
      return 'note';
    } else if (activityType.contains('video') || activityType.contains('watch')) {
      return 'video';
    } else {
      return 'other';
    }
  }
  
  void _calculateStatistics(List<Map<String, dynamic>> filteredData) {
    _progressData = filteredData;
    _subjectScores = {};
    _studyMinutes = {};
    _activityTypeCounts = {'game': 0, 'video': 0, 'note': 0, 'other': 0};
    _subjectActivityData = {};
    _activityTypeSubjectData = {
      'game': {},
      'video': {},
      'note': {},
      'other': {},
    };
    
    _totalPoints = 0;
    _totalStudyMinutes = 0;
    
    // Track unique dates for active days count
    Set<String> activeDates = {};
    
    // Process each entry
    for (var entry in filteredData) {
      // Handle potentially missing or null fields with safe defaults
      // Get subject name with fallbacks
      final subject = entry['subjectName'] ?? entry['subject'] ?? 'General';
      
      // Handle numeric values safely
      double score = 0;
      if (entry['score'] != null) {
        score = (entry['score'] is double) ? entry['score'] : 
                (entry['score'] is int) ? (entry['score'] as int).toDouble() : 
                double.tryParse(entry['score'].toString()) ?? 0;
      } else if (entry['points'] != null) {
        score = (entry['points'] is double) ? entry['points'] : 
                (entry['points'] is int) ? (entry['points'] as int).toDouble() : 
                double.tryParse(entry['points'].toString()) ?? 0;
      }
      
      // Handle duration/study minutes
      double duration = 0;
      if (entry['duration'] != null) {
        duration = (entry['duration'] is double) ? entry['duration'] : 
                  (entry['duration'] is int) ? (entry['duration'] as int).toDouble() : 
                  double.tryParse(entry['duration'].toString()) ?? 0;
      } else if (entry['studyMinutes'] != null) {
        duration = (entry['studyMinutes'] is double) ? entry['studyMinutes'] : 
                  (entry['studyMinutes'] is int) ? (entry['studyMinutes'] as int).toDouble() : 
                  double.tryParse(entry['studyMinutes'].toString()) ?? 0;
      }
      
      // Get activity type with proper normalization
      final activityType = _normalizeActivityType(entry);
      
      // Handle timestamp safely
      DateTime timestamp;
      if (entry['timestamp'] is Timestamp) {
        timestamp = (entry['timestamp'] as Timestamp).toDate();
      } else if (entry['timestamp'] is DateTime) {
        timestamp = entry['timestamp'];
      } else if (entry['timestamp'] is String) {
        timestamp = DateTime.tryParse(entry['timestamp']) ?? DateTime.now();
      } else {
        timestamp = DateTime.now(); // Fallback to current time if missing
      }
      
      // Format date to YYYY-MM-DD for unique days tracking
      final dateStr = DateFormat('yyyy-MM-dd').format(timestamp);
      activeDates.add(dateStr);
      
      // Update subject scores
      _subjectScores[subject] = (_subjectScores[subject] ?? 0) + score;
      
      // Update study minutes by subject
      _studyMinutes[subject] = (_studyMinutes[subject] ?? 0) + duration;
      
      // Update activity type counts
      _activityTypeCounts[activityType] = (_activityTypeCounts[activityType] ?? 0) + 1;
      
      // Update subject-activity breakdown
      if (!_subjectActivityData.containsKey(subject)) {
        _subjectActivityData[subject] = {};
      }
      _subjectActivityData[subject]![activityType] = 
        (_subjectActivityData[subject]![activityType] ?? 0) + 1;
      
      // Update activity-subject breakdown
      if (!_activityTypeSubjectData.containsKey(activityType)) {
        _activityTypeSubjectData[activityType] = {};
      }
      _activityTypeSubjectData[activityType]![subject] = 
        (_activityTypeSubjectData[activityType]![subject] ?? 0) + 1;
      
      // Update summary statistics
      _totalPoints += score;
      _totalStudyMinutes += duration;
    }
    
    // Count unique active days
    _daysActive = activeDates.length;
    
    // Assign consistent colors to subjects
    List<Color> colorPalette = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.pink, Colors.amber,
      Colors.indigo, Colors.cyan, Colors.lime, Colors.brown,
    ];
    
    int colorIndex = 0;
    for (String subject in _subjectScores.keys) {
      if (!_subjectColors.containsKey(subject)) {
        _subjectColors[subject] = colorPalette[colorIndex % colorPalette.length];
        colorIndex++;
      }
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Student Analytics',
      selectedIndex: widget.selectedIndex,
      onNavigate: widget.onNavigate,
      body: SafeArea(
        child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: AppColors.primaryColor.withOpacity(0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Filter by age and student
                        _buildAgeAndStudentFilters(),
                        const SizedBox(height: 16),
                        
                        // Time period filter
                        _buildTimeFilters(),
                        const SizedBox(height: 16),
                        
                        // Summary statistics
                        _buildSummaryCards(),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chart toggle
                        _buildChartToggle(),
                        const SizedBox(height: 16),
                        
                        // Chart title
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _showBySubject ? 'Subject Performance' : 'Activity Type Breakdown',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Show the appropriate chart based on toggle
                              SizedBox(
                                height: 350,
                                child: _showBySubject 
                                  ? _buildSubjectStackedBarChart() 
                                  : _buildActivityTypeStackedBarChart(),
                              ),
                              const SizedBox(height: 16),
                              
                              // Legend for chart colors
                              _buildLegend(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ),
    );
  }

  // Build toggle between subject and activity type views
  Widget _buildChartToggle() {
    return Container(
      width: double.infinity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.0,
            children: [
              Text(
                'View by:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(
                  'Subject',
                  style: TextStyle(
                    fontWeight: _showBySubject ? FontWeight.bold : FontWeight.normal,
                    color: _showBySubject ? AppColors.primaryColor : Colors.black87,
                  ),
                ),
                selected: _showBySubject,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _showBySubject = true);
                  }
                },
                backgroundColor: Colors.grey[100],
                selectedColor: AppColors.primaryColor.withOpacity(0.2),
                checkmarkColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _showBySubject 
                        ? AppColors.primaryColor 
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
              FilterChip(
                label: Text(
                  'Activity Type',
                  style: TextStyle(
                    fontWeight: !_showBySubject ? FontWeight.bold : FontWeight.normal,
                    color: !_showBySubject ? AppColors.primaryColor : Colors.black87,
                  ),
                ),
                selected: !_showBySubject,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _showBySubject = false);
                  }
                },
                backgroundColor: Colors.grey[100],
                selectedColor: AppColors.primaryColor.withOpacity(0.2),
                checkmarkColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: !_showBySubject 
                        ? AppColors.primaryColor 
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build summary statistic cards
  Widget _buildSummaryCards() {
    // Define a fixed height for all cards to ensure uniformity
    const double cardHeight = 110.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Points',
            _totalPoints.toStringAsFixed(0),
            Icons.star,
            Colors.amber,
            cardHeight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Study Time',
            '${_totalStudyMinutes.toStringAsFixed(0)} min',
            Icons.timer,
            Colors.blue,
            cardHeight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Active Days',
            _daysActive.toString(),
            Icons.calendar_today,
            Colors.green,
            cardHeight,
          ),
        ),
      ],
    );
  }
  
  // Build summary card widget
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color, double height) {
    return Container(
      height: height,
      child: Card(
        elevation: 6,
        shadowColor: color.withOpacity(0.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                color.withOpacity(0.1),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 6),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Build subject stacked bar chart
  Widget _buildSubjectStackedBarChart() {
    if (_progressData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No data available for the selected time period'),
        ),
      );
    }

    final List<String> subjects = _subjectActivityData.keys.toList();
    
    // Calculate max Y value to ensure consistent scale
    double maxY = _subjectActivityData.values
        .map((activityMap) => activityMap.values.fold<int>(0, (sum, count) => sum + count))
        .fold<int>(0, (max, sum) => sum > max ? sum : max)
        .toDouble() * 1.2;
    
    if (maxY < 5) maxY = 5; // Set a minimum scale
    
    // Create bars for each subject
    final List<BarChartGroupData> barGroups = [];
    
    int groupIndex = 0;
    _subjectActivityData.forEach((subject, activities) {
      List<BarChartRodData> rodData = [];
      
      // Add rods for each activity type
      activities.forEach((activityType, count) {
        rodData.add(
          BarChartRodData(
            toY: count.toDouble(),
            color: _activityTypeColors[activityType] ?? Colors.grey,
            width: 16,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        );
      });
      
      // Create the bar group
      if (rodData.isNotEmpty) {
        barGroups.add(
          BarChartGroupData(
            x: groupIndex,
            barRods: rodData,
          ),
        );
        groupIndex++;
      }
    });
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: barGroups.isEmpty ? 10 : null,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String subject = '';
              String activityType = '';
              
              // Find the subject name for this group index
              final entry = _subjectActivityData.entries.elementAtOrNull(group.x.toInt());
              if (entry != null) {
                subject = entry.key;
                final activityEntry = entry.value.entries.elementAtOrNull(rodIndex);
                if (activityEntry != null) {
                  activityType = activityEntry.key;
                }
              }
              
              return BarTooltipItem(
                '$subject - ${_activityTypeLabels[activityType] ?? activityType}\n${rod.toY.toInt()}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Find the subject name for this index
                final subjectEntry = _subjectActivityData.entries.elementAtOrNull(value.toInt());
                final subjectName = subjectEntry?.key ?? '';
                
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    subjectName.length > 10 ? '${subjectName.substring(0, 10)}...' : subjectName,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
  
  // Build activity type stacked bar chart
  Widget _buildActivityTypeStackedBarChart() {
    if (_progressData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No data available for the selected time period'),
        ),
      );
    }
    
    final List<String> activityTypes = _activityTypeSubjectData.keys.toList();
    final List<String> subjects = _subjectScores.keys.toList();
    
    // Calculate max Y value to ensure consistent scale
    double maxY = _activityTypeSubjectData.values
        .map((subjectMap) => subjectMap.values.fold<int>(0, (sum, count) => sum + count))
        .fold<int>(0, (max, sum) => sum > max ? sum : max)
        .toDouble() * 1.2;
    
    if (maxY < 5) maxY = 5; // Set a minimum scale

    // Create bars for each activity type
    final List<BarChartGroupData> barGroups = List.generate(
      activityTypes.length,
      (typeIndex) {
        final activityType = activityTypes[typeIndex];
        final subjectMap = _activityTypeSubjectData[activityType]!;
        
        List<BarChartRodData> rods = [];
        for (int i = 0; i < subjects.length; i++) {
          final subject = subjects[i];
          rods.add(
            BarChartRodData(
              toY: (subjectMap[subject] ?? 0).toDouble(),
              color: _subjectColors[subject],
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
          );
        }
        
        return BarChartGroupData(
          x: typeIndex,
          barRods: rods,
        );
      },
    );

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < activityTypes.length && rodIndex < subjects.length) {
                final activityType = activityTypes[groupIndex];
                final subject = subjects[rodIndex];
                final count = _activityTypeSubjectData[activityType]![subject] ?? 0;
                return BarTooltipItem(
                  '$subject: $count',
                  const TextStyle(color: Colors.white),
                );
              }
              return null;
            },
          ),
          touchCallback: (_, __) {}, // Empty callback to prevent showing indicators
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value < 0 || value >= activityTypes.length) return const Text('');
                String activityType = activityTypes[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _activityTypeLabels[activityType] ?? activityType.capitalize(),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
              reservedSize: 40,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
              reservedSize: 30,
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }
  
  // Using class-level _activityTypeLabels declared above

  // Build time filters matching child progress screen
  Widget _buildTimeFilters() {
    return Container(
      width: double.infinity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.0,
            children: [
              for (final filter in ['Today', 'Last 7 Days', 'Last 30 Days'])
                FilterChip(
                  label: Text(
                    filter,
                    style: TextStyle(
                      fontWeight: _selectedFilter == filter ? FontWeight.bold : FontWeight.normal,
                      color: _selectedFilter == filter ? AppColors.primaryColor : Colors.black87,
                    ),
                  ),
                  selected: _selectedFilter == filter,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      _loadProgressData();
                    }
                  },
                  backgroundColor: Colors.grey[100],
                  selectedColor: AppColors.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: _selectedFilter == filter 
                          ? AppColors.primaryColor 
                          : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Build age group and student filters
  Widget _buildAgeAndStudentFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Age Filter
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by Age',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                // Age dropdown with individual year options
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                  value: _selectedAgeGroup,
                  hint: Text('All Ages'),
                  items: [
                    DropdownMenuItem(value: null, child: Text('All Ages')),
                    DropdownMenuItem(value: '4 years old', child: Text('4 years old')),
                    DropdownMenuItem(value: '5 years old', child: Text('5 years old')),
                    DropdownMenuItem(value: '6 years old', child: Text('6 years old')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedAgeGroup = value;
                      _selectedStudentId = null; // Reset student when age changes
                    });
                    _loadProgressData();
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Student Filter
        if (_studentOptions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter by Student',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                    value: _selectedStudentId,
                    hint: Text('All Students'),
                    items: () {
                      // Get filtered list of student IDs based on selected age
                      List<String> filteredStudentIds = [];
                      
                      // Filter students by selected age group
                      if (_selectedAgeGroup != null && !_selectedAgeGroup!.startsWith('All')) {
                        int targetAge = 0;
                        // Extract age number from the string (e.g., "4 years old" -> 4)
                        if (_selectedAgeGroup!.startsWith('4')) targetAge = 4;
                        else if (_selectedAgeGroup!.startsWith('5')) targetAge = 5;
                        else if (_selectedAgeGroup!.startsWith('6')) targetAge = 6;
                        
                        // Only include students of the selected age
                        filteredStudentIds = _studentAges.entries
                          .where((entry) => entry.value == targetAge)
                          .map((entry) => entry.key)
                          .toList();
                      } else {
                        // Show all students if no age filter or "All Ages" is selected
                        filteredStudentIds = _studentOptions.keys.toList();
                      }
                      
                      // Create dropdown items
                      List<DropdownMenuItem<String>> items = [
                        DropdownMenuItem(
                          value: null,
                          child: Text('All Students'),
                        ),
                      ];
                      
                      // Add the filtered students
                      for (String studentId in filteredStudentIds) {
                        items.add(DropdownMenuItem(
                          value: studentId,
                          child: Text(_studentOptions[studentId] ?? 'Unknown'),
                        ));
                      }
                      
                      return items;
                    }(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStudentId = value;
                      });
                      _loadProgressData();
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  // No longer needed helper methods have been removed

  // Build legend for charts
  Widget _buildLegend() {
    if (_showBySubject) {
      return _buildActivityTypeLegend();
    } else {
      return _buildSubjectLegend();
    }
  }

  Widget _buildActivityTypeLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: _activityTypeColors.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: entry.value,
            ),
            const SizedBox(width: 4),
            Text(_activityTypeLabels[entry.key] ?? entry.key.capitalize()),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSubjectLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: _subjectColors.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              color: entry.value,
            ),
            const SizedBox(width: 4),
            Text(entry.key),
          ],
        );
      }).toList(),
    );
  }
}



extension IterableExtension<T> on Iterable<T> {
  T? elementAtOrNull(int index) {
    if (index >= 0 && index < length) {
      return elementAt(index);
    }
    return null;
  }
}
