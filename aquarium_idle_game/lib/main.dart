import 'package:aquarium_idle_game/views/aquarium/aquarium_screen_cubit.dart';
import 'package:aquarium_idle_game/views/aquarium/aquarium_screen_state.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen_cubit.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen_state.dart';
import 'package:aquarium_idle_game/widgets/coin_counter/coin_counter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aquarium_idle_game/views/aquarium/aquarium_screen.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen.dart';
import 'package:aquarium_idle_game/views/upgrades/upgrades_screen.dart';
import 'package:aquarium_idle_game/widgets/app_scaffold.dart';

void main() {
  runApp(AquariumIdleGame());
}

class AquariumIdleGame extends StatelessWidget {
  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => AppScaffold(child: AquariumScreen()),
      ),
      GoRoute(
        path: '/shop',
        builder: (context, state) => AppScaffold(child: ShopScreen()),
      ),
      GoRoute(
        path: '/upgrades',
        builder: (context, state) => AppScaffold(child: UpgradesScreen()),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => CoinCounterCubit(0)),
        BlocProvider(
          create:
              (context) => ShopScreenCubit(
                ShopScreenState(coinCount: 0, tabBarIndex: 0),
              ),
        ),
        BlocProvider(
          create: (context) => AquariumScreenCubit(AquariumScreenState()),
        ),
      ],

      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Aquarium Idle Game',
            theme: ThemeData(primarySwatch: Colors.blue),
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
