import 'package:bloc/bloc.dart';
import 'package:flutter/src/widgets/framework.dart';

import '../../state_management/animated_fish_repo.dart';
import '../../state_management/coin_repo.dart';
import '../../widgets/animated_fish.dart';
import 'aquarium_screen_state.dart';

class AquariumScreenCubit extends Cubit<AquariumScreenState>{
  AquariumScreenCubit(super.initialState){
    
    _setupListeners();
  }
  final coinRepo = CoinRepo();
  final fishRepo = AnimatedFishRepo();

  void incrementCoins() {
    coinRepo.incrementCoins();
  }

  void _setupListeners() {
    fishRepo.fishSubject.listen((event) {
      emit(AquariumScreenState().copyWith(fishList: event));
    });
  }
  
  
  
}


