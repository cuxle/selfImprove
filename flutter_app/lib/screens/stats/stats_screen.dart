import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/stats_provider.dart';
import '../../config/app_config.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StatsProvider>(context, listen: false).loadAllStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<StatsProvider>(context, listen: false).loadAllStats();
            },
          ),
        ],
      ),
      body: Consumer<StatsProvider>(
        builder: (context, statsProvider, child) {
          if (statsProvider.isLoading &&
              statsProvider.overview == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (statsProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    statsProvider.error!,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      statsProvider.loadAllStats();
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => statsProvider.loadAllStats(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewSection(statsProvider),
                  const SizedBox(height: 24),
                  _buildEmotionTrendSection(statsProvider),
                  const SizedBox(height: 24),
                  _buildIntensityDistributionSection(statsProvider),
                  const SizedBox(height: 24),
                  _buildChallengeStatsSection(statsProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverviewSection(StatsProvider provider) {
    final overview = provider.overview;
    if (overview == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '概览',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '总日记数',
                overview.totalDiaries.toString(),
                Icons.book,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '最近7天',
                overview.recentDiaries.toString(),
                Icons.calendar_today,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '平均强度',
                overview.avgEmotionIntensity.toStringAsFixed(1),
                Icons.trending_up,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '完成挑战',
                '${overview.completedChallenges}/${overview.totalChallenges}',
                Icons.emoji_events,
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionTrendSection(StatsProvider provider) {
    final trendData = provider.trendData;
    if (trendData == null || trendData.data.isEmpty) {
      return const SizedBox.shrink();
    }

    // 找出最大值用于归一化
    final maxIntensity = trendData.data
        .map((p) => p.avgIntensity)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '情绪趋势（最近30天）',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
          ),
          child: CustomPaint(
            size: Size.infinite,
            painter: TrendChartPainter(
              data: trendData.data,
              maxValue: maxIntensity,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntensityDistributionSection(StatsProvider provider) {
    final distribution = provider.intensityDistribution;
    if (distribution == null) return const SizedBox.shrink();

    final maxCount = distribution.distribution
        .map((d) => d.count)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '情绪强度分布',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '平均: ${distribution.avgIntensity.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: distribution.distribution.map((item) {
              final percentage =
                  maxCount > 0 ? (item.count / maxCount) : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${item.intensity}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: percentage,
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppConfig.getEmotionIntensityColor(
                                    item.intensity),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${item.count}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeStatsSection(StatsProvider provider) {
    final stats = provider.challengeStats;
    if (stats == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '挑战统计',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildChallengeStatRow(
                '总挑战数',
                stats.totalChallenges.toString(),
              ),
              const Divider(),
              _buildChallengeStatRow(
                '计划中',
                stats.statusDistribution['planned']?.toString() ?? '0',
              ),
              _buildChallengeStatRow(
                '进行中',
                stats.statusDistribution['in_progress']?.toString() ?? '0',
              ),
              _buildChallengeStatRow(
                '已完成',
                stats.statusDistribution['completed']?.toString() ?? '0',
              ),
              const Divider(),
              _buildChallengeStatRow(
                '尝试次数',
                stats.totalAttempts.toString(),
              ),
              _buildChallengeStatRow(
                '成功次数',
                stats.successfulAttempts.toString(),
              ),
              _buildChallengeStatRow(
                '成功率',
                '${stats.successRate.toStringAsFixed(1)}%',
                isHighlight: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeStatRow(String label, String value,
      {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isHighlight ? Colors.black : Colors.grey[700],
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 14,
              fontWeight: FontWeight.bold,
              color: isHighlight ? const Color(0xFF6B4EE6) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

/// 自定义折线图绘制器
class TrendChartPainter extends CustomPainter {
  final List<dynamic> data;
  final double maxValue;

  TrendChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF6B4EE6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFF6B4EE6)
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = <Offset>[];

    final stepX = size.width / (data.length - 1);
    final stepY = size.height / (maxValue > 0 ? maxValue : 10);

    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i].avgIntensity * stepY);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // 绘制点
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
