import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as Math;

class ActivityCompletionScreen extends StatefulWidget {
  final String activityType; // 'game', 'note', 'video'
  final String activityName;
  final String subject;
  final int points;
  final int studyMinutes;
  final String userId;
  final VoidCallback? onContinue;
  final VoidCallback? onRestart;

  const ActivityCompletionScreen({
    Key? key,
    required this.activityType,
    required this.activityName,
    required this.subject,
    required this.points,
    required this.studyMinutes,
    required this.userId,
    this.onContinue,
    this.onRestart,
  }) : super(key: key);

  @override
  State<ActivityCompletionScreen> createState() => _ActivityCompletionScreenState();
}

class _ActivityCompletionScreenState extends State<ActivityCompletionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _completionPlayer = AudioPlayer();
  bool _isDataSaved = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    
    // Play sound
    _initAudio();
    
    // Start animation
    _controller.forward();
    
    // Save progress data
    _saveProgressData();
  }
  
  void _initAudio() async {
    await _completionPlayer.setSource(AssetSource('sounds/completion.mp3'));
    _completionPlayer.resume();
  }
  
  Future<void> _saveProgressData() async {
    if (_isDataSaved) return;
    
    try {
      // Look up the real student name from the profiles collection
      String realUserName = "";
      bool foundRealName = false;
      
      try {
        print('Looking up real name for user ID: ${widget.userId}');
        
        // First check the profiles collection for the real student name
        final profileDoc = await FirebaseFirestore.instance.collection('profiles').doc(widget.userId).get();
        if (profileDoc.exists) {
          final profileData = profileDoc.data();
          if (profileData != null) {
            // Try studentName field first (as shown in your Firebase screenshot)
            if (profileData.containsKey('studentName')) {
              final studentName = profileData['studentName'];
              if (studentName is String && studentName.isNotEmpty) {
                realUserName = studentName;
                foundRealName = true;
                print('Found real student name from profiles.studentName: $realUserName for user ID: ${widget.userId}');
              }
            }
            // Also try name field as fallback
            else if (profileData.containsKey('name')) {
              final name = profileData['name'];
              if (name is String && name.isNotEmpty) {
                realUserName = name;
                foundRealName = true;
                print('Found real student name from profiles.name: $realUserName for user ID: ${widget.userId}');
              }
            }
          }
        }
        
        // If still no real name found, check the users collection as a fallback
        if (!foundRealName) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
          if (userDoc.exists) {
            final userData = userDoc.data();
            if (userData != null) {
              // Try different possible fields for user names
              if (userData.containsKey('displayName')) {
                final displayName = userData['displayName'];
                if (displayName is String && displayName.isNotEmpty && 
                    !displayName.toLowerCase().contains('default') && 
                    displayName != 'Default User') {
                  realUserName = displayName;
                  foundRealName = true;
                  print('Found real name from users.displayName: $realUserName for user ID: ${widget.userId}');
                }
              } else if (userData.containsKey('name')) {
                final name = userData['name'];
                if (name is String && name.isNotEmpty && 
                    !name.toLowerCase().contains('default') && 
                    name != 'Default User') {
                  realUserName = name;
                  foundRealName = true;
                  print('Found real name from users.name: $realUserName for user ID: ${widget.userId}');
                }
              }
            }
          }
        }
        
        // If we still have a default user name, try one more approach - query by userId
        if (!foundRealName) {
          // Query profiles collection where userId field equals our userId
          final profilesQuery = await FirebaseFirestore.instance.collection('profiles')
              .where('userId', isEqualTo: widget.userId)
              .limit(1)
              .get();
          
          if (profilesQuery.docs.isNotEmpty) {
            final profileData = profilesQuery.docs.first.data();
            if (profileData.containsKey('studentName')) {
              final studentName = profileData['studentName'];
              if (studentName is String && studentName.isNotEmpty) {
                realUserName = studentName;
                foundRealName = true;
                print('Found real name from profiles query: $realUserName for user ID: ${widget.userId}');
              }
            }
          }
        }
      } catch (e) {
        print('Error looking up real student name: $e');
      }
      
      // If we still have a default user name, use a more descriptive generic name
      if (realUserName.isEmpty) {
        realUserName = 'Student ${widget.userId.substring(0, Math.min(4, widget.userId.length))}';
        print('Using generic name: $realUserName for user ID: ${widget.userId}');
      }
      
      // Create progress data with the real user name
      final progressData = {
        'userId': widget.userId,
        'userName': realUserName, // Add the real student name
        'subject': widget.subject,
        'chapterName': widget.activityName,
        'points': widget.points,
        'studyMinutes': widget.studyMinutes,
        'timestamp': Timestamp.now(),
        'activityType': widget.activityType,
      };
      
      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('progress')
          .add(progressData);
      
      setState(() {
        _isDataSaved = true;
      });
      
      print('Progress saved to Firestore with real name: $progressData');
    } catch (e) {
      print('Error saving progress to Firestore: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _completionPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine star count based on points
    int starCount = 0;
    if (widget.points >= 80) {
      starCount = 5;
    } else if (widget.points >= 60) {
      starCount = 4;
    } else if (widget.points >= 40) {
      starCount = 3;
    } else if (widget.points >= 20) {
      starCount = 2;
    } else {
      starCount = 1;
    }
    
    // Get motivational message based on star count
    String message = '';
    switch (starCount) {
      case 5:
        message = 'Excellent job! You\'re a superstar!';
        break;
      case 4:
        message = 'Great work! Keep it up!';
        break;
      case 3:
        message = 'Good job! You\'re making progress!';
        break;
      case 2:
        message = 'Nice effort! Keep practicing!';
        break;
      case 1:
        message = 'Good try! You\'ll do better next time!';
        break;
    }

    // Use a Stack with a GestureDetector to capture all touch events
    return Stack(
      children: [
        // Modal barrier to block touches to underlying content
        Positioned.fill(
          child: GestureDetector(
            onTap: () {}, // Empty onTap to capture taps
            behavior: HitTestBehavior.opaque, // Important: ensures all taps are captured
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
        ),
        // Actual completion screen
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Completion header
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            widget.activityType == 'game' ? Icons.sports_esports :
                            widget.activityType == 'note' ? Icons.note :
                            Icons.video_library,
                            color: Colors.purple.shade700,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Activity Completed!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stars
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < starCount ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Motivational message
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildStatRow(
                          icon: Icons.star,
                          label: 'Points Earned',
                          value: '${widget.points}',
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          icon: Icons.timer,
                          label: 'Study Time',
                          value: '${widget.studyMinutes} min',
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 8),
                        _buildStatRow(
                          icon: Icons.book,
                          label: 'Subject',
                          value: widget.subject,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (widget.onRestart != null)
                        ElevatedButton.icon(
                          onPressed: widget.onRestart,
                          icon: const Icon(Icons.replay),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: widget.onContinue ?? () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
