import 'dart:convert';
import 'dart:io';
import 'package:dieahnungslosen/diary_entry.dart';
import 'package:dieahnungslosen/main.dart';
import 'package:openfoodfacts/model/Product.dart';
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
      name STRING,
      marke STRING,
      menge INTEGER,
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
      food_id INTEGER,
      FOREIGN KEY (food_id) REFERENCES food (food_id)
      )
    ''');
    await db.execute('''
    CREATE TABLE fridge(
      fridge_id INTEGER PRIMARY KEY AUTOINCREMENT,
      quantity INTEGER,
      food_id INTEGER,
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

  Future<List<DiaryEntry>> getDiaryEntries() async {
    Database db = await instance.database;
    var entries = await db.query('food_diary');
    List<DiaryEntry> entryList = entries.isNotEmpty
        ? entries.map((e) => DiaryEntry.fromMap(e)).toList()
        : [];
    return entryList;
  }

  Future<int> addProduct(OwnProduct product) async {
    Database db = await instance.database;
    return await db.insert('food', product.toMap());
  }

  Future<int> addDiaryEntry(DiaryEntry entry) async {
    Database db = await instance.database;
    return await db.insert('food_diary', entry.toMap());
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

  Future<int> updateProduct(OwnProduct product) async {
    Database db = await instance.database;
    return await db.update('food', product.toMap(),
        where: 'food_id = ?', whereArgs: [product.food_id]);
  }

  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    Database db = await instance.database;
    return await db.update('diary_entry', entry.toMap(),
        where: 'diary_id = ?', whereArgs: [entry.id]);
  }

  getFullName(int id) async {
    // get a reference to the database
    Database db = await DatabaseHelper.instance.database;

    // get single row
    List<String> columnsToSelect = ['food_id', 'name', 'marke'];
    String whereString = 'food_id = ?';
    List<dynamic> whereArguments = [id];
    List<Map> result = await db.query('food',
        columns: columnsToSelect,
        where: whereString,
        whereArgs: whereArguments);
    String marke = result.first['marke'];
    String name = result.first['name'];
    return '${marke.substring(1, marke.length - 1)} ${name.substring(1, marke.length - 1)}';
  }
}
