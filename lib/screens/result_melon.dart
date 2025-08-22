import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
final AudioPlayer _sePlayer = AudioPlayer();

class ResultMelon extends StatelessWidget {
  const ResultMelon({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '収穫成功！',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 40),
            Image.asset(
              'assets/melon.png',
              height: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              '立派なメロンが収穫できました！',
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