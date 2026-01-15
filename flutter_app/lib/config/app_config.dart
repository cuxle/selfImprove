import 'package:flutter/material.dart';

class AppConfig {
  // 应用名称
  static const String appName = '情绪遗产';

  // 主题颜色
  static const Color primaryColor = Color(0xFF6B4EE6);
  static const Color secondaryColor = Color(0xFF50E3C2);
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF2ECC71);
  static const Color warningColor = Color(0xFFF39C12);

  // 情绪强度颜色映射
  static Color getEmotionIntensityColor(int intensity) {
    if (intensity <= 3) return Colors.green;
    if (intensity <= 6) return Colors.orange;
    return Colors.red;
  }

  // 挑战难度颜色映射
  static Color getChallengeDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 挑战状态颜色
  static Color getChallengeStatusColor(String status) {
    switch (status) {
      case 'planned':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // 挑战状态文字
  static String getChallengeStatusText(String status) {
    switch (status) {
      case 'planned':
        return '计划中';
      case 'in_progress':
        return '进行中';
      case 'completed':
        return '已完成';
      default:
        return '未知';
    }
  }
}
