class ChallengeAttempt {
  final int id;
  final int challengeId;
  final DateTime attemptDate;
  final bool success;
  final String? notes;
  final String? emotionBefore;
  final String? emotionAfter;
  final DateTime createdAt;

  ChallengeAttempt({
    required this.id,
    required this.challengeId,
    required this.attemptDate,
    required this.success,
    this.notes,
    this.emotionBefore,
    this.emotionAfter,
    required this.createdAt,
  });

  factory ChallengeAttempt.fromJson(Map<String, dynamic> json) {
    return ChallengeAttempt(
      id: json['id'] as int,
      challengeId: json['challenge_id'] as int,
      attemptDate: DateTime.parse(json['attempt_date'] as String),
      success: json['success'] as bool,
      notes: json['notes'] as String?,
      emotionBefore: json['emotion_before'] as String?,
      emotionAfter: json['emotion_after'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ResponseChallenge {
  final int id;
  final int userId;
  final int? diaryId;
  final String challengeTitle;
  final String oldResponse;
  final String newResponse;
  final int difficultyLevel;
  final String status;
  final String? actualResult;
  final String? reflection;
  final int? successRate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;
  final List<ChallengeAttempt> attempts;

  ResponseChallenge({
    required this.id,
    required this.userId,
    this.diaryId,
    required this.challengeTitle,
    required this.oldResponse,
    required this.newResponse,
    required this.difficultyLevel,
    required this.status,
    this.actualResult,
    this.reflection,
    this.successRate,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.attempts = const [],
  });

  factory ResponseChallenge.fromJson(Map<String, dynamic> json) {
    return ResponseChallenge(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      diaryId: json['diary_id'] as int?,
      challengeTitle: json['challenge_title'] as String,
      oldResponse: json['old_response'] as String,
      newResponse: json['new_response'] as String,
      difficultyLevel: json['difficulty_level'] as int,
      status: json['status'] as String,
      actualResult: json['actual_result'] as String?,
      reflection: json['reflection'] as String?,
      successRate: json['success_rate'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      attempts: (json['attempts'] as List<dynamic>?)
              ?.map((attempt) =>
                  ChallengeAttempt.fromJson(attempt as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ChallengeCreateRequest {
  final String challengeTitle;
  final String oldResponse;
  final String newResponse;
  final int difficultyLevel;
  final int? diaryId;

  ChallengeCreateRequest({
    required this.challengeTitle,
    required this.oldResponse,
    required this.newResponse,
    required this.difficultyLevel,
    this.diaryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'challenge_title': challengeTitle,
      'old_response': oldResponse,
      'new_response': newResponse,
      'difficulty_level': difficultyLevel,
      'diary_id': diaryId,
    };
  }
}

class AttemptCreateRequest {
  final DateTime attemptDate;
  final bool success;
  final String? notes;
  final String? emotionBefore;
  final String? emotionAfter;

  AttemptCreateRequest({
    required this.attemptDate,
    required this.success,
    this.notes,
    this.emotionBefore,
    this.emotionAfter,
  });

  Map<String, dynamic> toJson() {
    return {
      'attempt_date': attemptDate.toIso8601String().split('T')[0],
      'success': success,
      'notes': notes,
      'emotion_before': emotionBefore,
      'emotion_after': emotionAfter,
    };
  }
}
