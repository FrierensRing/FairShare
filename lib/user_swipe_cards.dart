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
    List<String> selectedSplitters = [];
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
          content: Container(
            width: MediaQuery.sizeOf(context).width,
            height: 320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  height: 90,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    itemCount: userNames.length,
                    itemBuilder: (context, index) {
                      final user = userNames[index];
                      final isSelected = selectedSplitters.contains(user);

                      return CheckboxListTile(
                        title: Text(user),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              if (!selectedSplitters.contains(user)) {
                                selectedSplitters.add(user);
                              }
                            } else {
                              selectedSplitters.remove(user);
                            }
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.orange)),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedPayer != null &&
                    selectedSplitters.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  try {
                    double amount = double.parse(amountController.text);

                    setState(() {
                      transactions.add(
                        Transaction(
                          payerId: selectedPayer!,
                          splitBetween: List.from(selectedSplitters),
                          amount: amount,
                          description: descriptionController.text.trim(),
                        ),
                      );
                    });

                    Navigator.pop(context);

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transaction recorded')),
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

  void _openUserDetails(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsFullScreen(
          index: index,
          userName: userNames[index],
          userNames: userNames,
          transactions: transactions,
        ),
      ),
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
                                padding: EdgeInsets.all(20),
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
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 20),

                                    // Content area - Add a View Details button
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton.icon(
                                              icon: Icon(Icons.account_balance_wallet),
                                              label: Text("View Balance Details"),
                                              onPressed: () {
                                                _collapseCard();
                                                _openUserDetails(expandedCardIndex);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              ),
                                            ),
                                          ],
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
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.add_card, color: Colors.white),
        tooltip: 'Record Transaction',
      ),
    );
  }
}