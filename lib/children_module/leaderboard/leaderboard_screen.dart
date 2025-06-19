import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import '../../models/score.dart';
import '../../models/subject.dart';
import '../../services/score_service.dart';
import '../../services/content_service.dart';
import 'dart:math' as math;

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

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  final ScoreService _scoreService = ScoreService();
  final ContentService _contentService = ContentService();
  
  late TabController _tabController;
  String _selectedSubjectId = 'all';
  List<Subject> _subjects = [];
  bool _isLoading = true;
  List<LeaderboardEntry> _leaderboard = [];
  int _userRank = 0;
  int _userPoints = 0;
  
  // Animation controllers
  late AnimationController _confettiController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    // If a specific subject is selected, use that
    if (widget.selectedSubjectId != null) {
      _selectedSubjectId = widget.selectedSubjectId!;
    }
    
    _loadSubjects();
    _loadLeaderboard();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
  
  Future<void> _loadSubjects() async {
    try {
      // Listen to the stream and update subjects when data arrives
      _contentService.getSubjectsByAge(widget.ageGroup).listen((subjects) {
        setState(() {
          _subjects = subjects;
        });
      }, onError: (e) {
        print('Error in subjects stream: $e');
      });
    } catch (e) {
      print('Error setting up subjects stream: $e');
    }
  }
  
  Future<void> _loadLeaderboard() async {
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
        
        // If user is in top 3, play confetti animation
        if (userRank <= 3 && userRank > 0) {
          _confettiController.forward(from: 0);
        }
      }
      
      setState(() {
        _leaderboard = leaderboard;
        _userRank = userRank;
        _userPoints = userPoints;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading leaderboard: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade100,
      body: Container(
        decoration: const BoxDecoration(
          // Rainbow background image
          image: DecorationImage(
            image: AssetImage('assets/rainbow.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar with title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'LEADERBOARD',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [Shadow(color: Colors.white, blurRadius: 2)],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              
              // Subject selector (only show if not coming from subject navigation)
              if (widget.selectedSubjectId == null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSubjectId,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    isExpanded: true,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSubjectId = value;
                        });
                        _loadLeaderboard();
                      }
                    },
                    items: [
                      const DropdownMenuItem(
                        value: 'all',
                        child: Text('All Subjects', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                      ..._subjects.map((subject) => DropdownMenuItem(
                        value: subject.id,
                        child: Text(subject.name, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      )),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // User's stats card
              if (widget.userId != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade300,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      // Star icon
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // User info
                      Expanded(
                        child: Text(
                          'YOU',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      
                      // Points
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            _userPoints.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Top 3 podium section
              if (!_isLoading && _leaderboard.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // 2nd place
                      if (_leaderboard.length >= 2)
                        _buildPodiumItem(
                          _leaderboard[1],
                          height: 120,
                          isSecond: true,
                        ),
                      
                      // 1st place
                      if (_leaderboard.isNotEmpty)
                        _buildPodiumItem(
                          _leaderboard[0],
                          height: 150,
                          isFirst: true,
                        ),
                      
                      // 3rd place
                      if (_leaderboard.length >= 3)
                        _buildPodiumItem(
                          _leaderboard[2],
                          height: 100,
                          isThird: true,
                        ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // "YOU ARE 1st" text at bottom (only show if user is in top 3)
              if (widget.userId != null && _userRank <= 3 && _userRank > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    'YOU ARE ${_userRank}${_getOrdinalSuffix(_userRank)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()..shader = LinearGradient(
                        colors: const [Colors.purple, Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                    ),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Leaderboard list
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _leaderboard.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey.shade400),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No scores yet!',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(top: 8),
                              itemCount: _leaderboard.length,
                              itemBuilder: (context, index) {
                                final entry = _leaderboard[index];
                                final isCurrentUser = widget.userId != null && entry.userId == widget.userId;
                                
                                // Skip top 3 as they're shown in the podium
                                if (index < 3) return const SizedBox.shrink();
                                
                                // Highlight current user's row with green background
                                final backgroundColor = isCurrentUser ? Colors.green.shade300 : Colors.transparent;
                                
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      // Rank number
                                      SizedBox(
                                        width: 30,
                                        child: Text(
                                          entry.rank.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      
                                      // Name
                                      Expanded(
                                        child: Text(
                                          isCurrentUser ? 'You' : entry.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      
                                      // Points
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
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
  
  // New method for building podium profile pictures
  Widget _buildPodiumProfile(LeaderboardEntry entry, {
    required int rank,
    required double size,
  }) {
    return Column(
      children: [
        // Rank badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: rank == 1 ? Colors.amber : rank == 2 ? Colors.grey.shade300 : Colors.brown.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            rank.toString(),
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        
        // Profile picture
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getProfileColor(entry.userName),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Text(
              entry.userName.isNotEmpty ? entry.userName[0].toUpperCase() : '?',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: size * 0.4,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Name
        Text(
          entry.userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  // Helper method to build bottom navigation item
  Widget _buildNavItem(IconData icon, String label, {required bool isSelected}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isSelected ? Colors.amber : Colors.grey,
          size: 24,
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.amber : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  // Helper method to get profile color based on name
  Color _getProfileColor(String name) {
    if (name.isEmpty) return Colors.grey;
    
    // Generate a consistent color based on the name
    final int hashCode = name.hashCode;
    final List<Color> colors = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.purple.shade400,
      Colors.orange.shade400,
      Colors.pink.shade400,
      Colors.teal.shade400,
    ];
    
    return colors[hashCode.abs() % colors.length];
  }
  
  Widget _buildPodiumItem(LeaderboardEntry entry, {
    required double height,
    bool isFirst = false,
    bool isSecond = false,
    bool isThird = false,
  }) {
    final isCurrentUser = widget.userId != null && entry.userId == widget.userId;
    
    Color podiumColor;
    IconData trophyIcon;
    
    if (isFirst) {
      podiumColor = Colors.amber;
      trophyIcon = Icons.emoji_events;
    } else if (isSecond) {
      podiumColor = Colors.grey.shade300;
      trophyIcon = Icons.emoji_events;
    } else {
      podiumColor = Colors.brown.shade300;
      trophyIcon = Icons.emoji_events;
    }
    
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // User avatar
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrentUser ? Colors.blue : Colors.white,
              border: Border.all(
                color: podiumColor,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: isFirst ? 30 : 25,
              backgroundColor: podiumColor.withOpacity(0.3),
              child: Icon(
                trophyIcon,
                color: podiumColor,
                size: isFirst ? 30 : 24,
              ),
            ),
          ),
          const SizedBox(height: 4),
          
          // Username
          Text(
            isCurrentUser ? 'You' : entry.userName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: isFirst ? 14 : 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          
          // Points
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 12),
                const SizedBox(width: 2),
                Text(
                  entry.totalPoints.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
          
          // Podium
          Container(
            height: height,
            decoration: BoxDecoration(
              color: podiumColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Center(
              child: Text(
                entry.rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to get ordinal suffix (1st, 2nd, 3rd, etc.)
  String _getOrdinalSuffix(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return 'th';
    }
    
    switch (number % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }
  
  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.brown.shade300;
    return Colors.blue.shade300;
  }
}
