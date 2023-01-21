import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import "package:path/path.dart";
import 'package:path_provider/path_provider.dart';

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;

  Transaction({
    @required this.id,
    @required this.title,
    @required this.amount,
    @required this.date,
  });

  factory Transaction.fromMap(Map<String, dynamic> json) => new Transaction(
        id: json["id"],
        title: json["title"],
        amount: json["amount"],
        date: DateTime.parse(json["date"]),
        //date: json["date"],
      );

  Map<String, dynamic> toMap() {
    return {
      "id": id.toString(),
      "title": title,
      "amount": amount,
      "date": date.toIso8601String()
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "expenses.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute("""
       CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        title TEXT,
        amount DOUBLE,
        date TEXT
       )


      """);
  }

  Future<List<Transaction>> getTransactions() async {
    Database db = await instance.database;
    var transactions = await db.query("expenses", orderBy: 'title');
    List<Transaction> transactionList = transactions.isNotEmpty
        ? transactions.map((c) => Transaction.fromMap(c)).toList()
        : [];

    print("model $transactionList");
    return transactionList;
  }

  Future<int> add(Transaction transaction) async {
    Database db = await instance.database;
    return await db.insert("expenses", transaction.toMap()).then((value) {
      print("Successfullly added the expenses");
    });
  }

  Future<int> remove(String id) async {
    Database db = await instance.database;
    return await db.delete("expenses", where: "id=?", whereArgs: [id]);
  }

  Future<int> update(Transaction transaction) async {
    Database db = await instance.database;
    return await db.update("expenses", transaction.toMap(),
        where: 'id=?', whereArgs: [transaction.id]);
  }
}
