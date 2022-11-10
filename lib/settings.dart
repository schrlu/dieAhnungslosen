import 'package:dieahnungslosen/database_helper.dart';
import 'package:dieahnungslosen/main.dart';
import 'package:dieahnungslosen/navbar.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  List<DropdownMenuItem<int>> menuItems = [
    DropdownMenuItem(child: Text("Männlich"), value: 1),
    DropdownMenuItem(child: Text("Weiblich"), value: 2),
    DropdownMenuItem(child: Text("Sonstiges"), value: 3),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Einstellungen'),
      ),
      body: Column(
        children: [
          FutureBuilder<List?>(
            future: DatabaseHelper.instance.getSettings(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map settings = snapshot.data?.first;
                return Column(
                  children: [
                    Text(
                      'Geschlecht: ${getGender(settings['gender'])}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    TextButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Text('Geschlecht'),
                                    content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                DatabaseHelper.instance
                                                    .updateSettings(
                                                        'gender', 1);
                                                reloadPage(context, Settings());
                                              },
                                              child: const Text(
                                                'weiblich',
                                                style: TextStyle(
                                                    color: Colors.pinkAccent),
                                              )),TextButton(
                                              onPressed: () {
                                                DatabaseHelper.instance
                                                    .updateSettings(
                                                        'gender', 2);
                                                reloadPage(context, Settings());
                                              },
                                              child: const Text(
                                                'männlich',
                                                style: TextStyle(
                                                    color: Colors.lightBlue),
                                              )),TextButton(
                                              onPressed: () {
                                                DatabaseHelper.instance
                                                    .updateSettings(
                                                        'gender', 3);
                                                reloadPage(context, Settings());
                                              },
                                              child: Text(
                                                'sonstiges', style: TextStyle(color: Colors.grey),),
                                              ),
                                        ]),
                                  ));
                        },
                        child: Text(
                          'ändern',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ))
                  ],
                );
              } else {
                return Text('No settings found');
              }
            },
          )
        ],
      ),
    );
  }

  String? getGender(int value) {
    if (value == 1) {
      return "Weiblich";
    } else if (value == 2) {
      return "Männlich";
    } else if (value == 3) {
      return "Sonstiges";
    }
  }

  void reloadPage(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => page), (route) => false);
  }
}
