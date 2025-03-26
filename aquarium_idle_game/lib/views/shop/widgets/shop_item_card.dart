import 'package:aquarium_idle_game/model/decoration.dart' as model;
import 'package:aquarium_idle_game/model/fish.dart';
import 'package:aquarium_idle_game/widgets/animated_decoration.dart';
import 'package:aquarium_idle_game/widgets/animated_fish.dart';
import 'package:flutter/material.dart';

class ShopItemCard extends StatelessWidget {
  final dynamic item;
  final String itemType;
  final bool canAfford;
  final VoidCallback onBuy;
  final IconData iconData;
  final String bonusLabel;
  final dynamic bonusValue;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.itemType,
    required this.canAfford,
    required this.onBuy,
    required this.iconData,
    required this.bonusLabel,
    required this.bonusValue,
  });

  // Factory constructor for creating a fish card
  factory ShopItemCard.forFish({
    required Fish fish,
    required String fishType,
    required bool canAfford,
    required VoidCallback onBuy,
  }) {
    return ShopItemCard(
      item: fish,
      itemType: fishType,
      canAfford: canAfford,
      onBuy: onBuy,
      iconData: Icons.pets,
      bonusLabel: 'Bonus',
      bonusValue: fish.clickBonus,
    );
  }

  // Factory constructor for creating a decoration card
  factory ShopItemCard.forDecoration({
    required model.Decoration decoration,
    required String decorationType,
    required bool canAfford,
    required VoidCallback onBuy,
  }) {
    return ShopItemCard(
      item: decoration,
      itemType: decorationType,
      canAfford: canAfford,
      onBuy: onBuy,
      iconData: Icons.landscape,
      bonusLabel: 'Income',
      bonusValue: decoration.passiveIncome,
    );
  }

  Widget _buildItemPreview() {
    if (item is Fish) {
      return AnimatedFish(
        fish: item as Fish,
        isPreview: true,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.pets, color: (item as Fish).color, size: 50);
        },
      );
    } else if (item is model.Decoration) {
      return AnimatedDecoration(
        decoration: item as model.Decoration,
        isPreview: true,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.landscape, color: (item as model.Decoration).color, size: 50);
        },
      );
    } else {
      return Icon(iconData, color: item.color, size: 50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              child: Center(child: _buildItemPreview()),
            ),
          ),
          Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  itemType,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Price: ${item.price} coins',
                  style: TextStyle(color: canAfford ? Colors.green : Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '$bonusLabel: +$bonusValue${bonusLabel == 'Income' ? '/sec' : ''}',
                  style: const TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: canAfford ? onBuy : null,
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
  }
}