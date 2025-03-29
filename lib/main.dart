import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: UserSwipeCards()
    );
  }
}

class UserSwipeCards extends StatefulWidget {
  @override
  _UserSwipeCardsState createState() => _UserSwipeCardsState();
}

class _UserSwipeCardsState extends State<UserSwipeCards> {
  // List to store the cards that will be displayed
  final List<Widget> _cards = [];
  
  // Controller for the PageView
  late PageController _pageController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // Function to add a new card
  void _addCard() {
    setState(() {
      int newIndex = _cards.length;
      _cards.add(
        Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: 350,
              height: 500,
              alignment: Alignment.center,
              child: Text(
                "User ${newIndex + 1}",
                style: TextStyle(fontSize: 32),
              ),
            ),
          ),
        )
      );
      
      // Animate to the newly added card
      if (newIndex > 0) {
        _pageController.animateToPage(
          newIndex,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Users",
          style: TextStyle(fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Expanded(
            child: _cards.isEmpty
                ? Center(
                    child: Text(
                      "No users yet.\nTap the button below to add a user.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      return _cards[index];
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        tooltip: 'Add User',
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}