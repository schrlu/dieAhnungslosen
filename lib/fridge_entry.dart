import 'dart:ffi';

import 'package:intl/intl.dart';

class FridgeEntry {
  final int? fridge_id;
  int amount;
  String mhd;
  final int food_id;

  FridgeEntry({
    this.fridge_id,
    required this.amount,
    required this.mhd,
    required this.food_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'fridge_id': fridge_id,
      'amount': amount,
      'mhd': mhd,
      'food_id': food_id,
    };
  }

  factory FridgeEntry.fromMap(Map<String, dynamic> map) {
    FridgeEntry diaryEntry = FridgeEntry(
    fridge_id:  map['diary_id'] as int,
    amount:  map['amount'] as int,
    mhd:  map['mhd'] as String,
    food_id:  map['food_id'] as int,
    );
    return diaryEntry;
  }
}
