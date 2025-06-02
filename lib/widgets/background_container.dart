import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class BackgroundContainer extends StatefulWidget {
  const BackgroundContainer({super.key});

  @override
  State<BackgroundContainer> createState() => _BackgroundContainerState();
}

class _BackgroundContainerState extends State<BackgroundContainer> {
  late final Ticker _sparkleTicker;
  final List<Offset> _sparkles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _sparkleTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/rainbow.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        IgnorePointer(
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: SparklePainter(_sparkles),
          ),
        ),
      ],
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