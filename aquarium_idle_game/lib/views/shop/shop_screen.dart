import 'package:aquarium_idle_game/views/shop/shop_screen_cubit.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:aquarium_idle_game/state_management/fish_state.dart';
import 'package:aquarium_idle_game/views/aquarium/aquarium_screen.dart';

import '../../state_management/coin_state.dart';

class ShopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ShopScreenCubit(ShopScreenState(coinCount: 0, tabBarIndex: 0)),
      child: Builder(
        builder: (BuildContext context) {
          return _buildWidget(context);
        },
      ),
    );
  }

  Widget _buildWidget(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: TabBarView(
        controller: context.watch<ShopScreenCubit>().tabController,
        children: [
          _buildFishTab(context),
          _buildDecorationsTab(),
          // _buildUpgradesTab(),
        ],
      ),
    );
  }

  Widget _buildFishTab(BuildContext context) {
    final cubit = context.watch<ShopScreenCubit>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBuyButton('Buy Clownfish', () {
            cubit.buyFish('Clownfish');
          }),
        ],
      ),
    );
  }

  Widget _buildBuyButton(String buttonTitle, void Function() pressedCallback) {
    return ElevatedButton(
      onPressed: () {
        pressedCallback();
      },
      child: Text(buttonTitle),
    );
  }

  void buyFish(String type) {}

  _buildDecorationsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildBuyButton('Buy Decoration', () {}),
        ],
      ),
    );
  }
}
