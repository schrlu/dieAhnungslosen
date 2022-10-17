import 'package:dieahnungslosen/main.dart';
import 'package:dieahnungslosen/user_summary.dart';
import 'package:flutter/material.dart';
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
            site('Ernährungstagebuch', Icons.receipt, FoodDiary()),
            site('Kühlschrank', Icons.door_front_door_rounded, WhatsInMyFridge()),
            site('Zusammenfassung', Icons.summarize, UserSummary()),
            site('Einstellungen', Icons.settings, Settings()),
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

