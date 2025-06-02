import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../models/subject.dart';
import '../../services/score_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/activity_completion_screen.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Chapter chapter;
  final Subject subject;
  final String userId;
  final String userName;
  final int ageGroup;

  const VideoPlayerScreen({
    Key? key,
    required this.chapter,
    required this.subject,
    required this.userId,
    required this.userName,
    required this.ageGroup,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // Video player controllers
  VideoPlayerController? _videoPlayerController;
  YoutubePlayerController? _youtubePlayerController;
  
  // State variables
  bool _isYoutubeVideo = false;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _videoCompleted = false;
  bool _scoreSubmitted = false;
  DateTime _startTime = DateTime.now();
  
  // Services
  final ScoreService _scoreService = ScoreService();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  // Initialize the appropriate video player based on the URL
  Future<void> _initializePlayer() async {
    if (widget.chapter.videoUrl == null || widget.chapter.videoUrl!.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'No video available for this chapter';
        _isLoading = false;
      });
      return;
    }

    final String videoUrl = widget.chapter.videoUrl!;
    
    // Check if it's a YouTube video
    String? youtubeId = _getYoutubeId(videoUrl);
    
    if (youtubeId != null) {
      // Initialize YouTube player with iframe
      _isYoutubeVideo = true;
      _youtubePlayerController = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          strictRelatedVideos: true,
        ),
      );
      _youtubePlayerController!.loadVideoById(videoId: youtubeId);
      setState(() {
        _isLoading = false;
      });
    } else {
      // Initialize regular video player for direct URLs
      try {
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
        await _videoPlayerController!.initialize();
        setState(() {
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Error loading video: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // Extract YouTube video ID from URL
  String? _getYoutubeId(String url) {
    // Check if it's a YouTube URL
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      // Extract video ID using regex patterns for different YouTube URL formats
      RegExp regExp = RegExp(
        r'^.*((youtu.be/)|(v/)|(/u/\w/)|(embed/)|(watch\?))\??v?=?([^#&?]*).*',
        caseSensitive: false,
        multiLine: false,
      );
      Match? match = regExp.firstMatch(url);
      return match != null && match.groupCount >= 7 ? match.group(7) : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Extract arguments if they were passed as a map
    final args = ModalRoute.of(context)?.settings.arguments;
    late Chapter actualChapter = widget.chapter;
    late Subject actualSubject = widget.subject;
    late String actualUserId = widget.userId;
    late String actualUserName = widget.userName;
    String? videoUrl;
    String? videoFilePath;
    
    if (args is Map<String, dynamic>) {
      if (args.containsKey('chapter')) {
        actualChapter = args['chapter'] as Chapter;
      } else {
        videoUrl = args['videoUrl'] as String?;
        videoFilePath = args['videoFilePath'] as String?;
        actualChapter = Chapter(
          id: args['chapterId'] as String,
          name: args['chapterName'] as String,
          videoUrl: videoUrl,
          videoFilePath: videoFilePath,
          createdAt: Timestamp.now(),
        );
        
        actualSubject = Subject(
          id: args['subjectId'] as String,
          name: args['subjectName'] as String,
          moduleId: widget.ageGroup,
          chapters: [],
          createdAt: Timestamp.now(),
        );
      }
      
      if (args.containsKey('userId')) {
        actualUserId = args['userId'] as String;
      }
      if (args.containsKey('userName')) {
        actualUserName = args['userName'] as String;
      }
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade300, Colors.blue.shade600],
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
                    Expanded(
                      child: Text(
                        widget.chapter.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              // Video content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        // Video title
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.video_library, color: Colors.blue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Video Tutorial: ${widget.chapter.name}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Comic Sans MS',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Video player
                        Expanded(
                          child: _buildVideoPlayer(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Bottom navigation with single Finish button
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Finish'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      // Submit score when finishing the video
                      if (!_videoCompleted) {
                        setState(() {
                          _videoCompleted = true;
                        });
                        _submitScore();
                        // Don't navigate away immediately - let the completion screen show
                      } else {
                        // Only navigate away if already completed
                        Navigator.pop(context);
                      }
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

  // Submit score to the database
  Future<void> _submitScore() async {
    if (_scoreSubmitted) return; // Prevent duplicate submissions
    
    try {
      // Calculate points based on video completion
      int points = 10; // Base points for watching a video
      
      // Calculate study time in minutes
      final now = DateTime.now();
      final duration = now.difference(_startTime);
      final studyMinutes = (duration.inSeconds / 60).ceil(); // Round up to nearest minute
      
      await _scoreService.addScore(
        userId: widget.userId,
        userName: widget.userName,
        subjectId: widget.subject.id,
        subjectName: widget.subject.name,
        activityId: widget.chapter.id,
        activityType: 'video',
        activityName: 'Video: ${widget.chapter.name}',
        points: points,
        ageGroup: widget.ageGroup,
      );
      
      setState(() {
        _scoreSubmitted = true;
      });
      
      // Show completion screen with animation and sound using a more reliable approach
      if (mounted) {
        // Use a full-screen dialog that completely replaces the current screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ActivityCompletionScreen(
              activityType: 'video',
              activityName: widget.chapter.name,
              subject: widget.subject.name,
              points: points,
              studyMinutes: studyMinutes,
              userId: widget.userId,
              onContinue: () {
                // Just pop once to return to chapter selection
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error submitting score: $e');
    }
  }
  
  Widget _buildVideoPlayer() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    if (_isYoutubeVideo && _youtubePlayerController != null) {
      return SizedBox(
        width: double.infinity,
        child: YoutubePlayer(
          controller: _youtubePlayerController!,
          aspectRatio: 16 / 9,
        ),
      );
    } else if (_videoPlayerController != null && _videoPlayerController!.value.isInitialized) {
      return Column(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            ),
          ),
          VideoProgressIndicator(
            _videoPlayerController!,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.red,
              bufferedColor: Colors.grey,
              backgroundColor: Colors.black12,
            ),
            padding: const EdgeInsets.all(16),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _videoPlayerController!.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 48,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      if (_videoPlayerController!.value.isPlaying) {
                        _videoPlayerController!.pause();
                      } else {
                        _videoPlayerController!.play();
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    return const Center(
      child: Text('No video available'),
    );
  }
}
