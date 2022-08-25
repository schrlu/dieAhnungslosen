import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dieahnungslosen/navbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(const MaterialApp(home: const FoodDiary()));

class FoodDiary extends StatelessWidget {
  const FoodDiary({Key? key}) : super(key: key);

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
                    content: Column(children: <Widget>[
                      Container(
                        child: TextField(
                          decoration: InputDecoration(hintText: 'Bezeichnung'),
                        ),
                      ),
                      Container(
                        child: TextField(
                          decoration:
                              InputDecoration(hintText: 'Menge in Gramm'),
                        ),
                      ),
                      Container(
                          alignment: Alignment.bottomCenter,
                          child: TextButton(
                              onPressed: () => {

                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text('Success'),
                                        content: IconButton(
                                          onPressed: () {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        FoodDiary()),
                                                (route) => false);
                                          },
                                          icon: Icon(FontAwesomeIcons.check,
                                              color: Colors.green),
                                        ),
                                      ))},
                              child: Text('Submit')))
                    ],),
                  )),
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ));
  }
}
// constraints: BoxConstraints(
// child: Container(
// borderRadius: BorderRadius.circular(20.0)),
// shape: RoundedRectangleBorder(
// return Dialog(
// builder: (BuildContext context) {
// context: context,
// showDialog(
// maxHeight: MediaQuery.of(context).size.height),
// child: Padding(
// padding: const EdgeInsets.all(12.0),
// child: Column(
// children: <Widget>[
// Row(
// children: [
// Container(
// child: const Text(
// 'Lebensmittel Eintrag',
// style: TextStyle(
// fontWeight: FontWeight.bold,
// fontSize: 18,
// color: Colors.black,
// wordSpacing: 1,
// ),
// ),
// ),
// ],
// ),
// Row(
// children: [
// Container(
// child: Text(
// 'Test',
// ),
// ),
// ],
// ),
// ],
// ),
// ),
// ),
// );
// }),
