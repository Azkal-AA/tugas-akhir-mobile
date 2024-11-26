// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import '../models/game.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   factory DatabaseHelper() => _instance;
//   DatabaseHelper._internal();

//   Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDb();
//     return _database!;
//   }

//   Future<Database> _initDb() async {
//     final path = join(await getDatabasesPath(), "wishlist.db");
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: (db, version) async {
//         await db.execute('''
//           CREATE TABLE wishlist (
//             id TEXT PRIMARY KEY,
//             title TEXT,
//             price REAL,
//             store TEXT,
//             thumb TEXT
//           )
//         ''');
//       },
//     );
//   }

//   Future<void> insertGame(Game game) async {
//     final db = await database;
//     await db.insert(
//       "wishlist",
//       {
//         'id': game.id,
//         'title': game.title,
//         'price': game.price,
//         'store': game.store,
//         'thumb': game.thumb, // Menyimpan URL gambar
//       },
//       conflictAlgorithm:
//           ConflictAlgorithm.replace, // Menghindari error pada primary key
//     );
//   }

//   Future<List<Game>> getWishlist() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('wishlist');
//     return List.generate(maps.length, (i) {
//       return Game(
//         id: maps[i]['id'],
//         title: maps[i]['title'],
//         price: maps[i]['price'],
//         store: maps[i]['store'],
//         thumb: maps[i]['thumb'],
//         originalPrice: 0, // Set default jika tidak disimpan di database
//         discount: 0, // Set default jika tidak disimpan di database
//       );
//     });
//   }

//   Future<void> deleteGame(String id) async {
//     final db = await database;
//     await db.delete("wishlist", where: "id = ?", whereArgs: [id]);
//   }
// }
