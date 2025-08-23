import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
// carrot 変数
  int carrotcount = 0; 
  int pumpkincount = 0;
  int meloncount = 0;
  // 料理の数
  int carrotcakecount = 0;
  int melonjuicecount = 0;
  int pumpkinsoupcount = 0;
  
  // 食べた回数カウント
  int carrotcakeEaten = 0;
  int melonjuiceEaten = 0;
  int pumpkinsoupEaten = 0;
  
  // 最後に食べた料理を記録するリスト（最新3つまで）
  List<String> recentFoods = [];
  
  // うさぎの進化状態
  String rabbitType = 'normal'; // normal, carrot, melon, pumpkin
  
  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _sePlayer = AudioPlayer();
  
  // ドラッグ＆ドロップ用の変数
  AnimationController? _eatAnimationController;
  Animation<double>? _eatAnimation;
  @override
  void initState(){
    super.initState();
    _playBGM();
    _loadCount();
    
    // 食事アニメーションの初期化
    _eatAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _eatAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _eatAnimationController!,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _loadCount() async{
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    carrotcount = prefs.getInt('carrot')  ?? 0;
    meloncount = prefs.getInt('melon') ?? 0;
    pumpkincount = prefs.getInt('pumpkin') ?? 0;
    carrotcakecount = prefs.getInt('carrotcake') ?? 0;
    melonjuicecount = prefs.getInt('melonjuice') ?? 0;
    pumpkinsoupcount = prefs.getInt('pumpkinsoup') ?? 0;
    
    // 食べた回数を読み込み
    carrotcakeEaten = prefs.getInt('carrotcake_eaten') ?? 0;
    melonjuiceEaten = prefs.getInt('melonjuice_eaten') ?? 0;
    pumpkinsoupEaten = prefs.getInt('pumpkinsoup_eaten') ?? 0;
    
    // 最近食べた料理のリストを読み込み
    recentFoods = prefs.getStringList('recent_foods') ?? [];
    
    // うさぎの進化状態を更新
    _updateRabbitType();
  });
  
  }
  
  void _updateRabbitType() {
    // 最近食べた3つの料理が全て同じかチェック
    if (recentFoods.length >= 3) {
      // 最新の3つを取得
      List<String> lastThree = recentFoods.sublist(recentFoods.length - 3);
      
      // 3つとも同じ料理かチェック
      if (lastThree.every((food) => food == 'carrotcake')) {
        rabbitType = 'carrot';
      } else if (lastThree.every((food) => food == 'melonjuice')) {
        rabbitType = 'melon';
      } else if (lastThree.every((food) => food == 'pumpkinsoup')) {
        rabbitType = 'pumpkin';
      } else {
        rabbitType = 'normal';
      }
    } else {
      rabbitType = 'normal';
    }
  }
  
  String _getRabbitImagePath() {
    switch (rabbitType) {
      case 'carrot':
        return 'assets/carrot_rabbit.png';
      case 'melon':
        return 'assets/melon_rabbit.png';
      case 'pumpkin':
        return 'assets/punpkin_rabbit.png';
      default:
        return 'assets/rabbit.png';
    }
  }
  Future<void> _playBGM() async{
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('home.mp3'));
  }
  
  Future<void> _feedRabbit(String foodType) async {
    // うさぎに料理を食べさせる処理
    final prefs = await SharedPreferences.getInstance();
    
    if (foodType == 'carrotcake' && carrotcakecount > 0) {
      setState(() {
        carrotcakecount--;
        carrotcakeEaten++;
        // 最近食べた料理リストに追加（最大10個まで保持）
        recentFoods.add('carrotcake');
        if (recentFoods.length > 10) {
          recentFoods.removeAt(0);
        }
        _updateRabbitType();
      });
      await prefs.setInt('carrotcake', carrotcakecount);
      await prefs.setInt('carrotcake_eaten', carrotcakeEaten);
      await prefs.setStringList('recent_foods', recentFoods);
      await _sePlayer.play(AssetSource('eat.mp3'));
      _eatAnimationController?.forward().then((_) {
        _eatAnimationController?.reverse();
      });
    } else if (foodType == 'melonjuice' && melonjuicecount > 0) {
      setState(() {
        melonjuicecount--;
        melonjuiceEaten++;
        // 最近食べた料理リストに追加（最大10個まで保持）
        recentFoods.add('melonjuice');
        if (recentFoods.length > 10) {
          recentFoods.removeAt(0);
        }
        _updateRabbitType();
      });
      await prefs.setInt('melonjuice', melonjuicecount);
      await prefs.setInt('melonjuice_eaten', melonjuiceEaten);
      await prefs.setStringList('recent_foods', recentFoods);
      await _sePlayer.play(AssetSource('eat.mp3'));
      _eatAnimationController?.forward().then((_) {
        _eatAnimationController?.reverse();
      });
    } else if (foodType == 'pumpkinsoup' && pumpkinsoupcount > 0) {
      setState(() {
        pumpkinsoupcount--;
        pumpkinsoupEaten++;
        // 最近食べた料理リストに追加（最大10個まで保持）
        recentFoods.add('pumpkinsoup');
        if (recentFoods.length > 10) {
          recentFoods.removeAt(0);
        }
        _updateRabbitType();
      });
      await prefs.setInt('pumpkinsoup', pumpkinsoupcount);
      await prefs.setInt('pumpkinsoup_eaten', pumpkinsoupEaten);
      await prefs.setStringList('recent_foods', recentFoods);
      await _sePlayer.play(AssetSource('eat.mp3'));
      _eatAnimationController?.forward().then((_) {
        _eatAnimationController?.reverse();
      });
    }
  }
  
  @override
  void dispose() {
    _eatAnimationController?.dispose();
    _bgmPlayer.dispose();
    _sePlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 205, 151),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildItemCounter('assets/melon.png', meloncount, '/cook/melonjuice'),
                  _buildItemCounter('assets/ninzin.png', carrotcount, '/cook/carrotcake'),
                  _buildItemCounter('assets/pumpkin.png', pumpkincount, '/cook/pumpkinsoup'),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: DragTarget<String>(
                  onAcceptWithDetails: (details) {
                    _feedRabbit(details.data);
                  },
                  onWillAcceptWithDetails: (details) {
                    // 料理の数が0より多い場合のみ受け入れる
                    if (details.data == 'carrotcake' && carrotcakecount > 0) return true;
                    if (details.data == 'melonjuice' && melonjuicecount > 0) return true;
                    if (details.data == 'pumpkinsoup' && pumpkinsoupcount > 0) return true;
                    return false;
                  },
                  builder: (context, candidateData, rejectedData) {
                    if (_eatAnimationController != null) {
                      return AnimatedBuilder(
                        animation: _eatAnimationController!,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: candidateData.isNotEmpty ? 1.1 : (_eatAnimation?.value ?? 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: candidateData.isNotEmpty 
                                  ? Colors.green.withValues(alpha: 0.2)
                                  : Colors.transparent,
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Image.asset(
                              _getRabbitImagePath(),
                              height: 250,
                            ),
                          ),
                        );
                      },
                    );
                    } else {
                      // アニメーションコントローラーがまだ初期化されていない場合
                      return Transform.scale(
                        scale: candidateData.isNotEmpty ? 1.1 : 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: candidateData.isNotEmpty 
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.transparent,
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            _getRabbitImagePath(),
                            height: 250,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            // 畑ガチャボタン（完全に中央）
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: ()async {
                    int veg = Random().nextInt(3);
                    await _sePlayer.play(AssetSource('taiko.mp3'));
                    await _sePlayer.onPlayerComplete.first;
                    _bgmPlayer.dispose();
                    if(veg==0){
                      await Navigator.pushNamed(context, '/game');
                    }else if(veg==1){
                      await Navigator.pushNamed(context, '/game/melon');  
                    }else{
                      await Navigator.pushNamed(context, '/game/pumpkin');
                    }
                    _loadCount();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 166, 71),
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                  ),
                  child: const Text(
                    '畑ガチャ',
                    style: TextStyle(fontSize: 22, color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ),
            ),
              ],
            ),
            // ランキングボタン（右上に配置）
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () async {
                    await _sePlayer.play(AssetSource('taiko.mp3'));
                    if (mounted) {
                      Navigator.pushNamed(context, '/ranking');
                    }
                  },
                  icon: Image.asset(
                    'assets/krank.png',
                    width: 40,
                    height: 40,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemCounter(String imagePath, int count, String route) {
    final bool isEnabled = count > 0;
    
    int dishCount = 0;
    String dishImagePath = '';
    if (route == '/cook/melonjuice') {
      dishCount = melonjuicecount;
      dishImagePath = 'assets/melonjuice.png';
    } else if (route == '/cook/carrotcake') {
      dishCount = carrotcakecount;
      dishImagePath = 'assets/carrotcake.png';
    } else if (route == '/cook/pumpkinsoup') {
      dishCount = pumpkinsoupcount;
      dishImagePath = 'assets/pumpkinsoup.png';
    }
    
    return 
    // 縦に並べる
    Column(
      children: [

    GestureDetector(
      onTap: isEnabled ? () async {
        _bgmPlayer.dispose();
        await _sePlayer.play(AssetSource('taiko.mp3'));
        await _sePlayer.onPlayerComplete.first;
        Navigator.pushNamed(context, route);
      } : null,
      child: Column(
        children: [
          Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Image.asset(
              imagePath,
              height: 50,
              width: 50,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.white : Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled 
                    ? const Color.fromARGB(255, 255, 166, 71) 
                    : Colors.grey,
                width: 2,
              ),
            ),
            child: Text(
              '×$count',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isEnabled 
                    ? const Color.fromARGB(255, 255, 166, 71)
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      ),
      const SizedBox(height: 8),
          // 料理をドラッグ可能にする
          dishCount > 0 
              ? Draggable<String>(
                  data: route == '/cook/melonjuice' 
                      ? 'melonjuice' 
                      : route == '/cook/carrotcake' 
                          ? 'carrotcake' 
                          : 'pumpkinsoup',
                  feedback: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        dishImagePath,
                        height: 60,
                        width: 60,
                      ),
                    ),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Column(
                      children: [
                        Image.asset(
                          dishImagePath,
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '×$dishCount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onDragStarted: () {
                    // ドラッグ開始時の処理（必要に応じて追加）
                  },
                  onDragEnd: (_) {
                    // ドラッグ終了時の処理（必要に応じて追加）
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        dishImagePath,
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '×$dishCount',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Opacity(
                      opacity: 0.5,
                      child: Image.asset(
                        dishImagePath,
                        height: 40,
                        width: 40,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '×0',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
      ],
    );
  }
}