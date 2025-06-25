import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/daily_record.dart';
import '../models/manual_expense.dart';

class DatabaseController {
  // Singleton pattern implementation
  static final DatabaseController _instance = DatabaseController._internal();
  static Database? _database;

  factory DatabaseController() => _instance;

  DatabaseController._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDatabase() async {
    try {
      final String dbPath = await getDatabasesPath();
      final String path = join(dbPath, 'ticket.db');

      // Delete the database if it exists but is corrupted
      try {
        final db = await openDatabase(path);
        await db.close();
      } catch (e) {
        await deleteDatabase(path);
      }

      return await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) async {
          // Verify database structure
          try {
            await db.query('daily_records', limit: 1);
          } catch (e) {
            await db.execute('DROP TABLE IF EXISTS daily_records');
            await _onCreate(db, 1);
          }
        },
      );
    } catch (e) {
      throw Exception('Failed to initialize database: $e');
    }
  }

  // Create database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_records (
        date TEXT PRIMARY KEY,
        ticketPrice REAL,
        preSale INTEGER,
        bookNumber INTEGER,
        completedBooks INTEGER,
        ticketsPerSheet INTEGER,
        grocery REAL,
        sarf REAL,
        lunch REAL,
        hetham REAL,
        alhouri REAL,
        majed REAL,
        white REAL,
        anas REAL,
        manualExpenses TEXT,
        remainingTickets INTEGER,
        tickets INTEGER,
        expenseTotal REAL,
        cashBox REAL,
        total REAL
      )
    ''');
  }

  // Insert or replace daily record
  Future<int> insertRecord(DailyRecord record) async {
    final Database db = await database;
    return await db.insert(
      'daily_records',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all records sorted by date
  Future<List<DailyRecord>> getAllRecords() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_records',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return DailyRecord(
        date: maps[i]['date'],
        ticketPrice: maps[i]['ticketPrice'],
        preSale: maps[i]['preSale'],
        bookNumber: maps[i]['bookNumber'],
        completedBooks: maps[i]['completedBooks'],
        ticketsPerSheet: maps[i]['ticketsPerSheet'],
        grocery: maps[i]['grocery'],
        sarf: maps[i]['sarf'],
        lunch: maps[i]['lunch'],
        hetham: maps[i]['hetham'],
        alhouri: maps[i]['alhouri'],
        majed: maps[i]['majed'],
        white: maps[i]['white'],
        anas: maps[i]['anas'],
        manualExpenses: List<ManualExpense>.from(
          jsonDecode(maps[i]['manualExpenses']).map(
            (x) => ManualExpense.fromMap(x),
          ),
        ),
        remainingTickets: maps[i]['remainingTickets'],
        tickets: maps[i]['tickets'],
        expenseTotal: maps[i]['expenseTotal'],
        cashBox: maps[i]['cashBox'],
        total: maps[i]['total'],
      );
    });
  }

  // Calculate the total for a specific field between two dates
  Future<double> getFieldTotalBetweenDates(
      String field, String startDate, String endDate) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'daily_records',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );

    double total = 0.0;
    for (var map in maps) {
      total += map[field] ?? 0.0;
    }

    return total;
  }

  // Delete specific record by date
  Future<int> deleteRecord(String date) async {
    try {
      final Database db = await database;
      return await db.delete(
        'daily_records',
        where: 'date = ?',
        whereArgs: [date],
      );
    } catch (e) {
      print("Error deleting record: $e");
      return -1; // Indicate failure
    }
  }

  // Check if record exists for today
  Future<bool> recordExists(String date) async {
    final Database db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'daily_records',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.isNotEmpty;
  }

  // Close the database connection
  Future<void> close() async {
    final Database db = await database;
    await db.close();
  }

  // Get the database path
  Future<String> get databasePath async {
    if (_database != null) return _database!.path;
    await database;
    return _database!.path;
  }
}
