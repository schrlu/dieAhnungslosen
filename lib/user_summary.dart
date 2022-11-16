import 'dart:ffi';

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
import 'own_product.dart';

class UserSummary extends StatefulWidget {
  const UserSummary({super.key});

  @override
  State<UserSummary> createState() => _UserSummaryState();
}

class _UserSummaryState extends State<UserSummary> {
  late int gender;
  int cal1Day = 2000;
  double fat1Day = 65;
  double carb1Day = 300;
  double sug1Day = 50;
  double prot1Day = 67;
  double salt1Day = 6;
  late Map summary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
          title: Text('Zusammenfassung'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder<List?>(
                future: DatabaseHelper.instance.getSettings(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    Map settings = snapshot.data?.first;
                    gender = settings['gender'];
                    setGoals();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacer(),
                        FutureBuilder<List?>(
                            future: DatabaseHelper.instance.getSummary(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                summary = {
                                  1: snapshot.data?.first['kalorien'],
                                  2: snapshot.data?.first['fett'],
                                  3: snapshot.data?.first['gesaettigt'],
                                  4: snapshot.data?.first['kohlenhydrate'],
                                  5: snapshot.data?.first['davonZucker'],
                                  6: snapshot.data?.first['eiweiss'],
                                  7: snapshot.data?.first['salz']
                                };

                                summary.forEach((key, value) {
                                  if (value == null) {
                                    summary[key] = 0;
                                  }
                                });
                                return Column(
                                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Nährwerte letzter 7 Tage',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('Kalorien: ${summary[1]} kcal',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'Fett: ${summary[2].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'davon gesättigte Fettsäuren: ${summary[3].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'Kohlenhydrate: ${summary[4].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'davon Zucker: ${summary[5].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'Eiweiß: ${summary[6].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'Salz: ${summary[7].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                    ]);
                              } else {
                                return Text('noname');
                              }
                            }),
                        Spacer(),
                        FutureBuilder<int?>(
                            future: DatabaseHelper.instance.getMaxDateDiff(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                int dateDiff = snapshot.data!.toInt();
                                if (dateDiff > 7) {
                                  dateDiff = 7;
                                } else {
                                  dateDiff++;
                                }

                                return Column(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Nährwert Sollvergleich',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                          'Kalorien: ${(cal1Day * dateDiff) - summary[1]} kcal',
                                          style: TextStyle(fontSize: 18)),
                                      Text(
                                          'Fett: ${((fat1Day * dateDiff) - summary[2]).toStringAsFixed(1)} g',
                                          style: TextStyle(fontSize: 18)),
                                      Text(
                                          'Kohlenhydrate: ${((carb1Day * dateDiff) - summary[4]).toStringAsFixed(1)} g',
                                          style: TextStyle(fontSize: 18)),
                                      Text(
                                          'Zucker: ${((sug1Day * dateDiff) - summary[5]).toStringAsFixed(1)} g',
                                          style: TextStyle(fontSize: 18)),
                                      Text(
                                          'Eiweiß: ${((prot1Day * dateDiff) - summary[6]).toStringAsFixed(1)} g',
                                          style: TextStyle(fontSize: 18)),
                                      Text(
                                          'Salz: ${((salt1Day * dateDiff) - summary[7]).toStringAsFixed(1)} g',
                                          style: TextStyle(fontSize: 18)),
                                    ]);
                              } else {
                                return Text(
                                    'Bisher keine Ernährung aufgezeichnet');
                              }
                            }),
                        Spacer(),
                        FutureBuilder<List?>(
                            future: DatabaseHelper.instance.getSummaryCurrentDay(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                summary = {
                                  1: snapshot.data?.first['kalorien'],
                                  2: snapshot.data?.first['fett'],
                                  3: snapshot.data?.first['gesaettigt'],
                                  4: snapshot.data?.first['kohlenhydrate'],
                                  5: snapshot.data?.first['davonZucker'],
                                  6: snapshot.data?.first['eiweiss'],
                                  7: snapshot.data?.first['salz']
                                };

                                summary.forEach((key, value) {
                                  if (value == null) {
                                    summary[key] = 0;
                                  }
                                });
                                return Column(
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Nährwerte letzter 7 Tage',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text('Kalorien: ${summary[1]} kcal',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'Fett: ${summary[2].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'davon gesättigte Fettsäuren: ${summary[3].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'Kohlenhydrate: ${summary[4].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'davon Zucker: ${summary[5].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'Eiweiß: ${summary[6].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                      Text(
                                          'Salz: ${summary[7].toStringAsFixed(1)} g',
                                          style: const TextStyle(fontSize: 18)),
                                    ]);
                              } else {
                                return Text('noname');
                              }
                            }),
                        Spacer(
                          flex: 10,
                        ),
                      ],
                    );
                  } else {
                    return Text('no settings found');
                  }
                })));
  }

  void setGoals() {
    if (gender == 1) {
      cal1Day = 1900;
      fat1Day = 65;
      carb1Day = 230;
      sug1Day = 50;
      prot1Day = 48;
      salt1Day = 6;
    } else if (gender == 2) {
      cal1Day = 2400;
      fat1Day = 65;
      carb1Day = 300;
      sug1Day = 50;
      prot1Day = 62;
      salt1Day = 6;
    } else if (gender == 3) {
      cal1Day = 2150;
      fat1Day = 65;
      carb1Day = 265;
      sug1Day = 50;
      prot1Day = 54;
      salt1Day = 6;
    }
  }
}
