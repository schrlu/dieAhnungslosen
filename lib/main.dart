import 'dart:convert';
import 'dart:developer';

import 'package:dieahnungslosen/database_helper.dart';
import 'package:dieahnungslosen/diary_entry.dart';
import 'package:dieahnungslosen/product_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dieahnungslosen/navbar.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: FoodDiary()));
}

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
                return Center(child: Text('Lädt'));
              }
              return snapshot.data!.isEmpty
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
                          child: Text(
                              DatabaseHelper.instance.getFullName(entry.id)),
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
