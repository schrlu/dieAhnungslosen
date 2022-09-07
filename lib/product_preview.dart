import 'dart:convert';
import 'dart:ffi';
import 'package:dieahnungslosen/database_helper.dart';
import 'package:dieahnungslosen/diary_entry.dart';
import 'package:dieahnungslosen/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:openfoodfacts/utils/ProductFields.dart';
import 'package:openfoodfacts/utils/ProductQueryConfigurations.dart';
import 'navbar.dart';
import 'own_product.dart';
import 'package:intl/intl.dart';

class ProductPreview extends StatelessWidget {
  final String _barcode;

  ProductPreview(this._barcode);

  OwnProduct? prod;

  @override
  Widget build(BuildContext context) {
    TextEditingController mengeController = TextEditingController();
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
                future: getProduct(_barcode),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var name = snapshot.data!.first['name'];
                    var marke = snapshot.data!.first['marke'];
                    foodId = snapshot.data!.first['food_id'];
                    // prod = snapshot.data!;
                    return Column(
                      children: [
                        buildTextFormFieldDisabled('Produktname', name),
                        buildTextFormFieldDisabled('Produktmarke', marke),
                        buildTextFormField('Menge in g/ml', mengeController),
                      ],
                    );
                  } else {
                    return Text('Keine Daten gefunden');
                  }
                }),
          ),
          Center(
            child: IconButton(
              onPressed: () async {
                var now = new DateTime.now();
                var formatter = new DateFormat('dd-MM-yyyy');
                String formattedDate = formatter.format(now);
                  DiaryEntry entry = DiaryEntry(
                  weight: double.parse(mengeController.text),
                  date: formattedDate,
                  food_id: foodId,
                );
                DatabaseHelper.instance.addDiaryEntry(entry);
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => FoodDiary()),
                    (route) => false);
              },
              icon: Icon(Icons.check, color: Colors.green),
            ),
          )
        ],
      ),
    );
  }

  TextFormField buildTextFormFieldDisabled(String decoration, [name]) {
    return TextFormField(
      initialValue: '$decoration $name',
      enabled: false,
      decoration: (InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20))),
    );
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
          kalorien: jsonEncode(result.product?.nutriments?.energyKcal100g),
          fett: jsonEncode(result.product?.nutriments?.fat),
          gesaettigt: jsonEncode(result.product?.nutriments?.saturatedFat),
          kohlenhydrate: jsonEncode(result.product?.nutriments?.carbohydrates),
          davonZucker: jsonEncode(result.product?.nutriments?.sugars),
          eiweiss: jsonEncode(result.product?.nutriments?.proteins),
          salz: jsonDecode(jsonEncode(result.product))['salt_100g']);
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
