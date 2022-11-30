import 'package:dieahnungslosen/main.dart';
import 'package:dieahnungslosen/user_summary.dart';
import 'package:flutter/material.dart';
import 'package:dieahnungslosen/fridge.dart';
import 'package:dieahnungslosen/settings.dart';

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Routen zu den anderen Seiten
    return Drawer(
        backgroundColor: Color.fromARGB(255, 1, 5, 6),
        child: ListView(
          children: [
            Image.asset('images/navbar/food.jpg'),
            Site('Ernährungstagebuch', Icons.receipt, FoodDiary()),
            Site('Kühlschrank', Icons.door_front_door_rounded, WhatsInMyFridge()),
            Site('Zusammenfassung', Icons.summarize, UserSummary()),
            Site('Einstellungen', Icons.settings, Settings()),
          ],
        ));
  }
}

class Site extends StatelessWidget {
  IconData icon;
  Widget page;
  String title;
  Site(this.title, this.icon, this.page);

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

