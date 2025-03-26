import 'package:flutter/material.dart';
import '../model/decoration.dart' as model;

class DecorationFactory {
  late final Map<String, model.Decoration> decorationMap;
  static const basePath = 'assets/animations/decorations';
  DecorationFactory() {
    decorationMap = Map.from({
      'Seaweed': model.Decoration(
        assetPath: '$basePath/seaweed.json',
        color: Colors.green,
        type: 'Seaweed',
        passiveIncome: 1,
        price: 50,
        size: 1.0,
      ),
      'Coral': model.Decoration(
        assetPath: '$basePath/coral.json',
        color: Colors.pink,
        type: 'Coral',
        passiveIncome: 2,
        price: 100,
        size: 1.0,
      ),
      'Treasure Chest': model.Decoration(
        assetPath: '$basePath/treasure chest.json',
        color: Colors.amber,
        type: 'Treasure Chest',
        passiveIncome: 5,
        price: 250,
        size: 1.0,
      ),
      'Castle': model.Decoration(
        assetPath: '$basePath/castle.json',
        color: Colors.grey,
        type: 'Castle',
        passiveIncome: 10,
        price: 500,
        size: 1.2,
      ),
    });
  }

  model.Decoration getDecoration(String type) {
    return decorationMap[type]!;
  }

  List<String> get decorationTypes {
    return decorationMap.keys.toList();
  }
}