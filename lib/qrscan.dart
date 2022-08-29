import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
void main() => runApp(MaterialApp(
      home: QrCode(),
    ));

class QrCode extends StatefulWidget {
  const QrCode({Key? key}) : super(key: key);

  @override
  State<QrCode> createState() => QrCodeState();
}

class QrCodeState extends State<QrCode> {
  String barcode = "";

  scan() async {
    return await FlutterBarcodeScanner.scanBarcode(
        "#000000", 'Abbrechen', true, ScanMode.BARCODE).then((value) =>
        setState(() => barcode = value));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(child: Text('Scan BC'),
            onPressed: () => scan()),
        Text(barcode)
      ],
    ));
  }

  String get data => barcode;
}
