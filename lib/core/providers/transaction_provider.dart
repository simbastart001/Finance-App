import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../database/database_service.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  TransactionNotifier() : super([]) {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    print('backIntLogs: Loading transactions...');
    
    try {
      print('backIntLogs: Attempting to load from API');
      final apiTransactions = await ApiService.getTransactions();
      state = apiTransactions..sort((a, b) => b.date.compareTo(a.date));
      print('backIntLogs: Successfully loaded ${apiTransactions.length} transactions from API');
    } catch (e) {
      print('backIntLogs: API failed, falling back to local database: $e');
      final localTransactions = DatabaseService.getAllTransactions();
      state = localTransactions..sort((a, b) => b.date.compareTo(a.date));
      print('backIntLogs: Loaded ${localTransactions.length} transactions from local database');
    }
  }

  Future<void> addTransaction({
    required String title,
    required double amount,
    required String category,
    required TransactionType type,
    String? description,
  }) async {
    print('backIntLogs: Adding transaction: $title');
    
    final user = await AuthService.getCurrentUser();
    final deviceId = await AuthService.getDeviceId();
    
    final transaction = Transaction(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      category: category,
      date: DateTime.now(),
      type: type,
      description: description,
      userId: user?.id,
      deviceId: deviceId,
    );

    try {
      print('backIntLogs: Attempting to create transaction via API');
      await ApiService.createTransaction(transaction);
      print('backIntLogs: Transaction created successfully via API');
    } catch (e) {
      print('backIntLogs: API create failed, saving locally: $e');
      await DatabaseService.addTransaction(transaction);
      print('backIntLogs: Transaction saved to local database');
    }
    
    loadTransactions();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    print('backIntLogs: Updating transaction: ${transaction.id}');
    
    try {
      print('backIntLogs: Attempting to update transaction via API');
      await ApiService.updateTransaction(transaction);
      print('backIntLogs: Transaction updated successfully via API');
    } catch (e) {
      print('backIntLogs: API update failed, updating locally: $e');
      await DatabaseService.updateTransaction(transaction);
      print('backIntLogs: Transaction updated in local database');
    }
    loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    print('backIntLogs: Deleting transaction: $id');
    
    try {
      print('backIntLogs: Attempting to delete transaction via API');
      await ApiService.deleteTransaction(id);
      print('backIntLogs: Transaction deleted successfully via API');
    } catch (e) {
      print('backIntLogs: API delete failed, deleting locally: $e');
      await DatabaseService.deleteTransaction(id);
      print('backIntLogs: Transaction deleted from local database');
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