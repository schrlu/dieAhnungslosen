import 'package:dieahnungslosen/database_helper.dart';
import 'package:dieahnungslosen/diary_entry.dart';
import 'package:dieahnungslosen/product_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dieahnungslosen/navbar.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: FoodDiary(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
  ));
}

class FoodDiary extends StatefulWidget {
  const FoodDiary({Key? key}) : super(key: key);

  @override
  State<FoodDiary> createState() => FoodDiaryState();
}

class FoodDiaryState extends State<FoodDiary> {
  String _barcode = "";
  var formatter = DateFormat('dd.MM.yyyy');
  TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
          title: const Text('Ernährungstagebuch'),
        ),
        //FutureBuilder für die Datenbankabfrage für Ernährungstagebuch-Einträge
        body: FutureBuilder<List<DiaryEntry>>(
            future: DatabaseHelper.instance.getDiaryEntries(),
            builder: (BuildContext context,
                AsyncSnapshot<List<DiaryEntry>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              }
              //Wenn keine Einträge vorhanden sind, soll dies auf dem Bildschirm angezeigt werden
              return snapshot.data!.isEmpty
                  ? Center(
                      child: Text('Keine Einträge vorhanden'),
                    )
                  :
                  //ListView mit in dem alle Einträge gezeigt werden
                  ListView(
                      children: snapshot.data!.map((entry) {
                        return Padding(
                          padding:
                              const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                          //Container mit Linien zur Abtrennung der einzelnen Einträge
                          child: Container(
                              decoration: const BoxDecoration(
                                  border: Border(
                                bottom:
                                    BorderSide(width: 0.2, color: Colors.grey),
                                top: BorderSide(width: 0.2, color: Colors.grey),
                              )),
                              //Eintrag anklickbar machen
                              child: InkWell(
                                onTap: () {
                                  //Nährwerte pro 100g des Produktes anzeigen
                                  watchProduct(entry.food_id);
                                },
                                //Den Eintrag slidable machen
                                child: Slidable(
                                    actionPane: SlidableDrawerActionPane(),
                                    secondaryActions: [
                                      //Den Eintrag editierbar machen
                                      IconSlideAction(
                                        caption: 'Edit',
                                        color: Colors.black45,
                                        icon: Icons.edit,
                                        onTap: () {
                                          editProduct(entry);
                                        },
                                      ),
                                      //Den Eintrag löschbar machen
                                      IconSlideAction(
                                        caption: 'Delete',
                                        color: Colors.red,
                                        icon: Icons.delete,
                                        onTap: () async {
                                          await DatabaseHelper.instance
                                              .removeDiaryEntry(
                                                  entry.diary_id!);
                                          setState(() {});
                                        },
                                      )
                                    ],
                                    //Den Eintrag in ein Grid aufteilen mit 3 Spalten und 2 Zeilen
                                    child: GridView.count(
                                      crossAxisCount: 3,
                                      shrinkWrap: true,
                                      childAspectRatio: 2,
                                      children: <Widget>[
                                        //Attribute des Produktes des Eintrags aus der Datenbank entnehmen
                                        FutureBuilder<List?>(
                                            future: DatabaseHelper.instance
                                                .getOneProductFromId(
                                                    entry.food_id),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                //Spalte mit brand und Name des Produkts
                                                return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      buildEntryText(snapshot
                                                          .data!
                                                          .first['brand']),
                                                      buildEntryText(snapshot
                                                          .data!.first['name'])
                                                    ]);
                                              } else {
                                                return Text('noname');
                                              }
                                            }),
                                        //Spalte mit quantity des Produkts
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            buildEntryText('Menge:'),
                                            buildEntryText(
                                                '${entry.weight} g/ml'),
                                          ],
                                        ),
                                        //Spalte mit Datum des Eintrags
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            buildEntryText('Datum:'),
                                            buildEntryText(
                                                '${formatter.format(DateTime.parse(entry.date))}'),
                                          ],
                                        ),
                                      ],
                                    )),
                              )),
                        );
                      }).toList(),
                    );
            }),
        //Button zum Scannen des Barcodes eines Produktes
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
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

  //Methode zum bauen eines Entry Textes
  Flexible buildEntryText(String text) {
    return Flexible(child: Text(text, style: TextStyle(fontSize: 12)));
  }

  //Methode zum scannen eines Barcodes
  scan() async {
    return await FlutterBarcodeScanner.scanBarcode(
            "#000000", 'Abbrechen', true, ScanMode.BARCODE)
        .then((value) => setState(() => _barcode = value));
  }

  //Methde zum aufrufen eines Fensters in dem man den Eintrag editieren kann
  editProduct(DiaryEntry entry) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: FutureBuilder<String?>(
                  future: DatabaseHelper.instance.getName(entry.food_id),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        child: Text(snapshot.data!,
                            // textAlign:
                            // TextAlign.left,
                            style: TextStyle(fontSize: 25)),
                      );
                    } else {
                      return Text('noname');
                    }
                  }),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Menge in g/ml'),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: quantityController,
                    decoration: InputDecoration(hintText: 'Neue Menge'),
                  ),
                  TextButton(
                      onPressed: () => {
                            DatabaseHelper.instance.updateDiaryEntry(
                                entry, double.parse(quantityController.text)),
                            setState(() {}),
                            Navigator.pop(context),
                          },
                      child: Text('Submit')),
                ],
              ),
            ));
  }

  //Methode zum aufrufen eines Fensters, in dem die Nährwerte des Produkts angezeigt werden
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
                          'Kalorien: ${snapshot.data!.first['calories']} kcal'),
                      Text('Fett: ${snapshot.data!.first['fat']} g'),
                      Text(
                          'davon gesättigte Fettsäuren: ${snapshot.data!.first['saturated']} g'),
                      Text(
                          'Kohlenhydrate: ${snapshot.data!.first['carbohydrates']} g'),
                      Text(
                          'davon Zucker: ${snapshot.data!.first['sugar']} g'),
                      Text('Eiweiß: ${snapshot.data!.first['protein']} g'),
                      Text('Salz: ${snapshot.data!.first['salt']} g'),
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
