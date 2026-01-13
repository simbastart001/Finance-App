import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/database_service.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final apiTransactions = await ApiService.getTransactions();
      state = apiTransactions..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      state = DatabaseService.getAllTransactions()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    required TransactionType type,
    String? description,
  }) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
      type: type,
      description: description,
    );

    try {
      await ApiService.createTransaction(transaction);
    } catch (e) {
      await DatabaseService.addTransaction(transaction);
    }
    
    loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    try {
      await ApiService.updateTransaction(transaction);
    } catch (e) {
      await DatabaseService.updateTransaction(transaction);
    }
    loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    try {
      await ApiService.deleteTransaction(id);
    } catch (e) {
      await DatabaseService.deleteTransaction(id);
    }
    loadTransactions();
  }

  List<Transaction> getIncomeTransactions() {
    return state.where((t) => t.type == TransactionType.income).toList();
  }

  List<Transaction> getExpenseTransactions() {
    return state.where((t) => t.type == TransactionType.expense).toList();
  }

  double getTotalIncome() {
    return getIncomeTransactions().fold(0, (sum, t) => sum + t.amount);
  }

  double getTotalExpenses() {
    return getExpenseTransactions().fold(0, (sum, t) => sum + t.amount);
  }

  double getBalance() {
    return getTotalIncome() - getTotalExpenses();
  }
}

final transactionProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>(
  (ref) => TransactionNotifier(),
);