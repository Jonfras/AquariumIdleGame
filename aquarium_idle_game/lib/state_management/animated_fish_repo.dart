import 'package:aquarium_idle_game/widgets/animated_fish.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/fish.dart';
import '../util/fish_factory.dart';
import '../pref_constants.dart';
import '../api/generated/lib/api.dart';

class AnimatedFishRepo {
  AnimatedFishRepo._privateConstructor() {
    fishSubject = BehaviorSubject<List<AnimatedFish>>.seeded([]);
    _fishCountMap = {};
    _fishMergeCountMap = {};
    _setupSaveListener();
    loadFishFromBackend(); // Add this line to load fish at initialization
  }

  static final AnimatedFishRepo _instance = AnimatedFishRepo._privateConstructor();

  factory AnimatedFishRepo() {
    return _instance;
  }

  final FishFactory factory = FishFactory();
  late final BehaviorSubject<List<AnimatedFish>> fishSubject;
  final _fishSaveSubject = BehaviorSubject<List<Fish>>();
  final _gameApi = GameApi(ApiClient(basePath: 'http://localhost:5000'));

  Map<String, List<Fish>> _fishCountMap = {};

  Map<String, int> _fishMergeCountMap = {};

  // Add this method to load fish from backend
  Future<void> loadFishFromBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(PrefConstants.userIdKey);

      debugPrint('Loading fish for user ID: $userId');

      if (userId == null) {
        debugPrint('Cannot load fish: userId is null');
        return;
      }

      final response = await _gameApi.gameFishUserIdGet(userId);

      if (response != null && response.errorMessage == '' && response.data != null) {
        final List<FishDto> fishDtos = response.data!;
        debugPrint('Loaded ${fishDtos.length} fish from backend');

        // Convert FishDto to Fish models
        final List<Fish> loadedFish = fishDtos.map((dto) {
          // Parse color from hex string
          Color color;
          try {
            color = Color(int.parse(dto.color!, radix: 16));
          } catch (e) {
            color = Colors.blue; // Default color if parsing fails
          }

          return Fish(
            assetPath: factory.getFish(dto.fishType ?? 'clownfish').assetPath,
            color: color,
            type: dto.fishType ?? 'clownfish',
            clickBonus: dto.clickBonus?.toInt() ?? 1,
            price: dto.price?.toInt() ?? 10,
            size: dto.size ?? 1.0,
          );
        }).toList();

        // Process loaded fish for merge count tracking
        for (var fish in loadedFish) {
          String type = fish.type;

          // Initialize lists if needed
          _fishCountMap[type] ??= [];
          _fishMergeCountMap[type] ??= 0;

          // Calculate merge level based on size (reverse of the merge calculation)
          double sizeFactor = fish.size / factory.getFish(type).size;
          int estimatedMergeLevel = ((sizeFactor - 1) / 0.1).round();

          if (estimatedMergeLevel > (_fishMergeCountMap[type] ?? 0)) {
            _fishMergeCountMap[type] = estimatedMergeLevel;
          }

          // Add to count map
          _fishCountMap[type]!.add(fish);
        }

        // Add fish to display
        final fishList = loadedFish.map((fish) => AnimatedFish(fish: fish)).toList();
        fishSubject.add(fishList);

        debugPrint('Fish loaded successfully. Types: ${_fishCountMap.keys.join(', ')}');
      } else {
        debugPrint('Failed to load fish or no fish data available');
      }
    } catch (e) {
      debugPrint('Error loading fish from backend: $e');
    }
  }

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

    // Trigger save process
    _triggerFishSave();
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

    // Trigger save process
    _triggerFishSave();
  }

  void _updateFishList(String type, Fish fish) {
    final fishList = List<AnimatedFish>.from(fishSubject.valueOrNull ?? []);
    fishList.add(AnimatedFish(fish: fish));
    debugPrint('AnimatedFishRepo: Emitting updated fish list, size: ${fishList.length}');
    fishSubject.add(fishList);
  }

  void _triggerFishSave() {
    final allFish = _getAllFish();
    _fishSaveSubject.add(allFish);
  }

  List<Fish> _getAllFish() {
    final fishList = fishSubject.valueOrNull ?? [];
    return fishList.map((animatedFish) => animatedFish.fish).toList();
  }

  void _setupSaveListener() {
    _fishSaveSubject
        .debounceTime(const Duration(seconds: 2))
        .listen((fishList) async {
      try {
        await _saveFishToBackend(fishList);
      } catch (e) {
        debugPrint('Failed to save fish to backend: $e');
      }
    });
  }

  Future<void> _saveFishToBackend(List<Fish> fishList) async {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt(PrefConstants.userIdKey);
    if (userId == null) {
      debugPrint('Cannot save fish: userId is null');
      return;
    }

    // Convert Fish model to FishDto for API
    final fishDtos = fishList.map((fish) => FishDto(
      userId: userId,
      fishType: fish.type,
      size: fish.size,
      clickBonus: fish.clickBonus,
      color: fish.color.value.toRadixString(16),
      price: fish.price,
    )).toList();

    try {
      await _gameApi.gameFishPost(fishDto: fishDtos);
      debugPrint('Fish saved to backend: ${fishDtos.length} fish');
    } catch (e) {
      debugPrint('Failed to save fish to backend: $e');
    }
  }
}