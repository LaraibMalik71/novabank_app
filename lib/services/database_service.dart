import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();

  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'novabank.db');
    debugPrint('NOVABANK DATABASE PATH: $path');
    return openDatabase(
      path,
      version: 6,

      onCreate: (db, version) async {
        await _createUsersTable(db);
        await _createTransactionsTable(db);
        await _createBeneficiariesTable(db);
        await _createNotificationsTable(db);
        await _createCardsTable(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createTransactionsTable(db);
        }

        if (oldVersion < 3) {
          await _createBeneficiariesTable(db);
        }
        if (oldVersion < 4) {
          await _createNotificationsTable(db);
        }
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE users ADD COLUMN account_number TEXT');
        }
        if (oldVersion < 6) {
          await _createCardsTable(db);
        }
      },
    );
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        password_salt TEXT NOT NULL,
        account_number TEXT
      )
    ''');
  }

  Future<void> _createTransactionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        sender TEXT NOT NULL,
        receiver TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createBeneficiariesTable(Database db) async {
    await db.execute('''
      CREATE TABLE beneficiaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        account_number TEXT NOT NULL,
        bank_name TEXT NOT NULL,
        beneficiary_type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createNotificationsTable(Database db) async {
    await db.execute('''
    CREATE TABLE notifications (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      body TEXT NOT NULL,
      created_at TEXT NOT NULL,
      is_read INTEGER NOT NULL DEFAULT 0
    )
  ''');
  }

  Future<void> _createCardsTable(Database db) async {
    await db.execute('''
    CREATE TABLE cards (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      card_number TEXT NOT NULL UNIQUE,
      cardholder_name TEXT NOT NULL,
      nickname TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'Active',
      is_primary INTEGER NOT NULL DEFAULT 0,
      created_at TEXT NOT NULL
    )
  ''');
  }
}
