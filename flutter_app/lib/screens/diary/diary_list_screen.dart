import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/diary_provider.dart';
import '../../providers/tag_provider.dart';
import '../../config/app_config.dart';
import 'diary_create_screen.dart';
import 'diary_detail_screen.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  int? _selectedTagId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TagProvider>(context, listen: false).loadTags();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('情绪日记'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showTagFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DiaryProvider>(context, listen: false)
                  .loadDiaries(tagId: _selectedTagId);
            },
          ),
        ],
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, child) {
          if (diaryProvider.isLoading && diaryProvider.diaries.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (diaryProvider.diaries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.book_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '还没有日记记录',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击右下角按钮开始记录',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => diaryProvider.loadDiaries(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: diaryProvider.diaries.length,
              itemBuilder: (context, index) {
                final diary = diaryProvider.diaries[index];
                final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DiaryDetailScreen(diary: diary),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppConfig.getEmotionIntensityColor(
                                      diary.emotionIntensity),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      diary.immediateEmotion,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateFormat.format(diary.createdAt),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${diary.emotionIntensity}/10',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppConfig.getEmotionIntensityColor(
                                      diary.emotionIntensity),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Content
                          Text(
                            diary.triggerEvent,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                          // Tags
                          if (diary.tags.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: diary.tags.take(3).map((tag) {
                                return Chip(
                                  label: Text(
                                    tag.tagName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DiaryCreateScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF6B4EE6),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showTagFilterDialog(BuildContext context) async {
    final tagProvider = Provider.of<TagProvider>(context, listen: false);
    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);

    final selectedTagId = await showDialog<int?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('按标签筛选'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('全部日记'),
                leading: Radio<int?>(
                  value: null,
                  groupValue: _selectedTagId,
                  onChanged: (value) {
                    Navigator.of(context).pop(value);
                  },
                ),
                onTap: () {
                  Navigator.of(context).pop(null);
                },
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tagProvider.tags.length,
                  itemBuilder: (context, index) {
                    final tag = tagProvider.tags[index];
                    return ListTile(
                      title: Text(tag.tagName),
                      subtitle: Text(_getTagTypeText(tag.tagType)),
                      leading: Radio<int?>(
                        value: tag.id,
                        groupValue: _selectedTagId,
                        onChanged: (value) {
                          Navigator.of(context).pop(value);
                        },
                      ),
                      onTap: () {
                        Navigator.of(context).pop(tag.id);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selectedTagId),
            child: const Text('取消'),
          ),
        ],
      ),
    );

    if (selectedTagId != _selectedTagId && context.mounted) {
      setState(() {
        _selectedTagId = selectedTagId;
      });
      await diaryProvider.loadDiaries(tagId: _selectedTagId);
    }
  }

  String _getTagTypeText(String type) {
    switch (type) {
      case 'emotion':
        return '情绪标签';
      case 'pattern':
        return '模式标签';
      case 'trigger':
        return '触发标签';
      default:
        return '未知类型';
    }
  }
}
