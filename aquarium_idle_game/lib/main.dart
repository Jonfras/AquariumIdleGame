import 'dart:async';
import 'package:aquarium_idle_game/views/aquarium/aquarium_screen_cubit.dart';
import 'package:aquarium_idle_game/views/aquarium/aquarium_screen_state.dart';
import 'package:aquarium_idle_game/views/aquarium/aquarium_screen_wrapper.dart';
import 'package:aquarium_idle_game/views/login/cubit/auth_cubit.dart';
import 'package:aquarium_idle_game/views/login/login_view.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen_cubit.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen_state.dart';
import 'package:aquarium_idle_game/widgets/coin_counter/coin_counter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:aquarium_idle_game/views/aquarium/aquarium_screen.dart';
import 'package:aquarium_idle_game/views/shop/shop_screen.dart';
import 'package:aquarium_idle_game/views/settings/settings_screen.dart';
import 'package:aquarium_idle_game/widgets/app_scaffold.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authCubit = AuthCubit();
  runApp(AquariumIdleGame(authCubit: authCubit));
}

class AquariumIdleGame extends StatelessWidget {
  final AuthCubit authCubit;

  AquariumIdleGame({Key? key, required this.authCubit}) : super(key: key);

  late final GoRouter _router = GoRouter(
    initialLocation: '/login',
    redirect: _handleRedirect,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => AppScaffold(child: AquariumScreenWrapper()),
      ),
      GoRoute(
        path: '/shop',
        builder: (context, state) => AppScaffold(child: ShopScreen()),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
  );

  Future<String?> _handleRedirect(BuildContext context, GoRouterState state) async {
    final isLoggedIn = await authCubit.isLoggedIn();
    final isLoginRoute = state.uri.toString() == '/login';

    // If user is not logged in and not on login page, redirect to login
    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }

    // If user is logged in and on login page, redirect to home
    if (isLoggedIn && isLoginRoute) {
      return '/';
    }

    // Otherwise no redirection needed
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(create: (context) => CoinCounterCubit(0)),
        BlocProvider(
          create: (context) => ShopScreenCubit(
            ShopScreenState(coinCount: 0, tabBarIndex: 0),
          ),
        ),
        // Remove AquariumScreenCubit from here
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

// Helper class to convert auth stream to a Listenable for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}