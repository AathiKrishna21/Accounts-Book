import 'dart:core';
import 'dart:io';
import 'package:path/path.dart';
import 'package:accounts_book/models/trxn_class.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'models/acct_class.dart';

class SQLiteDbProvider {
  SQLiteDbProvider._();
  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await initDB();
    return _database!;
  }
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "abdatabase.db");
    return await openDatabase(
        path, version: 1,
        onOpen: (db) {},
        onConfigure: _onConfigure,
        // onUpgrade: _onUpgrade,
        onCreate: (Database db, int version) async {
          await db.execute("CREATE TABLE Trxn ("
              "id INTEGER PRIMARY KEY,"
              "date TEXT,"
              "reason TEXT,"
              "is_gain INTEGER,"
              "total REAL,"
              "title INTEGER,"
              "FOREIGN KEY (title) REFERENCES Acct(id) ON DELETE CASCADE)");
          await db.execute(
              "CREATE TABLE Acct ("
                  "id INTEGER PRIMARY KEY,"
                  "acct TEXT)"
          );
        }
    );
  }

  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }
  // _onUpgrade(Database db, int oldVersion, int newVersion) async{
  // }
  Future<List<Acct>> getAllAccts() async {
    final db = await database;
    List<Map<String,dynamic>> results = await db.query(
        "Acct", columns: Acct.columns, orderBy: "id ASC"
    );
    List<Acct> accts = [];
    results.forEach((result) {
      Acct acct = Acct.fromMap(result);
      accts.add(acct);
    });
    return accts;
  }
  Future<List<Trxn>> getgainAcctsByTopic(int str,int t) async {
    final db = await database;
    List<Map<String,dynamic>> results = await db.rawQuery("SELECT * FROM Trxn WHERE is_gain="+t.toString()+" AND title= "+str.toString());
    List<Trxn> trxns = [];
    results.forEach((result) {
      Trxn trxn = Trxn.fromMap(result);
      trxns.add(trxn);
    });
    return trxns;
  }
  gettotal(int title,int is_gain) async {
    final db = await database;
    List<Map<String,dynamic>> results = await db.rawQuery("SELECT SUM(total) as total FROM Trxn where title="+title.toString()+" AND is_gain="+is_gain.toString());
    return results.toList();
  }
   getAcctById(int id) async {
    final db = await database;
    var result = await db.query("Acct", where: "id = ", whereArgs: [id]);
    return result.isNotEmpty ? Acct.fromMap(result.first) : Null;
  }
  insertAcct(Acct acct) async {
    final db = await database;
    var maxIdResult = await db.rawQuery("SELECT MAX(id)+1 as last_inserted_id FROM Acct");
    var id = maxIdResult.first["last_inserted_id"];
    var result = await db.rawInsert(
        "INSERT Into Acct (id, acct)"
            " VALUES (?, ?)",
        [id, acct.acct]
    );
    // return result;
  }
  insert(Trxn trxn) async {
    final db = await database;
    var maxIdResult = await db.rawQuery("SELECT MAX(id)+1 as last_inserted_id FROM Trxn");
    var id = maxIdResult.first["last_inserted_id"];
    var result = await db.rawInsert(
        "INSERT Into Trxn (id, date, reason, is_gain, total, title)"
            " VALUES (?, ?, ?, ?, ?, ?)",
        [id, trxn.date, trxn.reason, trxn.is_gain, trxn.total, trxn.title]
    );
  }
  update(Trxn trxn) async {
    final db = await database;
    var result = await db.update(
        "Trxn", trxn.toMap(), where: "id = ?", whereArgs: [trxn.id]
    );
    return result;
  }
  updateAcct(Acct acct) async {
    final db = await database;
    var result = await db.update(
        "Acct", acct.toMap(), where: "id = ?", whereArgs: [acct.id]
    );
    return result;
  }
  delete(int id) async {
    final db = await database;
    db.delete("Trxn", where: "id = ?", whereArgs: [id]);
  }
  deleteAcct(int id) async {
    final db = await database;
    db.delete("Acct", where: "id = ?", whereArgs: [id]);
  }
}