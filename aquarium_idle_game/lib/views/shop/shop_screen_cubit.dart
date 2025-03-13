import 'package:aquarium_idle_game/state_management/animated_fish_repo.dart';
import 'package:aquarium_idle_game/state_management/fish_state.dart';
import 'package:aquarium_idle_game/util/fish_factory.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/ticker.dart';

import '../../state_management/coin_repo.dart';

class ShopScreenCubit extends Cubit<ShopScreenState> implements TickerProvider {
  ShopScreenCubit(super.initialState) {
    _setupListeners();
    _initTabController();
  }

  final fishRepo = AnimatedFishRepo();
  final coinRepo = CoinRepo();
  final fishFactory = FishFactory();
  
  late final coinListener;
  late final fishRepoListener;

  late final TabController tabController;

  void buyFish(String type) {
    final fish = fishFactory.getFish(type);
    if (coinRepo.spendCoins(fish.price)) {
      fishRepo.addFish(type);
    }
  }

  void _setupListeners() {
    coinListener = coinRepo.coinSubject.listen((event) {
      emit(state.copyWith(coinCount: event));
    });
  }

  void _initTabController() {
    tabController = TabController(length: 2, vsync: this);

    tabController.addListener(() {
      emit(state.copyWith(tabBarIndex: tabController.index));
    });
  }

  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick, debugLabel: 'workflow_cubit_ticker');
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
