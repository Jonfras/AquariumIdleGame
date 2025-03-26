import 'package:flutter/material.dart';

import '../model/fish.dart';

class FishFactory {
  
  late final Map<String, Fish> fishMap;
  static const fishPath = 'assets/animations/fish/fish.json';

  FishFactory() {
    fishMap = Map.from({
      'Goldfish': Fish(
        assetPath: fishPath,
        color: Colors.yellow,
        type: 'Goldfish',
        clickBonus: 1,
        price: 10,
        size: 1.0,
      ),
      'Clownfish': Fish(
        assetPath: fishPath,
        color: Colors.orange,
        type: 'Clownfish',
        clickBonus: 2,
        price: 20,
        size: 1.0,
      ),
      'Blue Tang': Fish(
        assetPath: fishPath,
        color: Colors.blue,
        type: 'Blue Tang',
        clickBonus: 3,
        price: 30,
        size: 1.0,
      ),
      'Angelfish': Fish(
        assetPath: fishPath,
        color: Colors.yellow,
        type: 'Angelfish',
        clickBonus: 4,
        price: 40,
        size: 1.0,

      ),
      'Pufferfish': Fish(
        assetPath: fishPath,
        color: Colors.green,
        type: 'Pufferfish',
        clickBonus: 5,
        price: 50,
        size: 1.0,

      ),
    });
  }
  
  Fish getFish(String type) {
    return fishMap[type]!;
  }
  
  List<String> get fishTypes{
    return fishMap.keys.toList();
  }
  
  
  
  
}
