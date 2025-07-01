import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import '../../widgets/admin_scaffold.dart';

// Data models for analytics
class TimeSeriesData {
  final DateTime date;
  final int sessions;

  TimeSeriesData(this.date, this.sessions);
}

class SessionDuration {
  final String name;
  final int count;
  final double percentage;
  final Color color;

  SessionDuration(this.name, this.count, this.percentage, this.color);
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
  _AnalyticScreenState createState() => _AnalyticScreenState();
}

class _AnalyticScreenState extends State<AnalyticScreen> with SingleTickerProviderStateMixin {
  // Tab controller
  late TabController _tabController;
  final List<String> _tabs = ['General']; // Keep only General tab
  int currentTabIndex = 0;

  // Firestore references
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Analytics data
  bool _isLoading = true;
  int _totalSessions = 0;
  int _totalExercises = 0;
  int _activeUsers = 0;
  int _totalUsers = 0;
  int _newUsers = 0;
  double _averageScore = 0.0;
  double _averageSessionTime = 0.0;
  
  // Session duration metrics
  int _under5Min = 0;
  int _between5And10Min = 0;
  int _between10And20Min = 0;
  int _over20Min = 0;
  
  // Time series data
  List<TimeSeriesData> _sessionData = [];
  
  // Filters
  String? _selectedStudentId;
  List<DropdownMenuItem<String>> _studentOptions = [];
  String _selectedAgeGroup = 'All Ages';
  
