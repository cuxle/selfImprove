import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/challenge_provider.dart';
import '../../config/app_config.dart';
import 'challenge_create_screen.dart';
import 'challenge_detail_screen.dart';

class ChallengeListScreen extends StatelessWidget {
  const ChallengeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新回应挑战'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ChallengeProvider>(context, listen: false)
                  .loadChallenges();
            },
          ),
        ],
      ),
      body: Consumer<ChallengeProvider>(
        builder: (context, challengeProvider, child) {
          if (challengeProvider.isLoading &&
              challengeProvider.challenges.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (challengeProvider.challenges.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '还没有挑战',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击右下角按钮创建挑战',
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
            onRefresh: () => challengeProvider.loadChallenges(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 计划中的挑战
                _buildSection(
                  context,
                  '计划中',
                  challengeProvider.getChallengesByStatus('planned'),
                ),
                const SizedBox(height: 16),

                // 进行中的挑战
                _buildSection(
                  context,
                  '进行中',
                  challengeProvider.getChallengesByStatus('in_progress'),
                ),
                const SizedBox(height: 16),

                // 已完成的挑战
                _buildSection(
                  context,
                  '已完成',
                  challengeProvider.getChallengesByStatus('completed'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ChallengeCreateScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF6B4EE6),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List challenges) {
    if (challenges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            '$title (${challenges.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...challenges.map((challenge) {
          final dateFormat = DateFormat('yyyy-MM-dd');
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChallengeDetailScreen(challenge: challenge),
                  ),
                );
              },
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppConfig.getChallengeDifficultyColor(
                                    challenge.difficultyLevel)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '难度 ${challenge.difficultyLevel}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppConfig.getChallengeDifficultyColor(
                                  challenge.difficultyLevel),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.arrow_back, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            challenge.oldResponse,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.arrow_forward,
                            size: 16, color: Color(0xFF6B4EE6)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            challenge.newResponse,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B4EE6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '创建于 ${dateFormat.format(challenge.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (challenge.attempts.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                size: 16, color: Colors.green[600]),
                            const SizedBox(width: 4),
                            Text(
                              '已尝试 ${challenge.attempts.length} 次',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
