// lib/views/shop/widgets/transparent_header.dart
import 'package:flutter/material.dart';

class TransparentHeader extends StatelessWidget {
  final String title;
  final Widget trailingWidget;

  const TransparentHeader({
    required this.title,
    required this.trailingWidget,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.withOpacity(0.8),
            Colors.blue.withOpacity(0.4),
            Colors.blue.withOpacity(0.0),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Already black
              ),
            ),
            trailingWidget,
          ],
        ),
      ),
    );
  }
}