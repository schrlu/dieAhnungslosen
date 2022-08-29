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
            site('Ernährungstagebuch', FontAwesomeIcons.receipt, FoodDiary()),
            site('Kühlschrank', FontAwesomeIcons.carrot, WhatsInMyFridge()),
            site('Einstellungen', FontAwesomeIcons.slidersH, Settings()),
          ],
        ));
  }
}

class site extends StatelessWidget {
  IconData icon;
  Widget page;
  String title;
  site(this.title, this.icon, this.page);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: ListTile(
          textColor: Colors.white,
          leading: Icon(icon, color: Colors.white),
          title: Text(title),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => page,
              ),
            );
          },
        ),
    );
  }
}

