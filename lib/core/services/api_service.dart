import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';
import './auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.222.225:5169/api';

  static Future<List<Transaction>> getTransactions() async {
    print('backIntLogs: Fetching transactions from API');
    
    try {
      final token = AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('backIntLogs: API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('backIntLogs: Successfully fetched ${data.length} transactions');
        return data.map((json) => Transaction.fromJson(json)).toList();
      }
      print('backIntLogs: Failed to fetch transactions - Status: ${response.statusCode}');
      throw Exception('Failed to load transactions');
    } catch (e) {
      print('backIntLogs: Error fetching transactions: $e');
      rethrow;
    }
  }

  static Future<Transaction> createTransaction(Transaction transaction) async {
    print('backIntLogs: Creating transaction: ${transaction.title}');
    
    try {
      final token = AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(transaction.toJson()),
      );
      
      print('backIntLogs: Create transaction response: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        print('backIntLogs: Transaction created successfully');
        return Transaction.fromJson(json.decode(response.body));
      }
      print('backIntLogs: Failed to create transaction - Status: ${response.statusCode}');
      throw Exception('Failed to create transaction');
    } catch (e) {
      print('backIntLogs: Error creating transaction: $e');
      rethrow;
    }
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    print('backIntLogs: Updating transaction: ${transaction.id}');
    
    try {
      final token = AuthService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/transactions/${transaction.id}'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: json.encode(transaction.toJson()),
      );
      
      print('backIntLogs: Update transaction response: ${response.statusCode}');
      
      if (response.statusCode != 204) {
        print('backIntLogs: Failed to update transaction - Status: ${response.statusCode}');
        throw Exception('Failed to update transaction');
      }
      print('backIntLogs: Transaction updated successfully');
    } catch (e) {
      print('backIntLogs: Error updating transaction: $e');
      rethrow;
    }
  }

  static Future<void> deleteTransaction(String id) async {
    print('backIntLogs: Deleting transaction: $id');
    
    try {
      final token = AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/transactions/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('backIntLogs: Delete transaction response: ${response.statusCode}');
      
      if (response.statusCode != 204) {
        print('backIntLogs: Failed to delete transaction - Status: ${response.statusCode}');
        throw Exception('Failed to delete transaction');
      }
      print('backIntLogs: Transaction deleted successfully');
    } catch (e) {
      print('backIntLogs: Error deleting transaction: $e');
      rethrow;
    }
  }
}