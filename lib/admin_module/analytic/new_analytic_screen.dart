import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import '../../widgets/admin_app_bar.dart';
import '../../widgets/admin_scaffold.dart';
import '../../utils/app_colors.dart';

// Data models for analytics
class TimeSeriesData {
  final DateTime date;
  final int sessions;
  final int exercises;
  
  TimeSeriesData(this.date, this.sessions, this.exercises);
}

class ScoreDistribution {
  final String scoreRange;
  final int count;
  final Color color;
  
  ScoreDistribution(this.scoreRange, this.count, this.color);
}

class SessionDuration {
  final String durationRange;
  final int count;
  final double percentage;
  final Color color;
  
  SessionDuration(this.durationRange, this.count, this.percentage, this.color);
}

class AnalyticScreen extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onNavigate;
  
  const AnalyticScreen({
    Key? key,
    required this.selectedIndex,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<AnalyticScreen> createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> {
  // Filter state
  String _selectedAge = 'All';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String? _selectedStudentId;
  Map<String, String> _studentOptions = {}; // userId to name mapping
  
  // Data loading state
  bool _isLoading = true;
  
  // Analytics data
  Map<String, String> userNames = {}; // Store user IDs to real names mapping
  int _totalUsers = 0;
  int _totalActivities = 0;
  double _averageScore = 0.0;
  double _averageSessionLength = 0.0; // in minutes
  double _completionRate = 0.0; // percentage
  
  // Trend data
  List<TimeSeriesData> _sessionData = [];
  List<ScoreDistribution> _scoreDistribution = [];
  
  // Session duration breakdown
  int _sessionsUnder5Min = 0;
  int _sessions5to10Min = 0;
  int _sessions10to20Min = 0;
  int _sessionsOver20Min = 0;
  
  // Unique user IDs for sessions
  final Set<String> uniqueUserIds = {};
  
  // Helper getter to determine if we're on a mobile device
  bool get isMobile => MediaQuery.of(context).size.width < 600;
  
  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  // Load analytics data with filters applied
  Future<void> _loadAnalyticsData() async {
    setState(() => _isLoading = true);
    
    try {
      // Apply age filter if needed
      int? ageFilter;
      if (_selectedAge != 'All') {
        ageFilter = int.parse(_selectedAge);
      }
      
      print('Loading analytics with filters: Age=$_selectedAge, Date Range=${DateFormat('yyyy-MM-dd').format(_startDate)} to ${DateFormat('yyyy-MM-dd').format(_endDate)}, Student=${_selectedStudentId != null ? _studentOptions[_selectedStudentId] ?? "Unknown" : "All"}');
      
      // Reset all data collections
      _studentOptions.clear();
      userNames.clear();
      _sessionData.clear();
      _scoreDistribution.clear();
      _sessionsUnder5Min = 0;
      _sessions5to10Min = 0;
      _sessions10to20Min = 0;
      _sessionsOver20Min = 0;
      _completionRate = 0.0;
      _totalUsers = 0;
      _totalActivities = 0;
      _averageScore = 0.0;
      _averageSessionLength = 0.0;
      
      // Load students from profiles collection
      final profilesSnapshot = await FirebaseFirestore.instance.collection('profiles').get();
      print('Found ${profilesSnapshot.docs.length} users in profiles collection');
      
      for (var doc in profilesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = doc.id;
        
        // Get user name
        String? userName;
        if (data.containsKey('studentName') && data['studentName'] is String && data['studentName'].toString().isNotEmpty) {
          userName = data['studentName'] as String;
        } else if (data.containsKey('name') && data['name'] is String && data['name'].toString().isNotEmpty) {
          userName = data['name'] as String;
        }
        
        // Skip admin users (check both userId and userName)
        if ((userId.toLowerCase().contains('admin')) || 
            (userName != null && userName.toLowerCase().contains('admin'))) {
          print('Skipping admin user: $userId, $userName');
          continue;
        }
        
        // Get age information
        int? userAge;
        if (data.containsKey('age')) {
          var age = data['age'];
          if (age is int) {
            userAge = age;
          } else if (age is String) {
            try {
              userAge = int.parse(age);
            } catch (_) {}
          }
        }
        
        // Apply age filter if needed
        if (ageFilter != null && userAge != ageFilter) {
          print('Skipping user $userName due to age filter ($userAge != $ageFilter)');
          continue; // Skip if age doesn't match filter
        }
        
        // Only add if we have a valid name
        if (userName != null && userName.isNotEmpty) {
          print('User from profiles: $userName, Age: $userAge, ID: $userId');
          _studentOptions[userId] = userName;
          userNames[userId] = userName;
          print('Added user $userName to dropdown options');
        }
      }
      
      print('Student options after filtering: ${_studentOptions.length}');
      
      // If a specific student is selected, filter userNames to only include that student
      if (_selectedStudentId != null) {
        final selectedName = _studentOptions[_selectedStudentId];
        if (selectedName != null) {
          userNames = {_selectedStudentId!: selectedName};
        }
      }
      
      // Count total users based on filtered userNames
      _totalUsers = userNames.length;
      
      // We've already loaded all users from both collections above
      print('Total users after filtering: $_totalUsers');
      
      if (_totalUsers == 0) {
        print('WARNING: No users found matching the current filters');
      }
      
      // Query scores collection with filters
      // First get all scores and filter in memory to handle missing timestamps
      Query scoresQuery = FirebaseFirestore.instance.collection('scores');
      
      // Apply student filter if selected
      if (_selectedStudentId != null) {
        scoresQuery = scoresQuery.where('userId', isEqualTo: _selectedStudentId);
      }
      
      print('Querying scores with date range: ${DateFormat('yyyy-MM-dd').format(_startDate)} to ${DateFormat('yyyy-MM-dd').format(_endDate)}');
      final scoresSnapshot = await scoresQuery.get();
      print('Found ${scoresSnapshot.docs.length} score records in Firestore');
      
      // Process scores data
      Map<DateTime, Map<String, int>> dailyData = {};
      Map<String, int> scoreRanges = {
        '0-20': 0,
        '21-40': 0,
        '41-60': 0,
        '61-80': 0,
        '81-100': 0,
      };
      
      int totalPoints = 0;
      int totalScores = 0;
      int totalSessionMinutes = 0;
      int totalActivities = 0;
      int completedActivities = 0;
      
      // Process all scores and filter by date in memory
      for (var doc in scoresSnapshot.docs) {
        final scoreData = doc.data() as Map<String, dynamic>;
        final userId = scoreData['userId'] as String?;
        
        if (userId == null) {
          print('Skipping score record - missing userId');
          continue;
        }
        
        // Skip users not in our filtered user list
        if (!userNames.containsKey(userId)) {
          print('Skipping score record - user not in filtered list: $userId');
          continue;
        }
        
        print('Processing score record for user: $userId (${userNames[userId]})');
        
        // Apply date range filter - handle missing timestamps gracefully
        final timestamp = scoreData['timestamp'];
        DateTime? scoreDate;
        
        if (timestamp is Timestamp) {
          scoreDate = timestamp.toDate();
        } else if (timestamp is String) {
          try {
            scoreDate = DateTime.parse(timestamp);
          } catch (e) {
            print('Invalid timestamp format: $timestamp');
          }
        }
        
        // Skip if timestamp is missing or outside date range
        if (scoreDate == null) {
          print('Skipping score record - missing or invalid timestamp');
          continue;
        }
        
        if (scoreDate.isBefore(_startDate) || scoreDate.isAfter(_endDate.add(const Duration(days: 1)))) {
          print('Skipping score record - outside date range: $scoreDate');
          continue;
        }
        
        // Add to daily trend data
        final dateKey = DateTime(scoreDate.year, scoreDate.month, scoreDate.day);
        dailyData[dateKey] ??= {'sessions': 0, 'exercises': 0};
        dailyData[dateKey]!['exercises'] = (dailyData[dateKey]!['exercises'] ?? 0) + 1;
        
        // Only count unique sessions per user per day
        final sessionKey = '$userId-${dateKey.toString()}';
        if (!uniqueUserIds.contains(sessionKey)) {
          uniqueUserIds.add(sessionKey);
          dailyData[dateKey]!['sessions'] = (dailyData[dateKey]!['sessions'] ?? 0) + 1;
        }
        
        // Process score data - handle different data types
        final scoreValue = scoreData['score'];
        num? score;
        
        if (scoreValue is num) {
          score = scoreValue;
        } else if (scoreValue is String) {
          try {
            score = num.parse(scoreValue);
          } catch (e) {
            print('Invalid score format: $scoreValue');
          }
        }
        
        if (score != null) {
          // Ensure score is within valid range 0-100
          score = score.clamp(0, 100);
          
          totalScores++;
          totalPoints += score.toInt();
          
          // Add to score distribution
          if (score <= 20) {
            scoreRanges['0-20'] = (scoreRanges['0-20'] ?? 0) + 1;
          } else if (score <= 40) {
            scoreRanges['21-40'] = (scoreRanges['21-40'] ?? 0) + 1;
          } else if (score <= 60) {
            scoreRanges['41-60'] = (scoreRanges['41-60'] ?? 0) + 1;
          } else if (score <= 80) {
            scoreRanges['61-80'] = (scoreRanges['61-80'] ?? 0) + 1;
          } else {
            scoreRanges['81-100'] = (scoreRanges['81-100'] ?? 0) + 1;
          }
          
          print('Added score: $score to distribution');
        }
        
        // Process session duration - handle different data types and field names
        num? duration;
        
        // Check for different field names that might contain duration
        if (scoreData.containsKey('duration')) {
          final durationValue = scoreData['duration'];
          if (durationValue is num) {
            duration = durationValue;
          } else if (durationValue is String) {
            try {
              duration = num.parse(durationValue);
            } catch (e) {
              print('Invalid duration format: $durationValue');
            }
          }
        } else if (scoreData.containsKey('studyMinutes')) {
          final studyMinutes = scoreData['studyMinutes'];
          if (studyMinutes is num) {
            // studyMinutes is already in minutes, so we don't need to convert
            duration = studyMinutes * 60; // Convert to seconds for consistent processing
          }
        } else if (scoreData.containsKey('timeSpent')) {
          final timeSpent = scoreData['timeSpent'];
          if (timeSpent is num) {
            duration = timeSpent;
          }
        }
        
        if (duration != null && duration > 0) { // Ensure positive duration
          // Convert to minutes and ensure reasonable values (cap at 120 minutes)
          final minutes = (duration / 60).clamp(0, 120); 
          totalSessionMinutes += minutes.toInt();
          
          // Add to session duration breakdown
          if (minutes < 5) {
            _sessionsUnder5Min++;
          } else if (minutes < 10) {
            _sessions5to10Min++;
          } else if (minutes < 20) {
            _sessions10to20Min++;
          } else {
            _sessionsOver20Min++;
          }
          
          print('Added session duration: $minutes minutes');
        }
        
        // Track completion status - handle different data types and field names
        bool? completed;
        
        // Check various fields that might indicate completion
        if (scoreData.containsKey('completed')) {
          final completedValue = scoreData['completed'];
          if (completedValue is bool) {
            completed = completedValue;
          } else if (completedValue is String) {
            completed = completedValue.toLowerCase() == 'true';
          } else if (completedValue is num) {
            completed = completedValue > 0;
          }
        } else if (scoreData.containsKey('isCompleted')) {
          final isCompleted = scoreData['isCompleted'];
          if (isCompleted is bool) {
            completed = isCompleted;
          } else if (isCompleted is String) {
            completed = isCompleted.toLowerCase() == 'true';
          } else if (isCompleted is num) {
            completed = isCompleted > 0;
          }
        } else if (scoreData.containsKey('status')) {
          final status = scoreData['status'];
          if (status is String) {
            completed = status.toLowerCase() == 'completed' || status.toLowerCase() == 'done';
          }
        }
        
        // If score is present and greater than 0, consider it completed
        if (completed == null && score != null && score > 0) {
          completed = true;
        }
        
        // Always count the activity
        totalActivities++;
        
        if (completed == true) { // Explicitly check for true
          completedActivities++;
          print('Counted completed activity');
        }
      }
      
      // Calculate averages and rates
      _totalActivities = totalActivities;
      
      // Fix average score calculation - ensure we're using the actual count of scores
      _averageScore = totalScores > 0 ? totalPoints.toDouble() / totalScores : 0.0;
      
      // Fix average session length calculation - use total session minutes divided by number of sessions
      int totalSessions = _sessionsUnder5Min + _sessions5to10Min + _sessions10to20Min + _sessionsOver20Min;
      _averageSessionLength = totalSessions > 0 ? totalSessionMinutes.toDouble() / totalSessions : 0.0;
      
      // Fix completion rate calculation
      _completionRate = totalActivities > 0 ? (completedActivities.toDouble() / totalActivities) * 100 : 0.0;
      
      print('Analytics calculations: ');
      print('Total activities: $totalActivities');
      print('Completed activities: $completedActivities');
      print('Completion rate: $_completionRate%');
      print('Total scores: $totalScores');
      print('Total points: $totalPoints');
      print('Average score: $_averageScore');
      print('Total sessions: $totalSessions');
      print('Total session minutes: $totalSessionMinutes');
      print('Average session length: $_averageSessionLength minutes');
      
      // Convert daily data to time series
      List<DateTime> dateRange = [];
      for (var date = _startDate; date.isBefore(_endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
        dateRange.add(DateTime(date.year, date.month, date.day));
      }
      
      _sessionData = dateRange.map((date) {
        final data = dailyData[date] ?? {'sessions': 0, 'exercises': 0};
        return TimeSeriesData(date, data['sessions'] ?? 0, data['exercises'] ?? 0);
      }).toList();
      
      // Create score distribution data
      _scoreDistribution = [
        ScoreDistribution('0-20', scoreRanges['0-20'] ?? 0, Colors.red.shade300),
        ScoreDistribution('21-40', scoreRanges['21-40'] ?? 0, Colors.orange.shade300),
        ScoreDistribution('41-60', scoreRanges['41-60'] ?? 0, Colors.yellow.shade300),
        ScoreDistribution('61-80', scoreRanges['61-80'] ?? 0, Colors.lightGreen.shade300),
        ScoreDistribution('81-100', scoreRanges['81-100'] ?? 0, Colors.green.shade300),
      ];
      
      // Initialize empty score distribution if none exists
      if (_scoreDistribution.isEmpty) {
        _scoreDistribution = [
          ScoreDistribution('0-20', 0, Colors.red.shade300),
          ScoreDistribution('21-40', 0, Colors.orange.shade300),
          ScoreDistribution('41-60', 0, Colors.yellow.shade300),
          ScoreDistribution('61-80', 0, Colors.lightGreen.shade300),
          ScoreDistribution('81-100', 0, Colors.green.shade300),
        ];
      }
      
      // If we have students but no activity data, create empty time series data
      if (_sessionData.isEmpty && _studentOptions.isNotEmpty) {
        print('Creating empty time series data for students with no progress');
        List<DateTime> dateRange = [];
        for (var date = _startDate; date.isBefore(_endDate.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
          dateRange.add(DateTime(date.year, date.month, date.day));
        }
        
        _sessionData = dateRange.map((date) => TimeSeriesData(date, 0, 0)).toList();
      }
      
      print('Final analytics data: Users=${_totalUsers}, Activities=${_totalActivities}, Score=${_averageScore}');
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error loading analytics data: $e');
      setState(() {
        _isLoading = false;
        // Initialize empty score distribution on error
        _scoreDistribution = [
          ScoreDistribution('0-20', 0, Colors.red.shade300),
          ScoreDistribution('21-40', 0, Colors.orange.shade300),
          ScoreDistribution('41-60', 0, Colors.yellow.shade300),
          ScoreDistribution('61-80', 0, Colors.lightGreen.shade300),
          ScoreDistribution('81-100', 0, Colors.green.shade300),
        ];
      });
    }
  }
  
  // Handle age filter change
  void _onAgeFilterChanged(String? newValue) {
    if (newValue != null && newValue != _selectedAge) {
      setState(() {
        _selectedAge = newValue;
        // Reset student selection when age changes
        _selectedStudentId = null;
      });
      _loadAnalyticsData();
    }
  }
  
  // Handle date range change
  void _onDateRangeChanged(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _loadAnalyticsData();
  }
  
  // Handle search query change
  void _onStudentChanged(String? newValue) {
    setState(() {
      _selectedStudentId = newValue;
    });
    _loadAnalyticsData();
  }
  
  // Navigation is now handled by the parent widget through widget.onNavigate
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return AdminScaffold(
      title: 'Analytics Dashboard',
      selectedIndex: widget.selectedIndex,
      onNavigate: widget.onNavigate,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and filters
                  _buildTitleAndFilters(),
                  
                  SizedBox(height: isMobile ? 16 : 24),
                  
                  // Summary tiles - only section we're keeping
                  _buildSummaryTiles(),
                ],
              ),
            ),
    );
  }
  
  // Build title and filters section
  Widget _buildTitleAndFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_selectedStudentId != null)
              Chip(
                label: Text(_studentOptions[_selectedStudentId] ?? 'Student'),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _selectedStudentId = null;
                  });
                  _loadAnalyticsData();
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFilterBar(),
      ],
    );
  }
  
  // Helper method to build legend items for charts
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: isMobile ? 8 : 12,
          height: isMobile ? 8 : 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
        SizedBox(width: isMobile ? 2 : 4),
        Text(label, style: TextStyle(fontSize: isMobile ? 10 : 12)),
      ],
    );
  }

  // Build filter bar with age dropdown, date range picker, and user search
  Widget _buildFilterBar() {
    // Check if we're on a mobile device
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          isMobile
              // Mobile layout - vertical column
              ? Column(
                  children: [
                    // Age filter
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Age Group',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedAge,
                      items: ['All', '4', '5', '6']
                          .map((age) => DropdownMenuItem(
                                value: age,
                                child: Text(age),
                              ))
                          .toList(),
                      onChanged: _onAgeFilterChanged,
                    ),
                    const SizedBox(height: 12),
                    // Date range picker
                    InkWell(
                      onTap: _showDateRangePicker,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date Range',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${DateFormat('MMM d, yyyy').format(_startDate)} - ${DateFormat('MMM d, yyyy').format(_endDate)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Student dropdown
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Student',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(),
                        hintText: 'No students available',
                      ),
                      value: _studentOptions.isEmpty ? null : _selectedStudentId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Students'),
                        ),
                        ..._studentOptions.entries.map((entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            )).toList(),
                      ],
                      onChanged: _studentOptions.isEmpty ? null : _onStudentChanged,
                      disabledHint: _studentOptions.isEmpty ? const Text('No students available') : null,
                    ),
                  ],
                )
              // Desktop layout - horizontal row
              : Row(
                children: [
                  // Age filter
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Age Group',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedAge,
                      items: ['All', '4', '5', '6']
                          .map((age) => DropdownMenuItem(
                                value: age,
                                child: Text(age),
                              ))
                          .toList(),
                      onChanged: _onAgeFilterChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Date range picker
                  Expanded(
                    child: InkWell(
                      onTap: _showDateRangePicker,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date Range',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${DateFormat('MMM d, yyyy').format(_startDate)} - ${DateFormat('MMM d, yyyy').format(_endDate)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Icon(Icons.calendar_today, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Student dropdown
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Student',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        border: OutlineInputBorder(),
                        hintText: 'No students available',
                      ),
                      value: _studentOptions.isEmpty ? null : _selectedStudentId,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Students'),
                        ),
                        ..._studentOptions.entries.map((entry) => DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value),
                            )).toList(),
                      ],
                      onChanged: _studentOptions.isEmpty ? null : _onStudentChanged,
                      disabledHint: _studentOptions.isEmpty ? const Text('No students available') : null,
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
  
  // Show date range picker dialog
  void _showDateRangePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    
    if (picked != null) {
      _onDateRangeChanged(picked.start, picked.end);
    }
  }
  
  // Build summary tiles with sparklines
  Widget _buildSummaryTiles() {
    // Check if we're on a mobile device
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Use Column for mobile and Row for desktop
            isMobile
                ? Column(
                    children: [
                      _buildSummaryTile(
                        title: 'Total Users',
                        value: _totalUsers.toString(),
                        icon: Icons.people,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryTile(
                        title: 'Activities',
                        value: _totalActivities.toString(),
                        icon: Icons.assignment_turned_in,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryTile(
                        title: 'Avg. Score',
                        value: _averageScore.toStringAsFixed(1),
                        icon: Icons.star,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryTile(
                        title: 'Avg. Session',
                        value: '${_averageSessionLength.toStringAsFixed(1)} min',
                        icon: Icons.timer,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryTile(
                        title: 'Completion Rate',
                        value: '${_completionRate.toStringAsFixed(1)}%',
                        icon: Icons.check_circle,
                        color: Colors.teal,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryTile(
                              title: 'Total Users',
                              value: _totalUsers.toString(),
                              icon: Icons.people,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryTile(
                              title: 'Activities',
                              value: _totalActivities.toString(),
                              icon: Icons.assignment_turned_in,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryTile(
                              title: 'Avg. Score',
                              value: _averageScore.toStringAsFixed(1) + '%',
                              icon: Icons.star,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryTile(
                              title: 'Avg. Session',
                              value: '${_averageSessionLength.toStringAsFixed(1)} min',
                              icon: Icons.timer,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSummaryTile(
                              title: 'Completion Rate',
                              value: '${_completionRate.toStringAsFixed(1)}%',
                              icon: Icons.check_circle,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: SizedBox()), // Empty space for alignment
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
  
  // Build a single summary tile with sparkline graph
  Widget _buildSummaryTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    // Generate data points based on the metric type
    List<double> dataPoints;
    
    // Use real data from the time series for the sparklines
    if (_sessionData.isEmpty) {
      // If no data, use flat line
      dataPoints = List<double>.generate(10, (i) => 0.0);
    } else {
      // Use actual data based on the tile type
      switch (title) {
        case 'Total Users':
          // Use unique users per day
          dataPoints = _sessionData.map((data) => data.sessions.toDouble()).toList();
          break;
        case 'Activities':
          // Use exercise count
          dataPoints = _sessionData.map((data) => data.exercises.toDouble()).toList();
          break;
        case 'Avg. Score':
          // Use normalized score data (0-1 range)
          final maxScore = _averageScore > 0 ? _averageScore : 1.0;
          dataPoints = _sessionData.map((data) => 
            (data.exercises > 0) ? (_averageScore / 100) : 0.0).toList();
          break;
        case 'Avg. Session':
          // Use session duration trend
          dataPoints = _sessionData.map((data) => 
            (data.sessions > 0) ? (_averageSessionLength / 30) : 0.0).toList();
          break;
        case 'Completion Rate':
          // Use completion rate trend
          dataPoints = _sessionData.map((data) => 
            (data.exercises > 0) ? (_completionRate / 100) : 0.0).toList();
          break;
        default:
          dataPoints = List<double>.generate(10, (i) => 0.0);
      }
      
      // Ensure we have at least some data points
      if (dataPoints.isEmpty) {
        dataPoints = List<double>.generate(10, (i) => 0.0);
      }
      
      // Normalize data to fit in the sparkline (0.0-1.0 range)
      final maxValue = dataPoints.isEmpty ? 1.0 : 
                      dataPoints.reduce((max, value) => value > max ? value : max);
      if (maxValue > 0) {
        dataPoints = dataPoints.map((value) => value / maxValue).toList();
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
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
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          // Flat line at zero with better styling
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 40),
              painter: _SparklinePainter(color: color, dataPoints: dataPoints),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build trend charts section
  Widget _buildTrendCharts() {
    // Check if we're on a mobile device
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Activity Trends Chart - Simplified for mobile
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activity Trends',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                // Use a simple container with fixed dimensions to avoid megapixel warning
                Container(
                  height: 80, // Very small fixed height to avoid megapixel warning on mobile
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // Legend
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem('Sessions', Colors.blue),
                          const SizedBox(height: 8),
                          _buildLegendItem('Exercises', Colors.green),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Activity summary or message
                      Expanded(
                        child: _sessionData.isEmpty
                          ? Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.info_outline, color: Colors.grey.shade400, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    'No activity data',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: Text(
                                'Total: ${_sessionData.fold(0, (sum, item) => sum + item.sessions)} sessions, ${_sessionData.fold(0, (sum, item) => sum + item.exercises)} exercises',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Build engagement breakdown section
  Widget _buildEngagementBreakdown() {
    // Check if we're on a mobile device
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    // Calculate total sessions
    final totalSessions = _sessionsUnder5Min + _sessions5to10Min + _sessions10to20Min + _sessionsOver20Min;
    
    // Calculate percentages
    final List<SessionDuration> sessionData = [];
    if (totalSessions > 0) {
      sessionData.add(SessionDuration(
        'Under 5 min',
        _sessionsUnder5Min,
        (_sessionsUnder5Min / totalSessions) * 100,
        Colors.blue.shade300,
      ));
      sessionData.add(SessionDuration(
        '5-10 min',
        _sessions5to10Min,
        (_sessions5to10Min / totalSessions) * 100,
        Colors.green.shade300,
      ));
      sessionData.add(SessionDuration(
        '10-20 min',
        _sessions10to20Min,
        (_sessions10to20Min / totalSessions) * 100,
        Colors.amber.shade300,
      ));
      sessionData.add(SessionDuration(
        'Over 20 min',
        _sessionsOver20Min,
        (_sessionsOver20Min / totalSessions) * 100,
        Colors.orange.shade300,
      ));
    }
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Engagement Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Session Duration',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                sessionData.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Text('No data available'),
                        ),
                      )
                    : isMobile
                        ? Column(
                            children: [
                              SizedBox(
                                height: 180, // Smaller for mobile
                                child: _buildPieChart(sessionData),
                              ),
                              const SizedBox(height: 16),
                              _buildPieChartLegend(sessionData),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Pie chart
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 220,
                                  child: _buildPieChart(sessionData),
                                ),
                              ),
                              
                              // Legend
                              Expanded(
                                flex: 3,
                                child: _buildPieChartLegend(sessionData),
                              ),
                            ],
                          ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Build line chart for activity trends with simplified mobile-friendly approach
  Widget _buildLineChart() {
    // Check if we have any actual data points with non-zero values
    bool hasNonZeroData = false;
    if (_sessionData.isNotEmpty) {
      for (var data in _sessionData) {
        if (data.sessions > 0 || data.exercises > 0) {
          hasNonZeroData = true;
          break;
        }
      }
    }
    
    // Build legend for the chart
    Widget buildLegend() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem('Sessions', Colors.blue),
          SizedBox(width: isMobile ? 16 : 24),
          _buildLegendItem('Exercises', Colors.green),
        ],
      );
    }
    
    // If there's no data, show a placeholder
    if (!hasNonZeroData) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'No data available for the selected filters',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 16),
          buildLegend(),
        ],
      );
    }
    
    // Calculate max value for Y axis with 20% padding
    final maxValue = _sessionData.isEmpty 
        ? 5.0 
        : _sessionData.map((data) => max(data.sessions, data.exercises)).reduce(max).toDouble() * 1.2 + 1;
    
    // Prepare data points
    final sessionSpots = _sessionData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(index.toDouble(), data.sessions.toDouble());
    }).toList();
    
    final exerciseSpots = _sessionData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(index.toDouble(), data.exercises.toDouble());
    }).toList();
    
    // Calculate interval for x-axis labels
    final interval = isMobile && _sessionData.length > 10 ? 2 : 1;
    
    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: _sessionData.length > 0 ? _sessionData.length - 1.0 : 5,
              minY: 0,
              maxY: maxValue,
              clipData: FlClipData.all(),
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTitlesWidget: (value, meta) {
                      if (value % interval != 0) {
                        return const SizedBox.shrink();
                      }
                      final index = value.toInt();
                      if (index >= 0 && index < _sessionData.length) {
                        final date = _sessionData[index].date;
                        return Text(
                          DateFormat(isMobile ? 'MM/dd' : 'MM/dd/yy').format(date),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 9,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 9,
                        ),
                      );
                    },
                    reservedSize: 20,
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // Sessions line
                LineChartBarData(
                  spots: sessionSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
                // Exercises line
                LineChartBarData(
                  spots: exerciseSpots,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        buildLegend(),
      ],
    );
  }
  
  // Build bar chart for score distribution
  Widget _buildBarChart() {
    // Check if we're on a mobile device
    final isMobile = MediaQuery.of(context).size.width < 600;
    final hasData = _scoreDistribution.isNotEmpty;
    
    // Calculate a reasonable height based on available space
    final screenHeight = MediaQuery.of(context).size.height;
    final chartHeight = screenHeight * 0.25; // 25% of screen height
    
    if (!hasData) {
      return Container(
        height: chartHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            Text('No data available', style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }
    
    return SizedBox(
      height: chartHeight,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _scoreDistribution.map((e) => e.count).reduce(max).toDouble() * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${_scoreDistribution[groupIndex].scoreRange}: ${rod.toY.toInt()}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      _scoreDistribution[value.toInt()].scoreRange,
                      style: TextStyle(fontSize: isMobile ? 8 : 10),
                    ),
                  );
                },
                reservedSize: isMobile ? 20 : 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: isMobile ? 24 : 30,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(fontSize: isMobile ? 9 : 10),
                    ),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(_scoreDistribution.length, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: _scoreDistribution[index].count.toDouble(),
                  color: _scoreDistribution[index].color,
                  width: isMobile ? 14 : 20, // Narrower bars on mobile
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
  
  // Build pie chart for session durations
  Widget _buildPieChart(List<SessionDuration> data) {
    return PieChart(
      PieChartData(
        sections: data.map((item) {
          return PieChartSectionData(
            color: item.color,
            value: item.percentage,
            title: '',
            radius: 100,
          );
        }).toList(),
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }
  
  // Build legend for pie chart
  Widget _buildPieChartLegend(List<SessionDuration> data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.durationRange} (${item.count})',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Text(
                '${item.percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Simple sparkline painter
// Custom sparkline painter for summary tiles
class _SparklinePainter extends CustomPainter {
  final Color color;
  final List<double> dataPoints;
  
  _SparklinePainter({required this.color, required this.dataPoints});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Line paint
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    // Fill paint
    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    final fillPath = Path();
    
    // Calculate points based on data
    final points = List.generate(dataPoints.length, (index) {
      return Offset(
        size.width * index / (dataPoints.length - 1),
        size.height * (1 - dataPoints[index]), // Invert Y to draw from bottom up
      );
    });
    
    // Create the line path
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      fillPath.moveTo(points.first.dx, size.height); // Start fill from bottom
      fillPath.lineTo(points.first.dx, points.first.dy); // Up to first point
      
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
        fillPath.lineTo(points[i].dx, points[i].dy);
      }
      
      // Complete the fill path
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();
      
      // Draw the fill and then the line
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, linePaint);
      
      // Draw points
      final pointPaint = Paint()
        ..color = color
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      
      // Draw first and last points slightly larger
      canvas.drawCircle(points.first, 3, pointPaint);
      canvas.drawCircle(points.last, 3, pointPaint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
