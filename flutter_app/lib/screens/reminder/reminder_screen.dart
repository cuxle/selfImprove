import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reminder_provider.dart';
import '../../services/reminder_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReminderProvider>(context, listen: false).loadReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('提醒设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ReminderProvider>(context, listen: false).loadReminders();
            },
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, reminderProvider, child) {
          if (reminderProvider.isLoading && reminderProvider.reminders.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reminderProvider.reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    '还没有设置提醒',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击右下角按钮创建提醒',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => reminderProvider.loadReminders(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reminderProvider.reminders.length,
              itemBuilder: (context, index) {
                final reminder = reminderProvider.reminders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getReminderTypeColor(reminder.reminderType),
                      child: Icon(
                        _getReminderTypeIcon(reminder.reminderType),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      _getReminderTypeText(reminder.reminderType),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('时间: ${reminder.reminderTime}'),
                        Text('频率: ${_getFrequencyText(reminder.frequency)}'),
                        if (reminder.message != null)
                          Text('消息: ${reminder.message}', maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: reminder.isEnabled,
                          onChanged: (value) async {
                            await reminderProvider.toggleReminder(reminder.id, value);
                          },
                        ),
                        PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('编辑'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('删除', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditReminderDialog(context, reminder);
                            } else if (value == 'delete') {
                              _showDeleteDialog(context, reminder);
                            }
                          },
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateReminderDialog(context),
        backgroundColor: const Color(0xFF6B4EE6),
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getReminderTypeColor(String type) {
    return type == 'diary' ? Colors.blue : Colors.orange;
  }

  IconData _getReminderTypeIcon(String type) {
    return type == 'diary' ? Icons.book : Icons.flag;
  }

  String _getReminderTypeText(String type) {
    return type == 'diary' ? '日记提醒' : '挑战提醒';
  }

  String _getFrequencyText(String frequency) {
    switch (frequency) {
      case 'daily':
        return '每天';
      case 'weekly':
        return '每周';
      case 'custom':
        return '自定义';
      default:
        return frequency;
    }
  }

  Future<void> _showCreateReminderDialog(BuildContext context) async {
    String reminderType = 'diary';
    TimeOfDay selectedTime = TimeOfDay.now();
    String frequency = 'daily';
    final List<int> selectedDays = [];
    final messageController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('创建提醒'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('提醒类型'),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'diary', label: Text('日记'), icon: Icon(Icons.book)),
                    ButtonSegment(value: 'challenge', label: Text('挑战'), icon: Icon(Icons.flag)),
                  ],
                  selected: {reminderType},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      reminderType = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('提醒时间'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('重复频率'),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'daily', label: Text('每天')),
                    ButtonSegment(value: 'weekly', label: Text('每周')),
                  ],
                  selected: {frequency},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      frequency = newSelection.first;
                    });
                  },
                ),
                if (frequency == 'weekly') ...[
                  const SizedBox(height: 16),
                  const Text('选择星期'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final dayNames = ['一', '二', '三', '四', '五', '六', '日'];
                      return FilterChip(
                        label: Text(dayNames[index]),
                        selected: selectedDays.contains(index),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDays.add(index);
                            } else {
                              selectedDays.remove(index);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: '自定义消息（可选）',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 200,
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
              onPressed: () {
                if (frequency == 'weekly' && selectedDays.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请选择至少一天')),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );

    if (result == true && context.mounted) {
      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
      final request = ReminderCreateRequest(
        reminderType: reminderType,
        reminderTime: '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
        frequency: frequency,
        daysOfWeek: frequency == 'weekly' ? selectedDays : null,
        message: messageController.text.isNotEmpty ? messageController.text : null,
      );

      final success = await reminderProvider.createReminder(request);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提醒创建成功')),
        );
      } else if (reminderProvider.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reminderProvider.error!), backgroundColor: Colors.red),
        );
      }
    }

    messageController.dispose();
  }

  Future<void> _showEditReminderDialog(BuildContext context, Reminder reminder) async {
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(reminder.reminderTime.split(':')[0]),
      minute: int.parse(reminder.reminderTime.split(':')[1]),
    );
    String frequency = reminder.frequency;
    final List<int> selectedDays = reminder.daysOfWeek?.toList() ?? [];
    final messageController = TextEditingController(text: reminder.message);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑提醒'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('提醒时间'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                const Text('重复频率'),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'daily', label: Text('每天')),
                    ButtonSegment(value: 'weekly', label: Text('每周')),
                  ],
                  selected: {frequency},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      frequency = newSelection.first;
                    });
                  },
                ),
                if (frequency == 'weekly') ...[
                  const SizedBox(height: 16),
                  const Text('选择星期'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final dayNames = ['一', '二', '三', '四', '五', '六', '日'];
                      return FilterChip(
                        label: Text(dayNames[index]),
                        selected: selectedDays.contains(index),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedDays.add(index);
                            } else {
                              selectedDays.remove(index);
                            }
                          });
                        },
                      );
                    }),
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: '自定义消息（可选）',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 200,
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
      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
      final updates = {
        'reminder_time': '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
        'frequency': frequency,
        if (frequency == 'weekly') 'days_of_week': selectedDays,
        if (messageController.text.isNotEmpty) 'message': messageController.text,
      };

      final success = await reminderProvider.updateReminder(reminder.id, updates);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提醒更新成功')),
        );
      } else if (reminderProvider.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reminderProvider.error!), backgroundColor: Colors.red),
        );
      }
    }

    messageController.dispose();
  }

  Future<void> _showDeleteDialog(BuildContext context, Reminder reminder) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除这个${_getReminderTypeText(reminder.reminderType)}吗？'),
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
      final reminderProvider = Provider.of<ReminderProvider>(context, listen: false);
      final success = await reminderProvider.deleteReminder(reminder.id);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('提醒已删除')),
        );
      } else if (reminderProvider.error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reminderProvider.error!), backgroundColor: Colors.red),
        );
      }
    }
  }
}
