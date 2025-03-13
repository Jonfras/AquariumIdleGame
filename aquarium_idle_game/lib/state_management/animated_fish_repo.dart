import 'package:aquarium_idle_game/widgets/animated_fish.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '../model/fish.dart';
import '../util/fish_factory.dart';

class AnimatedFishRepo {
  AnimatedFishRepo._privateConstructor() {
    fishSubject = BehaviorSubject<List<AnimatedFish>>.seeded([]);
    _fishCountMap = {};
    _fishMergeCountMap = {};
  }

  static final AnimatedFishRepo _instance = AnimatedFishRepo._privateConstructor();

  factory AnimatedFishRepo() {
    return _instance;
  }

  final FishFactory factory = FishFactory();
  late final BehaviorSubject<List<AnimatedFish>> fishSubject;

  // Map to track count of each fish type
  Map<String, List<Fish>> _fishCountMap = {};

  // Map to track merge level of each fish type
  Map<String, int> _fishMergeCountMap = {};

  void addFish(String type) {
    debugPrint('AnimatedFishRepo: Adding fish of type: $type');

    // Get base fish from factory
    final fish = factory.getFish(type);

    // Initialize list for this type if it doesn't exist
    _fishCountMap[type] ??= [];
    _fishMergeCountMap[type] ??= 0;

    // Add fish to type map
    _fishCountMap[type]!.add(fish);

    // Check if we have 5 fish of the same type
    if (_fishCountMap[type]!.length >= 5) {
      _mergeFish(type);
    } else {
      // Add regular fish
      _updateFishList(type, fish);
    }
  }

  void _mergeFish(String type) {
    debugPrint('AnimatedFishRepo: Merging 5 fish of type: $type');

    // Get the current fish list
    final fishList = List<AnimatedFish>.from(fishSubject.valueOrNull ?? []);

    // Find all fish of the specified type in the current display list
    final fishToRemove = fishList.where((f) => f.fish.type == type).toList();

    // Remove up to 5 fish of this type
    int removeCount = fishToRemove.length > 5 ? 5 : fishToRemove.length;
    for (int i = 0; i < removeCount; i++) {
      if (i < fishToRemove.length) {
        fishList.remove(fishToRemove[i]);
      }
    }

    // Increment merge count for this fish type
    _fishMergeCountMap[type] = (_fishMergeCountMap[type] ?? 0) + 1;
    final mergeLevel = _fishMergeCountMap[type]!;

    // Get base fish properties
    final baseFish = factory.getFish(type);

    // Calculate new size - 10% increase per merge level
    final newSize = baseFish.size * (1 + 0.1 * mergeLevel);

    // Calculate new click bonus - increases with merge level
    // Base formula: original bonus × (5 + mergeLevel)
    // This preserves the value of 5 fish + adds merge bonus
    final newClickBonus = baseFish.clickBonus * (5 + mergeLevel);

    debugPrint('Merged fish size: ${newSize.toStringAsFixed(2)}x (merge level: $mergeLevel)');
    debugPrint('Merged fish click bonus: $newClickBonus (base: ${baseFish.clickBonus})');

    // Create a new fish with increased size and click bonus
    final upgradedFish = Fish(
      assetPath: baseFish.assetPath,
      color: baseFish.color,
      type: baseFish.type,
      clickBonus: newClickBonus,
      price: baseFish.price,
      size: newSize,
    );

    // Add the new larger fish
    fishList.add(AnimatedFish(fish: upgradedFish));

    // Remove the 5 merged fish from the count map and add the new one
    _fishCountMap[type] = _fishCountMap[type]!.skip(5).toList();
    _fishCountMap[type]!.add(upgradedFish);

    // Update fish list
    debugPrint('AnimatedFishRepo: Emitting updated fish list after merge, size: ${fishList.length}');
    fishSubject.add(fishList);
  }

  void _updateFishList(String type, Fish fish) {
    final fishList = List<AnimatedFish>.from(fishSubject.valueOrNull ?? []);
    fishList.add(AnimatedFish(fish: fish));
    debugPrint('AnimatedFishRepo: Emitting updated fish list, size: ${fishList.length}');
    fishSubject.add(fishList);
  }
}