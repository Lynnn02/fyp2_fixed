import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class CustomAuthButton extends StatelessWidget {
  final String label;
  final Future<void> Function()? onPressed;

  const CustomAuthButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        icon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Image.asset(
            'assets/google_logo.png',
            height: 24,
            width: 24,
          ),
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        onPressed: onPressed != null
            ? () async {
                final player = AudioPlayer();
                await player.play(AssetSource('click.mp3'));
                await onPressed!();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
    );
  }
}
