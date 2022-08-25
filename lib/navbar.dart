import 'package:dieahnungslosen/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dieahnungslosen/fridge.dart';
import 'package:dieahnungslosen/settings.dart';

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      children: [
        ListTile(
          leading: Icon(FontAwesomeIcons.receipt),
          title: Text('Ernährungstagebuch'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FoodDiary(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.carrot),
          title: Text('Kühlschrank'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WhatsInMyFridge(),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.slidersH),
          title: Text('Einstellungen'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Settings(),
              ),
            );
          },
        ),
      ],
    ));
  }
}
