import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math' as Math;

class ActivityCompletionScreen extends StatefulWidget {
  final String activityType; // 'game', 'note', 'video'
  final String activityName;
  final String subject;
  final int points; // Will be overridden for notes and videos
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
      // First, check if this is a default userId and try to get the real userId from profiles
      String actualUserId = widget.userId;
      
      if (widget.userId == 'default_user' || widget.userId.isEmpty) {
        // Try to get the current authenticated user
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          actualUserId = currentUser.uid;
          print('Using authenticated user ID instead of default_user: $actualUserId');
        }
      }
      
      // Look up the real student name from the profiles collection
      String realUserName = "";
      bool foundRealName = false;
        
      try {
        print('Looking up real name for user ID: $actualUserId');
        
        // First check the profiles collection for the real student name
        final profileDoc = await FirebaseFirestore.instance.collection('profiles').doc(actualUserId).get();
        if (profileDoc.exists) {
          final profileData = profileDoc.data();
          if (profileData != null) {
            // Try studentName field first (as shown in your Firebase screenshot)
            if (profileData.containsKey('studentName')) {
              final studentName = profileData['studentName'];
              if (studentName is String && studentName.isNotEmpty) {
                realUserName = studentName;
                foundRealName = true;
                print('Found real student name from profiles.studentName: $realUserName for user ID: $actualUserId');
              }
            }
            // Also try name field as fallback
            else if (profileData.containsKey('name')) {
              final name = profileData['name'];
              if (name is String && name.isNotEmpty) {
                realUserName = name;
                foundRealName = true;
                print('Found real student name from profiles.name: $realUserName for user ID: $actualUserId');
              }
            }
          }
        }
        
        // If still no real name found, check the users collection as a fallback
        if (!foundRealName) {
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(actualUserId).get();
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
                  print('Found real name from users.displayName: $realUserName for user ID: $actualUserId');
                }
              } else if (userData.containsKey('name')) {
                final name = userData['name'];
                if (name is String && name.isNotEmpty && 
                    !name.toLowerCase().contains('default') && 
                    name != 'Default User') {
                  realUserName = name;
                  foundRealName = true;
                  print('Found real name from users.name: $realUserName for user ID: $actualUserId');
                }
              }
            }
          }
        }
        
        // If we still have a default user name, try one more approach - query by userId
        if (!foundRealName) {
          // Query profiles collection where userId field equals our userId
          final profilesQuery = await FirebaseFirestore.instance.collection('profiles')
              .where('userId', isEqualTo: actualUserId)
              .limit(1)
              .get();
          
          if (profilesQuery.docs.isNotEmpty) {
            final profileData = profilesQuery.docs.first.data();
            if (profileData.containsKey('studentName')) {
              final studentName = profileData['studentName'];
              if (studentName is String && studentName.isNotEmpty) {
                realUserName = studentName;
                foundRealName = true;
                print('Found real name from profiles query: $realUserName for user ID: $actualUserId');
              }
            }
          }
        }
      } catch (e) {
        print('Error looking up real student name: $e');
      }
      
      // If we still have a default user name, use a more descriptive generic name
      if (realUserName.isEmpty) {
        realUserName = 'Student ${actualUserId.substring(0, Math.min(4, actualUserId.length))}';
        print('Using generic name: $realUserName for user ID: $actualUserId');
      }
      
      // Create progress data with the real user name
      final progressData = {
        'userId': actualUserId, // Use the actual userId, not default_user
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
    // Always show 5 stars for notes and video activities
    // For games, determine star count based on points
    late int starCount;
    late int displayPoints;
    late String message;
    late Color primaryColor;
    late Color secondaryColor;
    
    // Calculate stars, points, and colors based on activity type
    if (widget.activityType == 'game') {
      // For games, calculate stars based on actual points
      int points = widget.points;
      starCount = (points / 10).round().clamp(0, 5);
      displayPoints = points;
      primaryColor = Colors.indigo;
      secondaryColor = Colors.indigo[100]!;
      
      if (starCount >= 4) {
        message = 'Excellent job! You earned $starCount stars!';
      } else if (starCount >= 2) {
        message = 'Good effort! You earned $starCount stars!';
      } else {
        message = 'Keep practicing! You earned $starCount stars!';
      }
    } else {
      // For notes and videos, always show 5 stars and 50 points
      starCount = 5;
      displayPoints = 50;
      primaryColor = Colors.purple;
      secondaryColor = Colors.purple[100]!;
      message = 'Excellent job! You\'ve completed this learning activity!';
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
              width: MediaQuery.of(context).size.width * 0.8,
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
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
                        gradient: LinearGradient(
                          colors: [
                            primaryColor is MaterialColor ? primaryColor[300]! : primaryColor,
                            secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: (primaryColor is MaterialColor ? primaryColor[200]! : primaryColor).withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
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
                              color: primaryColor is MaterialColor ? primaryColor[700]! : primaryColor,
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
                        return TweenAnimationBuilder(
                          duration: Duration(milliseconds: 400 + (index * 120)),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, double value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: Icon(
                                  index < starCount ? Icons.star : Icons.star_border,
                                  color: index < starCount ? Colors.amber : Colors.grey.shade400,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Motivational message
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.amber.shade200, width: 2),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.blue.shade50,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: Colors.blue.shade100, width: 1),
                      ),
                      child: Column(
                        children: [
                          _buildStatRow(
                            icon: Icons.star,
                            label: 'Points Earned',
                            value: '$displayPoints',
                            color: Colors.amber.shade600,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1),
                          ),
                          _buildStatRow(
                            icon: Icons.timer,
                            label: 'Study Time',
                            value: '${widget.studyMinutes} min',
                            color: Colors.blue.shade600,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1),
                          ),
                          _buildStatRow(
                            icon: Icons.book,
                            label: 'Subject',
                            value: widget.subject,
                            color: Colors.green.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Buttons
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 1200),
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, double value, child) {
                      return Transform.translate(
                        offset: Offset(0, 30 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.onRestart != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: ElevatedButton.icon(
                              onPressed: widget.onRestart,
                              icon: const Icon(Icons.replay),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 3,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: ElevatedButton.icon(
                            onPressed: widget.onContinue ?? () {
                              // For games, navigate back to game list
                              if (widget.activityType == 'game') {
                                // Check if we're in admin module by looking at the route path
                                final currentRoute = ModalRoute.of(context);
                                final isAdminModule = currentRoute?.settings.name?.contains('admin') ?? false;
                                
                                if (isAdminModule) {
                                  // In admin module, just pop back to the game list
                                  Navigator.of(context).pop();
                                } else {
                                  // In student module, pop back to the subject list screen
                                  Navigator.of(context).popUntil((route) => route.isFirst || route.settings.name == '/subjects');
                                }
                              } else {
                                // For notes/videos, just pop once
                                Navigator.of(context).pop();
                              }
                            },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Continue'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
