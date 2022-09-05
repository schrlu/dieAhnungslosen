import 'package:openfoodfacts/utils/PnnsGroups.dart';

class OwnProduct {
  int? food_id;
  String? name;
  String? marke;
  String? menge;
  String? kalorien;
  String? fett;
  String? gesaettigt;
  String? kohlenhydrate;
  String? davonZucker;
  String? eiweiss;
  String? salz;

  OwnProduct(
      {this.food_id,
      required this.name,
      this.marke,
      this.menge,
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
      'name': name,
      'marke': marke,
      'menge': menge,
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
        name: map['name'],
        marke: map['marke'],
        menge: map['menge'],
        kalorien: map['kalorien'],
        fett: map['fett'],
        gesaettigt: map['gesaettigt'],
        kohlenhydrate: map['kohlenhydrate'],
        davonZucker: map['davonZucker'],
        eiweiss: map['eiweiss'],
        salz: map['salz']);
  }

}
