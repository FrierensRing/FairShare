// utils/balance_calculator.dart - Helper class to calculate balances
import '../models/transaction.dart';

class BalanceCalculator {
  static Map<String, Map<String, double>> calculateBalances(List<Transaction> transactions, List<String> users) {
    // Initialize the balance map (who owes whom)
    Map<String, Map<String, double>> balances = {};

    // Initialize balance map for each user
    for (var user in users) {
      balances[user] = {};
      for (var otherUser in users) {
        if (user != otherUser) {
          balances[user]![otherUser] = 0;
        }
      }
    }

    // Process each transaction
    for (var transaction in transactions) {
      final payer = transaction.payerId;
      final splitUsers = transaction.splitBetween;

      if (splitUsers.isEmpty) continue;

      // Calculate the amount per person
      final amountPerPerson = transaction.amount / splitUsers.length;

      // For each person who's part of the split
      for (var user in splitUsers) {
        if (user == payer) continue; // Payer doesn't owe themselves

        // Update the balance: user owes payer
        balances[user]![payer] = (balances[user]![payer] ?? 0) + amountPerPerson;
      }
    }

    // Simplify balances (resolve mutual debts)
    for (var person1 in users) {
      for (var person2 in users) {
        if (person1 != person2) {
          // How much person1 owes person2
          double amount1To2 = balances[person1]![person2] ?? 0;

          // How much person2 owes person1
          double amount2To1 = balances[person2]![person1] ?? 0;

          // Resolve mutual debt
          if (amount1To2 > 0 && amount2To1 > 0) {
            if (amount1To2 > amount2To1) {
              // person1 still owes person2
              balances[person1]![person2] = amount1To2 - amount2To1;
              balances[person2]![person1] = 0;
            } else {
              // person2 still owes person1
              balances[person2]![person1] = amount2To1 - amount1To2;
              balances[person1]![person2] = 0;
            }
          }
        }
      }
    }

    return balances;
  }
}