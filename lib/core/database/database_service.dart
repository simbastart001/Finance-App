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
}