import 'package:flutter/material.dart';

Future<void> showThemePopup(
  BuildContext context,
  String message, {
  String? description,
  IconData? icon,
  Color iconColor = Colors.blueAccent,
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 10),
      title: Row(
        children: [
          Icon(icon ?? Icons.info_outline, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: description != null
          ? Text(
              description,
              style: const TextStyle(fontSize: 16),
            )
          : null,
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
