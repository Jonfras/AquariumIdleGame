import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import '../../state_management/animated_fish_repo.dart';
import '../../state_management/coin_repo.dart';
import '../../state_management/decoration_repo.dart';
import 'aquarium_screen_state.dart';

class AquariumScreenCubit extends Cubit<AquariumScreenState> {
  AquariumScreenCubit(super.initialState) {
    debugPrint('AquariumScreenCubit: Initializing');
    _setupListeners();
  }

  final coinRepo = CoinRepo();
  final fishRepo = AnimatedFishRepo();
  final decorationRepo = DecorationRepo();
  late StreamSubscription _fishSubscription;
  late StreamSubscription _coinSubscription;
  late StreamSubscription _decorationSubscription;


  void incrementCoins() {
    coinRepo.incrementCoins();
  }

  void _setupListeners() {
    debugPrint('AquariumScreenCubit: Setting up listeners');
    _fishSubscription = fishRepo.fishSubject.listen((event) {
      debugPrint('AquariumScreenCubit: Fish list updated, size: ${event.length}');
      event.forEach((fish) {
        debugPrint('Cubit: Adding fish to aquarium: ${fish.fish.type}');
      });
      emit(state.copyWith(fishList: event));
    });

    _coinSubscription = coinRepo.coinSubject.listen((coins) {
      emit(state.copyWith(coins: coins));
    });

    _decorationSubscription = decorationRepo.decorationSubject.listen((decorations) {
      debugPrint('AquariumScreenCubit: Decoration list updated, size: ${decorations.length}');
      emit(state.copyWith(decorationList: decorations));
    });
  }

  @override
  Future<void> close() {
    _fishSubscription.cancel();
    _coinSubscription.cancel();
    _decorationSubscription.cancel();

    return super.close();
  }

  void markWelcomeMessageAsShown() {
    emit(state.copyWith(hasShownWelcomeMessage: true));
  }
}
