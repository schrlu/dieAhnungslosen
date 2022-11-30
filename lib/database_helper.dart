import 'dart:convert';
import 'dart:io';
import 'package:dieahnungslosen/diary_entry.dart';
import 'package:dieahnungslosen/fridge_entry.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:dieahnungslosen/own_product.dart';

class DatabaseHelper {
  //Singleton Pattern
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'dieAhnungslosen.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  //Erstellung der drei Datenbanktabellen und einfügen der Standard-Einstellungen bei Installation der App
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food(
      food_id INTEGER PRIMARY KEY AUTOINCREMENT,
      barcode STRING,
      name STRING,
      brand STRING,
      quantity STRING,
      quantity_ml DECIMAL,
      calories INTEGER,
      fat DECIMAL,
      saturated DECIMAL,
      carbohydrates DECIMAL,
      sugar DECIMAL,
      protein DECIMAL,
      salt DECIMAL
      )
    ''');
    await db.execute('''
      CREATE TABLE food_diary(
      diary_id INTEGER PRIMARY KEY AUTOINCREMENT,
      weight DECIMAL,
      date DATE,
      food_id INTEGER NOT NULL,
      FOREIGN KEY (food_id) REFERENCES food (food_id)
      )
    ''');

    await db.execute('''CREATE TABLE settings(
    settings_id INTEGER PRIMARY KEY AUTOINCREMENT,
    gender INTEGER
    )''');

    await db.execute('''INSERT INTO settings (gender)
    VALUES(1)''');

    await db.execute('''
    CREATE TABLE fridge(
      fridge_id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount INTEGER,
      food_id INTEGER NOT NULL,
      mhd DATE,
      FOREIGN KEY (food_id) REFERENCES food (food_id)
      )
    ''');
  }

  Future<List> getOneProductFromId(int id) async {
    Database db = await DatabaseHelper.instance.database;
    List<String> columnsToSelect = [
      'food_id',
      'barcode',
      'name',
      'brand',
      'quantity',
      'quantity_ml',
      'calories',
      'fat',
      'saturated',
      'carbohydrates',
      'sugar',
      'protein',
      'salt'
    ];
    String whereString = 'food_id = ?';
    List<dynamic> whereArguments = [id];
    List<Map> result = await db.query('food',
        columns: columnsToSelect,
        where: whereString,
        whereArgs: whereArguments);
    return result;
  }

  Future<List> getOneProductFromBarcode(String barcode) async {
    Database db = await DatabaseHelper.instance.database;
    List<String> columnsToSelect = [
      'food_id',
      'barcode',
      'name',
      'brand',
      'quantity',
      'quantity_ml',
      'calories',
      'fat',
      'saturated',
      'carbohydrates',
      'sugar',
      'protein',
      'salt'
    ];
    String whereString = 'barcode = ?';
    List<dynamic> whereArguments = [barcode];
    List<Map> result = await db.query('food',
        columns: columnsToSelect,
        where: whereString,
        whereArgs: whereArguments);
    return result;
  }

  Future<List> getOneDiaryEntry(int id, String date) async {
    Database db = await DatabaseHelper.instance.database;
    // get single row
    List<Map> result = await db.rawQuery(
        '''SELECT diary_id, weight, date, food_id FROM food_diary WHERE food_id = $id AND date = '$date' ''');
    return result;
  }

  Future<List> getOneFridgeEntry(int id, String mhd) async {
    Database db = await DatabaseHelper.instance.database;
    // get single row
    List<Map> result = await db.rawQuery(
        '''SELECT fridge_id, amount, mhd, food_id FROM fridge WHERE food_id = $id AND mhd = '$mhd' ''');
    return result;
  }

  Future<List> getSettings() async {
    Database db = await DatabaseHelper.instance.database;
    // get single row
    List<Map> result = await db
        .rawQuery('''SELECT gender FROM settings WHERE settings_id = 1''');
    return result;
  }

  Future<bool> checkProduct(String barcode) async {
    Database db = await DatabaseHelper.instance.database;
    // get single row
    List<String> columnsToSelect = ['barcode'];
    String whereString = 'barcode = ?';
    List<dynamic> whereArguments = [barcode];
    List<Map> result = await db.query('food',
        columns: columnsToSelect,
        where: whereString,
        whereArgs: whereArguments);
    return result.isNotEmpty;
  }

  Future<bool> checkDiaryEntry(int id, String date) async {
    Database db = await DatabaseHelper.instance.database;
    // get single row
    List<Map> result = await db.rawQuery(
        '''SELECT food_id FROM food_diary WHERE food_id = ? AND date = '$date' ''',
        [id]);
    return result.isNotEmpty;
  }
  //Check ob ein Eintrag mit der gegebenen ID existiert
  Future<bool> checkFridgeEntry(int id, String mhd) async {
    Database db = await DatabaseHelper.instance.database;
    // get single row
    List<Map> result = await db.rawQuery(
        '''SELECT fridge_id FROM fridge WHERE food_id = ? AND mhd = '$mhd' ''',
        [id]);
    return result.isNotEmpty;
  }
  //Check ob ein Eintrag (außer der aufrufende Eintrag) mit der gegebenen ID existiert
  Future<bool> checkFridgeEntryUpdate(int id, String mhd, int idNot) async {
    Database db = await DatabaseHelper.instance.database;
    // get single row
    List<Map> result = await db.rawQuery(
        '''SELECT fridge_id FROM fridge WHERE food_id = ? AND mhd = '$mhd' AND NOT fridge_id = $idNot''',
        [id]);
    return result.isNotEmpty;
  }

  Future<List<DiaryEntry>> getDiaryEntries() async {
    Database db = await instance.database;
    var entries = await db.rawQuery('''SELECT * FROM food_diary as f1
                                      WHERE date = ( SELECT max( f2.date ) FROM food_diary AS f2
                                                        WHERE f2.food_id = f1.food_id )
                                      GROUP BY food_id ORDER BY date ASC ''');
    List<DiaryEntry> entryList = entries.isNotEmpty
        ? entries.map((c) => DiaryEntry.fromMap(c)).toList()
        : [];
    return entryList;
  }

  Future<List<FridgeEntry>> getFridgeEntries() async {
    Database db = await instance.database;
    var entries = await db.query('fridge', orderBy: 'mhd ASC');
    List<FridgeEntry> entryList = entries.isNotEmpty
        ? entries.map((c) => FridgeEntry.fromMap(c)).toList()
        : [];
    return entryList;
  }

  Future<int> addProduct(OwnProduct product) async {
    Database db = await instance.database;
    return await db.insert('food', product.toMap());
  }

  Future<int> addDiaryEntry(DiaryEntry entry) async {
    Database db = await instance.database;
    if (await checkDiaryEntry(entry.food_id, entry.date)) {
      List<dynamic> dbEntry = await getOneDiaryEntry(entry.food_id, entry.date);
      await updateDiaryEntryFromID(dbEntry.first['diary_id'],
          (dbEntry.first['weight'].toDouble() + entry.weight));
      return 0;
    } else {
      return await db.insert('food_diary', entry.toMap());
    }
  }

  Future<int> addFridgeEntry(FridgeEntry entry) async {
    Database db = await instance.database;
    if (await checkFridgeEntry(entry.food_id, entry.mhd)) {
      List<dynamic> dbEntry = await getOneFridgeEntry(entry.food_id, entry.mhd);
      await updateFridgeEntryFromID(dbEntry.first['fridge_id'],
          (dbEntry.first['amount'].toDouble() + entry.amount));
      return 0;
    } else {
      return await db.insert('fridge', entry.toMap());
    }
  }

  Future<int> removeDiaryEntry(int id) async {
    Database db = await instance.database;
    return await db
        .delete('food_diary', where: 'diary_id = ?', whereArgs: [id]);
  }

  Future<int> removeFridgeEntry(int id) async {
    Database db = await instance.database;
    return await db.delete('fridge', where: 'fridge_id = ?', whereArgs: [id]);
  }


  updateDiaryEntry(DiaryEntry entry, double weight) async {
    Database db = await instance.database;
    entry.weight = weight;
    return await db.update('food_diary', entry.toMap(),
        where: 'diary_id = ?', whereArgs: [entry.diary_id]);
  }

  updateDiaryEntryFromID(int id, double weight) async {
    Database db = await instance.database;
    return await db.rawUpdate(
        '''UPDATE food_diary SET weight = ? WHERE diary_id = ?''',
        [weight, id]);
  }

  updateFridgeEntryFromID(int id, double amount) async {
    Database db = await instance.database;
    return await db.rawUpdate(
        '''UPDATE fridge SET amount = ? WHERE fridge_id = ?''', [amount, id]);
  }

  updateSettings(String type, int value) async {
    Database db = await instance.database;
    return await db.rawUpdate(
        '''UPDATE settings SET $type = ? WHERE settings_id = 1''', [value]);
  }

  updateFridgeEntry(FridgeEntry entry, DateTime mhd, int amount) async {
    var formatter = DateFormat('yyyy-MM-dd');
    Database db = await instance.database;
    entry.mhd = formatter.format(mhd);
    entry.amount = amount;

    if (await checkFridgeEntryUpdate(
        entry.food_id, entry.mhd, entry.fridge_id!)) {
      List<Map> result = await db.rawQuery(
          '''SELECT fridge_id, amount FROM fridge WHERE food_id = ? AND mhd = '${entry.mhd}' ''',
          [entry.food_id]);
      await db.rawUpdate(
          ''' UPDATE fridge SET amount = ${result.first['amount'] + entry.amount} where fridge_id = ${result.first['fridge_id']}''');
      await db.rawDelete(
          ''' DELETE FROM fridge WHERE fridge_id = ${entry.fridge_id}''');
      return 0;
    } else {
      return await db.update('fridge', entry.toMap(),
          where: 'fridge_id = ?', whereArgs: [entry.fridge_id]);
    }
  }

  Future<List?> getSummary() async {
    Database db = await instance.database;
    String sqlString = '''SELECT sum(fd.weight*f.calories/100) as calories,
     sum(fd.weight*f.fat/100) as fat, 
     sum(fd.weight*f.saturated/100) as saturated, 
     sum(fd.weight*f.carbohydrates/100) as carbohydrates,
     sum(fd.weight*f.sugar/100) as sugar,
     sum(fd.weight*f.protein/100) as protein,
     sum(fd.weight*f.salt/100) as salt
     FROM food AS f
     JOIN food_diary AS fd ON
     f.food_id = fd.food_id
     WHERE (JulianDay('now') - 7) < JulianDay(fd.date)''';
    var result = await db.rawQuery(sqlString);
    return result;
  }

  Future<List?> getSummaryCurrentDay() async {
    DateFormat ymd = DateFormat('yyyy-MM-dd');
    Database db = await instance.database;
    String sqlString = '''SELECT sum(fd.weight*f.calories/100) as calories,
     sum(fd.weight*f.fat/100) as fat, 
     sum(fd.weight*f.saturated/100) as saturated, 
     sum(fd.weight*f.carbohydrates/100) as carbohydrates,
     sum(fd.weight*f.sugar/100) as sugar,
     sum(fd.weight*f.protein/100) as protein,
     sum(fd.weight*f.salt/100) as salt
     FROM food AS f
     JOIN food_diary AS fd ON
     f.food_id = fd.food_id
     WHERE '${ymd.format(DateTime.now())}' LIKE fd.date''';
    var result = await db.rawQuery(sqlString);
    return result;
  }

  Future<String?> getNutriment(String nutriment, int id) async {
    Database db = await instance.database;
    List result = await db.rawQuery('''SELECT $nutriment FROM food
                      WHERE food_id = $id''');
    return result.first[nutriment];
  }

  Future<String?> getName(int id) async {
    // get a reference to the database
    Database db = await DatabaseHelper.instance.database;

    // get single row
    List<String> columnsToSelect = ['name'];
    String whereString = 'food_id = ?';
    List<dynamic> whereArguments = [id];
    List<Map> result = await db.query('food',
        columns: columnsToSelect,
        where: whereString,
        whereArgs: whereArguments);
    String name = result.first['name'];
    return name;
  }
  //Maximaler Datumsunterschied zwischen Einträgen der Ernährungstagebuch-Einträge
  Future<int?> getMaxDateDiff() async {
    Database db = await DatabaseHelper.instance.database;
    List result = await db.rawQuery('''Select Cast ((
    JulianDay('now') - JulianDay(min(date))
) As Integer) as diff FROM food_diary''');
    if (result.isNotEmpty) {
      return result.first['diff'];
    }
    return 0;
  }
}
