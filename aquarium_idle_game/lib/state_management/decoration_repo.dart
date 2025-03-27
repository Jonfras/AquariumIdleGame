import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/decoration.dart' as model;
import '../widgets/animated_decoration.dart';
import '../util/decoration_factory.dart';
import 'coin_repo.dart';
import '../api/generated/lib/api.dart';
import '../pref_constants.dart';

class DecorationRepo {
  DecorationRepo._privateConstructor() {
    decorationSubject = BehaviorSubject<List<AnimatedDecoration>>.seeded([]);
    _decorationCountMap = {};
    _decorationMergeCountMap = {};
    _totalPassiveIncome = 0;
    _setupSaveListener();
    _startPassiveIncomeTimer();
    loadDecorationsFromBackend();
  }

  static final DecorationRepo _instance = DecorationRepo._privateConstructor();

  factory DecorationRepo() {
    return _instance;
  }

  final DecorationFactory factory = DecorationFactory();
  final Random _random = Random();
  late final BehaviorSubject<List<AnimatedDecoration>> decorationSubject;
  final coinRepo = CoinRepo();
  final _decorationSaveSubject = BehaviorSubject<List<model.Decoration>>();
  final _gameApi = GameApi(ApiClient(basePath: 'http://localhost:5000'));

  Map<String, List<model.Decoration>> _decorationCountMap = {};
  Map<String, int> _decorationMergeCountMap = {};
  int _totalPassiveIncome = 0;
  late Timer _passiveIncomeTimer;
  final passiveIncomeSubject = BehaviorSubject<int>.seeded(0);

  // Load decorations from backend
  Future<void> loadDecorationsFromBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(PrefConstants.userIdKey);

      debugPrint('Loading decorations for user ID: $userId');
      if (userId == null) {
        debugPrint('Cannot load decorations: userId is null');
        return;
      }

      final response = await _gameApi.gameDecorationsUserIdGet(userId);

