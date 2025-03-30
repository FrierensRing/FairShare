import 'package:flutter/material.dart';
import 'user_details_full_screen.dart';
import 'transaction.dart';

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
      builder: (context) => AlertDialog(
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add users first')),
      );
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
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Column(
            children: [
              SizedBox(height: 20),
              Icon(Icons.receipt_long, size: 50),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Center(
                  child: Text('Record Transaction', textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(  // Changed to SingleChildScrollView to handle overflow
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,  // Allow container to size to content
                children: [
                  // Description field
                  Text('Description (optional):', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  TextField(
                    controller: descriptionController,
                    cursorColor: Colors.grey,
                    decoration: InputDecoration(
                      hintText: 'E.g., Dinner, Movie tickets, etc.',
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Who paid dropdown
                  Text('Who paid?', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      items: userNames.map<DropdownMenuItem<String>>((String user) {
                        return DropdownMenuItem<String>(
                          value: user,
                          child: Text(user),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Who should split
                  Text('Split between:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Container(
                    height: 100,  // Slightly increased height for better visibility
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,  // Added to ensure proper sizing inside scroll view
                      itemCount: userNames.length,
                      itemBuilder: (context, index) {
                        final user = userNames[index];
                        final isSelected = selectedSplittersMap[user] ?? false;

                        return CheckboxListTile(
                          title: Text(user),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              selectedSplittersMap[user] = value ?? false;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 15),

                  // Amount field
                  Text('Amount:', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  TextField(
                    controller: amountController,
                    cursorColor: Colors.grey,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange, width: 2),
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
              child: Text('Cancel', style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () {
                // Get list of selected users for splitting
                List<String> selectedSplitters = selectedSplittersMap.entries
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
                    this.setState(() {
                      transactions.add(newTransaction);
                    });

                    // Navigator.pop(context); - We already pop above

                    // Show success message with calculated split
                    double perPersonAmount = amount / selectedSplitters.length;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Transaction recorded: ${selectedPayer} paid \$${amount.toStringAsFixed(2)}. ' +
                                'Each person owes \$${perPersonAmount.toStringAsFixed(2)}'
                        ),
                        duration: Duration(seconds: 4),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid amount')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all required fields')),
                  );
                }
              },
              child: Text('Save', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      ),
    );
  }

// Widget to build balance details section
  Widget _buildBalanceDetails(String userName, int userIndex) {
    // Calculate balances for this user
    Map<String, Map<String, double>> balances =
    BalanceCalculator.calculateBalances(transactions, userNames);

    // Filter transactions related to this user
    List<Transaction> userTransactions = transactions.where((transaction) =>
    transaction.payerId == userName || transaction.splitBetween.contains(userName)
    ).toList();

    // Debug - print total transaction count
    print("Building details for $userName with ${transactions.length} total transactions and ${userTransactions.length} user transactions");

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Balance Summary",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // User Owes Others - scrollable list
        Container(
          height: 120, // Reduced height to give more space to transactions
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: userNames.length,
            itemBuilder: (context, i) {
              if (i == userIndex) return SizedBox.shrink(); // Skip self

              String otherUser = userNames[i];
              double amount = balances[userName]?[otherUser] ?? 0;
              bool isPositive = amount > 0;

              // Only show entries where there's a balance
              if (amount == 0) return SizedBox.shrink();

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isPositive ? Colors.red.shade300 : Colors.green.shade300,
                    width: 1.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: isPositive ? Colors.red.shade100 : Colors.green.shade100,
                        child: Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          color: isPositive ? Colors.red : Colors.green,
                          size: 14,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isPositive
                                  ? "You owe ${otherUser}"
                                  : "${otherUser} owes you",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "\$${amount.abs().toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isPositive ? Colors.red : Colors.green,
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
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Transaction History",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Transaction history - scrollable list with INCREASED HEIGHT
        Expanded( // Changed from Container with fixed height to Expanded
          child: userTransactions.isEmpty
              ? Center(
            child: Text(
              "No transactions yet",
              style: TextStyle(color: Colors.grey),
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: userTransactions.length,
            itemBuilder: (context, i) {
              // Debug - print transaction index being built
              print("Building transaction $i of ${userTransactions.length}");

              Transaction transaction = userTransactions[i];
              bool isPayer = transaction.payerId == userName;
              bool isRecipient = transaction.splitBetween.contains(userName);

              // Debug information
              print("Transaction $i: isPayer=$isPayer, isRecipient=$isRecipient");

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 2,
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: isPayer ? Colors.blue.shade100 : Colors.amber.shade100,
                    child: Icon(
                      isPayer ? Icons.payments : Icons.account_balance_wallet,
                      color: isPayer ? Colors.blue : Colors.amber,
                      size: 14,
                    ),
                  ),
                  title: Text(
                    isPayer
                        ? "You paid \$${transaction.amount.toStringAsFixed(2)}"
                        : "${transaction.payerId} paid \$${transaction.amount.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 12),
                  ),
                  subtitle: Text(
                    "Split: ${transaction.splitBetween.join(', ')}",
                    style: TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    "${transaction.dateTime.day}/${transaction.dateTime.month}/${transaction.dateTime.year}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            },
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
              SizedBox(height: 80), // Top spacing
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Users", style: TextStyle(fontSize: 28)),
              ),
              SizedBox(height: 10),
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
                            color: Colors.green[100],
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              width: 350,
                              height: 400,
                              alignment: Alignment.center,
                              child: Text(
                                "➕ Add A Friend",
                                style: TextStyle(fontSize: 28),
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  userNames.isNotEmpty &&
                                      index < userNames.length
                                      ? userNames[index]
                                      : "Page ${index + 1}",
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
                                      child: userNames.isNotEmpty && expandedCardIndex < userNames.length
                                          ? _buildBalanceDetails(userNames[expandedCardIndex], expandedCardIndex)
                                          : Center(child: Text("No data available")),
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
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add_card, color: Colors.white),
        tooltip: 'Record Transaction',
      ),
    );
  }
}