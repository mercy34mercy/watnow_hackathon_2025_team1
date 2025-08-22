import 'package:flutter/material.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int melonCount = 0;
  int carrotCount = 0;
  int pumpkinCount = 0;

  void _gacha() async {
    final result = await Navigator.pushNamed(context, '/farm-gacha');
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        switch (result['item']) {
          case '人参':
            carrotCount += result['count'] as int;
            break;
          case 'メロン':
            melonCount += result['count'] as int;
            break;
          case 'カボチャ':
            pumpkinCount += result['count'] as int;
            break;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 205, 151),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildItemCounter('assets/melon.png', melonCount),
                  _buildItemCounter('assets/ninzin.png', carrotCount),
                  _buildItemCounter('assets/pumpkin.png', pumpkinCount),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/rabbit.png',
                  height: 250,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                      backgroundColor: const Color.fromARGB(255, 255, 166, 71),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text(
                      '畑ガチャ',
                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pushNamed(context, '/cook/melonjuice');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child: const Text(
                      '料理',
                      style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCounter(String imagePath, int count) {
    return Column(
      children: [
        Image.asset(
          imagePath,
          height: 50,
          width: 50,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color.fromARGB(255, 255, 166, 71), width: 2),
          ),
          child: Text(
            '×$count',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 255, 166, 71),
            ),
          ),
        ),
      ],
    );
  }
}