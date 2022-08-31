import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dieahnungslosen/navbar.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:openfoodfacts/model/Product.dart';
import 'package:openfoodfacts/model/ProductList.dart';
import 'package:openfoodfacts/model/UserAgent.dart';
import 'package:openfoodfacts/utils/PnnsGroups.dart';
import 'package:openfoodfacts/utils/ProductQueryConfigurations.dart';
import 'dart:async';
import 'package:openfoodfacts/model/OcrIngredientsResult.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:openfoodfacts/utils/TagType.dart';

void main() => runApp(MaterialApp(home: FoodDiary()));

class FoodDiary extends StatefulWidget {
  const FoodDiary({Key? key}) : super(key: key);

  @override
  State<FoodDiary> createState() => FoodDiaryState();
}

class FoodDiaryState extends State<FoodDiary> {
  Future<String?> getProduct(String barcode) async {
    // var barcode = '0048151623426';

    ProductQueryConfiguration configuration = ProductQueryConfiguration(barcode,
        language: OpenFoodFactsLanguage.GERMAN, fields: [ProductField.ALL]);
    ProductResult result = await OpenFoodAPIClient.getProduct(configuration);

    if (result.status == 1) {
      // return result.product;
      print(jsonEncode(result.product));
      return jsonEncode(result.product);
    } else {
      throw Exception('product not found, please insert data for $barcode');
    }
  }

  String _barcode = "";

  scan() async {
    return await FlutterBarcodeScanner.scanBarcode(
        "#000000", 'Abbrechen', true, ScanMode.BARCODE)
        .then((value) => setState(() => _barcode = value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
          title: const Text('Ernährungstagebuch'),
        ),
        body: Column(
          children: [
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(20),
              children: [
                FutureBuilder<String?>(
                    future: getProduct(_barcode),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        String data = snapshot.data!;
                        String productJson = jsonDecode(data)['product_name'];
                        OwnProduct product = new OwnProduct(name: jsonDecode(data)['product_name'],
                            marke: jsonDecode(data)['brands'],
                            menge: jsonDecode(data)['quantity'],
                            bildurl: jsonDecode(data)['image_front_url']);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            product.name != null?
                            Text('Produktbezeichnung: ${product.name}') : Text('Kein Name gefunden'),
                            product.marke != null?
                            Text('Marke: ${product.marke}') : Text('Keine Marke gefunden'),
                            product.menge != null?
                            Text('Menge: ${product.menge}') : Text('Keine Menge gefunden'),
                            product.bildurl != null?
                            Image.network(product.bildurl) : Text('Kein Bild gefunden')
                          ],
                        );
                      } else{
                        return Text('waiting');
                      }
                    })
              ],
            ),
          ],
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Manueller Eintrag'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        eingabefeld('Bezeichnung', 'Name'),
                        eingabefeld('Menge in Gramm', 'Menge'),
                        eingabefeld('bla bla', 'bla bla'),
                        TextButton(
                            onPressed: () => {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      successWindow(FoodDiary()))
                            },
                            child: Text('Submit')),
                      ],
                    ),
                  )),
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            Padding(
                padding: EdgeInsets.only(top: 15),
                child: FloatingActionButton(
                    onPressed: () => scan(), child: Icon(Icons.camera_alt))),
          ],
        ));
  }
}

class eingabefeld extends StatelessWidget {
  String title;
  String decoration;

  eingabefeld(this.title, this.decoration);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, textAlign: TextAlign.left),
        TextField(decoration: InputDecoration(hintText: decoration)),
        const Padding(padding: EdgeInsets.only(bottom: 30)),
      ],
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
    );
  }
}

class successWindow extends StatelessWidget {
  Widget page;

  successWindow(this.page);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AlertDialog(
        title: Text('Success'),
        content: IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => page),
                    (route) => false);
          },
          icon: Icon(Icons.check, color: Colors.green),
        ),
      ),
    );
  }
}

class OwnProduct{
  String name;
  String marke;
  String menge;
  String bildurl;

  OwnProduct({required this.name, required this.marke, required this.menge, required this.bildurl });
}