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
  Future<OwnProduct?> getProduct(String barcode) async {
    // var barcode = '0048151623426';

    ProductQueryConfiguration configuration = ProductQueryConfiguration('7622300315733',
        language: OpenFoodFactsLanguage.GERMAN, fields: [ProductField.ALL]);
    ProductResult result = await OpenFoodAPIClient.getProduct(configuration);
    if (result.status == 1) {
      // return result.product;

      OwnProduct product = OwnProduct(
          name: jsonEncode(result.product?.productName),
          marke: jsonEncode(result.product?.brands),
          menge: jsonEncode(result.product?.quantity),
          bildurl: jsonDecode(jsonEncode(result.product))['image_front_url'],
          kalorien:
          jsonEncode(result.product?.nutriments?.energyKcal100g),
          fett: jsonEncode(result.product?.nutriments?.fat),
          gesaettigt: jsonEncode(result.product?.nutriments?.saturatedFat),
          kohlenhydrate:
          jsonEncode(result.product?.nutriments?.carbohydrates),
          davonZucker:
          jsonEncode(result.product?.nutriments?.sugars),
          ballaststoffe:
          jsonEncode(result.product?.nutriments?.fiber),
          eiweiss:
          jsonEncode(result.product?.nutriments?.proteins),
          salz: jsonDecode(jsonEncode(result.product))['salt_100g']
      );
    print(jsonEncode(result.product?.nutriments));
    return product;
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
                FutureBuilder<OwnProduct?>(
                    future: getProduct(_barcode),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        OwnProduct producttest = snapshot.data!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            producttest.name != null
                                ? Text(
                                'Produktbezeichnung: ${producttest.name}')
                                : Text('Kein Name gefunden'),
                            producttest.marke != null
                                ? Text('Marke: ${producttest.marke}')
                                : Text('Keine Marke gefunden'),
                            producttest.menge != null
                                ? Text('Menge: ${producttest.menge}')
                                : Text('Keine Menge gefunden'),
                            Text(''),
                            Text('Nährwerte:'),
                            producttest.kalorien != null
                                ? Text('Energie: ${producttest.kalorien} kcal')
                                : Text('Keine Kalorien gefunden'),
                            producttest.fett != null
                                ? Text('Fett: ${producttest.fett}g')
                                : Text('Kein Fett gefunden'),
                            producttest.fett != null
                                ? Text(
                                'davon gesättigte Fettsäuren: ${producttest
                                    .gesaettigt}g')
                                : Text('Keine gesättigten Fettsäuren gefunden'),
                            producttest.kohlenhydrate != null
                                ? Text(
                                'Kohlenhydrate: ${producttest.kohlenhydrate}g')
                                : Text('Keine Kohlenhydrate gefunden'),
                            producttest.davonZucker != null
                                ? Text(
                                'davon Zucker: ${producttest.davonZucker}g')
                                : Text('Kein Zucker gefunden'),
                            producttest.ballaststoffe != null
                                ? Text(
                                'Ballaststoffe: ${producttest.ballaststoffe}g')
                                : Text('Keine Ballaststoffe gefunden'),
                            producttest.eiweiss != null
                                ? Text('Eiweiß: ${producttest.eiweiss}g')
                                : Text('Kein Eiweiß gefunden'),
                            producttest.salz != null
                                ? Text('Salz: ${producttest.fett}g')
                                : Text('Kein Salz gefunden'),
                            producttest.bildurl != null
                                ? Image.network(producttest.bildurl)
                                : Text('Kein Bild gefunden'),
                          ],
                        );
                      } else {
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
              onPressed: () =>
                  showDialog(
                      context: context,
                      builder: (context) =>
                          AlertDialog(
                            title: const Text('Manueller Eintrag'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                eingabefeld('Bezeichnung', 'Name'),
                                eingabefeld('Menge in Gramm', 'Menge'),
                                eingabefeld('bla bla', 'bla bla'),
                                TextButton(
                                    onPressed: () =>
                                    {
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

class OwnProduct {
  String name;
  String marke;
  String menge;
  String bildurl;
  String kalorien;
  String fett;
  String gesaettigt;
  String kohlenhydrate;
  String davonZucker;
  String ballaststoffe;
  String eiweiss;
  String salz;

  OwnProduct({required this.name,
    required this.marke,
    required this.menge,
    required this.bildurl,
    required this.kalorien,
    required this.fett,
    required this.gesaettigt,
    required this.kohlenhydrate,
    required this.davonZucker,
    required this.ballaststoffe,
    required this.eiweiss,
    required this.salz
  });
}
