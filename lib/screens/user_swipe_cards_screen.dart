// screens/user_swipe_cards_screen.dart - Main screen with user cards
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'user_details_screen.dart';
import '../models/transaction.dart';
import '../models/glass_panel.dart';
import '../services/data_manager.dart';
import '../widgets/user_card_widget.dart';
import '../widgets/balance_summary_widget.dart';
import '../widgets/transaction_list_widget.dart';
import '../dialogs/add_user_dialog.dart';
import '../dialogs/add_transaction_dialog.dart';
import '../dialogs/delete_confirmation_dialog.dart';

class UserSwipeCardsScreen extends StatefulWidget {
  const UserSwipeCardsScreen({super.key});

  @override
  _UserSwipeCardsScreenState createState() => _UserSwipeCardsScreenState();
}

class _UserSwipeCardsScreenState extends State<UserSwipeCardsScreen>
    with SingleTickerProviderStateMixin {
  // State variables
  int cardCount = 0;
  int expandedCardIndex = -1; // -1 means no card is expanded
  List<String> userNames = []; // Store user names
  List<Transaction> transactions = []; // Store transactions
  int currentPageIndex = 0; // Track current page for arrow navigation

  // Controllers and animations
  late AnimationController _animationController;
  late PageController _pageController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Add listener to track current page
    _pageController.addListener(() {
      if (_pageController.page != null) {
        setState(() {
          currentPageIndex = _pageController.page!.round();
        });
      }
    });

    // Load saved data
    _loadSavedData();
  }

  // Load saved data
  void _loadSavedData() async {
    try {
      // Load users
      final savedUsers = await DataManager.loadUsers();

      // Load transactions
      final savedTransactions = await DataManager.loadTransactions();

      if (mounted) {
        setState(() {
          userNames = savedUsers;
          transactions = savedTransactions;
          cardCount = userNames.length;
        });
      }
    } catch (e) {
      print('Error loading saved data: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Navigation functions
  void _navigateToPreviousCard() {
    if (currentPageIndex > 0 && expandedCardIndex == -1) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToNextCard() {
    if (currentPageIndex < cardCount && expandedCardIndex == -1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Card expansion functions
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

  // Callback for when a user is added
  void _handleUserAdded(String name) {
    setState(() {
      userNames.add(name);
      cardCount = userNames.length;
    });

    // Save updated users list
    DataManager.saveUsers(userNames);

    // Animate to the new user card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.animateToPage(
        cardCount - 1,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  // Callback for when a transaction is added
  void _handleTransactionAdded(Transaction transaction) {
    setState(() {
      transactions.add(transaction);
    });

    // Save updated transactions
    DataManager.saveTransactions(transactions);
  }

  // Handle transaction deletion
  Future<void> _handleDeleteTransaction(
    Transaction transaction,
    int index,
  ) async {
    bool confirmed =
        await DeleteConfirmationDialogs.showDeleteTransactionDialog(
          context,
          transaction,
        );

    if (confirmed) {
      setState(() {
        transactions.remove(transaction);
      });

      // Save updated transactions
      await DataManager.saveTransactions(transactions);

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Transaction deleted'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Handle user deletion
  Future<void> _handleDeleteUser(int userIndex) async {
    if (userIndex < 0 || userIndex >= userNames.length) return;

    String userName = userNames[userIndex];
    bool confirmed = await DeleteConfirmationDialogs.showDeleteUserDialog(
      context,
      userName,
    );

    if (confirmed) {
      // Create a copy of the userNames list without the deleted user
      final updatedUserNames = List<String>.from(userNames);
      updatedUserNames.removeAt(userIndex);

      // Remove all transactions where this user is the payer or part of the split
      List<Transaction> updatedTransactions =
          transactions
              .where(
                (transaction) =>
                    transaction.payerId != userName &&
                    !transaction.splitBetween.contains(userName),
              )
              .toList();

      // Save the updated data
      await DataManager.saveUsers(updatedUserNames);
      await DataManager.saveTransactions(updatedTransactions);

      // Collapse expanded card
      _collapseCard();

      // Update state
      setState(() {
        userNames = updatedUserNames;
        transactions = updatedTransactions;
        cardCount = userNames.length;
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User deleted along with their transactions'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // Build the expanded card content
  Widget _buildExpandedCardContent(String userName, int index) {
    // Filter transactions related to this user
    List<Transaction> userTransactions =
        transactions
            .where(
              (transaction) =>
                  transaction.payerId == userName ||
                  transaction.splitBetween.contains(userName),
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Header
        Text(
          userName,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
          color: Colors.amberAccent),
        ),
        SizedBox(height: 8),
        Divider(),
    
        // Balance summary section
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text(
            "Balance Summary",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
    
        // Balance summary content
        SizedBox(
          height: 200,
          child: BalanceSummaryWidget(
            userName: userName,
            userIndex: index,
            userNames: userNames,
            transactions: transactions,
          ),
        ),
    
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text(
            "Transaction History",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
    
        // Transaction history section
        Expanded(
          child: TransactionListWidget(
            userName: userName,
            transactions: userTransactions,
            onDeleteTap: _handleDeleteTransaction,
          ),
        ),
    
        // Delete user button
        SizedBox(height: 16),
        ElevatedButton.icon(
          icon: Icon(Icons.person_remove_outlined, color: Colors.white),
          label: Text("Delete User", style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => _handleDeleteUser(index),
        ),
      ],
    );
  }

  // Build the "Add User" card
  Widget _buildAddUserCard() {
    return Center(
      child: GestureDetector(
        onTap: () {
          AddUserDialog.show(context, _handleUserAdded);
        },
        child: Card(
          color: Colors.transparent,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: GlassContainer(
            child: Container(
              width: 350,
              height: 400,
              alignment: Alignment.center,
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 90),
                    Icon(
                      Icons.touch_app,
                      color: Colors.white.withOpacity(0.4),
                      size: 90,
                    ),
                    SizedBox(height: 70,),
                    Text(
                      "tap to add new users",
                      style: TextStyle(
                        color: Colors.white. withOpacity(0.7),
                        fontSize: 20,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
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
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3A3A3F), Color(0xFF1A1A1D)],
              ),
            ),
          ),
          Column(
            children: [
              SizedBox(height: 80),
              Container(
                height: 130,
                width: 2000,
                color: Colors.transparent,
                child: Center(
                  child: GlassContainer(
                    borderSize: 0.1,
                    child: Container(
                      height: 100,
                      width: 300,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(width: 5),
                          Container(
                            width: 90,
                            height: 90,
                            child: GlassContainer(
                              borderRadius: 25,
                              borderSize: 0,
                              color: Colors.black,
                              child: Icon(
                                Icons.group,
                                color: const Color.fromARGB(255, 255, 255, 255),
                                size: 60,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            "Users",
                            style: TextStyle(color: Colors.white, fontSize: 40),
                          ),
                          SizedBox(width: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    // PageView for the cards
                    PageView.builder(
                      controller: _pageController,
                      // Disable scrolling when a card is expanded
                      physics:
                          expandedCardIndex != -1
                              ? NeverScrollableScrollPhysics()
                              : AlwaysScrollableScrollPhysics(),
                      itemCount: cardCount + 1,
                      itemBuilder: (context, index) {
                        if (index == cardCount) {
                          // "Add User" card
                          return _buildAddUserCard();
                        }

                        return UserCardWidget(
                          userName: userNames[index],
                          index: index,
                          userNames: userNames,
                          transactions: transactions,
                          onTap: _expandCard,
                        );
                      },
                    ),

                    // Left arrow button
                    if (expandedCardIndex == -1 && currentPageIndex > 0)
                      Positioned(
                        left: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                color: Colors.white,
                              ),
                              onPressed: _navigateToPreviousCard,
                              iconSize: 26,
                              padding: EdgeInsets.all(12),
                              tooltip: 'Previous User',
                            ),
                          ),
                        ),
                      ),

                    // Right arrow button
                    if (expandedCardIndex == -1 && currentPageIndex < cardCount)
                      Positioned(
                        right: 10,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                              onPressed: _navigateToNextCard,
                              iconSize: 26,
                              padding: EdgeInsets.all(12),
                              tooltip: 'Next User',
                            ),
                          ),
                        ),
                      ),
                  ],
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
                      onTap: _collapseCard, // Close on tap outside
                      child: Center(
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: GestureDetector(
                            onTap:
                                () {}, // Prevent closing when tapping on the card
                            child: Card(
                              color: Colors.transparent,
                              elevation: 12 * _animationController.value,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: GlassContainer(
                                child: Container(
                                  width: 350,
                                  height: 600,
                                  padding: EdgeInsets.all(16),
                                  child:
                                      userNames.isNotEmpty &&
                                              expandedCardIndex < userNames.length
                                          ? _buildExpandedCardContent(
                                            userNames[expandedCardIndex],
                                            expandedCardIndex,
                                          )
                                          : Center(
                                            child: Text("No data available"),
                                          ),
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
        onPressed:
            () => AddTransactionDialog.show(
              context,
              userNames,
              _handleTransactionAdded,
            ),
        backgroundColor: Colors.amber,
        tooltip: 'Record Transaction',
        child: Icon(Icons.add_card, color: Colors.white),
      ),
    );
  }
}
