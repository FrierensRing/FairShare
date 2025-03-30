// widgets/transaction_list_widget.dart - Widget for displaying transaction lists
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class TransactionListWidget extends StatelessWidget {
  final String userName;
  final List<Transaction> transactions;
  final Function(Transaction, int) onDeleteTap;

  const TransactionListWidget({
    Key? key,
    required this.userName,
    required this.transactions,
    required this.onDeleteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter transactions related to this user
    List<Transaction> userTransactions = transactions.where((transaction) =>
      transaction.payerId == userName || transaction.splitBetween.contains(userName)
    ).toList();

    return userTransactions.isEmpty
        ? Center(
            child: Text(
              "No transactions yet",
              style: TextStyle(color: Colors.grey),
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: userTransactions.length,
            itemBuilder: (context, i) {
              Transaction transaction = userTransactions[i];
              bool isPayer = transaction.payerId == userName;

              return Card(
                margin: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                elevation: 2,
                child: InkWell(
                  onTap: () => onDeleteTap(transaction, i),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 25,
                      height: 25,
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      alignment: Alignment.center,
                      child: Icon(
                        isPayer
                            ? Icons.payment
                            : Icons.account_balance_wallet_outlined,
                        size: 30,
                        color: isPayer ? Colors.blue : Colors.amber,
                      ),
                    ),
                    title: Text(
                      isPayer
                          ? "You paid \$${transaction.amount.toStringAsFixed(2)}"
                          : "${transaction.payerId} paid \$${transaction.amount.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Split: ${transaction.splitBetween.join(', ')}",
                          style: TextStyle(fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (transaction.description.isNotEmpty)
                          Text(
                            "For: ${transaction.description}",
                            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${transaction.dateTime.day}/${transaction.dateTime.month}/${transaction.dateTime.year}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.delete_outline, color: Colors.red.shade300, size: 16),
                      ],
                    ),
                    isThreeLine: transaction.description.isNotEmpty,
                  ),
                ),
              );
            },
          );
  }
}