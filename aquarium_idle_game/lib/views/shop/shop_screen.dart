import 'package:aquarium_idle_game/views/shop/shop_screen_cubit.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aquarium_idle_game/util/fish_factory.dart';

import '../../util/decoration_factory.dart';

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
          tabs: const [
            Tab(text: 'Fish'),
            Tab(text: 'Decorations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: context.watch<ShopScreenCubit>().tabController,
        children: [
          _buildFishTab(context),
          _buildDecorationsTab(context),
        ],
      ),
    );
  }

  Widget _buildFishTab(BuildContext context) {
    final cubit = context.watch<ShopScreenCubit>();
    final fishFactory = FishFactory();
    final fishTypes = fishFactory.fishTypes;
    final coinCount = cubit.state.coinCount;

    return Column(
      children: [
        // Coin display
        Container(
          padding: const EdgeInsets.all(16.0),
          alignment: Alignment.centerRight,
          child: Text(
            'Coins: $coinCount',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Fish grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75, // Adjusted for more height
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: fishTypes.length,
            itemBuilder: (context, index) {
              final fishType = fishTypes[index];
              final fish = fishFactory.getFish(fishType);
              final canAfford = coinCount >= fish.price;

              return Card(
                elevation: 4,
                child: Column(
                  children: [
                    // Fish image
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: fish.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        child: Center(
                          child: Icon(
                            Icons.pets,
                            color: fish.color,
                            size: 50,
                          ),
                        ),
                      ),
                    ),

                    // Fish info - Fixed height container
                    Container(
                      height: 70, // Fixed height for info section
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            fishType,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Price: ${fish.price} coins',
                            style: TextStyle(
                              color: canAfford ? Colors.green : Colors.red,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bonus: +${fish.clickBonus}',
                            style: const TextStyle(fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Buy button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: canAfford ? () => cubit.buyFish(fishType) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford ? Colors.blue : Colors.grey,
                          minimumSize: const Size(100, 32),
                        ),
                        child: const Text('Buy'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDecorationsTab(BuildContext context) {
    final cubit = context.watch<ShopScreenCubit>();
    final decorationFactory = DecorationFactory();
    final decorationTypes = decorationFactory.decorationTypes;
    final coinCount = cubit.state.coinCount;
    final passiveIncome = cubit.state.passiveIncome;

    return Column(
      children: [
        // Coin and passive income display
        Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Passive Income: +$passiveIncome/sec',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Coins: $coinCount',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Decoration grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12.0),
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
              final canAfford = coinCount >= decoration.price;

              return Card(
                elevation: 4,
                child: Column(
                  children: [
                    // Decoration image
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: decoration.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.all(8),
                        child: Center(
                          child: Icon(
                            Icons.landscape,
                            color: decoration.color,
                            size: 50,
                          ),
                        ),
                      ),
                    ),

                    // Decoration info
                    Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            decorationType,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Price: ${decoration.price} coins',
                            style: TextStyle(
                              color: canAfford ? Colors.green : Colors.red,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Income: +${decoration.passiveIncome}/sec',
                            style: const TextStyle(fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Buy button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: canAfford ? () => cubit.buyDecoration(decorationType) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canAfford ? Colors.blue : Colors.grey,
                          minimumSize: const Size(100, 32),
                        ),
                        child: const Text('Buy'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}