import 'dart:ffi';

import 'package:intl/intl.dart';

class DiaryEntry {
  final int? diary_id;
  final double weight;
  final String date;
  final int food_id;

  DiaryEntry({
    this.diary_id,
    required this.weight,
    required this.date,
    required this.food_id,
  });

  Map<String, dynamic> toMap() {
    return {
      'diary_id': diary_id,
      'weight': weight,
      'date': date,
      'food_id': food_id,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    DiaryEntry diaryEntry = DiaryEntry(
    diary_id:  map['diary_id'] as int,
    weight:  map['weight'].toDouble(),
    date:  map['date'] as String,
    food_id:  map['food_id'] as int,
    );
    return diaryEntry;
  }
}
