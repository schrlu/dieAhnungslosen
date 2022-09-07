import 'package:openfoodfacts/utils/PnnsGroups.dart';

class OwnProduct {
  int? food_id;
  String? barcode;
  String? name;
  String? marke;
  String? menge;
  double? menge_ml;
  String? kalorien;
  String? fett;
  String? gesaettigt;
  String? kohlenhydrate;
  String? davonZucker;
  String? eiweiss;
  String? salz;

  OwnProduct(
      {this.food_id,
      this.barcode,
      this.name,
      this.marke,
      this.menge,
        this.menge_ml,
      this.kalorien,
      this.fett,
      this.gesaettigt,
      this.kohlenhydrate,
      this.davonZucker,
      this.eiweiss,
      this.salz});

  Map<String, dynamic> toMap() {
    return {
      'food_id': food_id,
      'barcode': barcode,
      'name': name,
      'marke': marke,
      'menge': menge,
      'menge_ml': menge_ml,
      'kalorien': kalorien,
      'fett': fett,
      'gesaettigt': gesaettigt,
      'kohlenhydrate': kohlenhydrate,
      'davonZucker': davonZucker,
      'eiweiss': eiweiss,
      'salz': salz
    };
  }

  factory OwnProduct.fromMap(Map<String, dynamic> map) {
    return OwnProduct(
        food_id: map['food_id'],
        barcode: map['barcode'],
        name: map['name'],
        marke: map['marke'],
        menge: map['menge'],
        menge_ml: map['menge_ml'].toDouble() as double,
        kalorien: map['kalorien'],
        fett: map['fett'],
        gesaettigt: map['gesaettigt'],
        kohlenhydrate: map['kohlenhydrate'],
        davonZucker: map['davonZucker'],
        eiweiss: map['eiweiss'],
        salz: map['salz']);
  }
}
