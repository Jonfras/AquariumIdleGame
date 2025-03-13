import 'package:flutter/material.dart';

import '../model/fish.dart';

class FishState {
  List<Fish> _fishList = [];

  // Getter für die Liste aller Fische
  List<Fish> get fishList => _fishList;
  set fishList(List<Fish> fishList) => _fishList = fishList;

}