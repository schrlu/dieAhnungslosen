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

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE food(
      food_id INTEGER PRIMARY KEY AUTOINCREMENT,
      barcode STRING,
      name STRING,
      marke STRING,
      menge STRING,
      menge_ml DECIMAL,
      kalorien INTEGER,
      fett DECIMAL,
      gesaettigt DECIMAL,
      kohlenhydrate DECIMAL,
      davonZucker DECIMAL,
      eiweiss DECIMAL,
      salz DECIMAL
      )
    ''');
    await db.execute('''
      CREATE TABLE food_diary(
      diary_id INTEGER PRIMARY KEY AUTOINCREMENT,
      weight DECIMAL,
      date DATE,
      food_id INTEGER,
      FOREIGN KEY (food_id) REFERENCES food (food_id)
      )
    ''');
    await db.execute('''
    CREATE TABLE fridge(
      fridge_id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount INTEGER,
      food_id INTEGER,
      mhd STRING,
      FOREIGN KEY (food_id) REFERENCES food (food_id)
      )
    ''');
  }

  Future<List<OwnProduct>> getProducts() async {
    Database db = await instance.database;
    var products = await db.query('food');
    List<OwnProduct> productsList = products.isNotEmpty
        ? products.map((e) => OwnProduct.fromMap(e)).toList()
        : [];
    return productsList;
  }

  Future<List> getOneProductFromId(int id) async {
    Database db = await DatabaseHelper.instance.database;
    // get single row
    List<String> columnsToSelect = [
      'food_id',
      'barcode',
      'name',
      'marke',
      'menge',
      'menge_ml',
      'kalorien',
      'fett',
      'gesaettigt',
      'kohlenhydrate',
      'davonZucker',
      'eiweiss',
      'salz'
    ];
    String whereString = 'food_id = ?';
    List<dynamic> whereArguments = [id];
    List<Map> result = await db.query('food',
        columns: columnsToSelect,
        where: whereString,
        whereArgs: whereArguments);
    print(result);
    return result;
  }

  Future<List> getOneProduct(String barcode) async {
    Database db = await DatabaseHelper.instance.database;
    // get single row
    List<String> columnsToSelect = [
      'food_id',
      'barcode',
      'name',
      'marke',
      'menge',
      'menge_ml',
      'kalorien',
      'fett',
      'gesaettigt',
      'kohlenhydrate',
      'davonZucker',
      'eiweiss',
      'salz'
    ];
    String whereString = 'barcode = ?';
    List<dynamic> whereArguments = [barcode];
    List<Map> result = await db.query('food',
        columns: columnsToSelect,
        where: whereString,
        whereArgs: whereArguments);
    return result;
  }

  Future<List> getOneDiaryEntry(int id) async {
    Database db = await DatabaseHelper.instance.database;
    // get single row
    List<Map> result = await db.rawQuery(
        '''SELECT diary_id, weight, date, food_id FROM food_diary WHERE food_id = $id AND date = (SELECT DATE('now')) ''');
    return result;
  }

  Future<bool> checkProduct(String barcode) async {
    // get a reference to the database
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

  Future<bool> checkDiaryEntry(int id) async {
    // get a reference to the database
    Database db = await DatabaseHelper.instance.database;
    // get single row
    List<Map> result = await db.rawQuery(
        '''SELECT food_id FROM food_diary WHERE food_id = ? AND date = (SELECT DATE('now'))''',
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
    var entries = await db.query('fridge', orderBy: 'mhd DESC');
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
    if (await checkDiaryEntry(entry.food_id)) {
      List<dynamic> dbEntry = await getOneDiaryEntry(entry.food_id);
      await updateDiaryEntryFromID(dbEntry.first['diary_id'],
          (dbEntry.first['weight'].toDouble() + entry.weight));
      return 0;
    } else {
      return await db.insert('food_diary', entry.toMap());
    }
  }

  Future<int> addFridgeEntry(FridgeEntry entry) async {
    Database db = await instance.database;
    return await db.insert('fridge', entry.toMap());
  }

  Future<int> removeProduct(int id) async {
    Database db = await instance.database;
    return await db.delete('food', where: 'food_id = ?', whereArgs: [id]);
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

  Future<int> updateProduct(OwnProduct product) async {
    Database db = await instance.database;
    return await db.update('food', product.toMap(),
        where: 'food_id = ?', whereArgs: [product.food_id]);
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

  updateFridgeEntry(FridgeEntry entry, DateTime mhd, int amount) async {
    var formatter = DateFormat('yyyy-MM-dd');
    Database db = await instance.database;
    entry.mhd = formatter.format(mhd);
    entry.amount = amount;
    return await db.update('food_diary', entry.toMap(),
        where: 'diary_id = ?', whereArgs: [entry.fridge_id]);
  }

  Future<List?> getSummary () async {
    Database db = await instance.database;
    print('test');

    var result = await db.rawQuery('''SELECT food_id, sum(weight) as weight FROM food_diary
	                                WHERE (SELECT DATE('now') - 7 ) < date 
                                GROUP BY food_id''');
    return result;
  }



  Future<String?> getNutriment(String nutriment, int id) async {
    Database db = await instance.database;
    List result = db.rawQuery('''SELECT $nutriment FROM food
                      WHERE food_id = $id''') as List;
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

  Future<String?> getMarke(int id) async {
    // get a reference to the database
    Database db = await DatabaseHelper.instance.database;

    // get single row
    List<String> columnsToSelect = ['marke'];
    String whereString = 'food_id = ?';
    List<dynamic> whereArguments = [id];
    List<Map> result = await db.query('food',
        columns: columnsToSelect,
        where: whereString,
        whereArgs: whereArguments);
    String marke = result.first['marke'];
    return marke;
  }


}
