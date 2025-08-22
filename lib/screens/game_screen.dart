import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shakeAnimation;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  
  int _shakeCount = 0;
  int timelimit = 30;
  bool _isShaking = false;
  bool _canHarvest = false;
  double _carrotPosition = 0;

  final AudioPlayer _bgmPlayer = AudioPlayer();
  
  @override
  void initState() {
    super.initState();
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
    _startTimer();
  }
  
  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) async {
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
          final prefs = await SharedPreferences.getInstance();
          var carrotcount = prefs.getInt('carrot') ?? 0;
          carrotcount += 1;
          await prefs.setInt('carrot', carrotcount);
          Navigator.pushReplacementNamed(context, '/result');
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
       Navigator.pushReplacementNamed(context, '/result/failed/carrot');
    }
  });
}
  Future<void> _playBGM() async{
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('harvest.mp3'));
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
                          'assets/ninzin.png',
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