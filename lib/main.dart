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
  runApp(MaterialApp(home: FoodDiary(),
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
  TextEditingController mengeController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
          title: const Text('Ernährungstagebuch'),
        ),
        body: FutureBuilder<List<DiaryEntry>>(
            future: DatabaseHelper.instance.getDiaryEntries(),
            builder: (BuildContext context,
                AsyncSnapshot<List<DiaryEntry>> snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              }

              return snapshot.data!.isEmpty
                  ? Center(
                      child: Text('Keine Einträge vorhanden'),
                    )
                  :
              ListView(
                      children: snapshot.data!.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                              10.0, 0.0, 10.0, 0.0),
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                bottom: BorderSide(
                                    width: 1.0, color: Colors.grey),
                                top: BorderSide(
                                    width: 1.0, color: Colors.grey),
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
                                              .removeDiaryEntry(
                                                  entry.diary_id!);
                                          setState(() {});
                                          // reloadPage(context, FoodDiary());
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
                                                future: DatabaseHelper
                                                    .instance
                                                    .getMarke(
                                                        entry.food_id),
                                                builder:
                                                    (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Container(
                                                      child: Text(
                                                          snapshot.data!,
                                                          // textAlign:
                                                          // TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  12)),
                                                    );
                                                  } else {
                                                    return Text('noname');
                                                  }
                                                }),
                                            FutureBuilder<String?>(
                                                future: DatabaseHelper
                                                    .instance
                                                    .getName(entry.food_id),
                                                builder:
                                                    (context, snapshot) {
                                                  if (snapshot.hasData) {
                                                    return Container(
                                                      child: Text(
                                                          snapshot.data!,
                                                          // textAlign:
                                                          // TextAlign.left,
                                                          style: TextStyle(
                                                              fontSize:
                                                                  15)),
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
                                            Text('Menge:'),
                                            Text('${entry.weight} g/ml')
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
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // FloatingActionButton(
            //   heroTag: 'Manual-Button',
            //   onPressed: () => showDialog(
            //       context: context,
            //       builder: (context) => AlertDialog(
            //             title: const Text('Manueller Eintrag'),
            //             content: Column(
            //               mainAxisSize: MainAxisSize.min,
            //               children: <Widget>[
            //                 eingabefeld('Bezeichnung', 'Name'),
            //                 eingabefeld('Menge in Gramm', 'Menge'),
            //                 eingabefeld('bla bla', 'bla bla'),
            //                 TextButton(
            //                     onPressed: () => {
            //                           showDialog(
            //                               context: context,
            //                               builder: (context) =>
            //                                   successWindow(FoodDiary()))
            //                         },
            //                     child: Text('Submit')),
            //               ],
            //             ),
            //           )),
            //
            //   tooltip: 'Increment',
            //   child: const Icon(Icons.add),
            // ),
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
                    controller: mengeController,
                    decoration: InputDecoration(hintText: 'Neue Menge'),
                  ),
                  TextButton(
                      onPressed: () => {
                            DatabaseHelper.instance.updateDiaryEntry(
                                entry, double.parse(mengeController.text)),
                      setState(() {}),
                      Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (context) => FoodDiary()), (route) => false),
                          },
                      child: Text('Submit')),
                ],
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
            reloadPage(context, page);
          },
          icon: Icon(Icons.check, color: Colors.green),
        ),
      ),
    );
  }

  void reloadPage(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => page), (route) => false);
  }
}
