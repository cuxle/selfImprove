import '../config/api_config.dart';
import '../models/emotion_diary.dart';
import 'api_service.dart';

class DiaryService {
  final ApiService _apiService = ApiService();

  // 创建日记
  Future<EmotionDiary> createDiary(DiaryCreateRequest request) async {
    final response = await _apiService.post(
      ApiConfig.diaries,
      body: request.toJson(),
    );

    return EmotionDiary.fromJson(response);
  }

  // 获取日记列表
  Future<List<EmotionDiary>> getDiaries({
    int skip = 0,
    int limit = 10,
    String? emotion,
    int? tagId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };

    if (emotion != null) {
      queryParams['emotion'] = emotion;
    }
    if (tagId != null) {
      queryParams['tag_id'] = tagId.toString();
    }
    if (startDate != null) {
      queryParams['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParams['end_date'] = endDate.toIso8601String();
    }

    final response = await _apiService.get(
      ApiConfig.diaries,
      queryParameters: queryParams,
    );

    final diariesList = response['diaries'] as List<dynamic>;
    return diariesList
        .map((diary) => EmotionDiary.fromJson(diary as Map<String, dynamic>))
        .toList();
  }

  // 获取单个日记
  Future<EmotionDiary> getDiary(int id) async {
    final response = await _apiService.get(
      ApiConfig.diaryById(id),
    );

    return EmotionDiary.fromJson(response);
  }

  // 更新日记
  Future<EmotionDiary> updateDiary(
    int id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiService.put(
      ApiConfig.diaryById(id),
      body: updates,
    );

    return EmotionDiary.fromJson(response);
  }

  // 删除日记
  Future<void> deleteDiary(int id) async {
    await _apiService.delete(
      ApiConfig.diaryById(id),
    );
  }
}
