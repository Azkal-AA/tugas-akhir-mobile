import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class WishlistDatabase {
  static final WishlistDatabase instance = WishlistDatabase._init();
  static Database? _database;

  WishlistDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('wishlist.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wishlist (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        price REAL NOT NULL,
        originalPrice REAL NOT NULL,
        discount INTEGER NOT NULL,
        thumb TEXT NOT NULL,
        store TEXT
      )
    ''');
  }

  Future<void> addToWishlist(Map<String, dynamic> game) async {
    final db = await instance.database;
    await db.insert('wishlist', game);
  }

  Future<void> removeFromWishlist(String id) async {
    final db = await instance.database;
    await db.delete('wishlist', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getWishlist() async {
    final db = await instance.database;
    return await db.query('wishlist');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
