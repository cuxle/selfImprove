import '../config/api_config.dart';
import '../models/emotion_tag.dart';
import 'api_service.dart';

class TagService {
  final ApiService _apiService = ApiService();

  /// 获取标签列表
  Future<List<EmotionTag>> getTags({
    int skip = 0,
    int limit = 100,
    String? tagType,
  }) async {
    final queryParams = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };

    if (tagType != null) {
      queryParams['tag_type'] = tagType;
    }

    final response = await _apiService.get(
      ApiConfig.tags,
      queryParameters: queryParams,
    );

    final items = response['items'] as List<dynamic>;
    return items.map((item) => EmotionTag.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// 创建标签
  Future<EmotionTag> createTag(TagCreateRequest request) async {
    final response = await _apiService.post(
      ApiConfig.tags,
      body: request.toJson(),
    );

    return EmotionTag.fromJson(response);
  }

  /// 获取单个标签
  Future<EmotionTag> getTag(int id) async {
    final response = await _apiService.get(ApiConfig.tagById(id));
    return EmotionTag.fromJson(response);
  }

  /// 更新标签
  Future<EmotionTag> updateTag(int id, Map<String, dynamic> updates) async {
    final response = await _apiService.put(
      ApiConfig.tagById(id),
      body: updates,
    );

    return EmotionTag.fromJson(response);
  }

  /// 删除标签
  Future<void> deleteTag(int id) async {
    await _apiService.delete(ApiConfig.tagById(id));
  }

  /// 获取标签使用统计
  Future<List<TagUsageStats>> getTagUsageStats() async {
    final response = await _apiService.get(ApiConfig.tagStats);
    final statsList = response as List<dynamic>;
    return statsList
        .map((stats) => TagUsageStats.fromJson(stats as Map<String, dynamic>))
        .toList();
  }
}

/// 标签使用统计模型
class TagUsageStats {
  final int id;
  final String tagName;
  final String tagType;
  final int usageCount;

  TagUsageStats({
    required this.id,
    required this.tagName,
    required this.tagType,
    required this.usageCount,
  });

  factory TagUsageStats.fromJson(Map<String, dynamic> json) {
    return TagUsageStats(
      id: json['id'] as int,
      tagName: json['tag_name'] as String,
      tagType: json['tag_type'] as String,
      usageCount: json['usage_count'] as int,
    );
  }
}
