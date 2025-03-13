import 'package:bloc/bloc.dart';

import '../../state_management/coin_repo.dart';

class CoinCounterCubit extends Cubit<int> {
  CoinCounterCubit(super.initialState){
    _setupListeners();
  }

  final coinRepo = CoinRepo();
  late final coinListener;
  
  void _setupListeners() {
    coinListener = coinRepo.coinSubject.listen((event) {
      emit(event);
    });
  }
  
  @override
  Future<void> close() {
    coinListener.cancel();
    return super.close();
  }
}