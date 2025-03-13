import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:math';

import '../model/decoration.dart' as model;
import '../widgets/animated_decoration.dart';
import '../util/decoration_factory.dart';
import 'coin_repo.dart';

class DecorationRepo {
  DecorationRepo._privateConstructor() {
    decorationSubject = BehaviorSubject<List<AnimatedDecoration>>.seeded([]);
    _decorationCountMap = {};
    _decorationMergeCountMap = {};
    _totalPassiveIncome = 0;
    _startPassiveIncomeTimer();
  }

  static final DecorationRepo _instance = DecorationRepo._privateConstructor();

  factory DecorationRepo() {
    return _instance;
  }

  final DecorationFactory factory = DecorationFactory();
  final Random _random = Random();
  late final BehaviorSubject<List<AnimatedDecoration>> decorationSubject;
  final coinRepo = CoinRepo();

  // Map to track count of each decoration type
  Map<String, List<model.Decoration>> _decorationCountMap = {};

  // Map to track merge level of each decoration type
  Map<String, int> _decorationMergeCountMap = {};

  // Total passive income per second
  int _totalPassiveIncome = 0;
  late Timer _passiveIncomeTimer;

  // Subject for passive income stream
  final passiveIncomeSubject = BehaviorSubject<int>.seeded(0);

  void addDecoration(String type) {
    debugPrint('DecorationRepo: Adding decoration of type: $type');

    // Get decoration from factory
    final decoration = factory.getDecoration(type);

    // Initialize lists and counters if they don't exist
    _decorationCountMap[type] ??= [];
    _decorationMergeCountMap[type] ??= 0;

    // Add decoration to type map
    _decorationCountMap[type]!.add(decoration);

    // Check if we have 5 decorations of the same type
    if (_decorationCountMap[type]!.length >= 5) {
      _mergeDecorations(type);
    } else {
      // Generate random position for the decoration
      final position = Offset(
        _random.nextDouble() * 300,
        _random.nextDouble() * 50 + 10,
      );

      // Update passive income
      _totalPassiveIncome += decoration.passiveIncome;
      passiveIncomeSubject.add(_totalPassiveIncome);

      // Add to decoration list
      _updateDecorationList(decoration, position);

      debugPrint('DecorationRepo: Total passive income: $_totalPassiveIncome coins/sec');
    }
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
    // Base formula: original income × (5 + mergeLevel)
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

    // Generate random position for the merged decoration
    final position = Offset(
      _random.nextDouble() * 300,
      _random.nextDouble() * 50 + 10,
    );

    // Add the new larger decoration
    decorationList.add(AnimatedDecoration(decoration: upgradedDecoration, position: position));

    // Remove the 5 merged decorations from the count map and add the new one
    _decorationCountMap[type] = _decorationCountMap[type]!.skip(5).toList();
    _decorationCountMap[type]!.add(upgradedDecoration);

    // Update total passive income
    _updateTotalPassiveIncome();

    // Update decoration list
    debugPrint('DecorationRepo: Emitting updated decoration list after merge, size: ${decorationList.length}');
    decorationSubject.add(decorationList);
  }

  void _updateTotalPassiveIncome() {
    // Recalculate total passive income from all decorations
    int newTotal = 0;
    for (var decorationList in _decorationCountMap.values) {
      for (var decoration in decorationList) {
        newTotal += decoration.passiveIncome;
      }
    }
    _totalPassiveIncome = newTotal;
    passiveIncomeSubject.add(_totalPassiveIncome);

    debugPrint('DecorationRepo: Updated total passive income: $_totalPassiveIncome coins/sec');
  }

  void _updateDecorationList(model.Decoration decoration, Offset position) {
    final decorationList = List<AnimatedDecoration>.from(decorationSubject.valueOrNull ?? []);
    decorationList.add(AnimatedDecoration(decoration: decoration, position: position));
    decorationSubject.add(decorationList);
  }

  // Start a timer that adds passive income
  void _startPassiveIncomeTimer() {
    _passiveIncomeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_totalPassiveIncome > 0) {
        coinRepo.addPassiveIncome(_totalPassiveIncome);
      }
    });
  }

  void dispose() {
    _passiveIncomeTimer.cancel();
    decorationSubject.close();
    passiveIncomeSubject.close();
  }
}