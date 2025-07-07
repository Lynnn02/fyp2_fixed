import 'package:flutter/material.dart';

class CompletionScreen extends StatelessWidget {
  final int points;
  final VoidCallback onNext;

  const CompletionScreen({
    Key? key,
    required this.points,
    required this.onNext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.lightBlue.shade200,
            Colors.lightBlue.shade100,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Cloud decorations
          Positioned(
            top: 20,
            left: 20,
            child: _buildCloud(60),
          ),
          Positioned(
            top: 10,
            right: 30,
            child: _buildCloud(80),
          ),
          
          // Rainbow decoration
          Positioned(
            bottom: -100,
            right: -100,
            child: _buildRainbow(300),
          ),
          
          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Stars
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStar(40, -15),
                    _buildStar(60, 0),
                    _buildStar(80, -10),
                    _buildStar(60, 0),
                    _buildStar(40, -15),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Module complete text
                const Text(
                  'MODULE',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const Text(
                  'COMPLETE',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Points earned
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '+$points POINTS',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Next button
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildStar(double size, double verticalOffset) {
    return Transform.translate(
      offset: Offset(0, verticalOffset),
      child: Icon(
        Icons.star,
        color: Colors.amber,
        size: size,
      ),
    );
  }

  Widget _buildRainbow(double size) {
    return CustomPaint(
      size: Size(size, size),
      painter: RainbowPainter(),
    );
  }
}

class RainbowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.red.shade300,
      Colors.blue.shade300,
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
      
      final radius = size.width - (i * 40);
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
