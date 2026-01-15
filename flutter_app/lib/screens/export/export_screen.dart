import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  Map<String, dynamic>? _weeklyReport;
  Map<String, dynamic>? _monthlyReport;
  bool _isLoadingWeekly = false;
  bool _isLoadingMonthly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据导出'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExportSection(),
          const SizedBox(height: 24),
          _buildReportSection(),
        ],
      ),
    );
  }

  Widget _buildExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '导出数据',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.file_download, color: Colors.blue),
                title: const Text('导出为 JSON'),
                subtitle: const Text('适合程序处理和备份'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showExportDialog('json'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('导出为 CSV'),
                subtitle: const Text('可用Excel打开'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showExportDialog('csv'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '报告查看',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.orange),
                title: const Text('周报告'),
                subtitle: const Text('最近7天数据分析'),
                trailing: _isLoadingWeekly
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _isLoadingWeekly ? null : () => _loadWeeklyReport(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.purple),
                title: const Text('月报告'),
                subtitle: const Text('最近30天数据分析'),
                trailing: _isLoadingMonthly
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _isLoadingMonthly ? null : () => _loadMonthlyReport(),
              ),
            ],
          ),
        ),
        if (_weeklyReport != null) ...[
          const SizedBox(height: 16),
          _buildReportCard('周报告', _weeklyReport!),
        ],
        if (_monthlyReport != null) ...[
          const SizedBox(height: 16),
          _buildReportCard('月报告', _monthlyReport!),
        ],
      ],
    );
  }

  Widget _buildReportCard(String title, Map<String, dynamic> report) {
    final summary = report['summary'] as Map<String, dynamic>;
    final insights = report['insights'] as List<dynamic>;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${report['start_date']} ~ ${report['end_date']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    '日记数',
                    summary['total_diaries'].toString(),
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    '平均强度',
                    summary['avg_emotion_intensity'].toString(),
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    '挑战数',
                    summary['total_challenges'].toString(),
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    '已完成',
                    summary['completed_challenges'].toString(),
                    Colors.green,
                  ),
                ),
              ],
            ),
            if (insights.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                '洞察建议',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...insights.map((insight) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            insight as String,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
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
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Future<void> _showExportDialog(String format) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('导出为 ${format.toUpperCase()}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('将在浏览器中打开下载链接'),
            const SizedBox(height: 16),
            Text(
              '提示：由于浏览器安全限制，请在新标签页中复制以下URL并添加Authorization头：',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: SelectableText(
                'Bearer $token',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              final url = format == 'json'
                  ? '${ApiConfig.baseUrl}${ApiConfig.exportDiariesJson}'
                  : '${ApiConfig.baseUrl}${ApiConfig.exportDiariesCsv}';

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('导出URL: $url\n请使用API测试工具或浏览器扩展'),
                  duration: const Duration(seconds: 5),
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadWeeklyReport() async {
    setState(() {
      _isLoadingWeekly = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.exportReportWeekly}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _weeklyReport = json.decode(utf8.decode(response.bodyBytes));
          _isLoadingWeekly = false;
        });
      } else {
        throw Exception('加载失败');
      }
    } catch (e) {
      setState(() {
        _isLoadingWeekly = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载周报告失败: $e')),
        );
      }
    }
  }

  Future<void> _loadMonthlyReport() async {
    setState(() {
      _isLoadingMonthly = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.exportReportMonthly}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _monthlyReport = json.decode(utf8.decode(response.bodyBytes));
          _isLoadingMonthly = false;
        });
      } else {
        throw Exception('加载失败');
      }
    } catch (e) {
      setState(() {
        _isLoadingMonthly = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载月报告失败: $e')),
        );
      }
    }
  }
}
