import '../models/transaction.dart';
import '../services/api_service.dart';
import '../database/database_service.dart';

class SyncService {
  static Future<void> syncTransactions() async {
    print('syncLogs: Starting sync...');
    
    try {
      // Push unsynced local transactions
      await _pushUnsyncedTransactions();
      
      // Pull all user transactions from backend
      await _pullTransactions();
      
      print('syncLogs: Sync completed successfully');
    } catch (e) {
      print('syncLogs: Sync failed: $e');
    }
  }

  static Future<void> _pushUnsyncedTransactions() async {
    final localTransactions = DatabaseService.getAllTransactions();
    final unsynced = localTransactions.where((t) => !t.isSynced).toList();
    
    print('syncLogs: Found ${unsynced.length} unsynced transactions');
    
    for (var transaction in unsynced) {
      try {
        await ApiService.createTransaction(transaction);
        transaction.isSynced = true;
        transaction.updatedAt = DateTime.now();
        await DatabaseService.updateTransaction(transaction);
        print('syncLogs: Synced transaction: ${transaction.id}');
      } catch (e) {
        print('syncLogs: Failed to sync transaction ${transaction.id}: $e');
      }
    }
  }

  static Future<void> _pullTransactions() async {
    try {
      final apiTransactions = await ApiService.getTransactions();
      print('syncLogs: Pulled ${apiTransactions.length} transactions from API');
      
      for (var transaction in apiTransactions) {
        transaction.isSynced = true;
        final existing = DatabaseService.getTransaction(transaction.id);
        
        if (existing == null) {
          await DatabaseService.addTransaction(transaction);
        } else if (transaction.updatedAt.isAfter(existing.updatedAt)) {
          await DatabaseService.updateTransaction(transaction);
          print('syncLogs: Updated transaction ${transaction.id} from server');
        }
      }
    } catch (e) {
      print('syncLogs: Failed to pull transactions: $e');
    }
  }
}
