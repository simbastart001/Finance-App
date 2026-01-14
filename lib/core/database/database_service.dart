import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class DatabaseService {
  static const String _transactionBoxName = 'transactions';
  static Box<Transaction>? _transactionBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    _transactionBox = await Hive.openBox<Transaction>(_transactionBoxName);
    await _migrateData();
  }

  static Future<void> _migrateData() async {
    final box = transactionBox;
    for (var key in box.keys) {
      final transaction = box.get(key);
      if (transaction != null) {
        // Set default values for new fields if they're at epoch time
        if (transaction.createdAt.year == 1) {
          transaction.createdAt = transaction.date;
        }
        if (transaction.updatedAt.year == 1) {
          transaction.updatedAt = transaction.date;
        }
        await box.put(key, transaction);
      }
    }
  }

  static Box<Transaction> get transactionBox {
    if (_transactionBox == null) {
      throw Exception('Database not initialized');
    }
    return _transactionBox!;
  }

  static Future<void> addTransaction(Transaction transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    await transactionBox.put(transaction.id, transaction);
  }

  static Future<void> deleteTransaction(String id) async {
    await transactionBox.delete(id);
  }

  static List<Transaction> getAllTransactions() {
    return transactionBox.values.toList();
  }

  static List<Transaction> getTransactionsByType(TransactionType type) {
    return transactionBox.values.where((t) => t.type == type).toList();
  }

  static List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return transactionBox.values
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();
  }

  static Transaction? getTransaction(String id) {
    return transactionBox.get(id);
  }
}