import 'package:flutter/material.dart';

import '../color.dart';

class PinkButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const PinkButton({
    required this.title,
    required this.icon,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    const buttonColor = Color(0xFF3E3D3D);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: pinkAccent, size: 22),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: pinkAccent.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }
}