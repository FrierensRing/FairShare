// widgets/user_card_widget.dart - Widget for user card display
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction.dart';
import '../utils/balance_calculator.dart';

class UserCardWidget extends StatelessWidget {
  final String userName;
  final int index;
  final List<String> userNames;
  final List<Transaction> transactions;
  final Function(int) onTap;

  const UserCardWidget({
    Key? key,
    required this.userName,
    required this.index,
    required this.userNames,
    required this.transactions,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 350,
            height: 500,
            alignment: Alignment.center,
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: 350,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                          color: Colors.amber,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(16),
                                ),
                                color: const Color.fromARGB(
                                  255,
                                  255,
                                  174,
                                  0,
                                ),
                              ),
                              child: Icon(
                                Icons.emoji_emotions_outlined,
                                color: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
                                size: 55,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(flex: 10, child: Container()),
                  ],
                ),
                _buildUserCardContent(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserCardContent(BuildContext context) {
    // Calculate balances for this user
    Map<String, Map<String, double>> balances =
        BalanceCalculator.calculateBalances(transactions, userNames);

    // Calculate total balances
    double totalOwed = 0; // What this user owes others
    double totalOwing = 0; // What others owe this user

    // Loop through all users to check both directions of debt
    for (var otherUser in userNames) {
      if (otherUser != userName) {
        // Check what this user owes to others
        if (balances.containsKey(userName) &&
            balances[userName]!.containsKey(otherUser)) {
          double amount = balances[userName]![otherUser] ?? 0;
          if (amount > 0) {
            totalOwed += amount;
          }
        }

        // Check what others owe to this user
        if (balances.containsKey(otherUser) &&
            balances[otherUser]!.containsKey(userName)) {
          double amount = balances[otherUser]![userName] ?? 0;
          if (amount > 0) {
            totalOwing += amount;
          }
        }
      }
    }

    // Calculate net balance (positive means user owes more than they're owed)
    double netBalance = totalOwed - totalOwing;
    bool isNetPositive = netBalance > 0;

    return Column(
      children: [
        // User name
        Padding(
          padding: EdgeInsets.only(top: 5, bottom: 0),
          child: SizedBox(
            height: 75, // Fixed height instead of percentage-based to ensure consistency
            child: Stack(
              children: [
                Positioned(
                  top: 2,
                  left: 2,
                  child: Text(
                    userName,
                    style: GoogleFonts.getFont(
                      "Oswald",
                      fontSize: 50,
                      color: Colors.white,
                      textStyle: TextStyle(letterSpacing: 2),
                    ),
                  ),
                ),
                Text(
                  userName,
                  style: GoogleFonts.getFont(
                    "Oswald",
                    fontSize: 50,
                    color: Color.fromARGB(255, 66, 66, 66),
                    textStyle: TextStyle(letterSpacing: 2),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Balance summary section
        SizedBox(
          child: Column(
            children: [
              if (transactions.isNotEmpty) ...[
                // Add more space between username and balance indicator
                SizedBox(height: 30),
                
                // Overall balance indicator
                Container(
                  padding: EdgeInsets.all(10),
                  width: 280,
                  decoration: BoxDecoration(
                    color: isNetPositive ? Colors.red.shade50 : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isNetPositive ? Colors.red.shade200 : Colors.green.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isNetPositive ? "Overall: You owe" : "Overall: You are owed",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isNetPositive ? Colors.red : Colors.green,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "\$${netBalance.abs().toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: isNetPositive ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),

                // Detailed balances
                Container(
                  height: 200,
                  padding: EdgeInsets.only(left: 16, right: 16),
                  width: 330,
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 20),
                    shrinkWrap: true,
                    itemCount: userNames.length,
                    itemBuilder: (context, i) {
                      if (i == index) return SizedBox.shrink(); // Skip self

                      String otherUser = userNames[i];
                      double youOweAmount = 0;
                      if (balances.containsKey(userName) &&
                          balances[userName]!.containsKey(otherUser)) {
                        youOweAmount = balances[userName]![otherUser] ?? 0;
                      }

                      double theyOweAmount = 0;
                      if (balances.containsKey(otherUser) &&
                          balances[otherUser]!.containsKey(userName)) {
                        theyOweAmount = balances[otherUser]![userName] ?? 0;
                      }

                      if (youOweAmount == 0 && theyOweAmount == 0) {
                        return SizedBox.shrink();
                      }

                      double netAmount;
                      bool youOwe;

                      if (youOweAmount > 0) {
                        netAmount = youOweAmount;
                        youOwe = true;
                      } else if (theyOweAmount > 0) {
                        netAmount = theyOweAmount;
                        youOwe = false;
                      } else {
                        return SizedBox.shrink();
                      }

                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: youOwe ? Colors.red.shade300 : Colors.green.shade300,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: youOwe ? Colors.red.shade100 : Colors.green.shade100,
                                child: Icon(
                                  youOwe ? Icons.arrow_upward : Icons.arrow_downward,
                                  color: youOwe ? Colors.red : Colors.green,
                                  size: 14,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      youOwe ? "You owe ${otherUser}" : "${otherUser} owes you",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "\$${netAmount.abs().toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: youOwe ? Colors.red : Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                SizedBox(height: 20),
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 60,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 80),
                Text(
                  "No transactions yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],

              // Tap to expand hint
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, color: Colors.grey[600], size: 20),
                  SizedBox(width: 4),
                  Text(
                    "Tap to see details",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}