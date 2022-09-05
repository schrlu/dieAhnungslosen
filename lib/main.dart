import 'dart:convert';
import 'dart:developer';

import 'package:dieahnungslosen/database_helper.dart';
import 'package:dieahnungslosen/diary_entry.dart';
import 'package:dieahnungslosen/product_preview.dart';
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
import 'package:dieahnungslosen/own_product.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() => runApp(MaterialApp(home: FoodDiary()));

class FoodDiary extends StatefulWidget {
  const FoodDiary({Key? key}) : super(key: key);

  @override
  State<FoodDiary> createState() => FoodDiaryState();
}

class FoodDiaryState extends State<FoodDiary> {
  String _barcode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
          title: const Text('Ernährungstagebuch'),
        ),
        body: Center(
          child: FutureBuilder<List<DiaryEntry>>(
            future: DatabaseHelper.instance.getDiaryEntries(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Text('Lade Daten'),
                );
              }
              return snapshot.data.isEmpty
                  ? Center(
                      child: Text('Keine Produkte gefunden'),
                    )
                  : ListView(
                      children: snapshot.data!.map((entry) async {
                        return Slidable(
                          actionPane: SlidableDrawerActionPane(),
                          secondaryActions: [
                            IconSlideAction(
                              caption: 'Bearbeiten',
                              color: Colors.black,
                              icon: Icons.edit,
                              onTap: () {},
                            ),
                            IconSlideAction(
                                caption: 'Löschen',
                                color: Colors.red,
                                icon: Icons.delete,
                                onTap: () {
                                  DatabaseHelper.instance
                                      .removeDiaryEntry(entry.id!);
                                })
                          ],
                          child: Text(DatabaseHelper.instance.getFullName(entry.id)),
                        );
                      }).toList(),
                    );
            },
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'Manual-Button',
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
                    heroTag: 'Scan-Button',
                    onPressed: () async {
                      await scan();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductPreview(_barcode),
                          ));
                    },
                    child: Icon(Icons.camera_alt))),
          ],
        ));
  }

  scan() async {
    return await FlutterBarcodeScanner.scanBarcode(
            "#000000", 'Abbrechen', true, ScanMode.BARCODE)
        .then((value) => setState(() => _barcode = value));
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

// Column(
// children: [
// ListView(
// shrinkWrap: true,
// padding: EdgeInsets.all(20),
// children: [
// FutureBuilder<OwnProduct?>(
// future: getProduct(_barcode),
// builder: (context, snapshot) {
// if (snapshot.hasData) {
// OwnProduct producttest = snapshot.data!;
// return Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// producttest.name != null
// ? Text(
// 'Produktbezeichnung: ${producttest.name}')
//     : Text('Kein Name gefunden'),
// producttest.marke != null
// ? Text('Marke: ${producttest.marke}')
//     : Text('Keine Marke gefunden'),
// producttest.menge != null
// ? Text('Menge: ${producttest.menge}')
//     : Text('Keine Menge gefunden'),
// Text(''),
// Text('Nährwerte:'),
// producttest.kalorien != null
// ? Text('Energie: ${producttest.kalorien} kcal')
//     : Text('Keine Kalorien gefunden'),
// producttest.fett != null
// ? Text('Fett: ${producttest.fett}g')
//     : Text('Kein Fett gefunden'),
// producttest.fett != null
// ? Text(
// 'davon gesättigte Fettsäuren: ${producttest.gesaettigt}g')
//     : Text('Keine gesättigten Fettsäuren gefunden'),
// producttest.kohlenhydrate != null
// ? Text(
// 'Kohlenhydrate: ${producttest.kohlenhydrate}g')
//     : Text('Keine Kohlenhydrate gefunden'),
// producttest.davonZucker != null
// ? Text(
// 'davon Zucker: ${producttest.davonZucker}g')
//     : Text('Kein Zucker gefunden'),
// producttest.eiweiss != null
// ? Text('Eiweiß: ${producttest.eiweiss}g')
//     : Text('Kein Eiweiß gefunden'),
// producttest.salz != null
// ? Text('Salz: ${producttest.fett}g')
//     : Text('Kein Salz gefunden'),
// ],
// );
// } else {
// return Text('waiting');
// }
// })
// ],
// ),
// ],
// )
