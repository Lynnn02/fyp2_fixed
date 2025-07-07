import 'package:flutter/material.dart';
import '../../models/subject.dart';
import '../../services/content_service.dart';
import 'leaderboard_screen_redesign.dart';

class LeaderboardNavigation extends StatefulWidget {
  final String userId;
  final String userName;
  final int ageGroup;

  const LeaderboardNavigation({
    Key? key,
    required this.userId,
    required this.userName,
    required this.ageGroup,
  }) : super(key: key);

  @override
  State<LeaderboardNavigation> createState() => _LeaderboardNavigationState();
}

class _LeaderboardNavigationState extends State<LeaderboardNavigation> {
  final ContentService _contentService = ContentService();
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Listen to the stream and update subjects when data arrives
      _contentService.getSubjectsByAge(widget.ageGroup).listen((subjects) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }, onError: (e) {
        print('Error in subjects stream: $e');
        setState(() {
          _isLoading = false;
        });
      });
    } catch (e) {
      print('Error setting up subjects stream: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB066F2), Color(0xFF4A91F5)],
          ),
          image: DecorationImage(
            image: AssetImage('assets/rainbow.png'),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Leaderboards',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadSubjects,
                    ),
                  ],
                ),
              ),

              // Content area with cards
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          // Global leaderboard card
                          _buildLeaderboardCard(
                            title: 'Global Leaderboard',
                            subtitle: 'See how you rank against all students',
                            icon: Icons.emoji_events,
                            iconBgColor: const Color(0xFFFFF3D6),
                            iconColor: Colors.amber,
                            onTap: () => _navigateToLeaderboard('all'),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Subject leaderboards header
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
                            child: Text(
                              'Subject Leaderboards',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          
                          // Subject leaderboard cards
                          ..._subjects.map((subject) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildLeaderboardCard(
                              title: subject.name,
                              subtitle: 'See your ranking in ${subject.name}',
                              icon: _getSubjectIcon(_subjects.indexOf(subject)),
                              iconBgColor: _getSubjectIconBgColor(subject.name),
                              iconColor: _getSubjectIconColor(subject.name),
                              onTap: () => _navigateToLeaderboard(subject.id),
                            ),
                          )),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build a card for leaderboard navigation
  Widget _buildLeaderboardCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon with background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Navigate to the appropriate leaderboard screen
  void _navigateToLeaderboard(String subjectId) {
    // Get the studentID from profiles if available, otherwise use userId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeaderboardScreen(
          userId: widget.userId,
          userName: widget.userName,
          studentId: widget.userId, // Pass the studentId separately
          ageGroup: widget.ageGroup,
          selectedSubjectId: subjectId == 'all' ? null : subjectId,
          selectedSubjectName: subjectId == 'all' ? 'Global' : _subjects.firstWhere((s) => s.id == subjectId).name,
        ),
      ),
    );
  }

  // Get background color for subject icon based on subject name
  Color _getSubjectIconBgColor(String subjectName) {
    final Map<String, Color> bgColors = {
      'Math': const Color(0xFFE1F5FE),
      'Science': const Color(0xFFE8F5E9),
      'English': const Color(0xFFFFF3E0),
      'History': const Color(0xFFF3E5F5),
      'Art': const Color(0xFFFFEBEE),
      'Music': const Color(0xFFE0F2F1),
    };
    
    // Try to match by subject name, otherwise use a default
    for (final entry in bgColors.entries) {
      if (subjectName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    // Default background color if no match
    return const Color(0xFFE1F5FE);
  }

  // Get icon color for subject based on subject name
  Color _getSubjectIconColor(String subjectName) {
    final Map<String, Color> iconColors = {
      'Math': Colors.blue,
      'Science': Colors.green,
      'English': Colors.blue,
      'History': Colors.purple,
      'Art': Colors.red,
      'Music': Colors.teal,
    };
    
    // Try to match by subject name, otherwise use a default
    for (final entry in iconColors.entries) {
      if (subjectName.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    // Default icon color if no match
    return Colors.blue;
  }

  Color _getSubjectColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _getSubjectIcon(int index) {
    final icons = [
      Icons.book,
      Icons.science,
      Icons.calculate,
      Icons.language,
      Icons.history_edu,
      Icons.sports_soccer,
    ];
    return icons[index % icons.length];
  }
}
