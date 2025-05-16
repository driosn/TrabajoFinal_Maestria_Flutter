import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'document_manager.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Roles table
    await db.execute('''
      CREATE TABLE roles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        role TEXT NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create Users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        roleId INTEGER NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        isActive INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (roleId) REFERENCES roles (id)
      )
    ''');

    // Create Statuses table
    await db.execute('''
      CREATE TABLE statuses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        status TEXT NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Create Documents table
    await db.execute('''
      CREATE TABLE documents(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        imgLocalPath TEXT NOT NULL,
        scannedText TEXT NOT NULL,
        statusId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (statusId) REFERENCES statuses (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // Insert default roles
    await db.insert('roles', {'role': 'Editor'});
    await db.insert('roles', {'role': 'Admin'});

    // Insert default statuses
    await db.insert('statuses', {'status': 'Pendiente'});
    await db.insert('statuses', {'status': 'Aprobado'});
    await db.insert('statuses', {'status': 'Rechazado'});
    await db.insert('statuses', {'status': 'Cancelado'});

    // Insert default admin user
    await db.insert('users', {
      'name': 'Admin',
      'lastName': 'User',
      'email': 'admin@admin.com',
      'password': 'admin1234',
      'roleId': 2, // Admin role
      'createdAt': DateTime.now().toIso8601String(),
    });

    await db.insert('users', {
      'name': 'Editor',
      'lastName': 'User',
      'email': 'editor@editor.com',
      'password': 'editor1234',
      'roleId': 1, // Editor role
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add scannedText column to documents table
      await db.execute(
          'ALTER TABLE documents ADD COLUMN scannedText TEXT NOT NULL DEFAULT ""');
    }
  }

  Future<void> _onOpen(Database db) async {
    // Verificar si existe el usuario administrador
    final List<Map<String, dynamic>> adminUser = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@admin.com'],
    );

    if (adminUser.isEmpty) {
      // Si no existe, crear el usuario administrador
      await db.insert('users', {
        'name': 'Admin',
        'lastName': 'User',
        'email': 'admin@admin.com',
        'password': 'admin1234',
        'roleId': 2, // Admin role
        'createdAt': DateTime.now().toIso8601String(),
      });
    }

    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }
}
