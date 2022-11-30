import 'package:openfoodfacts/utils/PnnsGroups.dart';

class OwnProduct {
  int? food_id;
  String? barcode;
  String? name;
  String? brand;
  String? quantity;
  double? quantity_ml;
  String? calories;
  String? fat;
  String? saturated;
  String? carbohydrates;
  String? sugar;
  String? protein;
  String? salt;
  //Konstruktor
  OwnProduct(
      {this.food_id,
      this.barcode,
      this.name,
      this.brand,
      this.quantity,
        this.quantity_ml,
      this.calories,
      this.fat,
      this.saturated,
      this.carbohydrates,
      this.sugar,
      this.protein,
      this.salt});

  Map<String, dynamic> toMap() {
    return {
      'food_id': food_id,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'quantity': quantity,
      'quantity_ml': quantity_ml,
      'calories': calories,
      'fat': fat,
      'saturated': saturated,
      'carbohydrates': carbohydrates,
      'sugar': sugar,
      'protein': protein,
      'salt': salt
    };
  }

  factory OwnProduct.fromMap(Map<String, dynamic> map) {
    return OwnProduct(
        food_id: map['food_id'],
        barcode: map['barcode'],
        name: map['name'],
        brand: map['brand'],
        quantity: map['quantity'],
        quantity_ml: map['quantity_ml'].toDouble() as double,
        calories: map['calories'],
        fat: map['fat'],
        saturated: map['saturated'],
        carbohydrates: map['carbohydrates'],
        sugar: map['sugar'],
        protein: map['protein'],
        salt: map['salt']);
  }
}
