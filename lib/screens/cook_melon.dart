import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

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
  bool _isShaking = false;
  bool _canHarvest = false;
  
  int _fineCutCount = 0;
  int _shakePhaseCount = 0;
  DateTime? startTime;  // 料理開始時間を記録
  double? completionTime;  // 完成時の記録時間
  
  final AudioPlayer _bgmPlayer = AudioPlayer(playerId: "bgm");
  final player = AudioPlayer(playerId: "se");
  
  @override
  void initState() {
    super.initState();
    _setupAudioContext();
    _playBGM();
    startTime = DateTime.now();  // タイマー開始
    
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
        _playse('melon_firstcut.mp3');
        Vibration.vibrate(duration: 500);
        
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
        _playse('melon_firstcut.mp3');
        Vibration.vibrate(duration: 500);
        
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
        _playse('melon_cut.mp3');
        Vibration.vibrate(duration: 200);
        
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
        _playse('melon_shake.mp3');
        Vibration.vibrate(duration: 100);
        
        setState(() {
          _shakePhaseCount++;
          if (_shakePhaseCount >= 30) {
            _isCooked = true;
            // 完成時の時間を記録
            if (startTime != null) {
              completionTime = DateTime.now().difference(startTime!).inMilliseconds.toDouble();
            }
            _bgmPlayer.dispose();
            _saveCookedDish();
            
            
            _playse('cook_success.mp3');
            player.onPlayerComplete.listen((event) { 
              player.dispose();
  // 指定した処理
});
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

  Future<void> _playBGM() async{
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('cook.mp3'));
  }
  Future<void> _saveCookedDish() async {
    final prefs = await SharedPreferences.getInstance();
    int melonCount = prefs.getInt('melon') ?? 0;
    int melonJuiceCount = prefs.getInt('melonjuice') ?? 0;
    
    if (melonCount > 0) {
      await prefs.setInt('melon', melonCount - 1);
      await prefs.setInt('melonjuice', melonJuiceCount + 1);
    }
    
    // completionTimeが既に計算されているのでそれを使用
    if (completionTime != null) {
      // 記録リストを取得
      String? recordsJson = prefs.getString('melonjuice_records');
      List<double> records = [];
      
      if (recordsJson != null) {
        List<dynamic> decoded = jsonDecode(recordsJson);
        records = decoded.map((e) => e as double).toList();
      }
      
      // 新しい記録を追加（completionTimeを使用）
      records.add(completionTime!);
      records.sort();
      
      // トップ10の記録のみ保存
      if (records.length > 10) {
        records = records.take(10).toList();
      }
      
      // 保存
      await prefs.setString('melonjuice_records', jsonEncode(records));
    }
  }

  void _playse(String fileName) async {
    await player.play(AssetSource(fileName));
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
                    Column(
                      children: [
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
                        if (_isCooked && completionTime != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.yellow[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.orange,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              '記録: ${(completionTime! / 1000).toStringAsFixed(2)}秒',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ],
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
                        offset: Offset(0, 0),
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