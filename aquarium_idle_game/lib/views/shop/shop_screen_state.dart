class ShopScreenState {
  final int coinCount;
  final int tabBarIndex;

  ShopScreenState({required this.coinCount, required this.tabBarIndex});

  ShopScreenState copyWith({int? coinCount, int? tabBarIndex}) {
    return ShopScreenState(coinCount: coinCount ?? this.coinCount, tabBarIndex: tabBarIndex ?? this.tabBarIndex);
  }
}
