import 'dart:convert';

import 'package:dieahnungslosen/database_helper.dart';
import 'package:dieahnungslosen/diary_entry.dart';
import 'package:dieahnungslosen/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:openfoodfacts/utils/ProductFields.dart';
import 'package:openfoodfacts/utils/ProductQueryConfigurations.dart';

import 'navbar.dart';
import 'own_product.dart';

class ProductPreview extends StatefulWidget {
  final String _barcode;

  //Konstruktor
  ProductPreview(this._barcode);

  @override
  State<ProductPreview> createState() => _ProductPreviewState();
}

class _ProductPreviewState extends State<ProductPreview> {
  late String _barcode;
  OwnProduct? prod;
  int _groupValue = 1;
  DateFormat ymd = DateFormat('yyyy-MM-dd');
  DateFormat dmy = DateFormat('dd.MM.yyyy');
  DateTime start = DateTime(0000, 1, 1);
  DateTime end = DateTime(9999, 12, 31);
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    TextEditingController quantityController = TextEditingController();
    var foodId = 0;
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Produkt Vorschau'),
      ),
      body: Column(
        children: [
          Center(
            //Produkt mithilfe des gescannten Barcodes aus der Datenbank oder API lesen
            child: FutureBuilder<List?>(
                future: getProduct(widget._barcode),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var name = snapshot.data!.first['name'];
                    var brand = snapshot.data!.first['brand'];
                    foodId = snapshot.data!.first['food_id'];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildTextFormFieldDisabled('Produktmarke:', brand, 'diaryPreviewBrand'),
                        buildTextFormFieldDisabled('Produktname:', name, 'diaryPreviewName'),
                        //Angabe des Eintragsdatums
                        TextButton(
                          onPressed: () async {
                            date = (await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(0000),
                                lastDate: DateTime(9999, 12, 31)))!;
                            setState(() {});
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 12),
                            child: Text(
                              'Datum: ${dmy.format(date)}',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                        //Festlegen der quantity
                        const ListTile(
                          title: Text('Menge in g/ml'),
                        ),
                        RadioListTile(
                          value: 1,
                          groupValue: _groupValue,
                          onChanged: (newValue) => setState(() =>
                              _groupValue = int.parse(newValue.toString())),
                          title: Text(
                              'Standardmenge: (${snapshot.data!.first['quantity_ml']})'),
                        ),
                        RadioListTile(
                          value: 2,
                          groupValue: _groupValue,
                          onChanged: (newValue) => setState(() =>
                              _groupValue = int.parse(newValue.toString())),
                          title: buildTextFormField(
                              'Andere Menge', quantityController),
                        ),
                        //Bestätigungsbutton
                        IconButton(
                          onPressed: () async {
                            String formattedDate = ymd.format(date);
                            DiaryEntry entry = DiaryEntry(
                              weight: getWeight(
                                  snapshot.data!.first['quantity_ml'],
                                  quantityController.text),
                              date: formattedDate,
                              food_id: foodId,
                            );
                            await DatabaseHelper.instance.addDiaryEntry(entry);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FoodDiary()),
                                (route) => false);
                          },
                          icon: Icon(Icons.check, color: Colors.green),
                        )
                      ],
                    );
                  } else {
                    //Erneut versuchen oder abbrechen bei Fehlschlag des Scans
                    return Container(
                      child: Column(
                        children: [
                          Text('Scan fehlgeschlagen', key: Key('failed'),),
                          TextButton(
                              onPressed: () async {
                                await scan();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProductPreview(_barcode),
                                    ));
                              },
                              child: Text('erneut versuchen')),
                          Text(''),
                          TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => FoodDiary()),
                                    (route) => false);
                              },
                              child: Text('abbrechen')),
                        ],
                      ),
                    );
                  }
                }),
          ),
        ],
      ),
    );
  }

  double getWeight(int weight, String controller) {
    if (_groupValue == 1) {
      return double.parse(weight.toString());
    } else {
      return double.parse(controller);
    }
  }

  TextFormField buildTextFormFieldDisabled(String decoration, String name, String keyValue) {
    return TextFormField(
      initialValue: '$decoration $name',
      key: Key(keyValue),
      enabled: false,
      decoration: (InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20))),
    );
  }

  bool checkGroupValue() {
    return _groupValue != 1;
  }

  TextFormField buildTextFormField(
      String decoration, TextEditingController controller) {
    return TextFormField(
      keyboardType: TextInputType.number,
      controller: controller,
      enabled: checkGroupValue(),
      decoration: (InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          hintText: '$decoration')),
    );
  }

  //Wenn ein Produkt mit dem Barcode bereits vorhanden ist, wird dies benutzt, wenn nicht, dann wird über die API danach gesucht
  Future<List?> getProduct(String barcode) async {
    if (await DatabaseHelper.instance.checkProduct(barcode)) {
      return DatabaseHelper.instance.getOneProductFromBarcode(barcode);
    } else {
      ProductResult result = await apiConfigurator(barcode);
      OwnProduct productObj = apiGetProduct(result, barcode);
      DatabaseHelper.instance.addProduct(productObj);
      return DatabaseHelper.instance.getOneProductFromBarcode(barcode);
    }
  }

  //Erstellen eines Produkt aus den Daten der API
  OwnProduct apiGetProduct(ProductResult result, String barcode) {
    if (result.status == 1) {
      OwnProduct productApi = OwnProduct(
          barcode: jsonDecode(jsonEncode(result.product))['code'],
          name: jsonDecode(jsonEncode(result.product))['product_name'],
          brand: jsonDecode(jsonEncode(result.product))['brands'],
          quantity: jsonDecode(jsonEncode(result.product))['quantity'],
          quantity_ml:
              jsonDecode(jsonEncode(result.product))['product_quantity'],
          calories: jsonEncode(result.product?.nutriments?.energyKcal100g),
          fat: jsonEncode(result.product?.nutriments?.fat),
          saturated: jsonEncode(result.product?.nutriments?.saturatedFat),
          carbohydrates: jsonEncode(result.product?.nutriments?.carbohydrates),
          sugar: jsonEncode(result.product?.nutriments?.sugars),
          protein: jsonEncode(result.product?.nutriments?.proteins),
          salt: jsonEncode(result.product?.nutriments?.salt));
      DatabaseHelper.instance.addProduct(productApi);
      return productApi;
    } else {
      throw Exception('product not found, please insert data for $barcode');
    }
  }

  Future<ProductResult> apiConfigurator(String barcode) async {
    ProductQueryConfiguration configuration = ProductQueryConfiguration(barcode,
        language: OpenFoodFactsLanguage.GERMAN, fields: [ProductField.ALL]);
    ProductResult result = await OpenFoodAPIClient.getProduct(configuration);
    return result;
  }

  scan() async {
    return await FlutterBarcodeScanner.scanBarcode(
            "#000000", 'Abbrechen', true, ScanMode.BARCODE)
        .then((value) => setState(() => _barcode = value));
  }
}
