import 'package:dieahnungslosen/database_helper.dart';
import 'package:dieahnungslosen/main.dart';
import 'package:dieahnungslosen/navbar.dart';
import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text('Einstellungen'),
      ),
      body: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List?>(
            future: DatabaseHelper.instance.getSettings(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map settings = snapshot.data?.first;
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                            border: Border(
                          bottom: BorderSide(width: 0.1, color: Colors.grey),
                          top: BorderSide(width: 0.1, color: Colors.grey),
                        )),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text('Geschlecht'),
                                        content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              buildChoice(context, 'gender', 1,
                                                  'weiblich'),
                                              buildChoice(context, 'gender', 2,
                                                  'männlich'),
                                              buildChoice(context, 'gender', 3,
                                                  'sonstiges'),
                                            ]),
                                      ));
                            },
                            child: Text(
                              'Geschlecht: ${getGender(settings['gender'])}',
                              style: const TextStyle(fontSize: 25),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Text('No settings found');
              }
            },
          )
        ],
      ),
    );
  }

  TextButton buildChoice(BuildContext context, String setting,
      int settingNumber, String choiceString) {
    return TextButton(
        onPressed: () {
          DatabaseHelper.instance.updateSettings(setting, settingNumber);
          setState(() {});
          Navigator.pop(context);
        },
        child: Text(
          choiceString,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ));
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
}
