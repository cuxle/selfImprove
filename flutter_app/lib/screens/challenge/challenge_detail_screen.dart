import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/response_challenge.dart';
import '../../providers/challenge_provider.dart';
import '../../config/app_config.dart';
import 'challenge_edit_screen.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final ResponseChallenge challenge;

  const ChallengeDetailScreen({super.key, required this.challenge});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 加载最新的挑战数据（包含尝试记录）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChallengeProvider>(context, listen: false)
          .loadChallenge(widget.challenge.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('挑战详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChallengeEditScreen(
                    challenge: widget.challenge,
                  ),
                ),
              );

              // 如果编辑成功，重新加载挑战详情
              if (result == true && context.mounted) {
                Provider.of<ChallengeProvider>(context, listen: false)
                    .loadChallenge(widget.challenge.id);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: Consumer<ChallengeProvider>(
        builder: (context, challengeProvider, child) {
          final challenge = challengeProvider.selectedChallenge ?? widget.challenge;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题和状态
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                challenge.challengeTitle,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppConfig.getChallengeStatusColor(challenge.status)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                AppConfig.getChallengeStatusText(challenge.status),
                                style: TextStyle(
                                  color: AppConfig.getChallengeStatusColor(challenge.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.flag, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '难度 ${challenge.difficultyLevel}/5',
                              style: TextStyle(
                                color: AppConfig.getChallengeDifficultyColor(
                                    challenge.difficultyLevel),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('yyyy-MM-dd').format(challenge.createdAt),
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 旧的反应
                _buildSection(
                  '旧的自动反应',
                  challenge.oldResponse,
                  Icons.arrow_back,
                  Colors.grey,
                ),
                const SizedBox(height: 16),

                // 新的回应
                _buildSection(
                  '新的有意识回应',
                  challenge.newResponse,
                  Icons.arrow_forward,
                  const Color(0xFF6B4EE6),
                ),
                const SizedBox(height: 24),

                // 尝试记录标题
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '尝试记录 (${challenge.attempts.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddAttemptDialog(context, challenge.id),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加记录'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 尝试记录列表
                if (challenge.attempts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            '还没有尝试记录',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...challenge.attempts.map((attempt) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  attempt.success
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: attempt.success
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('yyyy-MM-dd')
                                      .format(attempt.attemptDate),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: attempt.success
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    attempt.success ? '成功' : '未成功',
                                    style: TextStyle(
                                      color: attempt.success
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (attempt.notes != null &&
                                attempt.notes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                attempt.notes!,
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
                            if (attempt.emotionBefore != null ||
                                attempt.emotionAfter != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (attempt.emotionBefore != null) ...[
                                    const Icon(Icons.sentiment_dissatisfied,
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text(attempt.emotionBefore!),
                                    const SizedBox(width: 12),
                                  ],
                                  if (attempt.emotionAfter != null) ...[
                                    const Icon(Icons.sentiment_satisfied,
                                        size: 16),
                                    const SizedBox(width: 4),
                                    Text(attempt.emotionAfter!),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, String content, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
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
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Text(
            content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddAttemptDialog(BuildContext context, int challengeId) async {
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final notesController = TextEditingController();
    final emotionBeforeController = TextEditingController();
    final emotionAfterController = TextEditingController();
    bool success = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加尝试记录'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('执行结果'),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('成功'), icon: Icon(Icons.check_circle)),
                    ButtonSegment(value: false, label: Text('未成功'), icon: Icon(Icons.cancel)),
                  ],
                  selected: {success},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      success = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: '笔记（可选）',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emotionBeforeController,
                  decoration: const InputDecoration(
                    labelText: '尝试前情绪（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emotionAfterController,
                  decoration: const InputDecoration(
                    labelText: '尝试后情绪（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    if (result == true && context.mounted) {
      final challengeProvider =
          Provider.of<ChallengeProvider>(context, listen: false);

      final request = AttemptCreateRequest(
        attemptDate: DateTime.now(),
        success: success,
        notes: notesController.text.isEmpty ? null : notesController.text,
        emotionBefore: emotionBeforeController.text.isEmpty
            ? null
            : emotionBeforeController.text,
        emotionAfter: emotionAfterController.text.isEmpty
            ? null
            : emotionAfterController.text,
      );

      final addSuccess = await challengeProvider.addAttempt(challengeId, request);

      if (addSuccess && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('尝试记录已添加')),
        );
      } else if (challengeProvider.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(challengeProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    dateController.dispose();
    notesController.dispose();
    emotionBeforeController.dispose();
    emotionAfterController.dispose();
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个挑战吗？删除后无法恢复。'),
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
      final challengeProvider =
          Provider.of<ChallengeProvider>(context, listen: false);
      final success = await challengeProvider.deleteChallenge(widget.challenge.id);

      if (success && context.mounted) {
        Navigator.of(context).pop(); // 返回列表页
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('挑战已删除')),
        );
      } else if (challengeProvider.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(challengeProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
