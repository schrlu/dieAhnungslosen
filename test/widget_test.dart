
import 'package:dieahnungslosen/database_helper.dart';
import 'package:dieahnungslosen/fridge.dart';
import 'package:dieahnungslosen/product_preview.dart';
import 'package:dieahnungslosen/settings.dart';
import 'package:dieahnungslosen/user_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {

  testWidgets('Fridge test', (WidgetTester tester) async {
    //find all widgets needed
    final button = find.byKey(Key('refresh'));
    //execute test

    await tester.pumpWidget(MaterialApp(home: WhatsInMyFridge()));
    await tester.pump();


    //check
    expect(button, findsOneWidget);
  });
  testWidgets('Inserting Food-Diary entry', (WidgetTester tester) async {
    //find all widgets needed
    final brand = find.byKey(Key('diaryPreviewBrand'));
    final name = find.byKey(Key('diaryPreviewName'));

    //execute test
    await tester.pumpWidget(MaterialApp(home: ProductPreview('42142188')));
    await tester.pump();
    expect(find.byKey(Key('failed')), findsOneWidget);
    // expect(brand, findsOneWidget);
    // expect(name, findsOneWidget);
    //check
    expect(find.byKey(Key('failed')), findsOneWidget);
  });
  testWidgets('Summary test', (WidgetTester tester) async {
    //find all widgets needed
    final DatabaseHelper db;
    final textField = find.byKey(Key('error'));

    //execute test
    await tester.pumpWidget(MaterialApp(home: UserSummary()));
    await tester.pump();

    //check
    expect(textField, findsOneWidget);
  });
  testWidgets('Settings test', (WidgetTester tester) async {
    //find all widgets needed
    final DatabaseHelper db;
    final textField = find.textContaining('No settings found');

    //execute test
    await tester.pumpWidget(MaterialApp(home: Settings()));
    await tester.pump();

    //check
    expect(textField, findsOneWidget);
  });
//   testWidgets('my drawer test', (WidgetTester tester) async {
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   // final navBarFridge = find.byKey(ValueKey('navBarFridge'));
//   final navBarFridge = find.byIcon(Icons.door_front_door_rounded);
//   await tester.pumpWidget(
//     MaterialApp(
//       home: Scaffold(
//         key: scaffoldKey,
//         drawer: NavBar(),
//       ),
//     ),
//   );
//
//   scaffoldKey.currentState?.openDrawer();
//   await tester.pump();
//   await tester.tap(navBarFridge);
//   await tester.pump();
//
//   expect(find.byWidget(WhatsInMyFridge()), findsOneWidget);
// });
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   //find all widgets needed
  //   final navBarFridge = find.byIcon(Icons.door_front_door_rounded);
  //   //execute test
  //
  //   await tester.pumpWidget(MaterialApp(home: FoodDiary()));
  //   await tester.pump();
  //   final ScaffoldState state = tester.firstState(find.byType(Scaffold));
  //   state.openDrawer();
  //   await tester.pump();
  //   await tester.tap(navBarFridge);
  //   await tester.pump();
  //
  //   //check
  //   expect(find.byIcon(Icons.refresh), findsOneWidget);
  // });
}
