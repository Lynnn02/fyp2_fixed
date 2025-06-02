import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade300, Colors.blue.shade500],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar with subject selector
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.selectedSubjectName != null 
                            ? '${widget.selectedSubjectName} Leaderboard' 
                            : 'Leaderboard',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _loadLeaderboard,
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
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSubjectId,
                    dropdownColor: Colors.purple.shade700,
                    style: const TextStyle(color: Colors.white),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
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
                        child: Text('All Subjects', style: TextStyle(color: Colors.white)),
                      ),
                      ..._subjects.map((subject) => DropdownMenuItem(
                        value: subject.id,
                        child: Text(subject.name, style: const TextStyle(color: Colors.white)),
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
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // User avatar or rank badge
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getRankColor(_userRank),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _userRank > 0 ? _userRank.toString() : '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // User info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName ?? 'You',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your Rank: ${_userRank > 0 ? _userRank : 'Not Ranked'}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Points
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              _userPoints.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Top 3 podium
              if (!_isLoading && _leaderboard.isNotEmpty)
                SizedBox(
                  height: 180,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Confetti animation for user in top 3
                      if (_userRank <= 3 && _userRank > 0)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Lottie.network(
                              'https://assets1.lottiefiles.com/packages/lf20_u4yrau.json',
                              controller: _confettiController,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      
                      Row(
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
                    ],
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Leaderboard list
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
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
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Complete activities to earn points',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
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
                                
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCurrentUser ? Colors.blue.shade50 : null,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isCurrentUser
                                        ? Border.all(color: Colors.blue.shade200)
                                        : null,
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: _getRankColor(entry.rank),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          entry.rank.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      isCurrentUser ? 'You' : entry.userName,
                                      style: TextStyle(
                                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.star, color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            entry.totalPoints.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber.shade800,
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
              ),
            ],
          ),
        ),
      ),
    );
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
  
  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey.shade400;
    if (rank == 3) return Colors.brown.shade300;
    return Colors.blue.shade300;
  }
}
