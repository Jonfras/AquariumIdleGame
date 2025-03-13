import 'package:aquarium_idle_game/widgets/animated_fish.dart';

class AquariumScreenState {
  List<AnimatedFish> fishList = [];
  int coins = 0;

  AquariumScreenState copyWith({List<AnimatedFish>? fishList, int? coins}) {
    return AquariumScreenState()
      ..fishList = fishList ?? this.fishList
      ..coins = coins ?? this.coins;
  }
}
