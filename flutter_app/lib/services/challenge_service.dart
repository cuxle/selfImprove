import '../config/api_config.dart';
import '../models/response_challenge.dart';
import 'api_service.dart';

class ChallengeService {
  final ApiService _apiService = ApiService();

  // 创建挑战
  Future<ResponseChallenge> createChallenge(
      ChallengeCreateRequest request) async {
    final response = await _apiService.post(
      ApiConfig.challenges,
      body: request.toJson(),
    );

    return ResponseChallenge.fromJson(response);
  }

  // 获取挑战列表
  Future<List<ResponseChallenge>> getChallenges({
    int skip = 0,
    int limit = 10,
    String? statusFilter,
  }) async {
    final queryParams = <String, String>{
      'skip': skip.toString(),
      'limit': limit.toString(),
    };

    if (statusFilter != null) {
      queryParams['status_filter'] = statusFilter;
    }

    final response = await _apiService.get(
      ApiConfig.challenges,
      queryParameters: queryParams,
    );

    final challengesList = response['challenges'] as List<dynamic>;
    return challengesList
        .map((challenge) =>
            ResponseChallenge.fromJson(challenge as Map<String, dynamic>))
        .toList();
  }

  // 获取单个挑战
  Future<ResponseChallenge> getChallenge(int id) async {
    final response = await _apiService.get(
      ApiConfig.challengeById(id),
    );

    return ResponseChallenge.fromJson(response);
  }

  // 更新挑战
  Future<ResponseChallenge> updateChallenge(
    int id,
    Map<String, dynamic> updates,
  ) async {
    final response = await _apiService.put(
      ApiConfig.challengeById(id),
      body: updates,
    );

    return ResponseChallenge.fromJson(response);
  }

  // 删除挑战
  Future<void> deleteChallenge(int id) async {
    await _apiService.delete(
      ApiConfig.challengeById(id),
    );
  }

  // 添加尝试记录
  Future<ChallengeAttempt> createAttempt(
    int challengeId,
    AttemptCreateRequest request,
  ) async {
    final response = await _apiService.post(
      ApiConfig.challengeAttempts(challengeId),
      body: request.toJson(),
    );

    return ChallengeAttempt.fromJson(response);
  }
}
