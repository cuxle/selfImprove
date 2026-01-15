import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tag_provider.dart';
import '../../models/emotion_tag.dart';
import '../../services/tag_service.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  String? _selectedType;

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
        title: const Text('标签管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: '查看统计',
            onPressed: () => _showStatsDialog(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedType = value == 'all' ? null : value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('全部标签')),
              const PopupMenuItem(value: 'emotion', child: Text('情绪标签')),
              const PopupMenuItem(value: 'pattern', child: Text('模式标签')),
              const PopupMenuItem(value: 'trigger', child: Text('触发标签')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TagProvider>(context, listen: false).loadTags();
            },
          ),
        ],
      ),
      body: Consumer<TagProvider>(
        builder: (context, tagProvider, child) {
          if (tagProvider.isLoading && tagProvider.tags.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final displayTags = _selectedType == null
              ? tagProvider.tags
              : tagProvider.getTagsByType(_selectedType!);

          if (displayTags.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.label_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '还没有标签',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击右下角按钮创建标签',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => tagProvider.loadTags(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayTags.length,
              itemBuilder: (context, index) {
                final tag = displayTags[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getTagTypeColor(tag.tagType),
                      child: Icon(
                        _getTagTypeIcon(tag.tagType),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      tag.tagName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(_getTagTypeText(tag.tagType)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditTagDialog(context, tag),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          color: Colors.red,
                          onPressed: () => _showDeleteDialog(context, tag),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTagDialog(context),
        backgroundColor: const Color(0xFF6B4EE6),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getTagTypeColor(String type) {
    switch (type) {
      case 'emotion':
        return Colors.blue;
      case 'pattern':
        return Colors.orange;
      case 'trigger':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTagTypeIcon(String type) {
    switch (type) {
      case 'emotion':
        return Icons.mood;
      case 'pattern':
        return Icons.insights;
      case 'trigger':
        return Icons.bolt;
      default:
        return Icons.label;
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

  Future<void> _showCreateTagDialog(BuildContext context) async {
    final tagNameController = TextEditingController();
    String selectedType = 'emotion';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('创建标签'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: tagNameController,
                decoration: const InputDecoration(
                  labelText: '标签名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('标签类型', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'emotion',
                    label: Text('情绪'),
                    icon: Icon(Icons.mood),
                  ),
                  ButtonSegment(
                    value: 'pattern',
                    label: Text('模式'),
                    icon: Icon(Icons.insights),
                  ),
                  ButtonSegment(
                    value: 'trigger',
                    label: Text('触发'),
                    icon: Icon(Icons.bolt),
                  ),
                ],
                selected: {selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    selectedType = newSelection.first;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tagNameController.text.isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );

    if (result == true && context.mounted) {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      final request = TagCreateRequest(
        tagName: tagNameController.text,
        tagType: selectedType,
      );

      final success = await tagProvider.createTag(request);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('标签创建成功')),
        );
      } else if (tagProvider.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tagProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    tagNameController.dispose();
  }

  Future<void> _showEditTagDialog(
      BuildContext context, EmotionTag tag) async {
    final tagNameController = TextEditingController(text: tag.tagName);
    String selectedType = tag.tagType;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑标签'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: tagNameController,
                decoration: const InputDecoration(
                  labelText: '标签名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('标签类型', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'emotion',
                    label: Text('情绪'),
                    icon: Icon(Icons.mood),
                  ),
                  ButtonSegment(
                    value: 'pattern',
                    label: Text('模式'),
                    icon: Icon(Icons.insights),
                  ),
                  ButtonSegment(
                    value: 'trigger',
                    label: Text('触发'),
                    icon: Icon(Icons.bolt),
                  ),
                ],
                selected: {selectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    selectedType = newSelection.first;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tagNameController.text.isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    if (result == true && context.mounted) {
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      final updates = <String, dynamic>{
        'tag_name': tagNameController.text,
        'tag_type': selectedType,
      };

      final success = await tagProvider.updateTag(tag.id, updates);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('标签更新成功')),
        );
      } else if (tagProvider.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tagProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    tagNameController.dispose();
  }

  Future<void> _showDeleteDialog(
      BuildContext context, EmotionTag tag) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除标签"${tag.tagName}"吗？删除后无法恢复。'),
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
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      final success = await tagProvider.deleteTag(tag.id);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('标签已删除')),
        );
      } else if (tagProvider.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tagProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showStatsDialog(BuildContext context) async {
    final tagProvider = Provider.of<TagProvider>(context, listen: false);

    // 加载统计数据
    await tagProvider.loadTagStats();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('标签使用统计'),
        content: SizedBox(
          width: double.maxFinite,
          child: Consumer<TagProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (provider.tagStats.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('暂无统计数据'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: provider.tagStats.length,
                itemBuilder: (context, index) {
                  final stats = provider.tagStats[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getTagTypeColor(stats.tagType),
                      child: Text(
                        '${stats.usageCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(stats.tagName),
                    subtitle: Text(_getTagTypeText(stats.tagType)),
                    trailing: Text(
                      '${stats.usageCount} 次',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
