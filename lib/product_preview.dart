import 'dart:convert';

import 'package:dieahnungslosen/database_helper.dart';
import 'package:dieahnungslosen/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/LanguageHelper.dart';
import 'package:openfoodfacts/utils/ProductFields.dart';
import 'package:openfoodfacts/utils/ProductQueryConfigurations.dart';
import 'navbar.dart';
import 'own_product.dart';

class ProductPreview extends StatelessWidget {
  final String _barcode;

  ProductPreview(this._barcode);

  OwnProduct? prod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Produkt Vorschau'),
      ),
      body: Column(
        children: [
          Center(
            child: FutureBuilder<OwnProduct?>(
                future: getProduct(_barcode),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    prod = snapshot.data!;

                    return Column(
                      children: [
                        Text('Produktname: ${prod?.name}'),
                        Text('Produktmarke ${prod?.marke}')
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

  Future<OwnProduct?> getProduct(String barcode) async {
    ProductQueryConfiguration configuration = ProductQueryConfiguration(barcode,
        language: OpenFoodFactsLanguage.GERMAN, fields: [ProductField.ALL]);
    ProductResult result = await OpenFoodAPIClient.getProduct(configuration);
    if (result.status == 1) {
      print(jsonDecode(jsonEncode(result.product)));
      OwnProduct product = OwnProduct(
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
      // print(jsonEncode(result.product?.nutriments));
      return product;
    } else {
      throw Exception('product not found, please insert data for $barcode');
    }
  }
}
