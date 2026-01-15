import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/diary_provider.dart';
import '../../providers/tag_provider.dart';
import '../../models/emotion_diary.dart';
import '../../models/emotion_tag.dart';

class DiaryCreateScreen extends StatefulWidget {
  const DiaryCreateScreen({super.key});

  @override
  State<DiaryCreateScreen> createState() => _DiaryCreateScreenState();
}

class _DiaryCreateScreenState extends State<DiaryCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _triggerEventController = TextEditingController();
  final _emotionController = TextEditingController();
  final _physicalReactionController = TextEditingController();
  final _autoThoughtController = TextEditingController();
  final _childhoodMemoryController = TextEditingController();
  final _patternController = TextEditingController();

  double _emotionIntensity = 5;
  final Set<int> _selectedTagIds = {};

  @override
  void initState() {
    super.initState();
    // 加载标签列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TagProvider>(context, listen: false).loadTags();
    });
  }

  @override
  void dispose() {
    _triggerEventController.dispose();
    _emotionController.dispose();
    _physicalReactionController.dispose();
    _autoThoughtController.dispose();
    _childhoodMemoryController.dispose();
    _patternController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = DiaryCreateRequest(
      triggerEvent: _triggerEventController.text,
      immediateEmotion: _emotionController.text,
      emotionIntensity: _emotionIntensity.round(),
      physicalReaction: _physicalReactionController.text.isEmpty
          ? null
          : _physicalReactionController.text,
      autoThought: _autoThoughtController.text.isEmpty
          ? null
          : _autoThoughtController.text,
      childhoodMemory: _childhoodMemoryController.text.isEmpty
          ? null
          : _childhoodMemoryController.text,
      patternRecognition:
          _patternController.text.isEmpty ? null : _patternController.text,
      tagIds: _selectedTagIds.toList(),
    );

    final diaryProvider = Provider.of<DiaryProvider>(context, listen: false);
    final success = await diaryProvider.createDiary(request);

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日记创建成功')),
      );
    } else if (diaryProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(diaryProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录情绪日记'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 触发事件
            const Text(
              '触发事件',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _triggerEventController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '描述发生了什么事情...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请描述触发事件';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 即时情绪
            const Text(
              '即时情绪',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emotionController,
              decoration: const InputDecoration(
                hintText: '例如：愤怒、悲伤、焦虑...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入即时情绪';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 情绪强度
            const Text(
              '情绪强度',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _emotionIntensity,
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _emotionIntensity.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _emotionIntensity = value;
                      });
                    },
                  ),
                ),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(
                    '${_emotionIntensity.round()}/10',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 身体反应（可选）
            const Text(
              '身体反应（可选）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _physicalReactionController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: '例如：心跳加速、胃痛、紧张...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 自动化思维（可选）
            const Text(
              '自动化思维（可选）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _autoThoughtController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: '你脑海中立刻浮现的想法...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 童年记忆联结（可选）
            const Text(
              '童年记忆联结（可选）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _childhoodMemoryController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: '这让你想起了什么童年经历...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 模式识别（可选）
            const Text(
              '模式识别（可选）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _patternController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: '你是否发现类似的情绪模式...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // 标签选择（可选）
            const Text(
              '添加标签（可选）',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Consumer<TagProvider>(
              builder: (context, tagProvider, child) {
                if (tagProvider.tags.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '暂无标签，请先在"我的"-"标签管理"中创建标签',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tagProvider.tags.map((tag) {
                    final isSelected = _selectedTagIds.contains(tag.id);
                    return FilterChip(
                      label: Text(tag.tagName),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTagIds.add(tag.id);
                          } else {
                            _selectedTagIds.remove(tag.id);
                          }
                        });
                      },
                      selectedColor: const Color(0xFF6B4EE6).withOpacity(0.3),
                      checkmarkColor: const Color(0xFF6B4EE6),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 32),

            // 提交按钮
            Consumer<DiaryProvider>(
              builder: (context, diaryProvider, child) {
                return ElevatedButton(
                  onPressed: diaryProvider.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF6B4EE6),
                    foregroundColor: Colors.white,
                  ),
                  child: diaryProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '保存日记',
                          style: TextStyle(fontSize: 16),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
