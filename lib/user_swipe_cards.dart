import 'package:flutter/material.dart';
import 'user_details_full_screen.dart';
import 'transaction.dart';
import 'package:google_fonts/google_fonts.dart';

class UserSwipeCards extends StatefulWidget {
  @override
  _UserSwipeCardsState createState() => _UserSwipeCardsState();
}

class _UserSwipeCardsState extends State<UserSwipeCards>
    with SingleTickerProviderStateMixin {
  int cardCount = 0;
  int expandedCardIndex = -1; // -1 means no card is expanded
  List<String> userNames = []; // Store user names
  List<Transaction> transactions = []; // Store transactions

  // Animation controller
  late AnimationController _animationController;
  late PageController _pageController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _expandCard(int index) {
    setState(() {
      expandedCardIndex = index;
    });
    _animationController.forward(from: 0.0);
  }

  void _collapseCard() {
    _animationController.reverse().then((_) {
      setState(() {
        expandedCardIndex = -1;
      });
    });
  }

  // Show dialog to input user name
  void _showNameInputDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Column(
              children: [
                SizedBox(height: 20),
                Icon(Icons.people, size: 50),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(
                    top: 8.0,
                    bottom: 8.0,
                  ), // customize as needed
                  child: Center(
                    child: Text('Enter User Name', textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
            content: Container(
              width: MediaQuery.sizeOf(context).width,
              height: 200,
              child: TextField(
                controller: nameController,
                cursorColor: Colors.grey,
                decoration: InputDecoration(
                  hintText: 'Enter name here',
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.orange,
                      width: 2,
                    ), // Focused state
                  ),
                ),
                autofocus: false,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel', style: TextStyle(color: Colors.orange)),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    setState(() {
                      userNames.add(name);
                      cardCount += 1;
                      _pageController.jumpToPage(cardCount);
                    });

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _pageController.animateToPage(
                        cardCount - 1,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    });

                    Navigator.pop(context);
                  }
                },
                child: Text('Add User', style: TextStyle(color: Colors.orange)),
              ),
            ],
          ),
    );
  }

  // Show dialog to record a transaction
  void _showTransactionDialog(BuildContext context) {
    if (userNames.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please add users first')));
      return;
    }

    String? selectedPayer = userNames.isNotEmpty ? userNames[0] : null;
    Map<String, bool> selectedSplittersMap = {};
    // Initialize all users as not selected for split
    for (var user in userNames) {
      selectedSplittersMap[user] = false;
    }

    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Column(
                    children: [
                      SizedBox(height: 20),
                      Icon(Icons.receipt_long, size: 50),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                        child: Center(
                          child: Text(
                            'Record Transaction',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: SingleChildScrollView(
                    // Changed to SingleChildScrollView to handle overflow
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize:
                            MainAxisSize
                                .min, // Allow container to size to content
                        children: [
                          // Description field
                          // Description field with 15 character limit
                          Text(
                            'Description (optional):',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          TextField(
                            controller: descriptionController,
                            cursorColor: Colors.grey,
                            maxLength: 15, // Limiting to 15 characters
                            decoration: InputDecoration(
                              hintText: 'E.g., Dinner, Movie...',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                              ),
                              counterText: '15 char max', // Custom counter text
                            ),
                          ),
                          SizedBox(height: 15),

                          // Who paid dropdown
                          Text(
                            'Who paid?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: DropdownButton<String>(
                              value: selectedPayer,
                              isExpanded: true,
                              underline: SizedBox(),
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() {
                                    selectedPayer = value;
                                  });
                                }
                              },
                              items:
                                  userNames.map<DropdownMenuItem<String>>((
                                    String user,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: user,
                                      child: Text(user),
                                    );
                                  }).toList(),
                            ),
                          ),
                          SizedBox(height: 15),

                          // Who should split
                          Text(
                            'Split between:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Container(
                            height: 100, // Fixed height for better visibility
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ListView.builder(
                              shrinkWrap:
                                  true, // Added to ensure proper sizing inside scroll view
                              itemCount: userNames.length,
                              itemBuilder: (context, index) {
                                final user = userNames[index];
                                final isSelected =
                                    selectedSplittersMap[user] ?? false;

                                return CheckboxListTile(
                                  title: Text(user),
                                  value: isSelected,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      selectedSplittersMap[user] =
                                          value ?? false;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 15),

                          // Amount field
                          Text(
                            'Amount:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          TextField(
                            controller: amountController,
                            cursorColor: Colors.grey,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter amount',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Get list of selected users for splitting
                        List<String> selectedSplitters =
                            selectedSplittersMap.entries
                                .where((entry) => entry.value)
                                .map((entry) => entry.key)
                                .toList();

                        if (selectedPayer != null &&
                            selectedSplitters.isNotEmpty &&
                            amountController.text.isNotEmpty) {
                          try {
                            double amount = double.parse(amountController.text);

                            // Create the transaction
                            Transaction newTransaction = Transaction(
                              payerId: selectedPayer!,
                              splitBetween: List.from(selectedSplitters),
                              amount: amount,
                              description: descriptionController.text.trim(),
                            );

                            // The issue might be that we're using the StatefulBuilder's setState
                            // Use the parent widget's setState to properly update the transactions list
                            Navigator.pop(context);

                            // Update state in the parent widget
                            setState(() {
                              transactions.add(newTransaction);
                            });

                            // Show success message with calculated split
                            double perPersonAmount =
                                amount / selectedSplitters.length;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Transaction recorded: ${selectedPayer} paid \$${amount.toStringAsFixed(2)}. ' +
                                      'Each person owes \$${perPersonAmount.toStringAsFixed(2)}',
                                ),
                                duration: Duration(seconds: 4),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter a valid amount'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please fill all required fields'),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'Save',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  // Modification for _buildBalanceDetails method in UserSwipeCards (for the expanded card)
  Widget _buildBalanceDetails(String userName, int userIndex) {
    // Calculate balances for this user
    Map<String, Map<String, double>> balances =
        BalanceCalculator.calculateBalances(transactions, userNames);

    // Filter transactions related to this user
    List<Transaction> userTransactions =
        transactions
            .where(
              (transaction) =>
                  transaction.payerId == userName ||
                  transaction.splitBetween.contains(userName),
            )
            .toList();

    // Debug - print total transaction count
    print(
      "Building details for $userName with ${transactions.length} total transactions and ${userTransactions.length} user transactions",
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 15),
          child: Text(
            "Balance Summary",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        // User Owes Others - scrollable list
        Container(
          height: 200, // Reduced height to give more space to transactions
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: userNames.length,
            itemBuilder: (context, i) {
              if (i == userIndex) return SizedBox.shrink(); // Skip self

              String otherUser = userNames[i];
              double youOweAmount = balances[userName]?[otherUser] ?? 0;
              double theyOweAmount = balances[otherUser]?[userName] ?? 0;

              // Skip if there's no debt in either direction
              if (youOweAmount == 0 && theyOweAmount == 0)
                return SizedBox.shrink();

              // Determine the net relationship
              double netAmount;
              bool youOwe;

              if (youOweAmount > 0) {
                netAmount = youOweAmount;
                youOwe = true;
              } else if (theyOweAmount > 0) {
                netAmount = theyOweAmount;
                youOwe = false;
              } else {
                return SizedBox.shrink(); // No debt
              }

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: youOwe ? Colors.red.shade300 : Colors.green.shade300,
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            youOwe
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                        child: Icon(
                          youOwe ? Icons.arrow_upward : Icons.arrow_downward,
                          color: youOwe ? Colors.red : Colors.green,
                          size: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                youOwe
                                    ? "You owe ${otherUser}"
                                    : "${otherUser} owes you",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        "\$${netAmount.abs().toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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

        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text(
            "Transaction History",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        // Transaction history section remains the same
        Expanded(
          child:
              userTransactions.isEmpty
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
                      // Debug - print transaction index being built
                      print(
                        "Building transaction $i of ${userTransactions.length}",
                      );

                      Transaction transaction = userTransactions[i];
                      bool isPayer = transaction.payerId == userName;
                      bool isRecipient = transaction.splitBetween.contains(
                        userName,
                      );

                      // Debug information
                      print(
                        "Transaction $i: isPayer=$isPayer, isRecipient=$isRecipient",
                      );

                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 25,
                            // Same as CircleAvatar's diameter (radius * 2)
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
                                ? "You paid \$${transaction.amount
                                .toStringAsFixed(2)}"
                                : "${transaction.payerId} paid \$${transaction
                                .amount.toStringAsFixed(2)}",
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
                                  style: TextStyle(fontSize: 13,
                                      fontStyle: FontStyle.italic),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                          trailing: Text(
                            "${transaction.dateTime.day}/${transaction.dateTime
                                .month}/${transaction.dateTime.year}",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                          isThreeLine: transaction.description.isNotEmpty,
                        ),
                      );
                    }),
        ),
      ],
    );
  }

  // Function to build the main card content with balance summary
  Widget _buildUserCardContent(String userName, int index) {
    // Calculate balances for this user
    Map<String, Map<String, double>> balances =
        BalanceCalculator.calculateBalances(transactions, userNames);

    // For debugging
    print("Building main card for $userName with balances: $balances");

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
            print("$userName owes $otherUser: $amount");
          }
        }

        // Check what others owe to this user
        if (balances.containsKey(otherUser) &&
            balances[otherUser]!.containsKey(userName)) {
          double amount = balances[otherUser]![userName] ?? 0;
          if (amount > 0) {
            totalOwing += amount;
            print("$otherUser owes $userName: $amount");
          }
        }
      }
    }

    // Calculate net balance (positive means user owes more than they're owed)
    double netBalance = totalOwed - totalOwing;
    bool isNetPositive = netBalance > 0;

    print(
      "$userName - Total owed: $totalOwed, Total owing: $totalOwing, Net: $netBalance",
    );

    return Column(
      children: [
        // User name
        Padding(
          padding: EdgeInsets.only(top: 5, bottom: 0),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height *
                0.15, // 20% of screen height
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
                // Overall balance indicator
                Container(
                  padding: EdgeInsets.all(10),
                  width: 280,
                  decoration: BoxDecoration(
                    color:
                        isNetPositive
                            ? Colors.red.shade50
                            : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isNetPositive
                              ? Colors.red.shade200
                              : Colors.green.shade200,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        isNetPositive
                            ? "Overall: You owe"
                            : "Overall: You are owed",
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
                            color:
                                youOwe
                                    ? Colors.red.shade300
                                    : Colors.green.shade300,
                            width: 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor:
                                    youOwe
                                        ? Colors.red.shade100
                                        : Colors.green.shade100,
                                child: Icon(
                                  youOwe
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
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
                                      youOwe
                                          ? "You owe ${otherUser}"
                                          : "${otherUser} owes you",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Base content with title and PageView
          Column(
            children: [
              Container(
                height: 190,
                width: 2000,
                color: const Color.fromARGB(255, 72, 71, 71),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.amber,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  0.2,
                                ), // shadow color
                                spreadRadius: 2, // how wide the shadow spreads
                                blurRadius: 10, // how soft the shadow is
                                offset: Offset(0, 4), // position (x, y)
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.group,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 30, left: 30),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 2,
                            left: 2,
                            child: Text(
                              "Users",
                              style: GoogleFonts.getFont(
                                "Oswald",
                                fontSize: 50,
                                color: Colors.amber,
                                textStyle: TextStyle(
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2, 2), // X, Y position
                                      blurRadius: 4.0, // Softness of shadow
                                      color: Colors.black45,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Text(
                            "Users",
                            style: GoogleFonts.getFont(
                              "Oswald",
                              fontSize: 50,
                              color: const Color.fromARGB(255, 255, 255, 255),
                              textStyle: TextStyle(letterSpacing: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1000, height: 4, color: Colors.amber),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  // Disable scrolling when a card is expanded
                  physics:
                      expandedCardIndex != -1
                          ? NeverScrollableScrollPhysics()
                          : AlwaysScrollableScrollPhysics(),
                  itemCount: cardCount + 1,
                  itemBuilder: (context, index) {
                    if (index == cardCount) {
                      // "Add Page" card remains unchanged
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            _showNameInputDialog(context);
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              width: 350,
                              height: 400,
                              alignment: Alignment.center,
                              child: Stack(
                                children: [
                                  Column(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          width: 350,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16),
                                            ),
                                            color: const Color.fromARGB(
                                              255,
                                              255,
                                              255,
                                              255,
                                            ),
                                          ),
                                          child: Center(
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 2,
                                                  left: 2,
                                                  child: Text(
                                                    "Tap",
                                                    style: GoogleFonts.getFont(
                                                      "Oswald",
                                                      fontSize: 50,
                                                      color:
                                                          const Color.fromARGB(
                                                            255,
                                                            255,
                                                            255,
                                                            255,
                                                          ),
                                                      textStyle: TextStyle(
                                                        letterSpacing: 2,
                                                        shadows: [
                                                          Shadow(
                                                            offset: Offset(
                                                              2,
                                                              2,
                                                            ), // X, Y position
                                                            blurRadius:
                                                                4.0, // Softness of shadow
                                                            color:
                                                                Colors.black45,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "Tap",
                                                  style: GoogleFonts.getFont(
                                                    "Oswald",
                                                    fontSize: 50,
                                                    color: Colors.amber,
                                                    textStyle: TextStyle(
                                                      letterSpacing: 2,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          width: 350,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(16),
                                              bottomRight: Radius.circular(16),
                                            ),
                                            color: Colors.amber,
                                          ),
                                          child: Center(
                                            child: Stack(
                                              children: [
                                                Positioned(
                                                  top: 2,
                                                  left: 2,
                                                  child: Text(
                                                    "Here",
                                                    style: GoogleFonts.getFont(
                                                      "Oswald",
                                                      fontSize: 50,
                                                      color: Colors.amber,
                                                      textStyle: TextStyle(
                                                        letterSpacing: 2,
                                                        shadows: [
                                                          Shadow(
                                                            offset: Offset(
                                                              2,
                                                              2,
                                                            ), // X, Y position
                                                            blurRadius:
                                                                4.0, // Softness of shadow
                                                            color:
                                                                Colors.black45,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  "Here",
                                                  style: GoogleFonts.getFont(
                                                    "Oswald",
                                                    fontSize: 50,
                                                    color: const Color.fromARGB(
                                                      255,
                                                      255,
                                                      255,
                                                      255,
                                                    ),
                                                    textStyle: TextStyle(
                                                      letterSpacing: 2,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.zero,
                                      width: 110,
                                      height: 20,
                                      color: const Color.fromARGB(
                                        255,
                                        71,
                                        71,
                                        71,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Container(
                                      padding: EdgeInsets.zero,
                                      width: 20,
                                      height: 110,
                                      color: const Color.fromARGB(
                                        255,
                                        71,
                                        71,
                                        71,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return Center(
                      child: GestureDetector(
                        onTap: () {
                          // Only expand the card if it's not already expanded
                          if (expandedCardIndex != index) {
                            _expandCard(index);
                          }
                        },
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
                                userNames.isNotEmpty && index < userNames.length
                                    ? _buildUserCardContent(
                                      userNames[index],
                                      index,
                                    )
                                    : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Page ${index + 1}",
                                          style: TextStyle(fontSize: 32),
                                        ),
                                        SizedBox(height: 16),
                                        Icon(
                                          Icons.touch_app,
                                          color: Colors.grey[600],
                                          size: 40,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Tap to expand",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Expanded card overlay (conditionally shown)
          if (expandedCardIndex != -1)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Positioned.fill(
                  child: Material(
                    color: Colors.black.withOpacity(
                      0.5 * _animationController.value,
                    ),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        // Close on tap outside
                        _collapseCard();
                      },
                      child: Center(
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: GestureDetector(
                            onTap: () {
                              // Prevent taps on the card from closing it
                              // by stopping the event propagation
                            },
                            child: Card(
                              elevation: 12 * _animationController.value,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Container(
                                width: 350,
                                height: 600,
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Header
                                    Text(
                                      userNames.isNotEmpty &&
                                              expandedCardIndex <
                                                  userNames.length
                                          ? userNames[expandedCardIndex]
                                          : "Page ${expandedCardIndex + 1}",
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Divider(),

                                    // Content area - Show balance details directly
                                    Expanded(
                                      child:
                                          userNames.isNotEmpty &&
                                                  expandedCardIndex <
                                                      userNames.length
                                              ? _buildBalanceDetails(
                                                userNames[expandedCardIndex],
                                                expandedCardIndex,
                                              )
                                              : Center(
                                                child: Text(
                                                  "No data available",
                                                ),
                                              ),
                                    ),

                                    // Footer hint
                                    Opacity(
                                      opacity: _animationController.value,
                                      child: Text(
                                        "Tap outside to close",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      // Add Floating Action Button for recording transactions
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(context),
        backgroundColor: Colors.amber,
        child: Icon(Icons.add_card, color: Colors.white),
        tooltip: 'Record Transaction',
      ),
    );
  }
}