      if (response != null && response.errorMessage == '' && response.data != null) {
        final List<DecorationDto> decorationDtos = response.data!;
        debugPrint('Loaded ${decorationDtos.length} decorations from backend');

        // Convert DecorationDto to Decoration models
        final List<model.Decoration> loadedDecorations = decorationDtos.map((dto) {
          // Parse color from hex string
          Color color;
          try {
            color = Color(int.parse(dto.color!, radix: 16));
          } catch (e) {
            color = Colors.green; // Default color if parsing fails
          }

          return model.Decoration(
            assetPath: factory.getDecoration(dto.decorationType ?? 'plants').assetPath,
            color: color,
            type: dto.decorationType ?? 'plants',
            passiveIncome: dto.passiveIncome?.toInt() ?? 1,
            price: dto.price?.toInt() ?? 10,
            size: dto.size ?? 1.0,
          );
        }).toList();

        // Process loaded decorations for merge tracking
        for (var decoration in loadedDecorations) {
          String type = decoration.type;

          // Initialize lists if needed
          _decorationCountMap[type] ??= [];
          _decorationMergeCountMap[type] ??= 0;

          // Calculate merge level based on size
          double sizeFactor = decoration.size / factory.getDecoration(type).size;
          int estimatedMergeLevel = ((sizeFactor - 1) / 0.1).round();

          if (estimatedMergeLevel > (_decorationMergeCountMap[type] ?? 0)) {
            _decorationMergeCountMap[type] = estimatedMergeLevel;
          }

          // Add to count map
          _decorationCountMap[type]!.add(decoration);
        }

        // Update total passive income
        _updateTotalPassiveIncome();

        // Add decorations to display
        final decorationList = loadedDecorations.map((decoration) {
          final position = Offset(
            _random.nextDouble() * 300,
            _random.nextDouble() * 50 + 10,
          );
          return AnimatedDecoration(decoration: decoration, position: position);
        }).toList();

        decorationSubject.add(decorationList);
        debugPrint('Decorations loaded successfully. Types: ${_decorationCountMap.keys.join(', ')}');
      }
    } catch (e) {
      debugPrint('Error loading decorations from backend: $e');
    }
  }

  void addDecoration(String type) {
    debugPrint('DecorationRepo: Adding decoration of type: $type');

    // Get base decoration from factory
    final decoration = factory.getDecoration(type);

    // Initialize list for this type if it doesn't exist
    _decorationCountMap[type] ??= [];
    _decorationMergeCountMap[type] ??= 0;

    // Add decoration to type map
    _decorationCountMap[type]!.add(decoration);

    // Check if we have 5 decorations of the same type
    if (_decorationCountMap[type]!.length >= 5) {
      _mergeDecorations(type);
    } else {
      // Add regular decoration
      _updateDecorationList(type, decoration);
    }

    // Trigger save process
    _triggerDecorationSave();
  }

  void _mergeDecorations(String type) {
    debugPrint('DecorationRepo: Merging 5 decorations of type: $type');

    // Get the current decoration list
    final decorationList = List<AnimatedDecoration>.from(decorationSubject.valueOrNull ?? []);

    // Find all decorations of the specified type in the current display list
    final decorationsToRemove = decorationList.where((d) => d.decoration.type == type).toList();

    // Remove up to 5 decorations of this type
    int removeCount = decorationsToRemove.length > 5 ? 5 : decorationsToRemove.length;
    for (int i = 0; i < removeCount; i++) {
      if (i < decorationsToRemove.length) {
        decorationList.remove(decorationsToRemove[i]);
      }
    }

    // Increment merge count for this decoration type
    _decorationMergeCountMap[type] = (_decorationMergeCountMap[type] ?? 0) + 1;
    final mergeLevel = _decorationMergeCountMap[type]!;

    // Get base decoration properties
    final baseDecoration = factory.getDecoration(type);

    // Calculate new size - 10% increase per merge level
    final newSize = baseDecoration.size * (1 + 0.1 * mergeLevel);

    // Calculate new passive income - increases with merge level
    // Base formula: original passive * (5 + mergeLevel)
    // This preserves the value of 5 decorations + adds merge bonus
    final newPassiveIncome = baseDecoration.passiveIncome * (5 + mergeLevel);

    debugPrint('Merged decoration size: ${newSize.toStringAsFixed(2)}x (merge level: $mergeLevel)');
    debugPrint('Merged decoration passive income: $newPassiveIncome (base: ${baseDecoration.passiveIncome})');

    // Create a new decoration with increased size and passive income
    final upgradedDecoration = model.Decoration(
      assetPath: baseDecoration.assetPath,
      color: baseDecoration.color,
      type: baseDecoration.type,
      passiveIncome: newPassiveIncome,
      price: baseDecoration.price,
      size: newSize,
    );

    // Add the new larger decoration with a random position
    final position = Offset(
      _random.nextDouble() * 300,
      _random.nextDouble() * 50 + 10,
    );
    decorationList.add(AnimatedDecoration(decoration: upgradedDecoration, position: position));

    // Remove the 5 merged decorations from the count map and add the new one
    _decorationCountMap[type] = _decorationCountMap[type]!.skip(5).toList();
    _decorationCountMap[type]!.add(upgradedDecoration);

    // Update decoration list
    debugPrint('DecorationRepo: Emitting updated decoration list after merge, size: ${decorationList.length}');
    decorationSubject.add(decorationList);

    // Update passive income after merge
    _updateTotalPassiveIncome();

    // Trigger save process
    _triggerDecorationSave();
  }

  void _updateDecorationList(String type, model.Decoration decoration) {
    final decorationList = List<AnimatedDecoration>.from(decorationSubject.valueOrNull ?? []);

    final position = Offset(
      _random.nextDouble() * 300,
      _random.nextDouble() * 50 + 10,
    );

    decorationList.add(AnimatedDecoration(
        decoration: decoration,
        position: position
    ));

    debugPrint('DecorationRepo: Emitting updated decoration list, size: ${decorationList.length}');
    decorationSubject.add(decorationList);

    // Update passive income when adding new decoration
    _updateTotalPassiveIncome();
  }

  void _updateTotalPassiveIncome() {
    int totalIncome = 0;

    // Sum up passive income from all decorations
    for (var type in _decorationCountMap.keys) {
      for (var decoration in _decorationCountMap[type]!) {
        totalIncome += decoration.passiveIncome;
      }
    }

    _totalPassiveIncome = totalIncome;
    passiveIncomeSubject.add(_totalPassiveIncome);
    debugPrint('Total passive income updated: $_totalPassiveIncome coins/min');
  }

  void _startPassiveIncomeTimer() {
    _passiveIncomeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_totalPassiveIncome > 0) {
        coinRepo.addPassiveIncome(_totalPassiveIncome);
        debugPrint('Added $_totalPassiveIncome passive income coins');
      }
    });
  }

  // Backend save methods
  void _triggerDecorationSave() {
    final allDecorations = _getAllDecorations();
    _decorationSaveSubject.add(allDecorations);
  }

  List<model.Decoration> _getAllDecorations() {
    final decorationList = decorationSubject.valueOrNull ?? [];
    return decorationList.map((animatedDecoration) => animatedDecoration.decoration).toList();
  }

  void _setupSaveListener() {
    _decorationSaveSubject
        .debounceTime(const Duration(seconds: 2))
        .listen((decorationList) async {
      try {
        await _saveDecorationsToBackend(decorationList);
      } catch (e) {
        debugPrint('Failed to save decorations to backend: $e');
      }
    });
  }

  Future<void> _saveDecorationsToBackend(List<model.Decoration> decorationList) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(PrefConstants.userIdKey);

    if (userId == null) {
      debugPrint('Cannot save decorations: userId is null');
      return;
    }

    // Convert Decoration model to DecorationDto for API
    final decorationDtos = decorationList.map((decoration) => DecorationDto(
      userId: userId,
      decorationType: decoration.type,
      size: decoration.size,
      passiveIncome: decoration.passiveIncome,
      color: decoration.color.value.toRadixString(16),
      price: decoration.price,
    )).toList();

    try {
      await _gameApi.gameDecorationsPost(decorationDto: decorationDtos);
      debugPrint('Decorations saved to backend: ${decorationDtos.length} decorations');
    } catch (e) {
      debugPrint('Failed to save decorations to backend: $e');
    }
  }

  void dispose() {
    _passiveIncomeTimer.cancel();
    decorationSubject.close();
    passiveIncomeSubject.close();
    _decorationSaveSubject.close();
  }
}