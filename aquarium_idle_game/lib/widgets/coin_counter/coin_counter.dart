import 'package:aquarium_idle_game/widgets/coin_counter/coin_counter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class CoinCounter extends StatelessWidget {
  const CoinCounter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CoinCounterCubit(0),
      child: Builder(
        builder: (context) {
          final cubit = context.watch<CoinCounterCubit>();
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            color: Colors.white.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.yellow),
                  const SizedBox(width: 8),
                  Text('${cubit.state} Coins', style: const TextStyle(fontSize: 18, color: Colors.black87)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
