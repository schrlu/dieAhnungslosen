

class DiaryEntry {
  int? id;
  DateTime? date;
  int? foodId;
  int? weight;

  DiaryEntry(
      {required this.id,
        required this.date,
        required this.foodId,
        required this.weight
        });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'foodId': foodId,
      'weight': weight,
    };
  }

  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
        id: map['id'],
        date: map['date'],
        foodId: map['foodId'],
        weight: map['weight']);
  }
}
