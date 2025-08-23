import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _sePlayer = AudioPlayer();
  late TabController _tabController;
  
  // 各料理のランキングデータ（トップ3）
  List<double> carrotcakeRecords = [];
  List<double> melonjuiceRecords = [];
  List<double> pumpkinsoupRecords = [];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRankingData();
  }
  
  Future<void> _loadRankingData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 各料理の記録を読み込み（JSON形式で保存されたリスト）
    String? carrotcakeJson = prefs.getString('carrotcake_records');
    String? melonjuiceJson = prefs.getString('melonjuice_records');
    String? pumpkinsoupJson = prefs.getString('pumpkinsoup_records');
    
    if (carrotcakeJson != null) {
      List<dynamic> decoded = jsonDecode(carrotcakeJson);
      carrotcakeRecords = decoded.map((e) => e as double).toList();
      carrotcakeRecords.sort();
      if (carrotcakeRecords.length > 3) {
        carrotcakeRecords = carrotcakeRecords.take(3).toList();
      }
    }
    
    if (melonjuiceJson != null) {
      List<dynamic> decoded = jsonDecode(melonjuiceJson);
      melonjuiceRecords = decoded.map((e) => e as double).toList();
      melonjuiceRecords.sort();
      if (melonjuiceRecords.length > 3) {
        melonjuiceRecords = melonjuiceRecords.take(3).toList();
      }
    }
    
    if (pumpkinsoupJson != null) {
      List<dynamic> decoded = jsonDecode(pumpkinsoupJson);
      pumpkinsoupRecords = decoded.map((e) => e as double).toList();
      pumpkinsoupRecords.sort();
      if (pumpkinsoupRecords.length > 3) {
        pumpkinsoupRecords = pumpkinsoupRecords.take(3).toList();
      }
    }
    
    setState(() {});
  }
  
  String _formatTime(double milliseconds) {
    if (milliseconds == double.infinity) {
      return '記録なし';
    }
    double seconds = milliseconds / 1000;
    return '${seconds.toStringAsFixed(2)}秒';
  }
  
  Widget _buildRankingList(List<double> records, String dishName, String imagePath) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 100,
              height: 100,
              color: Colors.grey.withValues(alpha: 0.5),
              colorBlendMode: BlendMode.modulate,
            ),
            const SizedBox(height: 20),
            Text(
              '$dishNameの\n記録がまだありません',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: records.length,
      itemBuilder: (context, index) {
        return _buildRankItem(index + 1, records[index], dishName, imagePath);
      },
    );
  }
  
  Widget _buildRankItem(int rank, double time, String dishName, String imagePath) {
    Color rankColor;
    double rankSize;
    
    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        rankSize = 36;
        break;
      case 2:
        rankColor = Colors.grey[400]!;
        rankSize = 32;
        break;
      case 3:
        rankColor = Colors.brown[400]!;
        rankSize = 28;
        break;
      default:
        rankColor = Colors.grey;
        rankSize = 24;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 順位
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: rankColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: rankSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // 料理画像
          Image.asset(
            imagePath,
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 15),
          // タイム表示
          Expanded(
            child: Text(
              _formatTime(time),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 205, 151),
      appBar: AppBar(
        title: const Text(
          '料理スピードランキング',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 166, 71),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            await _sePlayer.play(AssetSource('taiko.mp3'));
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: Image.asset(
                'assets/carrotcake.png',
                width: 30,
                height: 30,
              ),
            ),
            Tab(
              icon: Image.asset(
                'assets/melonjuice.png',
                width: 30,
                height: 30,
              ),
            ),
            Tab(
              icon: Image.asset(
                'assets/pumpkinsoup.png',
                width: 30,
                height: 30,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // タイトル
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/krank.png',
                    width: 40,
                    height: 40,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '最速記録TOP3',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 166, 71),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Image.asset(
                    'assets/krank.png',
                    width: 40,
                    height: 40,
                  ),
                ],
              ),
            ),
            // タブビュー
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRankingList(
                    carrotcakeRecords,
                    'キャロットケーキ',
                    'assets/carrotcake.png',
                  ),
                  _buildRankingList(
                    melonjuiceRecords,
                    'メロンジュース',
                    'assets/melonjuice.png',
                  ),
                  _buildRankingList(
                    pumpkinsoupRecords,
                    'パンプキンスープ',
                    'assets/pumpkinsoup.png',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _sePlayer.dispose();
    super.dispose();
  }
}