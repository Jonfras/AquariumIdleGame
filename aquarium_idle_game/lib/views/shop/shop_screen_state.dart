class ShopScreenState {
  final int coinCount;
  final int tabBarIndex;
  final int passiveIncome;

  ShopScreenState({
    required this.coinCount,
    required this.tabBarIndex,
    this.passiveIncome = 0,
  });

  ShopScreenState copyWith({int? coinCount, int? tabBarIndex, int? passiveIncome}) {
    return ShopScreenState(
      coinCount: coinCount ?? this.coinCount,
      tabBarIndex: tabBarIndex ?? this.tabBarIndex,
      passiveIncome: passiveIncome ?? this.passiveIncome,
    );
  }
}