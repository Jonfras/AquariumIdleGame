import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:aquarium_idle_game/state_management/coin_state.dart';
import 'package:aquarium_idle_game/state_management/fish_state.dart';
import 'package:aquarium_idle_game/widgets/coin_counter/coin_counter.dart';
import 'package:aquarium_idle_game/widgets/animated_fish.dart';

import 'aquarium_screen_cubit.dart';
import 'aquarium_screen_state.dart';

class AquariumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AquariumScreenCubit>();
    
    return BlocProvider(
        create: (context) => AquariumScreenCubit(AquariumScreenState()),
        child:
        Builder(builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Aquarium Idle')),
            body: GestureDetector(
              onTap: () => cubit.incrementCoins(),
              child: Container(
                color: Colors.lightBlue,
                child: Stack(
                  children: [
                    // Coin-Counter
                    const Align(
                      alignment: Alignment.topRight,
                      child: Padding(padding: EdgeInsets.all(16.0), child: CoinCounter()),
                    ),
                    ...cubit.state.fishList,
                    // Zentraler Text
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Klicke auf das Aquarium, um Coins zu sammeln!',
                            style: TextStyle(fontSize: 24, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        })

    );
  }
}
