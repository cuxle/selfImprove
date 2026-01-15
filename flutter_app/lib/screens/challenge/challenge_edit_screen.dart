import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/challenge_provider.dart';
import '../../models/response_challenge.dart';

class ChallengeEditScreen extends StatefulWidget {
  final ResponseChallenge challenge;

  const ChallengeEditScreen({super.key, required this.challenge});

  @override
  State<ChallengeEditScreen> createState() => _ChallengeEditScreenState();
}

class _ChallengeEditScreenState extends State<ChallengeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _oldResponseController;
  late final TextEditingController _newResponseController;

  late int _difficultyLevel;

  @override
  void initState() {
    super.initState();
    // 预填充现有数据
    _titleController = TextEditingController(text: widget.challenge.challengeTitle);
    _oldResponseController = TextEditingController(text: widget.challenge.oldResponse);
    _newResponseController = TextEditingController(text: widget.challenge.newResponse);
    _difficultyLevel = widget.challenge.difficultyLevel;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _oldResponseController.dispose();
    _newResponseController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 构建更新数据
    final updates = <String, dynamic>{
      'challenge_title': _titleController.text,
      'old_response': _oldResponseController.text,
      'new_response': _newResponseController.text,
      'difficulty_level': _difficultyLevel,
    };

    final challengeProvider = Provider.of<ChallengeProvider>(context, listen: false);
    final success = await challengeProvider.updateChallenge(widget.challenge.id, updates);

    if (success && mounted) {
      Navigator.of(context).pop(true); // 返回 true 表示已更新
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('挑战已更新')),
      );
    } else if (challengeProvider.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(challengeProvider.error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑挑战'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 挑战标题
            const Text(
              '挑战标题',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: '例如：在团队会议上表达不同意见',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入挑战标题';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 旧的自动反应
            const Text(
              '旧的自动反应',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '你过去是如何反应的？',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _oldResponseController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '例如：保持沉默，不敢说出自己的想法',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请描述旧的反应方式';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 新的有意识回应
            const Text(
              '新的有意识回应',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '你希望如何回应？',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _newResponseController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '例如：平静地表达我的观点，即使与他人不同',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请描述新的回应方式';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 难度等级
            const Text(
              '难度等级',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '这个挑战对你来说有多难？',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _difficultyLevel.toDouble(),
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _getDifficultyLabel(_difficultyLevel),
                    onChanged: (value) {
                      setState(() {
                        _difficultyLevel = value.round();
                      });
                    },
                  ),
                ),
                Container(
                  width: 80,
                  alignment: Alignment.center,
                  child: Text(
                    _getDifficultyLabel(_difficultyLevel),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 提交按钮
            Consumer<ChallengeProvider>(
              builder: (context, challengeProvider, child) {
                return ElevatedButton(
                  onPressed: challengeProvider.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF6B4EE6),
                    foregroundColor: Colors.white,
                  ),
                  child: challengeProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '保存修改',
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

  String _getDifficultyLabel(int level) {
    switch (level) {
      case 1:
        return '很容易';
      case 2:
        return '容易';
      case 3:
        return '中等';
      case 4:
        return '困难';
      case 5:
        return '很困难';
      default:
        return '中等';
    }
  }
}
