class EmotionTag {
  final int id;
  final String tagName;
  final String tagType;
  final DateTime? createdAt; // 改为可选

  EmotionTag({
    required this.id,
    required this.tagName,
    required this.tagType,
    this.createdAt, // 可选参数
  });

  factory EmotionTag.fromJson(Map<String, dynamic> json) {
    return EmotionTag(
      id: json['id'] as int,
      tagName: json['tag_name'] as String,
      tagType: json['tag_type'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tag_name': tagName,
      'tag_type': tagType,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

class TagCreateRequest {
  final String tagName;
  final String tagType;

  TagCreateRequest({
    required this.tagName,
    required this.tagType,
  });

  Map<String, dynamic> toJson() {
    return {
      'tag_name': tagName,
      'tag_type': tagType,
    };
  }
}
