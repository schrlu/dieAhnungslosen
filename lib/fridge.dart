import 'dart:convert';

import 'package:dieahnungslosen/navbar.dart';
import 'package:dieahnungslosen/product_preview_frige.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dieahnungslosen/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'fridge_entry.dart';

class WhatsInMyFridge extends StatefulWidget {
  const WhatsInMyFridge({super.key});

  @override
  State<WhatsInMyFridge> createState() => _WhatsInMyFridgeState();
}

class _WhatsInMyFridgeState extends State<WhatsInMyFridge> {
  TextEditingController anzahlController = TextEditingController();
  String _barcode = "";
  var formatter = DateFormat('dd.MM.yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
          title: const Text('Kühlschrank'),
        ),
        body: FutureBuilder<List<FridgeEntry>>(
            future: DatabaseHelper.instance.getFridgeEntries(),
            builder: (BuildContext context,
                AsyncSnapshot<List<FridgeEntry>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              }
              return snapshot.data!.isEmpty
                  ? const Center(
                      child: Text('Keine Einträge vorhanden'),
                    )
                  : ListView(
                      children: snapshot.data!.map((entry) {
                        return Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          child: Container(
                              decoration: const BoxDecoration(
                                  border: Border(
                                bottom:
                                    BorderSide(width: 0.2, color: Colors.grey),
                                top: BorderSide(width: 0.2, color: Colors.grey),
                              )),
                              child: InkWell(
                                onTap: () {
                                  watchProduct(entry.food_id);
                                },
                                child: Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    secondaryActions: [
                                      IconSlideAction(
                                        caption: 'Edit',
                                        color: Colors.black45,
                                        icon: Icons.edit,
                                        onTap: () {
                                          editProduct(entry);
                                        },
                                      ),
                                      IconSlideAction(
                                        caption: 'Delete',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: () async {
                                          await DatabaseHelper.instance
                                              .removeFridgeEntry(
                                                  entry.fridge_id!);
                                          setState(() {});
                                        },
                                      )
                                    ],
                                    child: GridView.count(
                                      crossAxisCount: 3,
                                      shrinkWrap: true,
                                      childAspectRatio: 2,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FutureBuilder<String?>(
                                                future: DatabaseHelper.instance
                                                    .getMarke(entry.food_id),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Container(
                                                      child: Text(
                                                          snapshot.data!,
                                                          // textAlign:
                                                          // TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                    );
                                                  } else {
                                                    return Text('noname');
                                                  }
                                                }),
                                            FutureBuilder<String?>(
                                                future: DatabaseHelper.instance
                                                    .getName(entry.food_id),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Container(
                                                      child: Text(
                                                          snapshot.data!,
                                                          // textAlign:
                                                          // TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize: 15)),
                                                    );
                                                  } else {
                                                    return Text('noname');
                                                  }
                                                }),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Anzahl: ${entry.amount}'),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('Datum:'),
                                            Text(
                                                '${formatter.format(DateTime.parse(entry.mhd))}'),
                                          ],
                                        ),
                                      ],
                                    )),
                              )),
                        );
                      }).toList(),
                    );
            }),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
                padding: EdgeInsets.only(top: 15),
                child: FloatingActionButton(
                    heroTag: 'reload Button',
                    onPressed: () async {
                      setState(() {});
                    },
                    child: Icon(Icons.refresh))),
            Padding(
                padding: EdgeInsets.only(top: 15),
                child: FloatingActionButton(
                    heroTag: 'Scan-Button',
                    onPressed: () async {
                      await scan();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductPreviewFridge(_barcode),
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

  void reloadPage(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => page), (route) => false);
  }

  Widget eingabefeld(String title, String decoration) {
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

  editProduct(FridgeEntry entry) {
    DateTime mhd = DateTime.parse(entry.mhd);
    DateFormat ymd = DateFormat('yyyy-MM-dd');
    DateFormat dmy = DateFormat('dd.MM.yyyy');
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: FutureBuilder<String?>(
                  future: DatabaseHelper.instance.getName(entry.food_id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        child: Text(snapshot.data!,
                            style: TextStyle(fontSize: 25)),
                      );
                    } else {
                      return Text('noname');
                    }
                  }),
              content: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Anzahl'),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: anzahlController,
                        decoration: InputDecoration(hintText: 'Neue Menge'),
                      ),
                      TextButton(
                          onPressed: () async {
                            mhd = (await showDatePicker(
                                context: context,
                                initialDate: DateTime.parse(entry.mhd),
                                firstDate: DateTime(0000),
                                lastDate: DateTime(9999, 12, 31)))!;
                            setState(() {});
                          },
                          child: Text(
                            'Mindesthaltbarkeitsdatum: ${dmy.format(mhd)}',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.normal),
                          )),
                      TextButton(
                          onPressed: () => {
                                DatabaseHelper.instance.updateFridgeEntry(entry,
                                    mhd!, int.parse(anzahlController.text)),
                                Navigator.pop(context),
                              },
                          child: Text('Submit')),
                    ],
                  );
                },
              ),
            ));
  }

  watchProduct(int id) {
    return showDialog(
        context: context,
        builder: (context) => FutureBuilder<List?>(
            future: DatabaseHelper.instance.getOneProductFromId(id),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AlertDialog(
                  title: Text('Nährwerte pro 100g/ml'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          'Kalorien: ${snapshot.data!.first['kalorien']} kcal'),
                      Text('Fett: ${snapshot.data!.first['fett']} g'),
                      Text(
                          'davon gesättigte Fettsäuren: ${snapshot.data!.first['gesaettigt']} g'),
                      Text(
                          'Kohlenhydrate: ${snapshot.data!.first['kohlenhydrate']} g'),
                      Text(
                          'davon Zucker: ${snapshot.data!.first['davonZucker']} g'),
                      Text('Eiweiß: ${snapshot.data!.first['eiweiss']} g'),
                      Text('Salz: ${snapshot.data!.first['salz']} g'),
                    ],
                  ),
                );
              } else {
                return AlertDialog(
                  title: Text('Fehler'),
                  content: Column(
                    children: [Text('Keine Nährwerte gefunden')],
                  ),
                );
              }
            }));
  }
}
