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
  
  // Cooking phases
  bool _isVerticalCut = false;
  bool _isHorizontalCut = false;
  bool _isFineCutting = false;
  bool _isShakePhase = false;
  bool _isCooked = false;
  
  int _fineCutCount = 0;
  int _shakePhaseCount = 0;
  
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _soundPlayer = AudioPlayer();
  
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
      double verticalMagnitude = event.y.abs();
      double horizontalMagnitude = event.x.abs();
      
      // フェーズ1: 縦に重く振って切る
      if (!_isVerticalCut && verticalMagnitude > 20 && !_isShaking) {
        _isShaking = true;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        _soundPlayer.play(AssetSource('cut.mp3'));
        
        setState(() {
          _isVerticalCut = true;
        });
        
        Future.delayed(const Duration(milliseconds: 300), () {
          _isShaking = false;
        });
      }
      
      // フェーズ2: 横に重く振って切る
      else if (_isVerticalCut && !_isHorizontalCut && horizontalMagnitude > 20 && !_isShaking) {
        _isShaking = true;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        _soundPlayer.play(AssetSource('cut.mp3'));
        
        setState(() {
          _isHorizontalCut = true;
          _isFineCutting = true;
        });
        
        Future.delayed(const Duration(milliseconds: 300), () {
          _isShaking = false;
        });
      }
      
      // フェーズ3: 軽く縦に振って細かく切る
      else if (_isFineCutting && !_isShakePhase && verticalMagnitude > 8 && !_isShaking) {
        _isShaking = true;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        _soundPlayer.play(AssetSource('cut.mp3'));
        
        setState(() {
          _fineCutCount++;
          if (_fineCutCount >= 5) {
            _isFineCutting = false;
            _isShakePhase = true;
          }
        });
        
        Future.delayed(const Duration(milliseconds: 200), () {
          _isShaking = false;
        });
      }
      
      // フェーズ4: シェイク（30回縦に細かく振る）
      else if (_isShakePhase && !_isCooked && verticalMagnitude > 8 && !_isShaking) {
        _isShaking = true;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        _soundPlayer.play(AssetSource('shake.mp3'));
        
        setState(() {
          _shakePhaseCount++;
          if (_shakePhaseCount >= 30) {
            _isCooked = true;
            _soundPlayer.play(AssetSource('complete.mp3'));
          }
        });
        
        Future.delayed(const Duration(milliseconds: 100), () {
          _isShaking = false;
        });
      }
      
      if (_canHarvest && verticalMagnitude > 25) {
        _accelerometerSubscription?.cancel();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/result/melon');
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
    _soundPlayer.dispose();
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 45,
            child: _isCooked
                ? Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                      child: Text('ホーム画面に戻る', style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          255,
                          166,
                          71,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  )
                : SizedBox(),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _isCooked
                        ? SizedBox(height: 0)
                        : Image.asset('assets/bikkurisen.png', width: 300),
                    Text(
                      _isCooked
                          ? 'できあがりました!'
                          : _isShakePhase
                              ? 'シェイクせよ!'
                              : _isFineCutting
                                  ? '細かく切れ!'
                                  : _isHorizontalCut
                                      ? '準備完了!'
                                      : _isVerticalCut
                                          ? '横に切れ!'
                                          : '縦に切れ!',
                      style: TextStyle(
                        fontSize: _isCooked ? 33 : 36,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                if (!_isVerticalCut) ...[
                  Text(
                    '縦に重く振って切る',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (_isVerticalCut && !_isHorizontalCut) ...[
                  Text(
                    '横に重く振って切る',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (_isFineCutting) ...[
                  Text(
                    '軽く縦に振る: $_fineCutCount / 5',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (_isShakePhase && !_isCooked) ...[
                  Text(
                    'シェイク: $_shakePhaseCount / 30',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value * sin(_animationController.value * pi * 2), 0),
                      child: Transform.translate(
                        offset: Offset(0, -_carrotPosition),
                        child: Image.asset(
                          _isCooked
                              ? 'assets/melonjuice.png'
                              : 'assets/melon.png',
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