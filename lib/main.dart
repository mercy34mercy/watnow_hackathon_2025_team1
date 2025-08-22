import 'package:carrot_harvest_game/screens/melon_screen.dart';
import 'package:carrot_harvest_game/screens/pumpkin_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/result_screen.dart';
import 'screens/result_melon.dart';
import 'screens/result_pumpkin.dart';
import 'screens/failed_carrot.dart';
import 'screens/failed_pumpkin.dart';
import 'screens/failed_melon.dart';
import 'screens/cook_carrot.dart';
import 'screens/cook_melon.dart';
import 'screens/cook_pumpkin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final int? carrot = prefs.getInt('carrot');
  if (carrot == null) {
    // 一度もsetIntされてない　
    await prefs.setInt('carrot', 0);
  }  
  final int? melon = prefs.getInt('melon');
  if (melon == null) {
    // 一度もsetIntされてない　
    await prefs.setInt('melon', 0);
  }  
  final int? pumpkin = prefs.getInt('pumpkin');
  if (pumpkin == null) {
    // 一度もsetIntされてない　
    await prefs.setInt('pumpkin', 0);
  }
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
        '/result/failed/pumpkin':(context) => const FailedPumpkin(),
        '/result/failed/carrot':(context) => const FailedCarrot(),
        '/result/failed/melon':(context) => const FailedMelon(),
        '/game/pumpkin': (context) => const GamePumpkinScreen(),
        '/cook/carrotcake':(context) => const CookCarrotScreen(),
        '/cook/melonjuice' :(context) => const CookMelonScreen(),
        '/cook/pumpkinsoup' :(context) => const CookPumpkinScreen()
      },
    );
  }
}