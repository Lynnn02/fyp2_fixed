import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:audioplayers/audioplayers.dart';

class WelcomeDesign extends StatefulWidget {
  final VoidCallback onStartPressed;
  const WelcomeDesign({super.key, required this.onStartPressed});

  @override
  State<WelcomeDesign> createState() => _WelcomeDesignState();
}

class _WelcomeDesignState extends State<WelcomeDesign>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;

  late final AnimationController _cloudController;
  late final Animation<Offset> _cloudAnimation;

  late final AnimationController _buttonGlowController;

  late final Ticker _sparkleTicker;
  final List<Offset> _sparkles = [];
  final Random _random = Random();

  double _fadeTextOpacity = 0.0;

  // 🎵 Audio players
  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _bgPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoController.forward();

    _cloudController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    _cloudAnimation = Tween<Offset>(
      begin: const Offset(-0.05, 0),
      end: const Offset(0.05, 0),
    ).animate(CurvedAnimation(
      parent: _cloudController,
      curve: Curves.easeInOut,
    ));

    _buttonGlowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
      lowerBound: 0.9,
      upperBound: 1.1,
    )..repeat(reverse: true);

    // Show fade-in text
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _fadeTextOpacity = 1.0;
      });
    });

    // ✨ Sparkles
    _sparkleTicker = Ticker((_) {
      if (_sparkles.length < 30) {
        _sparkles.add(Offset(
          _random.nextDouble(),
          _random.nextDouble(),
        ));
      } else {
        _sparkles.removeAt(0);
      }
      setState(() {});
    });
    _sparkleTicker.start();

    // 🎵 Start background music
    _playBackgroundMusic();
  }


  Future<void> _playBackgroundMusic() async {
    try {
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('bg_music.mp3'));
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _cloudController.dispose();
    _buttonGlowController.dispose();
    _sparkleTicker.dispose();
    _clickPlayer.dispose();
    _bgPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🌈 Background image
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/rainbow.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // ✨ Sparkles
        IgnorePointer(
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: SparklePainter(_sparkles),
          ),
        ),

        // ☁️ Cloud
        SlideTransition(
          position: _cloudAnimation,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Icon(Icons.cloud, size: 140, color: Colors.white),
            ),
          ),
        ),

        // Logo, Text & Button
        Center(
          child: ScaleTransition(
            scale: _logoAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', width: 240),
                const SizedBox(height: 10),
                AnimatedOpacity(
                  opacity: _fadeTextOpacity,
                  duration: const Duration(seconds: 1),
                  child: const Text(
                    "Let’s Learn Together!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ScaleTransition(
                  scale: _buttonGlowController,
                  child: _buildGradientButton(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton() {
    return GestureDetector(
      onTap: () async {
        await _clickPlayer.play(AssetSource('click.mp3'));
        widget.onStartPressed();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.orange, Colors.red, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withAlpha((0.4 * 255).toInt()),
              offset: const Offset(0, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Text(
          'START EXPLORING',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class SparklePainter extends CustomPainter {
  final List<Offset> sparkles;
  SparklePainter(this.sparkles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6);
    for (final offset in sparkles) {
      final position = Offset(offset.dx * size.width, offset.dy * size.height);
      canvas.drawCircle(position, 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
