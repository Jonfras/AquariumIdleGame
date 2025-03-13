import 'package:aquarium_idle_game/widgets/animated_fish.dart';
import 'package:rxdart/rxdart.dart';

import '../model/fish.dart';
import '../util/fish_factory.dart';

class AnimatedFishRepo {
  AnimatedFishRepo._privateConstructor();
  FishFactory factory = new FishFactory();

  static final AnimatedFishRepo _instance = AnimatedFishRepo._privateConstructor();

  factory AnimatedFishRepo() {
    return _instance;
  }

  final fishSubject = BehaviorSubject<List<AnimatedFish>>();

  void addFish(String type) {
    final fish = factory.getFish(type);
    final animatedFish = AnimatedFish(fish: fish);
    final fishList = fishSubject.valueOrNull ?? [];
    fishList.add(animatedFish);
    fishSubject.add(fishList);
  }
}