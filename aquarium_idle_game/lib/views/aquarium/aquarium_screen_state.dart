import 'package:aquarium_idle_game/widgets/animated_fish.dart';

import '../../widgets/animated_decoration.dart';

class AquariumScreenState {
  List<AnimatedFish> fishList = [];
  List<AnimatedDecoration> decorationList = []; // Added decoration list
  int coins = 0;
  bool hasShownWelcomeMessage = false;

  AquariumScreenState copyWith({
    List<AnimatedFish>? fishList,
    List<AnimatedDecoration>? decorationList,
    int? coins,
    bool? hasShownWelcomeMessage,
  }) {
    return AquariumScreenState()
      ..fishList = fishList ?? this.fishList
      ..decorationList = decorationList ?? this.decorationList
      ..coins = coins ?? this.coins
      ..hasShownWelcomeMessage = hasShownWelcomeMessage ?? this.hasShownWelcomeMessage;
  }
}