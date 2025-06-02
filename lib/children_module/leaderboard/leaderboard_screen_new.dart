import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/score.dart';
import '../../models/subject.dart';
import '../../services/score_service.dart';
import '../../services/content_service.dart';

class LeaderboardScreen extends StatefulWidget {
  final String? userId;
  final String? userName;
  final int ageGroup;
  final String? selectedSubjectId;
  final String? selectedSubjectName;

  const LeaderboardScreen({
    Key? key,
    this.userId,
    this.userName,
    required this.ageGroup,
    this.selectedSubjectId,
    this.selectedSubjectName,
  }) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final ScoreService _scoreService = ScoreService();
  final ContentService _contentService = ContentService();
  
  String _selectedSubjectId = 'all';
  String _selectedSubjectName = 'All Subjects';
  List<Subject> _subjects = [];
  bool _isLoading = true;
  List<LeaderboardEntry> _leaderboard = [];
  int _userRank = 0;
  int _userPoints = 0;
  
  @override
  void initState() {
    super.initState();
    
    // If a specific subject is selected, use that
    if (widget.selectedSubjectId != null) {
      _selectedSubjectId = widget.selectedSubjectId!;
      if (widget.selectedSubjectName != null) {
        _selectedSubjectName = widget.selectedSubjectName!;
      }
    }
    
    _loadSubjects();
    _loadLeaderboard();
  }
  
  Future<void> _loadSubjects() async {
    try {
      // Get subjects for the age group
      _contentService.getSubjectsByAge(widget.ageGroup).listen((subjects) {
        if (mounted) {
          setState(() {
            _subjects = subjects;
          });
        }
      });
    } catch (e) {
      print('Error loading subjects: $e');
    }
  }
  
  Future<void> _loadLeaderboard() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      List<LeaderboardEntry> leaderboard;
      
      if (_selectedSubjectId == 'all') {
        // Load global leaderboard for age group
        leaderboard = await _scoreService.getAgeGroupLeaderboard(widget.ageGroup);
      } else {
        // Load subject-specific leaderboard
        leaderboard = await _scoreService.getSubjectLeaderboard(_selectedSubjectId);
      }
      
      // Find user's rank and points
      int userRank = 0;
      int userPoints = 0;
      
      if (widget.userId != null) {
        final userEntry = leaderboard.firstWhere(
          (entry) => entry.userId == widget.userId,
          orElse: () => LeaderboardEntry(
            userId: widget.userId!,
            userName: widget.userName ?? 'You',
            totalPoints: 0,
            rank: leaderboard.length + 1,
            ageGroup: widget.ageGroup,
          ),
        );
        
        userRank = userEntry.rank;
        userPoints = userEntry.totalPoints;
      }
      
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
          _userRank = userRank;
          _userPoints = userPoints;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading leaderboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _changeSubject(String subjectId, String subjectName) {
    setState(() {
      _selectedSubjectId = subjectId;
      _selectedSubjectName = subjectName;
    });
    _loadLeaderboard();
  }
  
  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.orange.shade300; // Gold
    if (rank == 2) return Colors.blue.shade300;   // Silver-blue
    if (rank == 3) return Colors.green.shade300;  // Bronze-green
    if (rank <= 6) return Colors.orange.shade200; // Lower ranks
    return Colors.grey.shade300;                 // Everyone else
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // Sky blue background
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade200,
              Colors.lightBlue.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with cloud decorations
              Stack(
                children: [
                  // Cloud decorations
                  Positioned(
                    top: 5,
                    left: 20,
                    child: _buildCloud(60),
                  ),
                  Positioned(
                    top: 0,
                    right: 30,
                    child: _buildCloud(80),
                  ),
                  
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'LEADERBOARD',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          shadows: [
                            Shadow(
                              offset: const Offset(2, 2),
                              blurRadius: 3.0,
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Subject selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedSubjectId,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.blue),
                    underline: Container(height: 0),
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        String subjectName = 'All Subjects';
                        if (newValue != 'all') {
                          final subject = _subjects.firstWhere(
                            (s) => s.id == newValue,
                            orElse: () => Subject(
                              id: newValue,
                              name: 'Subject',
                              chapters: [],
                              createdAt: Timestamp.now(),
                              moduleId: widget.ageGroup,
                            ),
                          );
                          subjectName = subject.name;
                        }
                        _changeSubject(newValue, subjectName);
                      }
                    },
                    items: [
                      DropdownMenuItem<String>(
                        value: 'all',
                        child: const Text('All Subjects'),
                      ),
                      ..._subjects.map((Subject subject) {
                        return DropdownMenuItem<String>(
                          value: subject.id,
                          child: Text(subject.name),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              
              // Rainbow decoration on the side
              Positioned(
                bottom: 0,
                right: 0,
                child: _buildRainbow(200),
              ),
              
              // Leaderboard content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _leaderboard.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  size: 80,
                                  color: Colors.amber.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No scores yet!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Complete activities to earn points',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _leaderboard.length + 1, // +1 for user's rank at bottom
                            itemBuilder: (context, index) {
                              // Last item shows the user's rank
                              if (index == _leaderboard.length) {
                                return Container(
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          widget.userId != null
                                              ? 'YOU ARE ${_userRank}${_getOrdinalSuffix(_userRank)}'
                                              : 'Sign in to see your rank',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      if (widget.userId != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.white, size: 16),
                                              const SizedBox(width: 4),
                                              Text(
                                                _userPoints.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }
                              
                              final entry = _leaderboard[index];
                              final isCurrentUser = widget.userId != null && entry.userId == widget.userId;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Colors.blue.shade100
                                      : Colors.white.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _getRankColor(entry.rank),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: entry.rank <= 3
                                          ? Icon(
                                              Icons.star,
                                              color: Colors.white,
                                              size: entry.rank == 1 ? 24 : 20,
                                            )
                                          : Text(
                                              entry.rank.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ),
                                  ),
                                  title: Text(
                                    isCurrentUser ? 'YOU' : entry.userName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                      fontSize: entry.rank <= 3 ? 18 : 16,
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star, color: Colors.white, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          entry.totalPoints.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCloud(double size) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(size / 2),
      ),
    );
  }
  
  Widget _buildRainbow(double size) {
    return Image.asset(
      'assets/rainbow.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
  
  String _getOrdinalSuffix(int rank) {
    if (rank >= 11 && rank <= 13) {
      return 'th';
    }
    
    switch (rank % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
}

class RainbowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.red.shade300,
      Colors.orange.shade300,
      Colors.yellow.shade300,
      Colors.green.shade300,
      Colors.blue.shade300,
    ];
    
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    for (int i = 0; i < colors.length; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20;
      
      canvas.drawArc(
        rect.deflate(i * 40),
        3.14, // Start angle (PI radians = 180 degrees)
        3.14 / 2, // Sweep angle (PI/2 radians = 90 degrees)
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
