import 'package:dieahnungslosen/navbar.dart';
import 'package:flutter/material.dart';

class WhatsInMyFridge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Kühlschrank'),
      ),
    );
  }

}