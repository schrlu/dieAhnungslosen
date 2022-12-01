import 'dart:convert';

import 'package:dieahnungslosen/database_helper.dart';
import 'package:dieahnungslosen/fridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:openfoodfacts/utils/ProductFields.dart';
import 'package:openfoodfacts/utils/ProductQueryConfigurations.dart';

import 'fridge_entry.dart';
import 'navbar.dart';
import 'own_product.dart';

class ProductPreviewFridge extends StatefulWidget {
  final String _barcode;

  //Konstruktor
  ProductPreviewFridge(this._barcode);

  @override
  State<ProductPreviewFridge> createState() => _ProductPreviewFridgeState();
}

class _ProductPreviewFridgeState extends State<ProductPreviewFridge> {
  late String _barcode;
  OwnProduct? prod;
  DateFormat ymd = DateFormat('yyyy-MM-dd');
  DateFormat dmy = DateFormat('dd.MM.yyyy');
  DateTime start = DateTime(0000, 1, 1);
  DateTime end = DateTime(9999, 12, 31);
  DateTime date = DateTime.now();
  int _groupValue = 1;

  @override
  Widget build(BuildContext context) {
    TextEditingController anzahlController = TextEditingController();
    var foodId = 0;
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text('Produkt Vorschau'),
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
                    var quantity = snapshot.data!.first['quantity'];
                    foodId = snapshot.data!.first['food_id'];
                    return Column(
                      children: [
                        buildTextFormFieldDisabled('Produktname', name),
                        buildTextFormFieldDisabled('Produktmarke', brand),
                        buildTextFormFieldDisabled('Menge', quantity),
                        //Angabe des Mindesthaltbarkeitsdatums
                        ListTile(
                          title: Text(
                              'Mindesthaltbarkeitsdatum: ${dmy.format(date)}'),
                          onTap: () async {
                            date = (await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(0000),
                                lastDate: DateTime(9999, 12, 31)))!;
                            setState(() {});
                          },
                        ),
                        //Festlegen der Anzahl
                        const ListTile(
                          title: Text('Anzahl:'),
                        ),
                        buildTextFormField('Anzahl', anzahlController),
                        //Bestätigungsbutton
                        IconButton(
                          onPressed: () async {
                            if (anzahlController.text == '') {
                              anzahlController.text = '1';
                            }
                            FridgeEntry entry = FridgeEntry(
                              amount: int.parse(anzahlController.text),
                              mhd: ymd.format(date).toString(),
                              food_id: foodId,
                            );
                            await DatabaseHelper.instance.addFridgeEntry(entry);
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WhatsInMyFridge()),
                                (route) => false);
                          },
                          icon: Icon(Icons.check, color: Colors.green),
                        )
                      ],
                    );
                  } else {
                    //Erneut versuchen oder abbrechen bei Fehlschlag des Scans
                    return Column(
                      children: [
                        const Text('Scan fehlgeschlagen'),
                        TextButton(
                            onPressed: () async {
                              await scan();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ProductPreviewFridge(_barcode),
                                  ));
                            },
                            child: const Text('erneut versuchen')),
                        const Text(''),
                        TextButton(
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const WhatsInMyFridge()),
                                  (route) => false);
                            },
                            child: const Text('abbrechen')),
                      ],
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

  TextFormField buildTextFormFieldDisabled(String decoration, [name]) {
    return TextFormField(
      initialValue: '$decoration $name',
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
          salt: jsonEncode(result.product?.nutriments?.sodium));
      DatabaseHelper.instance.addProduct(productApi);
      return productApi;
    } else {
      throw Exception('product not found, please insert data for $barcode');
    }
  }

  //Konfiguration der API
  Future<ProductResult> apiConfigurator(String barcode) async {
    ProductQueryConfiguration configuration = ProductQueryConfiguration(barcode,
        language: OpenFoodFactsLanguage.GERMAN, fields: [ProductField.ALL]);
    ProductResult result = await OpenFoodAPIClient.getProduct(configuration);
    return result;
  }

  //Barcode Scan-Funktion
  scan() async {
    return await FlutterBarcodeScanner.scanBarcode(
            "#000000", 'Abbrechen', true, ScanMode.BARCODE)
        .then((value) => setState(() => _barcode = value));
  }
}
