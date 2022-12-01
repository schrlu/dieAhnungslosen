import 'package:dieahnungslosen/fridge.dart';
import 'package:dieahnungslosen/main.dart';
import 'package:dieahnungslosen/settings.dart';
import 'package:dieahnungslosen/user_summary.dart';
import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Routen zu den anderen Seiten
    return Drawer(
        backgroundColor: Color.fromARGB(255, 1, 5, 6),
        key: Key('navBar'),
        child: ListView(
          children: [
            Image.asset('images/navbar/food.jpg'),
            Site('Ernährungstagebuch', Icons.receipt, FoodDiary(),'navBarFoodDiary'),
            Site('Kühlschrank', Icons.door_front_door_rounded,
                WhatsInMyFridge(), 'navBarFridge'),
            Site('Zusammenfassung', Icons.summarize, UserSummary(), 'navBarSummary'),
            Site('Einstellungen', Icons.settings, Settings(), 'navBarSettings'),
          ],
        ));
  }
}

class Site extends StatelessWidget {
  IconData icon;
  Widget page;
  String title;
  String keyValue;

  Site(this.title, this.icon, this.page, this.keyValue);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        key: Key(keyValue),
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
