import 'package:flutter/foundation.dart';
import '../models/emotion_diary.dart';
import '../services/diary_service.dart';
import '../services/api_service.dart';

class DiaryProvider with ChangeNotifier {
  final DiaryService _diaryService = DiaryService();

  List<EmotionDiary> _diaries = [];
  EmotionDiary? _selectedDiary;
  bool _isLoading = false;
  String? _error;

  List<EmotionDiary> get diaries => _diaries;
  EmotionDiary? get selectedDiary => _selectedDiary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 加载日记列表
  Future<void> loadDiaries({
    String? emotion,
    int? tagId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _diaries = await _diaryService.getDiaries(
        skip: 0,
        limit: 100,
        emotion: emotion,
        tagId: tagId,
        startDate: startDate,
        endDate: endDate,
      );

      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载日记失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 创建日记
  Future<bool> createDiary(DiaryCreateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDiary = await _diaryService.createDiary(request);
      _diaries.insert(0, newDiary);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '创建日记失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 获取单个日记详情
  Future<void> loadDiary(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedDiary = await _diaryService.getDiary(id);

      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载日记详情失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 更新日记
  Future<bool> updateDiary(int id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedDiary = await _diaryService.updateDiary(id, updates);

      // 更新列表中的日记
      final index = _diaries.indexWhere((d) => d.id == id);
      if (index != -1) {
        _diaries[index] = updatedDiary;
      }

      // 更新选中的日记
      if (_selectedDiary?.id == id) {
        _selectedDiary = updatedDiary;
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
      _error = '更新日记失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 删除日记
  Future<bool> deleteDiary(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _diaryService.deleteDiary(id);

      _diaries.removeWhere((d) => d.id == id);

      if (_selectedDiary?.id == id) {
        _selectedDiary = null;
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
      _error = '删除日记失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 清除选中的日记
  void clearSelectedDiary() {
    _selectedDiary = null;
    notifyListeners();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
