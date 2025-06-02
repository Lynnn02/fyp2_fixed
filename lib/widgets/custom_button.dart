import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final List<Color> gradientColors;
  final Future<void> Function()? onPressed;

  const CustomButton({
    super.key,
    required this.label,
    required this.gradientColors,
    required this.onPressed,
  });

  // LOGIN
  factory CustomButton.login({required Future<void> Function()? onPressed}) =>
      CustomButton(label: 'SIGN IN', gradientColors: [Colors.green, Colors.lightGreen], onPressed: onPressed);

  // SIGN UP
  factory CustomButton.signUp({required Future<void> Function()? onPressed}) =>
      CustomButton(label: 'SIGN UP', gradientColors: [Colors.blue, Colors.blueAccent], onPressed: onPressed);

  // Play (Green Gradient)
  factory CustomButton.play({required Future<void> Function()? onPressed}) =>
      CustomButton(label: 'PLAY ▶', gradientColors: [Colors.green, Colors.lightGreen], onPressed: onPressed);

  // Exit (Red Gradient)
  factory CustomButton.exit({required Future<void> Function()? onPressed}) =>
      CustomButton(label: 'EXIT', gradientColors: [Colors.red, Colors.redAccent], onPressed: onPressed);

  // Guide (Yellow/Orange Gradient)
  factory CustomButton.guide({required Future<void> Function()? onPressed}) =>
      CustomButton(label: 'GUIDE', gradientColors: [Colors.orange, Colors.deepOrangeAccent], onPressed: onPressed);

  // Submit (Blue Gradient)
  factory CustomButton.submit({required Future<void> Function()? onPressed}) =>
      CustomButton(label: 'SUBMIT', gradientColors: [Colors.blue, Colors.blueAccent], onPressed: onPressed);

  // Reset (Purple Gradient)
  factory CustomButton.reset({required Future<void> Function()? onPressed}) =>
      CustomButton(label: 'RESET', gradientColors: [Colors.purple, Colors.purpleAccent], onPressed: onPressed);

  // Check (Grey Gradient)
  factory CustomButton.check({required Future<void> Function()? onPressed}) =>
      CustomButton(label: 'CHECK', gradientColors: [Colors.grey.shade700, Colors.grey], onPressed: onPressed);

  // Settings (Grey Gradient)
  factory CustomButton.settings({required Future<void> Function()? onPressed}) =>
      CustomButton(label: 'SETTING', gradientColors: [Colors.grey.shade600, Colors.grey.shade500], onPressed: onPressed);

  // No (Red Gradient)
  factory CustomButton.no({required Future<void> Function()? onPressed}) =>
      CustomButton(label: 'NO', gradientColors: [Colors.red, Colors.redAccent], onPressed: onPressed);

  // Yes (Green Gradient)
  factory CustomButton.yes({required Future<void> Function()? onPressed}) =>
      CustomButton(label: 'YES', gradientColors: [Colors.green, Colors.lightGreen], onPressed: onPressed);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withAlpha((0.5 * 255).toInt()),
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
        onPressed: onPressed != null
            ? () async {
                final player = AudioPlayer();
                await player.play(AssetSource('click.mp3'));
                await onPressed!();
              }
            : null,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}
