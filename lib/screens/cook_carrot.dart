import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CookCarrotScreen extends StatefulWidget {
  const CookCarrotScreen({super.key});

  @override
  State<CookCarrotScreen> createState() => _CookCarrotScreenState();
}

class _CookCarrotScreenState extends State<CookCarrotScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  int _shakeCount = 0;
  bool _isShaking = false;
  bool _canHarvest = false;
  double _carrotPosition = 0;
  bool isCooked = false;
  bool isCut = false;
  int kneadCount = 0;
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

  void _onVerticalSwipe(DragEndDetails details) {
    if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 500)
      if (isCut && !isCooked) {
        setState(() {
          kneadCount++;
          _playse('press.mp3');
          if (kneadCount >= 10) {
            isCooked = true;
            // 完成時の時間を記録
            if (startTime != null) {
              completionTime = DateTime.now().difference(startTime!).inMilliseconds.toDouble();
            }
            _playse('cook_success.mp3');
            _bgmPlayer.dispose();
            _saveCookedDish();
          }
        });
      }
  }

  void _startAccelerometer() {
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.brown[100],
        body: GestureDetector(
          onVerticalDragEnd: _onVerticalSwipe,
          child: Stack(
            children: [
              //
            ],
          ),
        ),
      );
    }

    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      double magnitude = event.y.abs();
      if (magnitude > 15 && !_isShaking) {
        _isShaking = true;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });

        setState(() {
          _shakeCount++;
          _playse('cut.mp3');
          _carrotPosition = min(_shakeCount * 2.0, 20.0);

          if (_shakeCount >= 5) {
            isCut = true;
          }
        });

        Future.delayed(const Duration(milliseconds: 300), () {
          _isShaking = false;
        });
      }

      if (_canHarvest && magnitude > 15) {
        _accelerometerSubscription?.cancel();
        isCooked = true;
        if (mounted) {
          // Navigator.pushReplacementNamed(context, '/result');
        }
      }
    });
  }

  void _playse(String fileName) async {
    await player.play(AssetSource(fileName));
  }
  Future<void> _playBGM() async {
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('cook.mp3'));
  }

  Future<void> _saveCookedDish() async {
    final prefs = await SharedPreferences.getInstance();
    int carrotCount = prefs.getInt('carrot') ?? 0;
    int carrotCakeCount = prefs.getInt('carrotcake') ?? 0;
    
    if (carrotCount > 0) {
      await prefs.setInt('carrot', carrotCount - 1);
      await prefs.setInt('carrotcake', carrotCakeCount + 1);
    }
    
    // completionTimeが既に計算されているのでそれを使用
    if (completionTime != null) {
      // 記録リストを取得
      String? recordsJson = prefs.getString('carrotcake_records');
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
      await prefs.setString('carrotcake_records', jsonEncode(records));
    }
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
      body: GestureDetector(
        onVerticalDragEnd: _onVerticalSwipe,
        child: Stack(
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
                          // fixedSize: Size(, height)
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
                            isCut
                                ? isCooked
                                      ? 'できあがりました!'
                                      : 'こねろ!'
                                : '切れ!',
                            style: TextStyle(
                              fontSize: isCooked ? 33 : 66,
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

                  if (!isCut && !isCooked) ...[
                    const SizedBox(height: 30),
                    Text(
                      '切った回数: $_shakeCount',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  if (isCut && !isCooked) ...[
                    const SizedBox(height: 20),
                    Text(
                      'こねた回数: $kneadCount / 10',
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
                          child: Image.asset(
                            isCooked
                                ? 'assets/carrotcake.png'
                                : 'assets/ninzin.png',
                            height: isCooked ? 500 : 200,
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
      ),
    );
  }
}
