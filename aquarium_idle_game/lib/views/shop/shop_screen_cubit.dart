import 'package:aquarium_idle_game/state_management/animated_fish_repo.dart';
import 'package:aquarium_idle_game/util/fish_factory.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../state_management/coin_repo.dart';

import 'package:aquarium_idle_game/state_management/decoration_repo.dart';

import '../../util/decoration_factory.dart';

class ShopScreenCubit extends Cubit<ShopScreenState> implements TickerProvider {
  ShopScreenCubit(super.initialState) {
    _setupListeners();
    _initTabController();
  }

  final fishRepo = AnimatedFishRepo();
  final coinRepo = CoinRepo();
  final fishFactory = FishFactory();
  final decorationRepo = DecorationRepo();
  final decorationFactory = DecorationFactory();

  late final coinListener;
  late final passiveIncomeListener;
  late final TabController tabController;

  void buyFish(String type) {
    final fish = fishFactory.getFish(type);
    if (coinRepo.spendCoins(fish.price)) {
      fishRepo.addFish(type);
    }
  }

  void buyDecoration(String type) {
    final decoration = decorationFactory.getDecoration(type);
    if (coinRepo.spendCoins(decoration.price)) {
      decorationRepo.addDecoration(type);
    }
  }

  void _setupListeners() {
    coinListener = coinRepo.coinSubject.listen((event) {
      emit(state.copyWith(coinCount: event));
    });

    passiveIncomeListener = decorationRepo.passiveIncomeSubject.listen((event) {
      emit(state.copyWith(passiveIncome: event));
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
    return Ticker(onTick, debugLabel: 'shop_cubit_ticker');
  }

  @override
  Future<void> close() {
    coinListener.cancel();
    passiveIncomeListener.cancel();
    tabController.dispose();
    return super.close();
  }
}