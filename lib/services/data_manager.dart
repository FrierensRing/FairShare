// services/data_manager.dart - Data persistence service
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class DataManager {
  // Keys for SharedPreferences
  static const String _usersKey = 'users';
  static const String _transactionsKey = 'transactions';

  // Save users list
  static Future<bool> saveUsers(List<String> users) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setStringList(_usersKey, users);
  }

  // Load users list
  static Future<List<String>> loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_usersKey) ?? [];
  }

  // Save transactions list
  static Future<bool> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert transactions to a JSON string
    final List<Map<String, dynamic>> transactionsJson = transactions.map((t) => {
      'payerId': t.payerId,
      'splitBetween': t.splitBetween,
      'amount': t.amount,
      'description': t.description,
      'dateTime': t.dateTime.toIso8601String(),
    }).toList();

    return prefs.setString(_transactionsKey, jsonEncode(transactionsJson));
  }

  // Load transactions list
  static Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsString = prefs.getString(_transactionsKey);

    if (transactionsString == null || transactionsString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> transactionsJson = jsonDecode(transactionsString);
      return transactionsJson.map((json) => Transaction(
        payerId: json['payerId'],
        splitBetween: List<String>.from(json['splitBetween']),
        amount: json['amount'].toDouble(),
        description: json['description'] ?? '',
        dateTime: DateTime.parse(json['dateTime']),
      )).toList();
    } catch (e) {
      print('Error loading transactions: $e');
      return [];
    }
  }

  // Clear all saved data (useful for testing or reset feature)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_transactionsKey);
  }
}