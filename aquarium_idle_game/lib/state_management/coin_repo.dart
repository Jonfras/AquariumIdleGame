import 'package:aquarium_idle_game/widgets/animated_fish.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoinRepo {
  CoinRepo._privateConstructor(){
    _loadCoins();
  }

  static final CoinRepo _instance = CoinRepo._privateConstructor();

  factory CoinRepo() {
    return _instance;
  }

  int _coinCount = 0;

  final coinSubject = BehaviorSubject<int>();

  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    _coinCount = prefs.getInt('coinCount') ?? 0;
    coinSubject.add(_coinCount);
  }

  void incrementCoins() {
    _coinCount += 1;
    _saveCoins();
    coinSubject.add(_coinCount);
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