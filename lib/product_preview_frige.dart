import 'dart:convert';
import 'dart:ffi';
import 'package:dieahnungslosen/database_helper.dart';
import 'package:dieahnungslosen/diary_entry.dart';
import 'package:dieahnungslosen/fridge.dart';
import 'package:dieahnungslosen/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:openfoodfacts/utils/ProductFields.dart';
import 'package:openfoodfacts/utils/ProductQueryConfigurations.dart';
import 'fridge_entry.dart';
import 'navbar.dart';
import 'own_product.dart';
import 'package:intl/intl.dart';

class ProductPreviewFridge extends StatefulWidget {
  final String _barcode;

  ProductPreviewFridge(this._barcode);

  @override
  State<ProductPreviewFridge> createState() => _ProductPreviewFridgeState();
}

class _ProductPreviewFridgeState extends State<ProductPreviewFridge> {
  OwnProduct? prod;
  int _groupValue = 1;
  DateFormat formatter = DateFormat('dd.MM.yyyy');
  DateTime? mhd = DateTime.now();
  @override
  Widget build(BuildContext context) {
    TextEditingController anzahlController = TextEditingController();
    var foodId = 0;
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Produkt Vorschau'),
      ),
      body: Column(
        children: [
          Center(
            child: FutureBuilder<List?>(
                future: getProduct(widget._barcode),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var name = snapshot.data!.first['name'];
                    var marke = snapshot.data!.first['marke'];
                    var menge = snapshot.data!.first['menge'];
                    foodId = snapshot.data!.first['food_id'];
                    return Column(
                      children: [
                        buildTextFormFieldDisabled('Produktname', name),
                        buildTextFormFieldDisabled('Produktmarke', marke),
                        buildTextFormFieldDisabled('Menge', menge),
                        ListTile(title: Text('Mindesthaltbarkeitsdatum: ')),
                        IconButton(
                          icon: Icon(Icons.edit_calendar),
                          onPressed: () async {
                            mhd = await showDatePicker(context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(0000),
                                lastDate: DateTime(9999, 12, 31));
                          },),
                        ListTile(
                          title: Text('Anzahl: '),
                        ),
                        buildTextFormField('Anzahl', anzahlController),
                        IconButton(
                          onPressed: () async {
                            // var formatter =
                            //     DateFormat('yyyy-MM-dd hh:mm:ss');
                            FridgeEntry entry = FridgeEntry(
                              amount: int.parse(anzahlController.text),
                              mhd: formatter.format(mhd).toString(),
                              food_id: foodId,
                            );
                            DatabaseHelper.instance.addFridgeEntry(entry);
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
                    return Text('Lädt...');
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

  Future<List?> getProduct(String barcode) async {
    if (await DatabaseHelper.instance.checkProduct(barcode)) {
      return DatabaseHelper.instance.getOneProduct(barcode);
    } else {
      ProductResult result = await apiConfigurator(barcode);
      OwnProduct productObj = apiGetProduct(result, barcode);
      DatabaseHelper.instance.addProduct(productObj);
      return DatabaseHelper.instance.getOneProduct(barcode);
    }
  }

  OwnProduct apiGetProduct(ProductResult result, String barcode) {
    if (result.status == 1) {
      OwnProduct productApi = OwnProduct(
          barcode: jsonDecode(jsonEncode(result.product))['code'],
          name: jsonDecode(jsonEncode(result.product))['product_name'],
          marke: jsonDecode(jsonEncode(result.product))['brands'],
          menge: jsonDecode(jsonEncode(result.product))['quantity'],
          menge_ml: jsonDecode(jsonEncode(result.product))['product_quantity'],
          kalorien: jsonEncode(result.product?.nutriments?.energyKcal100g),
          fett: jsonEncode(result.product?.nutriments?.fat),
          gesaettigt: jsonEncode(result.product?.nutriments?.saturatedFat),
          kohlenhydrate: jsonEncode(result.product?.nutriments?.carbohydrates),
          davonZucker: jsonEncode(result.product?.nutriments?.sugars),
          eiweiss: jsonEncode(result.product?.nutriments?.proteins),
          salz: jsonEncode(result.product?.nutriments?.sodium));
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
}
