import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class CookMelonScreen extends StatefulWidget {
  const CookMelonScreen({super.key});

  @override
  State<CookMelonScreen> createState() => _CookMelonScreenState();
}

class _CookMelonScreenState extends State<CookMelonScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  
  int _shakeCount = 0;
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
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticIn,
    ));
    
    _startAccelerometer();
  }
  
  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      double magnitude =  event.y.abs();
      if (magnitude > 15 && !_isShaking) {
        _isShaking = true;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        
        setState(() {
          _shakeCount++;
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
          Navigator.pushReplacementNamed(context, '/result');
        }
      }
    });
  }
  void _playse(String fileName) async {
    await player.play(AssetSource(fileName));
  }
  Future<void> _playBGM() async{
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('cook.mp3'));
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
      backgroundColor: Colors.brown[100],
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              color: Colors.brown[600],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '振った回数: $_shakeCount',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (_canHarvest)
                  const Text(
                    '思いっきり振り上げて収穫！',
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
                          'assets/melonjuice.png',
                          height: 300,
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