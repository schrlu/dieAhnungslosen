import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dieahnungslosen/navbar.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() => runApp(MaterialApp(home: FoodDiary()));

class FoodDiary extends StatefulWidget {
  const FoodDiary({Key? key}) : super(key: key);

  @override
  State<FoodDiary> createState() => FoodDiaryState();
}

class FoodDiaryState extends State<FoodDiary> {
  String _barcode = "";
  scan() async {
    return await FlutterBarcodeScanner.scanBarcode(
        "#000000", 'Abbrechen', true, ScanMode.BARCODE).then((value) =>
        setState(() => _barcode = value));
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Test"),
                        Text("Hallo"),
                        Text("Tralala")
                      ],
                    )
              ],

            ),
          ],
        ),
        floatingActionButton:
        Column(
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
              child: FloatingActionButton
                (
                onPressed: () => scan(),
              child: Icon(Icons.camera_alt),),
            )
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
