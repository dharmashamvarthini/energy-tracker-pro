import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bill_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'energy_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bills(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        units REAL,
        month TEXT,
        stressLevel REAL,
        date TEXT
      )
    ''');
  }

  Future<int> insertBill(BillModel bill) async {
    Database db = await database;
    return await db.insert('bills', bill.toMap());
  }

  Future<List<BillModel>> getAllBills() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bills', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => BillModel.fromMap(maps[i]));
  }

  Future<int> deleteBill(int id) async {
    Database db = await database;
    return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }
}