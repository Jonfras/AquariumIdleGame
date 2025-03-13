import 'package:flutter/material.dart';

class Decoration {
  final String assetPath;
  final Color color;
  final String type;
  final int passiveIncome; // Coins per second
  final int price;
  final double size;

  Decoration({
    required this.assetPath,
    required this.color,
    required this.type,
    required this.passiveIncome,
    required this.price,
    required this.size,
  });
}