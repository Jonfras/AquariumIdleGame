import 'package:aquarium_idle_game/util/decoration_factory.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen_cubit.dart';
import 'package:aquarium_idle_game/views/shop/widgets/shop_item_card.dart';
import 'package:aquarium_idle_game/views/shop/widgets/transparent_header.dart';
import 'package:aquarium_idle_game/widgets/coin_counter/coin_counter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DecorationsTabView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ShopScreenCubit>();
    final decorationFactory = DecorationFactory();
    final decorationTypes = decorationFactory.decorationTypes;
    final passiveIncome = cubit.state.passiveIncome;

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
            itemCount: decorationTypes.length,
            itemBuilder: (context, index) {
              final decorationType = decorationTypes[index];
              final decoration = decorationFactory.getDecoration(decorationType);
              final canAfford = cubit.state.coinCount >= decoration.price;

              return ShopItemCard.forDecoration(
                decoration: decoration,
                decorationType: decorationType,
                canAfford: canAfford,
                onBuy: () => cubit.buyDecoration(decorationType),
              );
            },
          ),
        ),

        // Header
        TransparentHeader(
          title: 'Passive Income: +$passiveIncome/sec',
          trailingWidget: const CoinCounter(),
        ),
      ],
    );
  }
}