import 'package:aquarium_idle_game/views/aquarium/aquarium_screen.dart';
import 'package:aquarium_idle_game/views/aquarium/aquarium_screen_cubit.dart';
import 'package:aquarium_idle_game/views/aquarium/aquarium_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AquariumScreenWrapper extends StatelessWidget {
  const AquariumScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AquariumScreenCubit(AquariumScreenState()),
      child: AquariumScreen(),
    );
  }
}