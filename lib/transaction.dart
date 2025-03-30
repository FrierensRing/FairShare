// Transaction model to store expense data

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

// Helper class to calculate balances
class BalanceCalculator {
  static Map<String, Map<String, double>> calculateBalances(List<Transaction> transactions, List<String> users) {
    // Initialize the balance map (who owes whom)
    Map<String, Map<String, double>> balances = {};

    // Initialize balance for each user
    for (var user in users) {
      balances[user] = {};
      for (var otherUser in users) {
        if (user != otherUser) {
          balances[user]![otherUser] = 0;
        }
      }
    }

    // Calculate balances based on transactions
    for (var transaction in transactions) {
      String payer = transaction.payerId;
      int splitCount = transaction.splitBetween.length;

      if (splitCount == 0) continue;

      double amountPerPerson = transaction.amount / splitCount;

      for (var debtor in transaction.splitBetween) {
        if (debtor == payer) continue; // Skip if the payer is also in the split list

        // Debtor owes money to payer
        balances[debtor]![payer] = (balances[debtor]![payer] ?? 0) + amountPerPerson;
        // Reduce the reverse debt if any
        balances[payer]![debtor] = (balances[payer]![debtor] ?? 0) - amountPerPerson;
      }
    }

    // Simplify balances (remove negative values and keep only one-way debts)
    for (var user in users) {
      for (var otherUser in users) {
        if (user != otherUser) {
          double amount = balances[user]![otherUser] ?? 0;
          if (amount < 0) {
            // If user owes a negative amount to otherUser, it means otherUser owes a positive amount to user
            balances[otherUser]![user] = (balances[otherUser]![user] ?? 0) + (-amount);
            balances[user]![otherUser] = 0;
          }
        }
      }
    }

    return balances;
  }
}