  // Completion rate
  double _completionRate = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          currentTabIndex = _tabController.index;
        });
      }
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load all analytics data
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadScoreData();
    setState(() {
      _isLoading = false;
    });
  }
  
  // Load score data
  Future<void> _loadScoreData() async {
    try {
      // Create query
      Query query = _firestore.collection('scores')
          .orderBy('timestamp', descending: true);
      
      // Execute query
      QuerySnapshot querySnapshot = await query.get();
      
      // Get raw documents
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      
      // Apply filters in memory (client-side)
      if (_selectedStudentId != null && _selectedStudentId!.isNotEmpty) {
        docs = docs.where((doc) => doc['userId'] == _selectedStudentId).toList();
      }
      
      // Process the filtered data
      await _processFilteredScoresData(docs);
      
    } catch (error) {
      print('Error loading score data: $error');
    }
  }
  
  // Process filtered score data
  Future<void> _processFilteredScoresData(List<QueryDocumentSnapshot> docs) async {
    if (docs.isEmpty) {
      setState(() {
        _totalSessions = 0;
        _averageScore = 0.0;
        _averageSessionTime = 0.0;
        _under5Min = 0;
        _between5And10Min = 0;
        _between10And20Min = 0;
        _over20Min = 0;
        _sessionData = [];
        _completionRate = 0.0;
      });
      return;
    }
    
    // Calculate analytics metrics
    int totalSessions = docs.length;
    double totalScore = 0.0;
    double totalDuration = 0.0;
    int under5 = 0;
    int between5And10 = 0;
    int between10And20 = 0;
    int over20 = 0;
    int totalExercises = 0;
    int completedSessions = 0;
    Set<String> uniqueUserIds = {};
    
    // Create date range for last 14 days
    List<DateTime> dateRange = _createDateRange();
    Map<String, int> sessionsByDate = {};
    
    // Initialize the date map
    for (var date in dateRange) {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      sessionsByDate[dateStr] = 0;
    }
    
    // Process each score document
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      
      // Count unique users
      if (data['userId'] != null) {
        uniqueUserIds.add(data['userId'].toString());
      }
      
      // Sum up scores
      if (data['score'] != null) {
        double score = data['score'] is int 
          ? (data['score'] as int).toDouble()
          : (data['score'] as double? ?? 0.0);
        totalScore += score;
      }
      
      // Count exercises
      if (data['exercisesCompleted'] != null) {
        totalExercises += (data['exercisesCompleted'] as int? ?? 0);
      }
      
      // Count completed sessions
      if (data['completed'] == true) {
        completedSessions++;
      }
      
      // Calculate session duration
      if (data['timestamp'] != null && data['endTimestamp'] != null) {
        final start = (data['timestamp'] as Timestamp).toDate();
        final end = (data['endTimestamp'] as Timestamp).toDate();
        final duration = end.difference(start).inSeconds;
        totalDuration += duration;
        
        // Add to date series data
        final dateStr = DateFormat('yyyy-MM-dd').format(start);
        sessionsByDate[dateStr] = (sessionsByDate[dateStr] ?? 0) + 1;
        
        // Categorize by duration
        if (duration < 5 * 60) { // less than 5 minutes
          under5++;
        } else if (duration < 10 * 60) { // 5-10 minutes
          between5And10++;
        } else if (duration < 20 * 60) { // 10-20 minutes
          between10And20++;
        } else { // over 20 minutes
          over20++;
        }
      }
    }
    
    // Generate time series data
    List<TimeSeriesData> timeSeriesData = [];
    for (var date in dateRange) {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final sessions = sessionsByDate[dateStr] ?? 0;
      timeSeriesData.add(TimeSeriesData(date, sessions));
    }
    
    // Update state with processed data
    setState(() {
      _totalSessions = totalSessions;
      _totalExercises = totalExercises;
      _activeUsers = uniqueUserIds.length;
      _averageScore = totalScore / math.max(totalSessions, 1);
      _averageSessionTime = totalDuration / math.max(totalSessions, 1);
      _under5Min = under5;
      _between5And10Min = between5And10;
      _between10And20Min = between10And20;
      _over20Min = over20;
      _sessionData = timeSeriesData;
      _completionRate = totalSessions > 0 ? completedSessions / totalSessions * 100 : 0;
    });
  }
  
  // Create a date range for the last 14 days
  List<DateTime> _createDateRange() {
    List<DateTime> dateRange = [];
    final now = DateTime.now();
    for (int i = 13; i >= 0; i--) {
      dateRange.add(DateTime(now.year, now.month, now.day - i));
    }
    return dateRange;
  }
  
  // Build section header for graph sections
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  // Build metric card for dashboard
  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build card container
  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
  
  // Build date range selector
  Widget _buildDateRangeSelector() {
    return _buildCard(
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.blue),
          const SizedBox(width: 16),
          Text(
            'Last 14 Days',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.tune),
            label: Text('Change Range'),
          ),
        ],
      ),
    );
  }
  
  // Build General Analytics Tab
  Widget _buildGeneralAnalyticsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width < 600 ? 16.0 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary metrics row
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Analytics Overview'),
                const SizedBox(height: 16),
                
                MediaQuery.of(context).size.width < 600
                  ? Column(
                      children: [
                        _buildMetricCard('Total Users', _totalUsers.toString(), Icons.people, Colors.blue),
                        const SizedBox(height: 16),
                        _buildMetricCard('Active Users', _activeUsers.toString(), Icons.person, Colors.green),
                        const SizedBox(height: 16),
                        _buildMetricCard('Sessions', _totalSessions.toString(), Icons.calendar_today, Colors.amber),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard('Total Users', _totalUsers.toString(), Icons.people, Colors.blue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard('Active Users', _activeUsers.toString(), Icons.person, Colors.green),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildMetricCard('Sessions', _totalSessions.toString(), Icons.calendar_today, Colors.amber),
                        ),
                      ],
                    ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Activity trend chart
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Activity Trend'),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 300,
                  child: _buildLineChart(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Main build method for the analytics screen
  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Analytics',
      selectedIndex: widget.selectedIndex,
      onNavigate: widget.onNavigate,
      body: _isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : _buildGeneralAnalyticsTab(),
    );
  }
  
  // Build line chart for activity trends
  Widget _buildLineChart() {
    if (_sessionData.isEmpty) {
      return const Center(child: Text('No data available'));
    }
    
    // Find max value for y-axis scaling
    final maxYValue = _sessionData.map((data) => data.sessions).reduce(math.max) + 2;
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < _sessionData.length) {
                  final date = _sessionData[value.toInt()].date;
                  final dateStr = DateFormat('dd/MM').format(date);
                  return Transform.rotate(
                    angle: 45 * 3.1415927 / 180,
                    child: Text(dateStr, style: const TextStyle(fontSize: 10)),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!),
        ),
        minX: 0,
        maxX: _sessionData.length.toDouble() - 1,
        minY: 0,
        maxY: maxYValue.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(_sessionData.length, (index) {
              return FlSpot(index.toDouble(), _sessionData[index].sessions.toDouble());
            }),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}