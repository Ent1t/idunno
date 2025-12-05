import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/member.dart';
import '../models/payment.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('loan_manager.db');
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

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact TEXT NOT NULL,
        photoPath TEXT,
        principalAmount REAL NOT NULL,
        monthlyPayment REAL NOT NULL,
        paymentDay INTEGER NOT NULL,
        loanTermMonths INTEGER NOT NULL,
        totalPayoutAmount REAL NOT NULL,
        startDate TEXT NOT NULL,
        status TEXT NOT NULL,
        totalPaid REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memberId INTEGER NOT NULL,
        amount REAL NOT NULL,
        paymentDate TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (memberId) REFERENCES members (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> insertMember(Member member) async {
    final db = await database;
    return await db.insert('members', member.toMap());
  }

  Future<List<Member>> getAllMembers() async {
    final db = await database;
    final result = await db.query('members');
    return result.map((map) => Member.fromMap(map)).toList();
  }

  Future<Member?> getMember(int id) async {
    final db = await database;
    final result = await db.query('members', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Member.fromMap(result.first);
  }

  Future<int> updateMember(Member member) async {
    final db = await database;
    return await db.update(
      'members',
      member.toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  Future<int> deleteMember(int id) async {
    final db = await database;
    return await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertPayment(Payment payment) async {
    final db = await database;
    return await db.insert('payments', payment.toMap());
  }

  Future<List<Payment>> getPaymentsByMember(int memberId) async {
    final db = await database;
    final result = await db.query(
      'payments',
      where: 'memberId = ?',
      whereArgs: [memberId],
      orderBy: 'paymentDate DESC',
    );
    return result.map((map) => Payment.fromMap(map)).toList();
  }

  Future<List<Payment>> getAllPayments() async {
    final db = await database;
    final result = await db.query('payments', orderBy: 'paymentDate DESC');
    return result.map((map) => Payment.fromMap(map)).toList();
  }
}
