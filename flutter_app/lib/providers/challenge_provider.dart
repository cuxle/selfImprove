import 'package:flutter/foundation.dart';
import '../models/response_challenge.dart';
import '../services/challenge_service.dart';
import '../services/api_service.dart';

class ChallengeProvider with ChangeNotifier {
  final ChallengeService _challengeService = ChallengeService();

  List<ResponseChallenge> _challenges = [];
  ResponseChallenge? _selectedChallenge;
  bool _isLoading = false;
  String? _error;

  List<ResponseChallenge> get challenges => _challenges;
  ResponseChallenge? get selectedChallenge => _selectedChallenge;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 按状态获取挑战列表
  List<ResponseChallenge> getChallengesByStatus(String status) {
    return _challenges.where((c) => c.status == status).toList();
  }

  // 加载挑战列表
  Future<void> loadChallenges({String? statusFilter}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _challenges = await _challengeService.getChallenges(
        skip: 0,
        limit: 100,
        statusFilter: statusFilter,
      );

      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载挑战失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 创建挑战
  Future<bool> createChallenge(ChallengeCreateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newChallenge = await _challengeService.createChallenge(request);
      _challenges.insert(0, newChallenge);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '创建挑战失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 获取单个挑战详情
  Future<void> loadChallenge(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedChallenge = await _challengeService.getChallenge(id);

      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载挑战详情失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新挑战
  Future<bool> updateChallenge(int id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedChallenge =
          await _challengeService.updateChallenge(id, updates);

      // 更新列表中的挑战
      final index = _challenges.indexWhere((c) => c.id == id);
      if (index != -1) {
        _challenges[index] = updatedChallenge;
      }

      // 更新选中的挑战
      if (_selectedChallenge?.id == id) {
        _selectedChallenge = updatedChallenge;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '更新挑战失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 删除挑战
  Future<bool> deleteChallenge(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _challengeService.deleteChallenge(id);

      _challenges.removeWhere((c) => c.id == id);

      if (_selectedChallenge?.id == id) {
        _selectedChallenge = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '删除挑战失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 添加尝试记录
  Future<bool> addAttempt(int challengeId, AttemptCreateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _challengeService.createAttempt(challengeId, request);

      // 重新加载挑战详情以获取最新的尝试记录
      await loadChallenge(challengeId);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '添加尝试记录失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 清除选中的挑战
  void clearSelectedChallenge() {
    _selectedChallenge = null;
    notifyListeners();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
