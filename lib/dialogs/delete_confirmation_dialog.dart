// dialogs/delete_confirmation_dialog.dart - Dialogs for confirming deletions
import 'package:flutter/material.dart';
import '../models/transaction.dart';

class DeleteConfirmationDialogs {
  // Dialog to confirm transaction deletion
  static Future<bool> showDeleteTransactionDialog(
    BuildContext context, 
    Transaction transaction
  ) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            SizedBox(height: 10),
            Icon(Icons.delete, color: Colors.red, size: 40),
            SizedBox(height: 10),
            Text("Delete Transaction"),
          ],
        ),
        content: Text(
          "Are you sure you want to delete this transaction?\n\n" +
          "${transaction.payerId} paid \$${transaction.amount.toStringAsFixed(2)}" +
          (transaction.description.isNotEmpty ? " for ${transaction.description}" : "")
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  // Dialog to confirm user deletion
  static Future<bool> showDeleteUserDialog(
    BuildContext context, 
    String userName
  ) async {
    bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          children: [
            SizedBox(height: 10),
            Icon(Icons.person_remove, color: Colors.red, size: 40),
            SizedBox(height: 10),
            Text("Delete User"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete ${userName}?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "All transactions paid by or split with this user will be deleted.",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 10),
            Text(
              "This action cannot be undone.",
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text('Delete User', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}