import 'package:flutter/material.dart';
import 'dart:math';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '人参収穫ゲーム',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 40),
            Image.asset(
              'assets/ninzin.png',
              height: 200,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                int veg = Random().nextInt(3);
                if(veg==0){
                Navigator.pushNamed(context, '/game');
                }else if(veg==1){
                Navigator.pushNamed(context, '/game/melon');  
                }else{
                Navigator.pushNamed(context, '/game/pumpkin');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text(
                'ゲームスタート',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}