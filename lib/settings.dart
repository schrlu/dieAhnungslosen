import 'package:dieahnungslosen/navbar.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 1, 5, 6),
        title: Text('Einstellungen'),
      ),
    );
  }

}