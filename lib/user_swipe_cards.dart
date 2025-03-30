import 'package:flutter/material.dart';

class UserSwipeCards extends StatefulWidget {
  @override
  _UserSwipeCardsState createState() => _UserSwipeCardsState();
}

class _UserSwipeCardsState extends State<UserSwipeCards> with SingleTickerProviderStateMixin {
  int cardCount = 0;
  int expandedCardIndex = -1; // -1 means no card is expanded
  
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
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
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
                child: Text(
                  "Users",
                  style: TextStyle(fontSize: 28),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  // Disable scrolling when a card is expanded
                  physics: expandedCardIndex != -1 
                      ? NeverScrollableScrollPhysics() 
                      : AlwaysScrollableScrollPhysics(),
                  itemCount: cardCount + 1,
                  itemBuilder: (context, index) {
                    if (index == cardCount) {
                      // "Add Page" card remains unchanged
                      return Center(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              cardCount += 1;
                               _pageController.jumpToPage(cardCount);
                            });
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _pageController.animateToPage(
                                cardCount-1,
                                duration: Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            });
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
                                "➕ Add Page",
                                style: TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        )
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
                    color: Colors.black.withOpacity(0.5 * _animationController.value),
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
                                      "Page ${expandedCardIndex + 1}",
                                      style: TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    
                                    // Content area - currently blank
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Expanded content goes here",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[700],
                                          ),
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
              }
            ),
        ],
      ),
    );
  }
}