import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../widgets/animated_decoration.dart';
import '../../widgets/background_widget.dart';
import '../../widgets/coin_counter/coin_counter.dart';
import 'aquarium_screen_cubit.dart';

class AquariumScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<AquariumScreenCubit>();

    return Scaffold(
      body: GestureDetector(
        onTap: () => cubit.incrementCoins(),
        child: Container(
          color: Colors.lightBlue,
          child: Stack(
            children: [
              BackgroundWidget(
                speed: 1,
              ),
              // Coin-Counter
              const Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CoinCounter(),
                ),
              ),

              if (cubit.state.decorationList.isNotEmpty)
                for (var decoration in cubit.state.decorationList) decoration,

              // Fish List - Create a list of widgets from the state
              if (cubit.state.fishList.isNotEmpty)
                for (var fish in cubit.state.fishList) fish,
              // Inside Stack in AquariumScreen
              // Add after fish list
              // Decorations list - similar to fish list


              // We'll use a Builder to access the Scaffold context for showing the SnackBar
              Builder(
                builder: (context) {
                  // Use post-frame callback to show snackbar after build completes
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!cubit.state.hasShownWelcomeMessage) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Klicke auf das Aquarium, um Coins zu sammeln!',
                          ),
                          duration: Duration(seconds: 5),
                        ),
                      );
                      cubit.markWelcomeMessageAsShown();
                    }
                  });
                  return const SizedBox.shrink(); // No permanent UI element needed
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
