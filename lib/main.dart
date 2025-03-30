// main.dart - Application entry point
import 'package:flutter/material.dart';
import 'screens/user_swipe_cards_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FairShare',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 63, 63, 63),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: UserSwipeCardsScreen(),
    );
  }
}