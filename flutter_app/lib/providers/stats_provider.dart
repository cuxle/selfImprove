import 'package:flutter/foundation.dart';
import '../services/stats_service.dart';
import '../services/api_service.dart';

class StatsProvider with ChangeNotifier {
  final StatsService _statsService = StatsService();

  StatsOverview? _overview;
  EmotionTrendData? _trendData;
  IntensityDistribution? _intensityDistribution;
  ChallengeStats? _challengeStats;

  bool _isLoading = false;
  String? _error;

  StatsOverview? get overview => _overview;
  EmotionTrendData? get trendData => _trendData;
  IntensityDistribution? get intensityDistribution => _intensityDistribution;
  ChallengeStats? get challengeStats => _challengeStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 加载统计概览
  Future<void> loadOverview() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _overview = await _statsService.getOverview();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载统计概览失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载情绪趋势数据
  Future<void> loadTrendData({int days = 30}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _trendData = await _statsService.getEmotionTrend(days: days);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载情绪趋势失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载情绪强度分布
  Future<void> loadIntensityDistribution() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _intensityDistribution = await _statsService.getIntensityDistribution();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载强度分布失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载挑战统计
  Future<void> loadChallengeStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _challengeStats = await _statsService.getChallengeStats();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载挑战统计失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载所有统计数据
  Future<void> loadAllStats({int trendDays = 30}) async {
    await Future.wait([
      loadOverview(),
      loadTrendData(days: trendDays),
      loadIntensityDistribution(),
      loadChallengeStats(),
    ]);
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
