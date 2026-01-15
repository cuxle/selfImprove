import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/emotion_diary.dart';
import '../../providers/diary_provider.dart';
import '../../config/app_config.dart';
import 'diary_edit_screen.dart';

class DiaryDetailScreen extends StatelessWidget {
  final EmotionDiary diary;

  const DiaryDetailScreen({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('日记详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DiaryEditScreen(diary: diary),
                ),
              );

              // 如果编辑成功，重新加载日记列表
              if (result == true && context.mounted) {
                Provider.of<DiaryProvider>(context, listen: false).loadDiaries();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 情绪和强度卡片
            Card(
              color: AppConfig.getEmotionIntensityColor(diary.emotionIntensity)
                  .withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppConfig.getEmotionIntensityColor(
                            diary.emotionIntensity),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${diary.emotionIntensity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            diary.immediateEmotion,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(diary.createdAt),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 触发事件
            _buildSection(
              '触发事件',
              diary.triggerEvent,
              Icons.event,
            ),
            const SizedBox(height: 16),

            // 身体反应
            if (diary.physicalReaction != null &&
                diary.physicalReaction!.isNotEmpty)
              _buildSection(
                '身体反应',
                diary.physicalReaction!,
                Icons.favorite,
              ),
            if (diary.physicalReaction != null &&
                diary.physicalReaction!.isNotEmpty)
              const SizedBox(height: 16),

            // 自动化思维
            if (diary.autoThought != null && diary.autoThought!.isNotEmpty)
              _buildSection(
                '自动化思维',
                diary.autoThought!,
                Icons.psychology,
              ),
            if (diary.autoThought != null && diary.autoThought!.isNotEmpty)
              const SizedBox(height: 16),

            // 童年记忆
            if (diary.childhoodMemory != null &&
                diary.childhoodMemory!.isNotEmpty)
              _buildSection(
                '童年记忆联结',
                diary.childhoodMemory!,
                Icons.history_edu,
              ),
            if (diary.childhoodMemory != null &&
                diary.childhoodMemory!.isNotEmpty)
              const SizedBox(height: 16),

            // 模式识别
            if (diary.patternRecognition != null &&
                diary.patternRecognition!.isNotEmpty)
              _buildSection(
                '模式识别',
                diary.patternRecognition!,
                Icons.insights,
              ),
            if (diary.patternRecognition != null &&
                diary.patternRecognition!.isNotEmpty)
              const SizedBox(height: 16),

            // 标签
            if (diary.tags.isNotEmpty) ...[
              const Text(
                '标签',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: diary.tags.map((tag) {
                  return Chip(
                    label: Text(tag.tagName),
                    avatar: const Icon(Icons.label, size: 18),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF6B4EE6)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条日记吗？删除后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
      final success = await diaryProvider.deleteDiary(diary.id);

      if (success && context.mounted) {
        Navigator.of(context).pop(); // 返回列表页
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('日记已删除')),
        );
      } else if (diaryProvider.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(diaryProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
