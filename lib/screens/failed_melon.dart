import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
final AudioPlayer _sePlayer = AudioPlayer();

class FailedMelon extends StatelessWidget {
  const FailedMelon({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '収穫失敗...',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 47, 29, 240),
              ),
            ),
            const SizedBox(height: 40),
            Image.asset(
              'assets/rotten_melon.png',
              height: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              'もう一度収穫してみよう！',
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () async {
                await _sePlayer.play(AssetSource('taiko.mp3'));
                await _sePlayer.onPlayerComplete.first;
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text(
                'タイトルに戻る',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}