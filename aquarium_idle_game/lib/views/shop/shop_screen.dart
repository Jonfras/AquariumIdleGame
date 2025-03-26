import 'package:aquarium_idle_game/views/shop/shop_screen_cubit.dart';
import 'package:aquarium_idle_game/views/shop/tabs/decorations_tab_view.dart';
import 'package:aquarium_idle_game/views/shop/tabs/fish_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/background_widget.dart';

class ShopScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return _buildWidget(context);
      },
    );
  }

  Widget _buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        bottom: TabBar(
          controller: context.watch<ShopScreenCubit>().tabController,
          tabs: const [Tab(text: 'Fish'), Tab(text: 'Decorations')],
        ),
      ),
      body: Stack(
        children: [
          BackgroundWidget(speed: 1),
          TabBarView(
            controller: context.watch<ShopScreenCubit>().tabController,
            children: [
              FishTabView(),
              DecorationsTabView(),
            ],
          ),
        ],
      ),
    );
  }
}