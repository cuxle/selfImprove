import 'package:flutter/foundation.dart';
import '../models/emotion_tag.dart';
import '../services/tag_service.dart';
import '../services/api_service.dart';

class TagProvider with ChangeNotifier {
  final TagService _tagService = TagService();

  List<EmotionTag> _tags = [];
  List<TagUsageStats> _tagStats = [];
  bool _isLoading = false;
  String? _error;

  List<EmotionTag> get tags => _tags;
  List<TagUsageStats> get tagStats => _tagStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 按类型获取标签
  List<EmotionTag> getTagsByType(String type) {
    return _tags.where((tag) => tag.tagType == type).toList();
  }

  // 加载标签列表
  Future<void> loadTags({String? tagType}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tags = await _tagService.getTags(
        skip: 0,
        limit: 100,
        tagType: tagType,
      );

      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载标签失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 创建标签
  Future<bool> createTag(TagCreateRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newTag = await _tagService.createTag(request);
      _tags.insert(0, newTag);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '创建标签失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 更新标签
  Future<bool> updateTag(int id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedTag = await _tagService.updateTag(id, updates);

      // 更新列表中的标签
      final index = _tags.indexWhere((tag) => tag.id == id);
      if (index != -1) {
        _tags[index] = updatedTag;
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
      _error = '更新标签失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 删除标签
  Future<bool> deleteTag(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _tagService.deleteTag(id);
      _tags.removeWhere((tag) => tag.id == id);

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = '删除标签失败: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 加载标签使用统计
  Future<void> loadTagStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tagStats = await _tagService.getTagUsageStats();

      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '加载标签统计失败: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
