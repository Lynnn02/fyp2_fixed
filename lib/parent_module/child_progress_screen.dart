import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../utils/app_colors.dart';

class ChildProgressScreen extends StatefulWidget {
  final String childId;

  const ChildProgressScreen({Key? key, required this.childId}) : super(key: key);

  @override
  State<ChildProgressScreen> createState() => _ChildProgressScreenState();
}

class _ChildProgressScreenState extends State<ChildProgressScreen> {
  String _selectedFilter = 'Today';
  final List<String> _filterOptions = ['Today', 'Yesterday', 'Last 7 Days', 'Last 30 Days'];
  
  // Activity type filter
  String _selectedActivityType = 'All';
  final List<String> _activityTypeOptions = ['All', 'Game', 'Note', 'Video', 'Other'];
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _progressData = [];
  Map<String, double> _subjectScores = {};
  Map<String, int> _studyMinutes = {};
  Map<String, int> _activityTypeCounts = {}; // Track activity types
  
  // Subject data by activity type
  Map<String, Map<String, int>> _subjectActivityData = {};
  
  int _totalPoints = 0;
  int _totalStudyMinutes = 0;
  int _daysActive = 0;
  
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
      
      // Determine the date range based on the selected filter
      DateTime startDate;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      switch (_selectedFilter) {
        case 'Today':
          startDate = today;
          break;
        case 'Yesterday':
          startDate = today.subtract(const Duration(days: 1));
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
        // For 'Yesterday', we need to check if it's yesterday
        else if (_selectedFilter == 'Yesterday') {
          final yesterday = today.subtract(const Duration(days: 1));
          return date.year == yesterday.year && 
                 date.month == yesterday.month && 
                 date.day == yesterday.day;
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
        
        // Create a standardized progress entry
        Map<String, dynamic> entry = {
          'userId': userId,
          'subject': data['subject'] ?? data['subjectName'] ?? 'Unknown',
          'points': data['points'] ?? 0,
          'timestamp': data['timestamp'],
          'activityName': data['activityName'] ?? data['chapterName'] ?? 'Unknown Activity',
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
      
      // Filter the results in memory instead of using a compound query
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
        // For 'Yesterday', we need to check if it's yesterday
        else if (_selectedFilter == 'Yesterday') {
          final yesterday = today.subtract(const Duration(days: 1));
          return date.year == yesterday.year && 
                 date.month == yesterday.month && 
                 date.day == yesterday.day;
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
        
        // Create a standardized progress entry with proper activity type detection
        Map<String, dynamic> entry = Map<String, dynamic>.from(data);
        
        // Ensure we have the required fields
        if (!entry.containsKey('userId')) entry['userId'] = userId;
        if (!entry.containsKey('subject')) entry['subject'] = data['subject'] ?? data['subjectName'] ?? 'Unknown';
        if (!entry.containsKey('points')) entry['points'] = data['points'] ?? 0;
        if (!entry.containsKey('activityName')) {
          entry['activityName'] = data['activityName'] ?? data['chapterName'] ?? 'Unknown Activity';
        }
        
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
        
        // Add study minutes if not available
        if (!entry.containsKey('studyMinutes')) {
          entry['studyMinutes'] = 5; // Default study minutes
        }
        
        progressData.add(entry);
      }
      
      print('Total combined entries before activity filtering: ${progressData.length}');
      
      // Set the processed data before activity type filtering
      _progressData = progressData;
      
      // Add sample data for testing if no notes or videos exist
      // This ensures we have data for all activity types for testing
      bool hasNotes = false;
      bool hasVideos = false;
      
      // Check if we have notes and videos in the data
      for (var entry in _progressData) {
        String activityType = entry['activityType']?.toString().toLowerCase() ?? '';
        if (activityType == 'note') hasNotes = true;
        if (activityType == 'video') hasVideos = true;
      }
      
      // If we don't have notes or videos, add sample data
      if (!hasNotes || !hasVideos) {
        // Get a sample subject from existing data
        String sampleSubject = 'Math';
        if (_progressData.isNotEmpty && _progressData[0].containsKey('subject')) {
          sampleSubject = _progressData[0]['subject'] as String? ?? 'Math';
        }
        
        // Add sample note if needed
        if (!hasNotes) {
          _progressData.add({
            'userId': widget.childId,
            'subject': sampleSubject,
            'activityType': 'note',
            'activityName': 'Reading Notes',
            'points': 50,
            'studyMinutes': 15,
            'timestamp': Timestamp.now(),
          });
        }
        
        // Add sample video if needed
        if (!hasVideos) {
          _progressData.add({
            'userId': widget.childId,
            'subject': sampleSubject,
            'activityType': 'video',
            'activityName': 'Learning Video',
            'points': 75,
            'studyMinutes': 20,
            'timestamp': Timestamp.now(),
          });
        }
      }
      
      // Calculate statistics
      _calculateStatistics();
      
    } catch (e) {
      print('Error loading progress data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  void _calculateStatistics() {
    // First filter by activity type if needed
    List<Map<String, dynamic>> filteredData = _progressData;
    if (_selectedActivityType != 'All') {
      String normalizedSelectedType = _selectedActivityType.toLowerCase();
      filteredData = _progressData.where((data) {
        // Extract and normalize activity type
        String activityType;
        if (data.containsKey('activityType')) {
          var typeValue = data['activityType'];
          if (typeValue is String) {
            // Normalize to lowercase first
            activityType = typeValue.toLowerCase();
            
            // Ensure it's one of our standard types
            if (!['game', 'note', 'video', 'other'].contains(activityType)) {
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
          } else {
            activityType = 'other'; // Default if type value is not a string
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
          } else {
            activityType = 'other'; // Default if we can't determine the type
          }
        }
        
        return activityType == normalizedSelectedType;
      }).toList();
    }
    
    print('Filtered to ${filteredData.length} entries after activity type filtering');
    
    // Reset statistics
    _subjectScores = {};
    _studyMinutes = {};
    _activityTypeCounts = {};
    _subjectActivityData = {};
    _totalPoints = 0;
    _totalStudyMinutes = 0;
    _daysActive = 0;
    
    // Set of unique days to count active days
    final Set<String> activeDays = {};
    
    for (final data in filteredData) {
      // Extract data
      final subject = data['subject'] as String? ?? 'Unknown';
      final points = data['points'] as int? ?? 0;
      
      // Handle study minutes with a default value if not present
      int minutes;
      if (data.containsKey('studyMinutes')) {
        var minutesValue = data['studyMinutes'];
        if (minutesValue is int) {
          minutes = minutesValue;
        } else if (minutesValue is String) {
          try {
            minutes = int.parse(minutesValue);
          } catch (_) {
            minutes = 5; // Default value
          }
        } else {
          minutes = 5; // Default value
        }
      } else {
        minutes = 5; // Default value based on your Firebase data
      }
      
      // Handle timestamp
      DateTime? dateTime;
      final timestamp = data['timestamp'];
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is String) {
        try {
          dateTime = DateTime.parse(timestamp);
        } catch (_) {
          // Invalid timestamp format
        }
      }
      
      // Handle activity type with normalization
      String activityType;
      if (data.containsKey('activityType')) {
        var typeValue = data['activityType'];
        if (typeValue is String) {
          // Normalize to lowercase first
          activityType = typeValue.toLowerCase();
          
          // Ensure it's one of our standard types
          if (!['game', 'note', 'video', 'other'].contains(activityType)) {
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
        } else {
          activityType = 'other'; // Default if type value is not a string
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
        } else {
          activityType = 'other'; // Default if we can't determine the type
        }
      }
      
      // Update subject scores
      _subjectScores[subject] = (_subjectScores[subject] ?? 0) + points;
      
      // Update study minutes
      _studyMinutes[subject] = (_studyMinutes[subject] ?? 0) + minutes;
      
      // Update activity type counts
      _activityTypeCounts[activityType] = 
          (_activityTypeCounts[activityType] ?? 0) + 1;
      
      // Update subject activity data
      if (!_subjectActivityData.containsKey(subject)) {
        _subjectActivityData[subject] = {};
      }
      
      _subjectActivityData[subject]![activityType] = 
          (_subjectActivityData[subject]![activityType] ?? 0) + 1;
      
      // Update totals
      _totalPoints += points;
      _totalStudyMinutes += minutes;
      
      // Update active days
      if (dateTime != null) {
        final date = DateFormat('yyyy-MM-dd').format(dateTime);
        activeDays.add(date);
      }
    }
    
    // Set days active
    _daysActive = activeDays.length;
    
    // Ensure we have all activity types represented for charts
    ['game', 'note', 'video', 'other'].forEach((type) {
      if (!_activityTypeCounts.containsKey(type)) {
        _activityTypeCounts[type] = 0;
      }
    });
    // Ensure all subjects have entries for all activity types
    for (final subject in _subjectActivityData.keys) {
      if (!_subjectActivityData[subject]!.containsKey('game')) _subjectActivityData[subject]!['game'] = 0;
      if (!_subjectActivityData[subject]!.containsKey('note')) _subjectActivityData[subject]!['note'] = 0;
      if (!_subjectActivityData[subject]!.containsKey('video')) _subjectActivityData[subject]!['video'] = 0;
      if (!_subjectActivityData[subject]!.containsKey('other')) _subjectActivityData[subject]!['other'] = 0;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Progress'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh progress data',
            onPressed: () {
              // Show a snackbar to indicate refresh is happening
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing progress data...')),
              );
              // Reload the progress data
              _loadProgressData();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/rainbow.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildProgressContent(),
      ),
    );
  }
  
  Widget _buildProgressContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter options
          _buildFilterOptions(),
          
          const SizedBox(height: 24),
          
          // Summary cards
          _buildSummaryCards(),
          
          const SizedBox(height: 24),
          
          // Activity type distribution chart
          _buildSectionHeader('Activity Type Distribution'),
          const SizedBox(height: 16),
          _buildActivityTypeDistributionChart(),
          
          const SizedBox(height: 24),
          
          // Combined activity-subject chart with filter
          _buildSectionHeader('Learning Activities by Subject'),
          const SizedBox(height: 8),
          _buildActivityTypeFilter(),
          const SizedBox(height: 16),
          _buildCombinedActivitySubjectChart(),
          
          const SizedBox(height: 24),
          
          // Subject performance chart
          _buildSectionHeader('Subject Performance'),
          const SizedBox(height: 16),
          _buildSubjectPerformanceChart(),
          
          const SizedBox(height: 24),
          
          // Study time chart
          _buildSectionHeader('Study Time Distribution'),
          const SizedBox(height: 16),
          _buildStudyTimeChart(),
          
          const SizedBox(height: 24),
          
          // Daily activity
          _buildSectionHeader('Daily Activity'),
          const SizedBox(height: 16),
          _buildDailyActivityChart(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
  
  Widget _buildActivityTypeDistributionChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Types',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: _getActivityTypeSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityTypeLegend(),
            const SizedBox(height: 8),
            _buildActivityTypeDetails(),
          ],
        ),
      ),
    );
  }
  
  List<PieChartSectionData> _getActivityTypeSections() {
    final Map<String, Color> typeColors = AppColors.getActivityTypeColorMap();
    
    final int total = _activityTypeCounts.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return [];
    
    return _activityTypeCounts.entries
      .where((entry) => entry.value > 0) // Only show types with values > 0
      .map((entry) {
        final type = entry.key;
        final count = entry.value;
        final percentage = count / total;
        
        return PieChartSectionData(
          color: typeColors[type] ?? Colors.grey,
          value: count.toDouble(),
          title: '${(percentage * 100).toStringAsFixed(1)}%',
          radius: 60,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        );
      }).toList();
  }
  
  Widget _buildActivityTypeLegend() {
    final Map<String, Color> typeColors = AppColors.getActivityTypeColorMap();
    
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: typeColors.entries
        .where((entry) => _activityTypeCounts[entry.key] != null && _activityTypeCounts[entry.key]! > 0)
        .map((entry) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                color: entry.value,
              ),
              const SizedBox(width: 4),
              Text(
                '${entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1)} (${_activityTypeCounts[entry.key] ?? 0})',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          );
        }).toList(),
    );
  }
  
  Widget _buildActivityTypeDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activity Breakdown:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(1.5),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('Count', style: TextStyle(fontWeight: FontWeight.bold)),
                const Text('% of Total', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            ..._activityTypeCounts.entries.map((entry) {
              final type = entry.key;
              final count = entry.value;
              final total = _activityTypeCounts.values.fold(0, (sum, count) => sum + count);
              final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) + '%' : '0%';
              
              return TableRow(
                children: [
                  Text(type.substring(0, 1).toUpperCase() + type.substring(1)),
                  Text('$count'),
                  Text(percentage),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const Text(
            'Time Period:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filterOptions.map((filter) {
              final isSelected = filter == _selectedFilter;
              
              // Get icon based on filter type
              IconData icon;
              switch (filter) {
                case 'Today':
                  icon = Icons.today;
                  break;
                case 'Yesterday':
                  icon = Icons.history;
                  break;
                case 'Last 7 Days':
                  icon = Icons.date_range;
                  break;
                case 'Last 30 Days':
                  icon = Icons.calendar_month;
                  break;
                default:
                  icon = Icons.calendar_today;
              }
              
              return InkWell(
                onTap: () {
                  if (_selectedFilter != filter) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    // Reload data when filter changes
                    _loadProgressData();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade700 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityTypeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 8),
            child: Text(
              'Activity Type:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: _activityTypeOptions.map((type) {
                final isSelected = _selectedActivityType == type;
                
                // Get icon and color based on activity type
                IconData icon;
                Color color;
                
                switch (type.toLowerCase()) {
                  case 'game':
                    icon = Icons.videogame_asset;
                    color = Colors.orange;
                    break;
                  case 'note':
                    icon = Icons.book;
                    color = Colors.blue;
                    break;
                  case 'video':
                    icon = Icons.play_circle_fill;
                    color = Colors.red;
                    break;
                  default: // All
                    icon = Icons.apps;
                    color = Colors.purple;
                }
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedActivityType = type;
                    });
                    _loadProgressData();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade300,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 16,
                          color: isSelected ? Colors.white : color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          type,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Points',
            value: _totalPoints.toString(),
            icon: Icons.star,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Study Time',
            value: '${_totalStudyMinutes} min',
            icon: Icons.timer,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Days Active',
            value: _daysActive.toString(),
            icon: Icons.calendar_today,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
  
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
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.purple.shade700,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubjectPerformanceChart() {
    if (_subjectScores.isEmpty) {
      return _buildEmptyDataMessage();
    }
    
    return Container(
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
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _subjectScores.values.fold(0.0, (max, value) => value > max ? value : max) * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.purple.shade100,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final subject = _subjectScores.keys.elementAt(groupIndex);
                return BarTooltipItem(
                  '$subject\n${rod.toY.toInt()} points',
                  const TextStyle(color: Colors.purple),
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
                  if (value >= _subjectScores.length || value < 0) return const Text('');
                  final subject = _subjectScores.keys.elementAt(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      subject.length > 10 ? '${subject.substring(0, 7)}...' : subject,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const Text('');
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _subjectScores.entries.map((entry) {
            final index = _subjectScores.keys.toList().indexOf(entry.key);
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value,
                  color: Colors.primaries[index % Colors.primaries.length],
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
  
  Widget _buildStudyTimeChart() {
    if (_studyMinutes.isEmpty) {
      return _buildEmptyDataMessage();
    }
    
    final List<PieChartSectionData> sections = [];
    int index = 0;
    
    for (final entry in _studyMinutes.entries) {
      final color = Colors.primaries[index % Colors.primaries.length];
      final percentage = _totalStudyMinutes > 0 
          ? entry.value / _totalStudyMinutes * 100 
          : 0;
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value.toDouble(),
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 100,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      
      index++;
    }
    
    return Column(
      children: [
        Container(
          height: 250,
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
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 40,
              sectionsSpace: 2,
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildChartLegend(),
      ],
    );
  }
  
  Widget _buildCombinedActivitySubjectChart() {
    if (_subjectActivityData.isEmpty) {
      return _buildEmptyDataMessage();
    }
    
    // Define colors for each activity type
    final Map<String, Color> activityColors = {
      'game': Colors.orange,
      'note': Colors.blue,
      'video': Colors.red,
      'other': Colors.grey,
    };
    
    // Filter subjects based on selected activity type
    List<String> subjects = _subjectActivityData.keys.toList();
    
    // Create bar groups for the chart
    final List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < subjects.length; i++) {
      final subject = subjects[i];
      final activityData = _subjectActivityData[subject]!;
      
      // Create rods for each activity type
      final List<BarChartRodData> rods = [];
      
      // If 'All' is selected, show all activity types
      if (_selectedActivityType == 'All') {
        // Create a list of activity types in a specific order for consistent display
        final orderedTypes = ['game', 'note', 'video', 'other'];
        
        // Add a rod for each activity type in order
        for (final activityType in orderedTypes) {
          final count = activityData[activityType] ?? 0;
          if (count > 0) { // Only add non-zero activities
            rods.add(
              BarChartRodData(
                toY: count.toDouble(),
                color: activityColors[activityType] ?? Colors.grey,
                width: 15,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
              ),
            );
          }
        }
      } else {
        // Show only the selected activity type
        final selectedType = _selectedActivityType.toLowerCase();
        final count = activityData[selectedType] ?? 0;
        
        if (count > 0) {
          rods.add(
            BarChartRodData(
              toY: count.toDouble(),
              color: activityColors[selectedType] ?? Colors.grey,
              width: 20,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          );
        }
      }
      
      // Only add the group if it has rods
      if (rods.isNotEmpty) {
        barGroups.add(
          BarChartGroupData(
            x: i,
            barRods: rods,
            showingTooltipIndicators: [0],
          ),
        );
      }
    }
    
    return Container(
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
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _getMaxActivityCount() * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.purple.shade100,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex < subjects.length) {
                        final subject = subjects[groupIndex];
                        String activityType = '';
                        
                        if (_selectedActivityType == 'All') {
                          // Determine which activity type this rod represents based on the rod index
                          // We're using the same order as in the chart creation
                          final orderedTypes = ['game', 'note', 'video', 'other'];
                          int typeIndex = 0;
                          int currentRodIndex = 0;
                          
                          // Find which activity type corresponds to this rod index
                          for (final type in orderedTypes) {
                            final count = _subjectActivityData[subject]![type] ?? 0;
                            if (count > 0) {
                              if (currentRodIndex == rodIndex) {
                                activityType = type;
                                break;
                              }
                              currentRodIndex++;
                            }
                          }
                        } else {
                          activityType = _selectedActivityType.toLowerCase();
                        }
                        
                        // Get friendly name for activity type
                        String typeName = '';
                        switch (activityType) {
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
                        
                        return BarTooltipItem(
                          '$subject\n$typeName: ${rod.toY.toInt()}',
                          const TextStyle(color: Colors.purple),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
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
                barGroups: barGroups,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: activityColors.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  // Helper method to get the maximum activity count for any subject
  double _getMaxActivityCount() {
    double maxCount = 0;
    
    if (_selectedActivityType == 'All') {
      // Find the maximum sum of all activity types for any subject
      for (final activityData in _subjectActivityData.values) {
        final sum = activityData.values.fold(0, (sum, count) => sum + count);
        if (sum > maxCount) {
          maxCount = sum.toDouble();
        }
      }
    } else {
      // Find the maximum count for the selected activity type
      final selectedType = _selectedActivityType.toLowerCase();
      for (final activityData in _subjectActivityData.values) {
        final count = activityData[selectedType] ?? 0;
        if (count > maxCount) {
          maxCount = count.toDouble();
        }
      }
    }
    
    return maxCount > 0 ? maxCount : 1; // Avoid returning 0 to prevent chart issues
  }
  
  Widget _buildActivityTypeChart() {
    if (_activityTypeCounts.isEmpty) {
      return _buildEmptyDataMessage();
    }
    
    // Define colors for each activity type
    final Map<String, Color> activityColors = {
      'game': Colors.orange,
      'note': Colors.blue,
      'video': Colors.red,
      'other': Colors.grey,
    };
    
    // Create sections for the pie chart
    final List<PieChartSectionData> sections = [];
    
    // Calculate total activities for percentage
    final int totalActivities = _activityTypeCounts.values.fold(0, (sum, count) => sum + count);
    
    // Create a section for each activity type
    _activityTypeCounts.forEach((type, count) {
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
    
    return Container(
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
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                startDegreeOffset: 180,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: activityColors.entries.map((entry) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.key.substring(0, 1).toUpperCase() + entry.key.substring(1),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChartLegend() {
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
        children: _studyMinutes.entries.map((entry) {
          final index = _studyMinutes.keys.toList().indexOf(entry.key);
          final color = Colors.primaries[index % Colors.primaries.length];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  '${entry.value} min',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildDailyActivityChart() {
    if (_progressData.isEmpty) {
      return _buildEmptyDataMessage();
    }
    
    // Group data by day
    final Map<String, int> dailyPoints = {};
    
    for (final data in _progressData) {
      final timestamp = data['timestamp'] as Timestamp?;
      if (timestamp != null) {
        final date = DateFormat('MM/dd').format(timestamp.toDate());
        final points = data['points'] as int? ?? 0;
        dailyPoints[date] = (dailyPoints[date] ?? 0) + points;
      }
    }
    
    // Sort by date
    final sortedDays = dailyPoints.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MM/dd').parse(a);
        final dateB = DateFormat('MM/dd').parse(b);
        return dateA.compareTo(dateB);
      });
    
    // Create line chart data
    final spots = <FlSpot>[];
    for (int i = 0; i < sortedDays.length; i++) {
      final day = sortedDays[i];
      final points = dailyPoints[day] ?? 0;
      spots.add(FlSpot(i.toDouble(), points.toDouble()));
    }
    
    return Container(
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
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.purple.shade100,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index >= 0 && index < sortedDays.length) {
                    final day = sortedDays[index];
                    return LineTooltipItem(
                      '$day: ${spot.y.toInt()} points',
                      const TextStyle(color: Colors.purple),
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= sortedDays.length || value < 0) {
                    return const Text('');
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      sortedDays[value.toInt()],
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.purple,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.purple.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyDataMessage() {
    return Container(
      height: 200,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No data available for this time period',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
