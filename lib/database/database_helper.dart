import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('tarefas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tarefas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        descricao TEXT NOT NULL
      )
    ''');
  }

  Future<int> inserirTarefa(String descricao) async {
    final db = await database;

    return await db.insert(
      'tarefas',
      {
        'descricao': descricao,
      },
    );
  }

  Future<List<Map<String, dynamic>>> listarTarefas() async {
    final db = await database;

    return await db.query('tarefas');
  }

  Future<void> removerTarefa(int id) async {
    final db = await database;

    await db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}