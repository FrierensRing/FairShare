// models/transaction.dart - Transaction model to store expense data

class Transaction {
  final String payerId; // Who paid
  final List<String> splitBetween; // Who needs to split
  final double amount;
  final String description;
  final DateTime dateTime;

  Transaction({
    required this.payerId,
    required this.splitBetween,
    required this.amount,
    this.description = '',
    DateTime? dateTime,
  }) : dateTime = dateTime ?? DateTime.now();
}