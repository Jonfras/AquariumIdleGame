import 'package:aquarium_idle_game/widgets/animated_fish.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'animated_fish_repo.dart';

class CoinRepo {
  CoinRepo._privateConstructor(){
    _loadCoins();
  }

  static final CoinRepo _instance = CoinRepo._privateConstructor();

  factory CoinRepo() {
    return _instance;
  }

  int _coinCount = 0;
  final AnimatedFishRepo _fishRepo = AnimatedFishRepo();
  final coinSubject = BehaviorSubject<int>();

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    _coinCount = prefs.getInt('coinCount') ?? 0;
    coinSubject.add(_coinCount);
  }

  void incrementCoins() {
    // Get total bonus from all fish
    int fishBonus = _calculateTotalFishBonus();

    // Set minimum increment to 1 if there are no fish
    int increment = fishBonus > 0 ? fishBonus : 1;

    _coinCount += increment;
    _saveCoins();
    coinSubject.add(_coinCount);

    debugPrint('Coins increased by $increment (Fish bonus: $fishBonus)');
  }

  void addPassiveIncome(int amount) {
    _coinCount += amount;
    _saveCoins();
    coinSubject.add(_coinCount);

    debugPrint('Passive income: +$amount coins');
  }

  int _calculateTotalFishBonus() {
    // Get current fish list
    final fishList = _fishRepo.fishSubject.valueOrNull ?? [];

    // Sum up all fish click bonuses
    int totalBonus = 0;
    for (var animatedFish in fishList) {
      totalBonus += animatedFish.fish.clickBonus;
    }

    return totalBonus;
  }

  Future<void> _saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coinCount', _coinCount);
  }

  bool spendCoins(int amount) {
    if (_coinCount >= amount) {
      _coinCount -= amount;
      _saveCoins();
      coinSubject.add(_coinCount);
      return true;
    }
    return false;
  }
}