import 'package:carrot_harvest_game/screens/melon_screen.dart';
import 'package:carrot_harvest_game/screens/pumpkin_screen.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';
import 'screens/result_melon.dart';
import 'screens/result_pumpkin.dart';
import 'screens/carrotcake_screen.dart';
import 'screens/melonjuice_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '人参収穫ゲーム',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/game': (context) => const GameScreen(),
        '/game/melon':(context) => const GameMelonScreen(),
        '/result': (context) => const ResultScreen(),
        '/result/melon': (context) => const ResultMelon(),
        '/result/pumpkin':(context) => const ResultPumpkin(),
        '/game/pumpkin': (context) => const GamePumpkinScreen(),
        '/cook/carrotcake':(context) => const CookCarrotScreen(),
        '/cook/melonjuice' :(context) => const CookMelonScreen()

      },
    );
  }
}