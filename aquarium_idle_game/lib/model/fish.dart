import 'dart:ui';

class Fish {
  final String assetPath;
  final Color color;
  final String type; // Eindeutiger Typ-Indikator (z. B. "Goldfish", "Clownfish")
  final int clickBonus;
  final int price;
  final double size;
  Fish({
    required this.assetPath,
    required this.color,
    required this.type,
    required this.clickBonus,
    required this.price,
    required this.size,
  });
}
