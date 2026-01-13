import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5169/api';

  static Future<List<Transaction>> getTransactions() async {
    final response = await http.get(Uri.parse('$baseUrl/transactions'));
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    }
    throw Exception('Failed to load transactions');
  }

  static Future<Transaction> createTransaction(Transaction transaction) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaction.toJson()),
    );
    
    if (response.statusCode == 201) {
      return Transaction.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create transaction');
  }

  static Future<void> updateTransaction(Transaction transaction) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/${transaction.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaction.toJson()),
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to update transaction');
    }
  }

  static Future<void> deleteTransaction(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/transactions/$id'));
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete transaction');
    }
  }
}