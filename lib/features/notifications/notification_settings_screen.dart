import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/riverpod/providers.dart';

/// Notification settings screen
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsNotifierProvider.notifier).loadPreferences();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(notificationsNotifierProvider);
    final preferences = provider.preferences;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки уведомлений'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Push notifications section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Push-уведомления',
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              'Получайте уведомления на устройство',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isLoading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Switch(
                          value: preferences?.pushEnabled ?? true,
                          onChanged: (value) => _updatePushEnabled(value),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Notification types info
          Text(
            'Типы уведомлений',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          _buildInfoCard(
            icon: Icons.check_circle,
            color: Colors.green,
            title: 'Контроль качества',
            description: 'Уведомления о завершённых проверках QC',
          ),

          _buildInfoCard(
            icon: Icons.bug_report,
            color: Colors.red,
            title: 'Дефекты',
            description: 'Уведомления о новых и назначенных дефектах',
          ),

          _buildInfoCard(
            icon: Icons.assignment,
            color: Colors.blue,
            title: 'Задачи',
            description: 'Уведомления о назначенных и выполненных задачах',
          ),

          _buildInfoCard(
            icon: Icons.schedule,
            color: Colors.orange,
            title: 'Дедлайны',
            description: 'Напоминания о сроках заказов',
          ),

          _buildInfoCard(
            icon: Icons.payment,
            color: Colors.purple,
            title: 'Подписка',
            description: 'Уведомления о пробном периоде и подписке',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title),
        subtitle: Text(
          description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ),
    );
  }

  Future<void> _updatePushEnabled(bool enabled) async {
    setState(() => _isLoading = true);

    try {
      await ref.read(notificationsNotifierProvider.notifier).updatePushEnabled(enabled);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'Push-уведомления включены'
                  : 'Push-уведомления отключены',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
