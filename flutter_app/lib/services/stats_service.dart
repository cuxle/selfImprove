import '../config/api_config.dart';
import 'api_service.dart';

class StatsService {
  final ApiService _apiService = ApiService();

  /// 获取统计概览
  Future<StatsOverview> getOverview() async {
    final response = await _apiService.get(ApiConfig.statsOverview);
    return StatsOverview.fromJson(response);
  }

  /// 获取情绪趋势数据
  Future<EmotionTrendData> getEmotionTrend({int days = 30}) async {
    final response = await _apiService.get(
      ApiConfig.statsEmotionTrend,
      queryParameters: {'days': days.toString()},
    );
    return EmotionTrendData.fromJson(response);
  }

  /// 获取情绪强度分布
  Future<IntensityDistribution> getIntensityDistribution() async {
    final response = await _apiService.get(ApiConfig.statsIntensityDistribution);
    return IntensityDistribution.fromJson(response);
  }

  /// 获取挑战完成率统计
  Future<ChallengeStats> getChallengeStats() async {
    final response = await _apiService.get(ApiConfig.statsChallengeCompletion);
    return ChallengeStats.fromJson(response);
  }
}

/// 统计概览模型
class StatsOverview {
  final int totalDiaries;
  final int recentDiaries;
  final double avgEmotionIntensity;
  final int totalChallenges;
  final int completedChallenges;

  StatsOverview({
    required this.totalDiaries,
    required this.recentDiaries,
    required this.avgEmotionIntensity,
    required this.totalChallenges,
    required this.completedChallenges,
  });

  factory StatsOverview.fromJson(Map<String, dynamic> json) {
    return StatsOverview(
      totalDiaries: json['total_diaries'] as int,
      recentDiaries: json['recent_diaries'] as int,
      avgEmotionIntensity: (json['avg_emotion_intensity'] as num).toDouble(),
      totalChallenges: json['total_challenges'] as int,
      completedChallenges: json['completed_challenges'] as int,
    );
  }
}

/// 情绪趋势数据模型
class EmotionTrendData {
  final String startDate;
  final String endDate;
  final List<TrendPoint> data;

  EmotionTrendData({
    required this.startDate,
    required this.endDate,
    required this.data,
  });

  factory EmotionTrendData.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>;
    return EmotionTrendData(
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      data: dataList
          .map((item) => TrendPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TrendPoint {
  final String date;
  final double avgIntensity;
  final int diaryCount;

  TrendPoint({
    required this.date,
    required this.avgIntensity,
    required this.diaryCount,
  });

  factory TrendPoint.fromJson(Map<String, dynamic> json) {
    return TrendPoint(
      date: json['date'] as String,
      avgIntensity: (json['avg_intensity'] as num).toDouble(),
      diaryCount: json['diary_count'] as int,
    );
  }
}

/// 情绪强度分布模型
class IntensityDistribution {
  final List<IntensityCount> distribution;
  final int totalCount;
  final double avgIntensity;

  IntensityDistribution({
    required this.distribution,
    required this.totalCount,
    required this.avgIntensity,
  });

  factory IntensityDistribution.fromJson(Map<String, dynamic> json) {
    final distList = json['distribution'] as List<dynamic>;
    return IntensityDistribution(
      distribution: distList
          .map((item) => IntensityCount.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['total_count'] as int,
      avgIntensity: (json['avg_intensity'] as num).toDouble(),
    );
  }
}

class IntensityCount {
  final int intensity;
  final int count;

  IntensityCount({
    required this.intensity,
    required this.count,
  });

  factory IntensityCount.fromJson(Map<String, dynamic> json) {
    return IntensityCount(
      intensity: json['intensity'] as int,
      count: json['count'] as int,
    );
  }
}

/// 挑战统计模型
class ChallengeStats {
  final int totalChallenges;
  final Map<String, int> statusDistribution;
  final int totalAttempts;
  final int successfulAttempts;
  final double successRate;
  final Map<String, dynamic> difficultyDistribution;

  ChallengeStats({
    required this.totalChallenges,
    required this.statusDistribution,
    required this.totalAttempts,
    required this.successfulAttempts,
    required this.successRate,
    required this.difficultyDistribution,
  });

  factory ChallengeStats.fromJson(Map<String, dynamic> json) {
    return ChallengeStats(
      totalChallenges: json['total_challenges'] as int,
      statusDistribution: Map<String, int>.from(json['status_distribution'] as Map),
      totalAttempts: json['total_attempts'] as int,
      successfulAttempts: json['successful_attempts'] as int,
      successRate: (json['success_rate'] as num).toDouble(),
      difficultyDistribution: json['difficulty_distribution'] as Map<String, dynamic>,
    );
  }
}
