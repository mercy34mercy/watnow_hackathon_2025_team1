import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';


class GameMelonScreen extends StatefulWidget {
  const GameMelonScreen({super.key});

  @override
  State<GameMelonScreen> createState() => _GameMelonScreenState();
}

class _GameMelonScreenState extends State<GameMelonScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  
  int _shakeCount = 0;
  int timelimit = 30;
  bool _isShaking = false;
  bool _canHarvest = false;
  double _carrotPosition = 0;
  final AudioPlayer _bgmPlayer = AudioPlayer(playerId: "bgm");
  final player = AudioPlayer(playerId: "se");

  
  @override
  void initState() {
    super.initState();
    _setupAudioContext();
    _playBGM();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _shakeAnimation = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.0, end: -200.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(begin: -200.0, end: 200.0).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 2,
    ),
    TweenSequenceItem(
      tween: Tween(begin:200.0, end: -100.0).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 2,
    ),
    TweenSequenceItem(
      tween: Tween(begin: -100.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
      weight: 1,
    ),
  ]).animate(_animationController);
    
    _startAccelerometer();
    _startTimer();
  }
  
  void _startAccelerometer()  {
    _accelerometerSubscription = accelerometerEventStream().listen((event) async {
      double magnitude = event.x.abs();
      
      if (magnitude > 15 && !_isShaking) {
        _isShaking = true;
        _animationController.forward(from: 0);
        
        setState(() {
          _shakeCount++;
          Vibration.vibrate(duration: 300);
          _playse('cut.mp3');
          _carrotPosition = min(_shakeCount * 2.0, 20.0);
          
          if (_shakeCount >= 8) {
            _canHarvest = true;
          }
        });
        
        Future.delayed(const Duration(milliseconds: 300), () {
          _isShaking = false;
        });
      }
      
      if (_canHarvest && magnitude > 25) {
        _accelerometerSubscription?.cancel();
        if (mounted) {
          final prefs = await SharedPreferences.getInstance();
          var meloncount = prefs.getInt('melon') ?? 0;
          meloncount += 1;
          Vibration.vibrate(duration: 1000);
          await prefs.setInt('melon', meloncount);
          _playse('harvest_success.mp3');
          Navigator.pushReplacementNamed(context, '/result/melon');
        }
      }
    });
  }
  void _startTimer() {
  Timer.periodic(const Duration(seconds: 1), (timer) {
    if (timelimit > 0) {
      setState(() {
        timelimit--;
      });
    } else {
      timer.cancel(); 
      _playse('bad_smell.mp3');
      // 0 になったらタイマーを止める
      // 必要ならここでリザルト画面に遷移するなどの処理
      Navigator.pushReplacementNamed(context, '/result/failed/melon');
    }
  });
}
void _setupAudioContext() async {
    // グローバルオーディオコンテキストの設定（iOS/Android共通）
    final audioContext = AudioContext(
      iOS: AudioContextIOS(
        options: {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
      android: AudioContextAndroid(
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.none,
      ),
    );
    
    await AudioPlayer.global.setAudioContext(audioContext);
  }
  Future<void> _playBGM() async{
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('harvest.mp3'));
  }
  void _playse(String fileName) async {
    await player.play(AssetSource(fileName));
  }
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _animationController.dispose();
    _bgmPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],//はいけい
      body: Stack(//下の方の背景
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              color: Colors.green[600],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '残り時間: $timelimit',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '振った回数: $_shakeCount',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (_canHarvest)
                  const Text(
                    '思いっきり横に振って収穫！',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value * sin(_animationController.value * pi * 2), 0),
                      child: Transform.translate(
                        offset: Offset(0, -_carrotPosition),
                        child: Image.asset(
                          'assets/melon.png',
                          height: 200,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}