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
  final AudioPlayer _sePlayer = AudioPlayer();
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
                  _buildItemCounter('assets/melon.png', meloncount, '/cook/melonjuice'),
                  _buildItemCounter('assets/ninzin.png', carrotcount, '/cook/carrotcake'),
                  _buildItemCounter('assets/pumpkin.png', pumpkincount, '/cook/pumpkinsoup'),
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
              child: Center(
                child: ElevatedButton(
                  onPressed: ()async {
                    int veg = Random().nextInt(3);
                    await _sePlayer.play(AssetSource('taiko.mp3'));
                    await _sePlayer.onPlayerComplete.first;
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
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  ),
                  child: const Text(
                    '畑ガチャ',
                    style: TextStyle(fontSize: 22, color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCounter(String imagePath, int count, String route) {
    final bool isEnabled = count > 0;
    
    return GestureDetector(
      onTap: isEnabled ? () async {
        _bgmPlayer.dispose();
        await _sePlayer.play(AssetSource('taiko.mp3'));
        await _sePlayer.onPlayerComplete.first;
        Navigator.pushNamed(context, route);
      } : null,
      child: Column(
        children: [
          Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Image.asset(
              imagePath,
              height: 50,
              width: 50,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.white : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled 
                    ? const Color.fromARGB(255, 255, 166, 71) 
                    : Colors.grey,
                width: 2,
              ),
            ),
            child: Text(
              '×$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isEnabled 
                    ? const Color.fromARGB(255, 255, 166, 71)
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}