import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.gradientColors,
    required this.onPressed,
  });

  // Named constructors for quick use
  factory CustomIconButton.previous({required VoidCallback onPressed}) =>
      CustomIconButton(icon: Icons.arrow_left, gradientColors: [Colors.green, Colors.greenAccent], onPressed: onPressed);

  factory CustomIconButton.next({required VoidCallback onPressed}) =>
      CustomIconButton(icon: Icons.arrow_right, gradientColors: [Colors.green, Colors.greenAccent], onPressed: onPressed);

  factory CustomIconButton.musicOn({required VoidCallback onPressed}) =>
      CustomIconButton(icon: Icons.music_note, gradientColors: [Colors.blue, Colors.indigo], onPressed: onPressed);

  factory CustomIconButton.musicOff({required VoidCallback onPressed}) =>
      CustomIconButton(icon: Icons.music_off, gradientColors: [Colors.blue, Colors.indigo], onPressed: onPressed);

  factory CustomIconButton.home({required VoidCallback onPressed}) =>
      CustomIconButton(icon: Icons.home, gradientColors: [Colors.blue, Colors.indigo], onPressed: onPressed);

  factory CustomIconButton.soundOn({required VoidCallback onPressed}) =>
      CustomIconButton(icon: Icons.volume_up, gradientColors: [Colors.orange, Colors.amber], onPressed: onPressed);

  factory CustomIconButton.soundOff({required VoidCallback onPressed}) =>
      CustomIconButton(icon: Icons.volume_off, gradientColors: [Colors.orange, Colors.amber], onPressed: onPressed);

  factory CustomIconButton.back({required VoidCallback onPressed}) =>
      CustomIconButton(icon: Icons.arrow_back, gradientColors: [Colors.orange, Colors.amber], onPressed: onPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: gradientColors),
        boxShadow: [
          BoxShadow(
          color: gradientColors.last.withAlpha((0.5 * 255).toInt()),
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        onPressed: onPressed,
      ),
    );
  }
}
