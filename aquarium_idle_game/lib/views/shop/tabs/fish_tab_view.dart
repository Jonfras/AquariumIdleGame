import 'package:aquarium_idle_game/util/fish_factory.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen_cubit.dart';
import 'package:aquarium_idle_game/views/shop/widgets/shop_item_card.dart';
import 'package:aquarium_idle_game/views/shop/widgets/transparent_header.dart';
import 'package:aquarium_idle_game/widgets/coin_counter/coin_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FishTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ShopScreenCubit>();
    final fishFactory = FishFactory();
    final fishTypes = fishFactory.fishTypes;
    final coinCount = cubit.state.coinCount;

    return Stack(
      children: [
        // Scrollable grid
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            padding: const EdgeInsets.only(top: 50),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: fishTypes.length,
            itemBuilder: (context, index) {
              final fishType = fishTypes[index];
              final fish = fishFactory.getFish(fishType);
              final canAfford = coinCount >= fish.price;

              return ShopItemCard.forFish(
                fish: fish,
                fishType: fishType,
                canAfford: canAfford,
                onBuy: () => cubit.buyFish(fishType),
              );
            },
          ),
        ),

        // Header
        const TransparentHeader(
          title: 'Available Fish',
          trailingWidget: CoinCounter(),
        ),
      ],
    );
  }
}