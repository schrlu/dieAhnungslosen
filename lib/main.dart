import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dieahnungslosen/navbar.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dieahnungslosen/qrscan.dart';
void main() => runApp(MaterialApp(home: FoodDiary()));

class FoodDiary extends StatelessWidget{
  FoodDiary({Key? key}) : super(key: key);
  QrCodeState _qr = new QrCodeState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
          title: const Text('Ernährungstagebuch'),
        ),
        body: null,
        floatingActionButton: FloatingActionButton(
          onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                    title: const Text('Lebensmittel Eintrag'),
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        eingabefeld('Bezeichnung', 'Name'),
                        eingabefeld('Menge in Gramm', 'Menge'),
                        eingabefeld('bla bla', 'bla bla'),
                        Column(
                          children: [
                            Text('Barcode-Scan'),
                            IconButton(
                                onPressed: () => _qr.scan(),
                                icon: Icon(FontAwesomeIcons.barcode)),
                          ],
                        ),
                        Text(_qr.barcode),
                        Container(
                            alignment: Alignment.bottomCenter,
                            child: TextButton(
                                onPressed: () => {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              successWindow(FoodDiary()))
                                    },
                                child: Text('Submit')))
                      ],
                    ),
                  )),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
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
          icon: Icon(FontAwesomeIcons.check, color: Colors.green),
        ),
      ),
    );
  }
}
