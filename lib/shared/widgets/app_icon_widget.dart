import 'package:flutter/material.dart';

class AppIconWidget extends StatelessWidget {
  final double size;

  const AppIconWidget({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.2),
      child: Image.asset(
        'assets/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.eco, size: size, color: Colors.greenAccent);
        },
      ),
    );
  }
}
