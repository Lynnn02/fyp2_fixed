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
    if (rank == 2) return Colors.blue.shade400;   // Blue
    if (rank == 3) return Colors.green.shade400;  // Green
    return Colors.orange.shade200;                // Lower ranks
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Rainbow background image
          image: DecorationImage(
            image: AssetImage('assets/rainbow.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              
              // Cloud decorations
              Positioned(
                top: 10,
                left: 10,
                child: _buildCloud(60),
              ),
              
              Positioned(
                top: 5,
                right: 20,
                child: _buildCloud(80),
              ),
              
              Column(
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
                            : Column(
                                children: [
                                  // Top players list
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      itemCount: _leaderboard.length > 6 ? 6 : _leaderboard.length,
                                      itemBuilder: (context, index) {
                                        final entry = _leaderboard[index];
                                        final isCurrentUser = widget.userId != null && entry.userId == widget.userId;
                                        
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 8),
                                          child: _buildRankItem(
                                            entry, 
                                            isCurrentUser,
                                            index < 3, // Show star for top 3
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  
                                  // User's rank at bottom with kid-friendly style
                                  if (widget.userId != null)
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Center(
                                        child: Stack(
                                          children: [
                                            // Shadow effect
                                            Text(
                                              'YOU ARE ${_userRank}${_getOrdinalSuffix(_userRank)}',
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black.withOpacity(0.3),
                                                fontFamily: 'Comic Sans MS',
                                                letterSpacing: 1.5,
                                              ),
                                            ),
                                            // Main text with colorful gradient
                                            ShaderMask(
                                              shaderCallback: (bounds) => LinearGradient(
                                                colors: [
                                                  Colors.purple.shade300,
                                                  Colors.blue.shade400,
                                                  Colors.green.shade400,
                                                  Colors.yellow.shade400,
                                                  Colors.orange.shade400,
                                                  Colors.red.shade400,
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ).createShader(bounds),
                                              child: Text(
                                                'YOU ARE ${_userRank}${_getOrdinalSuffix(_userRank)}',
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontFamily: 'Comic Sans MS',
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                            ),
                                          ],
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
      ),
    );
  }
  
  Widget _buildRankItem(LeaderboardEntry entry, bool isCurrentUser, bool showStar) {
    final rank = entry.rank;
    final color = _getRankColor(rank);
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          // Rank number with star
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: showStar 
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 40),
                      Text(
                        rank.toString(),
                        style: TextStyle(
                          color: Colors.amber.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  )
                : Text(
                    rank.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
            ),
          ),
          
          // Player name
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                isCurrentUser ? 'YOU' : entry.userName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          
          // Points
          Container(
            margin: const EdgeInsets.only(right: 8),
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
        ],
      ),
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
}
