import 'package:dieahnungslosen/navbar.dart';
import 'package:dieahnungslosen/main.dart';
import 'package:dieahnungslosen/product_preview.dart';
import 'package:dieahnungslosen/product_preview_frige.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dieahnungslosen/database_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dieahnungslosen/navbar.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'fridge_entry.dart';

class UserSummary extends StatefulWidget {
  const UserSummary({super.key});

  @override
  State<UserSummary> createState() => _UserSummaryState();
}

class _UserSummaryState extends State<UserSummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Zusammenfassung'),
      ),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
        children:[
          Text('Nährwerte letzter 7 Tage', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
          FutureBuilder<List?>(
              future: DatabaseHelper.instance
                  .getSummary(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List? summary = snapshot.data;
                  summary?.forEach((element) {
                    print(element);
                  });

                  // FutureBuilder<String?>(
                  //
                  // )
                  return Container(
                    child: Text(
                        'hallo ${snapshot.data?.first['weight']}',
                        // textAlign:
                        // TextAlign.left,
                        style: TextStyle(
                            fontSize: 12)),
                  );
                } else {
                  return Text('noname');
                }
              })
        ],
      )
    );
  }
}
