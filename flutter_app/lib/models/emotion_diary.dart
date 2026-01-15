import 'emotion_tag.dart';

class EmotionDiary {
  final int id;
  final int userId;
  final String triggerEvent;
  final String immediateEmotion;
  final int emotionIntensity;
  final String? physicalReaction;
  final String? autoThought;
  final String? childhoodMemory;
  final String? patternRecognition;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<EmotionTag> tags;

  EmotionDiary({
    required this.id,
    required this.userId,
    required this.triggerEvent,
    required this.immediateEmotion,
    required this.emotionIntensity,
    this.physicalReaction,
    this.autoThought,
    this.childhoodMemory,
    this.patternRecognition,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
  });

  factory EmotionDiary.fromJson(Map<String, dynamic> json) {
    return EmotionDiary(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      triggerEvent: json['trigger_event'] as String,
      immediateEmotion: json['immediate_emotion'] as String,
      emotionIntensity: json['emotion_intensity'] as int,
      physicalReaction: json['physical_reaction'] as String?,
      autoThought: json['auto_thought'] as String?,
      childhoodMemory: json['childhood_memory'] as String?,
      patternRecognition: json['pattern_recognition'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((tag) => EmotionTag.fromJson(tag as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trigger_event': triggerEvent,
      'immediate_emotion': immediateEmotion,
      'emotion_intensity': emotionIntensity,
      'physical_reaction': physicalReaction,
      'auto_thought': autoThought,
      'childhood_memory': childhoodMemory,
      'pattern_recognition': patternRecognition,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tags': tags.map((tag) => tag.toJson()).toList(),
    };
  }
}

class DiaryCreateRequest {
  final String triggerEvent;
  final String immediateEmotion;
  final int emotionIntensity;
  final String? physicalReaction;
  final String? autoThought;
  final String? childhoodMemory;
  final String? patternRecognition;
  final List<int> tagIds;

  DiaryCreateRequest({
    required this.triggerEvent,
    required this.immediateEmotion,
    required this.emotionIntensity,
    this.physicalReaction,
    this.autoThought,
    this.childhoodMemory,
    this.patternRecognition,
    this.tagIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'trigger_event': triggerEvent,
      'immediate_emotion': immediateEmotion,
      'emotion_intensity': emotionIntensity,
      'physical_reaction': physicalReaction,
      'auto_thought': autoThought,
      'childhood_memory': childhoodMemory,
      'pattern_recognition': patternRecognition,
      'tag_ids': tagIds,
    };
  }
}
