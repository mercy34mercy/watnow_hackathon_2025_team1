import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

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
  final AudioPlayer _bgmPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playBGM();

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
          if (kneadCount >= 10) {
            isCooked = true;
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
  Future<void> _playBGM() async{
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('cook.mp3'));
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
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/bikkurisen.png', width: 300),
                      Text(
                        isCut ? 'こねろ!' : '切れ!',
                        style: const TextStyle(
                          fontSize: 66,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  SizedBox(height: 30),
                  Text(
                    '切った回数: $_shakeCount',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

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
      ),
    );
  }
}
