import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fyp2/utils/app_colors.dart';
import 'package:intl/intl.dart';

class ChildProgressScreen extends StatefulWidget {
  final String childId;

  const ChildProgressScreen({
    Key? key,
    required this.childId,
  }) : super(key: key);

  @override
  State<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends State<ChildProgressScreen> {
  bool _isLoading = true;
  String _selectedFilter = 'Today';
  bool _showBySubject = true; // Toggle between subject and activity type view

  // Data structures
  List<Map<String, dynamic>> _progressData = [];
  Map<String, double> _subjectScores = {};
  Map<String, double> _studyMinutes = {};
  Map<String, int> _activityTypeCounts = {};
  Map<String, Map<String, int>> _subjectActivityData = {};
  Map<String, Map<String, int>> _activityTypeSubjectData = {};

  // Summary statistics
  double _totalPoints = 0;
  double _totalStudyMinutes = 0;
  int _daysActive = 0;

  // Color mapping for consistent colors
  final Map<String, Color> _subjectColors = {};
  final Map<String, Color> _activityTypeColors = {
    'game': Colors.green,
    'note': Colors.blue,
    'video': Colors.orange,
    'other': Colors.purple,
  };

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);
    
    try {
      // Get the current user's ID or use the provided childId
      final currentUser = FirebaseAuth.instance.currentUser;
      final String userId = currentUser?.uid ?? widget.childId;
      
      print('Loading progress data for user ID: $userId');
      
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
      
      print('Loading progress data from $startDate to now');
      
      // First get data from scores collection
      final scoresSnapshot = await FirebaseFirestore.instance
          .collection('scores')
          .where('userId', isEqualTo: userId)
          .get();
          
      print('Found ${scoresSnapshot.docs.length} score entries');
      
      // Filter the results in memory instead of using a compound query
      final filteredScoreDocs = scoresSnapshot.docs.where((doc) {
        final data = doc.data();
        final timestamp = data['timestamp'];
        
        if (timestamp == null) return false;
        
        DateTime date;
        if (timestamp is Timestamp) {
          date = timestamp.toDate();
        } else if (timestamp is String) {
          try {
            date = DateTime.parse(timestamp);
          } catch (e) {
            return false;
          }
        } else {
          return false;
        }
        
        // For 'Today', we need to check if it's the same day
        if (_selectedFilter == 'Today') {
          return date.year == today.year && 
                 date.month == today.month && 
                 date.day == today.day;
        }
        // For other filters, check if it's after the start date
        else {
          return date.isAfter(startDate) || 
                 (date.year == startDate.year && 
                  date.month == startDate.month && 
                  date.day == startDate.day);
        }
      }).toList();
      
      print('Filtered to ${filteredScoreDocs.length} score entries after date filtering');
      
      // Process the filtered scores data
      List<Map<String, dynamic>> progressData = [];
      
      for (var doc in filteredScoreDocs) {
        final data = doc.data();
        
        // Create a standardized progress entry with clear separation between subject and chapter
        String subjectName = data['subjectName'] ?? data['subject'] ?? 'Unknown';
        String chapterName = data['chapterName'] ?? data['activityName'] ?? 'Unknown Activity';
        
        Map<String, dynamic> entry = {
          'userId': userId,
          'subject': subjectName, // Always use the subject name for subject field
          'points': data['points'] ?? 0,
          'timestamp': data['timestamp'],
          'activityName': subjectName, // Use subject name for activity name to ensure consistent filtering
          'chapterName': chapterName, // Store chapter name separately
        };
        
        // Improved activity type detection and normalization
        String activityType = 'unknown';
        
        // First check if activityType is explicitly set
        if (data.containsKey('activityType')) {
          var typeValue = data['activityType'];
          if (typeValue is String) {
            activityType = typeValue.toLowerCase();
          }
        }
        
        // If still unknown, try to infer from other fields
        if (activityType == 'unknown') {
          // Check for game indicators
          if (data.containsKey('gameId') || data.containsKey('gameType') ||
              (data.containsKey('activityName') && data['activityName'].toString().toLowerCase().contains('game'))) {
            activityType = 'game';
          }
          // Check for note indicators
          else if (data.containsKey('noteId') || 
                  (data.containsKey('activityName') && 
                   data['activityName'].toString().toLowerCase().contains('note'))) {
            activityType = 'note';
          }
          // Check for video indicators
          else if (data.containsKey('videoId') || 
                  (data.containsKey('activityName') && 
                   data['activityName'].toString().toLowerCase().contains('video'))) {
            activityType = 'video';
          }
        }
        
        // Normalize the activity type to standard categories
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
        
        entry['activityType'] = activityType;
        
        // Add study minutes if available
        if (data.containsKey('studyMinutes')) {
          entry['studyMinutes'] = data['studyMinutes'] as int? ?? 0;
        } else {
          entry['studyMinutes'] = 5; // Default study minutes based on the Firebase data
        }
        
        progressData.add(entry);
      }
      
      // Also query Firestore for progress data
      final progressSnapshot = await FirebaseFirestore.instance
          .collection('progress')
          .where('userId', isEqualTo: userId)
          .get();
          
      print('Found ${progressSnapshot.docs.length} progress entries');
      
      // Filter the progress data by date
      final filteredProgressDocs = progressSnapshot.docs.where((doc) {
        final data = doc.data();
        final timestamp = data['timestamp'];
        
        if (timestamp == null) return false;
        
        DateTime date;
        if (timestamp is Timestamp) {
          date = timestamp.toDate();
        } else if (timestamp is String) {
          try {
            date = DateTime.parse(timestamp);
          } catch (e) {
            return false;
          }
        } else {
          return false;
        }
        
        // For 'Today', we need to check if it's the same day
        if (_selectedFilter == 'Today') {
          return date.year == today.year && 
                 date.month == today.month && 
                 date.day == today.day;
        }
        // For other filters, check if it's after the start date
        else {
          return date.isAfter(startDate) || 
                 (date.year == startDate.year && 
                  date.month == startDate.month && 
                  date.day == startDate.day);
        }
      }).toList();
      
      print('Filtered to ${filteredProgressDocs.length} progress entries after date filtering');
      
      // Process the filtered progress data
      for (var doc in filteredProgressDocs) {
        final data = doc.data();
        
        // Create a standardized progress entry
        String subjectName = data['subjectName'] ?? data['subject'] ?? 'Unknown';
        String activityName = data['activityName'] ?? 'Unknown Activity';
        
        Map<String, dynamic> entry = {
          'userId': userId,
          'subject': subjectName,
          'points': data['points'] ?? 0,
          'timestamp': data['timestamp'],
          'activityName': activityName,
        };
        
        // Determine activity type
        String activityType = 'other';
        if (data.containsKey('activityType')) {
          var typeValue = data['activityType'];
          if (typeValue is String) {
            activityType = typeValue.toLowerCase();
            
            // Normalize activity type
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
        
        entry['activityType'] = activityType;
        
        // Add study minutes if available
        if (data.containsKey('studyMinutes')) {
          entry['studyMinutes'] = data['studyMinutes'] as int? ?? 0;
        } else if (data.containsKey('duration')) {
          entry['studyMinutes'] = data['duration'] as int? ?? 0;
        } else {
          entry['studyMinutes'] = 5; // Default study minutes
        }
        
        progressData.add(entry);
      }
      
      print('Total combined entries before activity filtering: ${progressData.length}');
      
      // Use only real data from Firestore
      print('Using ${progressData.length} real data entries for statistics');

      
      // Calculate statistics
      _calculateStatistics(progressData);
      
    } catch (e) {
      print('Error loading progress data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _calculateStatistics(List<Map<String, dynamic>> filteredData) {
    // Reset all data structures
    _subjectScores = {};
    _studyMinutes = {};
    _activityTypeCounts = {};
    _subjectActivityData = {};
    _activityTypeSubjectData = {};
    _totalPoints = 0;
    _totalStudyMinutes = 0;
    
    // Track unique active days
    final Set<String> activeDays = {};
    
    // Process each data entry
    for (final data in filteredData) {
      final subject = data['subjectName'] ?? data['subject'] ?? 'Unknown';
      final points = data['points'] ?? 0;
      final minutes = data['studyMinutes'] ?? data['duration'] ?? 0;
      
      // Extract and normalize activity type
      String activityType = 'other';
      if (data.containsKey('activityType')) {
        var typeValue = data['activityType'];
        if (typeValue is String) {
          String normalizedType = typeValue.toLowerCase();
          if (normalizedType.contains('game') || normalizedType.contains('match') || normalizedType.contains('puzzle')) {
            activityType = 'game';
          } else if (normalizedType.contains('note') || normalizedType.contains('read') || normalizedType.contains('book')) {
            activityType = 'note';
          } else if (normalizedType.contains('video') || normalizedType.contains('watch')) {
            activityType = 'video';
          }
        }
      } else {
        if (data.containsKey('gameId') || data.containsKey('gameType')) {
          activityType = 'game';
        } else if (data.containsKey('noteId') || (data.containsKey('activityName') && data['activityName'].toString().toLowerCase().contains('note'))) {
          activityType = 'note';
        } else if (data.containsKey('videoId') || (data.containsKey('activityName') && data['activityName'].toString().toLowerCase().contains('video'))) {
          activityType = 'video';
        }
      }
      
      // Update subject scores
      _subjectScores[subject] = (_subjectScores[subject] ?? 0) + points.toDouble();
      
      // Update study minutes
      _studyMinutes[subject] = (_studyMinutes[subject] ?? 0) + minutes.toDouble();
      
      // Update activity type counts
      _activityTypeCounts[activityType] = (_activityTypeCounts[activityType] ?? 0) + 1;
      
      // Update subject activity data
      if (!_subjectActivityData.containsKey(subject)) {
        _subjectActivityData[subject] = {};
      }
      _subjectActivityData[subject]![activityType] = (_subjectActivityData[subject]![activityType] ?? 0) + 1;
      
      // Update activity type by subject data
      if (!_activityTypeSubjectData.containsKey(activityType)) {
        _activityTypeSubjectData[activityType] = {};
      }
      _activityTypeSubjectData[activityType]![subject] = (_activityTypeSubjectData[activityType]![subject] ?? 0) + 1;
      
      // Track active days
      if (data.containsKey('timestamp')) {
        final timestamp = data['timestamp'];
        DateTime? dateTime;
        if (timestamp is Timestamp) {
          dateTime = timestamp.toDate();
        } else if (timestamp is DateTime) {
          dateTime = timestamp;
        }
        if (dateTime != null) {
          final dayKey = '${dateTime.year}-${dateTime.month}-${dateTime.day}';
          activeDays.add(dayKey);
        }
      }
      
      // Update totals
      _totalPoints += points.toDouble();
      _totalStudyMinutes += minutes.toDouble();
    }
    
    // Set active days count
    _daysActive = activeDays.length;
    
    // Ensure all activity types have zero counts if no data
    for (final type in ['game', 'note', 'video', 'other']) {
      _activityTypeCounts[type] ??= 0;
    }
    
    // Ensure all subjects have entries for all activity types
    for (final subject in _subjectActivityData.keys) {
      for (final type in ['game', 'note', 'video', 'other']) {
        _subjectActivityData[subject]![type] ??= 0;
      }
    }
    
    // Ensure all activity types have entries for all subjects
    for (final type in _activityTypeSubjectData.keys) {
      for (final subject in _subjectScores.keys) {
        _activityTypeSubjectData[type]![subject] ??= 0;
      }
    }
    
    // Assign colors to subjects if not already assigned
    final List<Color> subjectColorPalette = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ];
    
    int colorIndex = 0;
    for (final subject in _subjectScores.keys) {
      if (!_subjectColors.containsKey(subject)) {
        _subjectColors[subject] = subjectColorPalette[colorIndex % subjectColorPalette.length];
        colorIndex++;
      }
    }
    
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Progress'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/rainbow.png'),
            fit: BoxFit.cover,
            opacity: 0.15, // Semi-transparent background
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimeFilters(),
                    const SizedBox(height: 20),
                    _buildSummaryCards(),
                    const SizedBox(height: 30),
                    _buildChartToggle(),
                    const SizedBox(height: 20),
                    _buildStackedBarChart(),
                    const SizedBox(height: 20), // Add some bottom padding
                  ],
                ),
              ),
      ),
    );
  }
  
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
  
  Widget _buildSummaryCards() {
    // Define a fixed height for all cards to ensure uniformity
    const double cardHeight = 110.0;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total Points',
            _totalPoints.toInt().toString(),
            Icons.star,
            Colors.amber,
            cardHeight,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryCard(
            'Study Time',
            '${_totalStudyMinutes.toInt()} min',
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
  
  Widget _buildChartToggle() {
    return Container(
      width: double.infinity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'View by: ',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
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
                    setState(() {
                      _showBySubject = true;
                    });
                  }
                },
                backgroundColor: Colors.grey[100],
                selectedColor: AppColors.primaryColor.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _showBySubject ? AppColors.primaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ChoiceChip(
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
                    setState(() {
                      _showBySubject = false;
                    });
                  }
                },
                backgroundColor: Colors.grey[100],
                selectedColor: AppColors.primaryColor.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: !_showBySubject ? AppColors.primaryColor : Colors.transparent,
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
  
  Widget _buildStackedBarChart() {
    // Create a container with a border and background for the chart
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0, left: 8.0),
            child: Text(
              _showBySubject ? 'Subject Performance' : 'Activity Type Breakdown',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Chart content
          _showBySubject ? _buildSubjectStackedBarChart() : _buildActivityTypeStackedBarChart(),
          // Legend
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _buildLegend(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSubjectStackedBarChart() {
    if (_subjectActivityData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No data available for the selected time period'),
        ),
      );
    }
    
    final List<String> subjects = _subjectActivityData.keys.toList();
    final List<String> activityTypes = ['game', 'note', 'video', 'other'];
    
    return SizedBox(
      height: 400,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _subjectActivityData.values
              .map((activityMap) => activityMap.values.fold<int>(0, (sum, count) => sum + count))
              .fold<int>(0, (max, sum) => sum > max ? sum : max)
              .toDouble() * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final subject = subjects[groupIndex];
                final activityType = activityTypes[rodIndex];
                final count = _subjectActivityData[subject]![activityType] ?? 0;
                return BarTooltipItem(
                  '$activityType: $count',
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
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= subjects.length) return const Text('');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      subjects[value.toInt()],
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
          barGroups: List.generate(
            subjects.length,
            (subjectIndex) {
              final subject = subjects[subjectIndex];
              final activityMap = _subjectActivityData[subject]!;
              
              return BarChartGroupData(
                x: subjectIndex,
                barRods: [
                  BarChartRodData(
                    toY: (activityMap['game'] ?? 0).toDouble(),
                    color: _activityTypeColors['game'],
                    width: 20,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  BarChartRodData(
                    toY: (activityMap['note'] ?? 0).toDouble(),
                    color: _activityTypeColors['note'],
                    width: 20,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  BarChartRodData(
                    toY: (activityMap['video'] ?? 0).toDouble(),
                    color: _activityTypeColors['video'],
                    width: 20,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  BarChartRodData(
                    toY: (activityMap['other'] ?? 0).toDouble(),
                    color: _activityTypeColors['other'],
                    width: 20,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildActivityTypeStackedBarChart() {
    if (_activityTypeSubjectData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No data available for the selected time period'),
        ),
      );
    }
    
    final List<String> activityTypes = _activityTypeSubjectData.keys.toList();
    final List<String> subjects = _subjectScores.keys.toList();
    
    return SizedBox(
      height: 400,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _activityTypeSubjectData.values
              .map((subjectMap) => subjectMap.values.fold<int>(0, (sum, count) => sum + count))
              .fold<int>(0, (max, sum) => sum > max ? sum : max)
              .toDouble() * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final activityType = activityTypes[groupIndex];
                if (rodIndex >= subjects.length) return null;
                final subject = subjects[rodIndex];
                final count = _activityTypeSubjectData[activityType]![subject] ?? 0;
                return BarTooltipItem(
                  '$subject: $count',
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
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value >= activityTypes.length) return const Text('');
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      activityTypes[value.toInt()],
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
          barGroups: List.generate(
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
          ),
        ),
      ),
    );
  }
  
  Widget _buildLegend() {
    final Map<String, Color> colorsToShow = _showBySubject 
        ? _activityTypeColors 
        : _subjectColors;
    
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16.0,
      runSpacing: 8.0,
      children: colorsToShow.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: entry.value,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 1,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                // Capitalize first letter of each word
                entry.key.split(' ').map((word) => 
                  word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}'
                ).join(' '),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}