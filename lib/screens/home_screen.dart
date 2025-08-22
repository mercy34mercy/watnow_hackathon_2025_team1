import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
// carrot 変数
  int carrotcount = 0; 
  int pumpkincount = 0;
  int meloncount = 0;
  final AudioPlayer _bgmPlayer = AudioPlayer();
  @override
  void initState(){
    super.initState();
    _playBGM();
    _loadCount();
  }

  Future<void> _loadCount() async{
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    carrotcount = prefs.getInt('carrot')  ?? 0;
    meloncount = prefs.getInt('melon') ?? 0;
    pumpkincount = prefs.getInt('pumpkin') ?? 0;
  });
  
  }
  Future<void> _playBGM() async{
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('home.mp3'));
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
                  _buildItemCounter('assets/melon.png', meloncount),
                  _buildItemCounter('assets/ninzin.png', carrotcount),
                  _buildItemCounter('assets/pumpkin.png', pumpkincount),
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
                    onPressed: ()async {
                int veg = Random().nextInt(3);
                _bgmPlayer.dispose();
                if(veg==0){
                await Navigator.pushNamed(context, '/game');
                }else if(veg==1){
                await Navigator.pushNamed(context, '/game/melon');  
                }else{
                await Navigator.pushNamed(context, '/game/pumpkin');
                }
                _loadCount();
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
                      _bgmPlayer.dispose();
                      Navigator.pushNamed(context, '/cook/pumpkinsoup');
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