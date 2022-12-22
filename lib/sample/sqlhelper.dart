import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class sqlHelper {
  static Future<void>createTables(sql.Database database)async{
    await database.execute("""CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    title TEXT,
    description TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)
    """);
  }
  static Future<sql.Database>db()async{
    return sql.openDatabase(
      'kindacode.db',
      version:1,
      onCreate:(sql.Database database,int version)async{
        await createTables(database);
      }
    );
  }
  static Future<int> createItem(String title,String?description)async{
    final db=await sqlHelper.db();
    final data1={'title':title,'description':description};
    final id =await db.insert('items', data1,conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await sqlHelper.db();
    return db.query('items', orderBy: "id");
  }
  static Future<int> updateItem(int id, String title, String? descrption) async {
    final db = await sqlHelper.db();
    final data1 = {
      'title': title,
      'description': descrption,
      'createdAt': DateTime.now().toString()
    };
    final result = await db.update('items', data1, where: "id = ?", whereArgs: [id]);
    return result;
  }
  static Future<void> deleteItem(int id) async {
    final db = await sqlHelper.db();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
