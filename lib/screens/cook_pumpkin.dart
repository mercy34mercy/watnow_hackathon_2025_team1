import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookPumpkinScreen extends StatefulWidget {
  const CookPumpkinScreen({super.key});

  @override
  State<CookPumpkinScreen> createState() => _CookPumpkinScreenState();
}

class _CookPumpkinScreenState extends State<CookPumpkinScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  int _shakeCount = 0;
  int kneadCount = 0;
  bool _isShaking = false;
  bool _canHarvest = false;
  double _carrotPosition = 0;
  bool isCooked = false;
  bool isCut = false;
  bool isMashed = false;
  bool isCoated = false;
  int _coatShakeCount = 0;
  Timer? _kneadTimer;
  Timer? _mashTimer;
  int _mashSeconds = 0;
  bool _isMashing = false; 
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

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticIn),
    );

    _startAccelerometer();
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      double magnitude = event.y.abs();
      
      // 切るフェーズ（5回振る）
      if (!isCut && magnitude > 15 && !_isShaking) {
        _isShaking = true;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        
        // 切る音を再生
        _playse('cut.mp3');

        setState(() {
          _shakeCount++;
          _carrotPosition = min(_shakeCount * 2.0, 20.0);

          if (_shakeCount >= 5) {
            isCut = true;
          }
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          _isShaking = false;
        });
      }
      
      // まぶすフェーズ（30回細かく振る）
      if (isMashed && !isCoated && magnitude > 8 && !_isShaking) {
        _isShaking = true;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        
        // まぶす音を再生
        _playse('mabushi.mp3');

        setState(() {
          _coatShakeCount++;
          
          if (_coatShakeCount >= 30) {
            isCoated = true;
            isCooked = true;
            // 完成時の時間を記録
            if (startTime != null) {
              completionTime = DateTime.now().difference(startTime!).inMilliseconds.toDouble();
            }
            _bgmPlayer.dispose();
            _playse('cook_success.mp3');
            _saveCookedDish();
          }
        });

        Future.delayed(const Duration(milliseconds: 100), () {
          _isShaking = false;
        });
      }

      if (_canHarvest && magnitude > 25) {
        _accelerometerSubscription?.cancel();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/result/pumpkin');
        }
      }
    });
  }

  void _startMashing() {
    if (_isMashing) return;
    _isMashing = true;
    _mashSeconds = 0;
    
    // つぶし始めの音
    _playse('press.mp3');
    
    _mashTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _mashSeconds++;
        if (_mashSeconds >= 5) {
          isMashed = true;
          _mashTimer?.cancel();
          _isMashing = false;
          // つぶし完了音
          
        }
      });
    });
  }

  void _stopMashing() {
    _mashTimer?.cancel();
    _mashSeconds = 0;
    _isMashing = false;
  }

  void _startKneading() {
    _kneadTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      setState(() {
        kneadCount++;
        if (kneadCount >= 10) {
          isCooked = true;
          _kneadTimer?.cancel();
        }
      });
    });
  }

  void _stopKneading() {
    _kneadTimer?.cancel();
  }

  Future<void> _saveCookedDish() async {
    final prefs = await SharedPreferences.getInstance();
    int pumpkinCount = prefs.getInt('pumpkin') ?? 0;
    int pumpkinSoupCount = prefs.getInt('pumpkinsoup') ?? 0;
    
    if (pumpkinCount > 0) {
      await prefs.setInt('pumpkin', pumpkinCount - 1);
      await prefs.setInt('pumpkinsoup', pumpkinSoupCount + 1);
    }
    
    // completionTimeが既に計算されているのでそれを使用
    if (completionTime != null) {
      // 記録リストを取得
      String? recordsJson = prefs.getString('pumpkinsoup_records');
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
      await prefs.setString('pumpkinsoup_records', jsonEncode(records));
    }
  }

  void _playse(String fileName) async {
    await player.play(AssetSource(fileName));
  }

  Future<void> _playBGM() async {
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
    _gyroscopeSubscription?.cancel();
    _animationController.dispose();
    _bgmPlayer.dispose();
    _kneadTimer?.cancel();
    _mashTimer?.cancel();
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
            child: Container(color: Colors.brown[600]),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 45,
            child: isCooked
                ? Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                        _bgmPlayer.dispose();
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
                    isCooked
                        ? SizedBox(height: 0)
                        : Image.asset('assets/bikkurisen.png', width: 300),

                    Column(
                      children: [
                        Text(
                          isCooked
                              ? 'できあがりました!'
                              : isMashed
                                  ? 'まぶせ!'
                                  : isCut
                                      ? 'つぶせ!'
                                      : '切れ!',
                          style: TextStyle(
                            fontSize: isCooked ? 33 : 50,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isCooked && completionTime != null) ...[
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
                if (!isCut) ...[
                  const SizedBox(height: 30),
                  Text(
                    '縦に振って切る: $_shakeCount / 5',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (isCut && !isMashed) ...[
                  const SizedBox(height: 20),
                  Text(
                    _isMashing 
                        ? 'つぶし中: $_mashSeconds / 5秒'
                        : 'かぼちゃを長押し!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                if (isMashed && !isCoated) ...[
                  const SizedBox(height: 20),
                  Text(
                    '細かく振ってまぶす: $_coatShakeCount / 30',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                      offset: Offset(
                        _shakeAnimation.value *
                            sin(_animationController.value * pi * 2),
                        0,
                      ),
                      child: Transform.translate(
                        offset: Offset(0, -_carrotPosition),
                        child: GestureDetector(
                          onLongPressStart: isCut && !isMashed ? (_) => _startMashing() : null,
                          onLongPressEnd: isCut && !isMashed ? (_) => _stopMashing() : null,
                          child: Image.asset(
                            isCooked
                                ? 'assets/pumpkinsoup.png'
                                : 'assets/pumpkin.png',
                            height: 300,
                          ),
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
