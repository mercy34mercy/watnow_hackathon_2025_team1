import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.harvestYellow,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '収穫成功！',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryOrange,
              ),
            ),
            const SizedBox(height: 40),
            Image.asset(
              'assets/ninzin.png',
              height: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              '立派な人参が収穫できました！',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text(
                'タイトルに戻る',
                style: TextStyle(fontSize: 20, color: AppColors.textLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}