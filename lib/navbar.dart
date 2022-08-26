import 'package:dieahnungslosen/main.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dieahnungslosen/fridge.dart';
import 'package:dieahnungslosen/settings.dart';

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color.fromARGB(255, 1, 5, 6),

        child: ListView(
      children: [
        Image.asset('images/navbar/food.jpg'),
        ListTile(
          textColor: Colors.white,
          leading: Icon(FontAwesomeIcons.receipt, color: Colors.white),
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
          textColor: Colors.white,
          leading: Icon(FontAwesomeIcons.carrot, color: Colors.white),
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
          textColor: Colors.white,
          leading: Icon(FontAwesomeIcons.slidersH, color: Colors.white,),
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
