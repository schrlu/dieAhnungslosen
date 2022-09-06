class DiaryEntry {
  int? diary_id;
  String? weight;
  String? date;
  int? food_id;

  DiaryEntry({this.diary_id,
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
    return DiaryEntry(
      diary_id: map['diary_id'],
      weight: map['weight'],
      date: map['date'],
      food_id: map['food_id'],
    );
  }
}
