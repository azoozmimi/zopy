import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/notification_item.dart';
import '../providers/notification_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/main_drawer.dart';
import 'assignment_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.newAssignment:
        return Icons.assignment_add;
      case NotificationType.deadlineReminder:
        return Icons.alarm;
      case NotificationType.deadlineChange:
        return Icons.update;
      case NotificationType.cancellation:
        return Icons.cancel_outlined;
      case NotificationType.announcement:
        return Icons.campaign;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.newAssignment:
        return const Color(0xFF1E56A0);
      case NotificationType.deadlineReminder:
        return Colors.orange;
      case NotificationType.deadlineChange:
        return Colors.purple;
      case NotificationType.cancellation:
        return Colors.red;
      case NotificationType.announcement:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<NotificationProvider>();
    final dateFormat = DateFormat('yyyy-MM-dd • hh:mm a');

    return Scaffold(
      drawer: const MainDrawer(currentRoute: 'notifications'),
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          if (provider.unreadCount > 0)
            TextButton.icon(
              onPressed: () => provider.markAllAsRead(),
              icon: const Icon(Icons.done_all, size: 18),
              label: Text(l10n.markAllRead, style: const TextStyle(fontSize: 12)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.fetchNotifications(),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.notifications.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.notifications_off_outlined,
                    title: l10n.noNotifications,
                    subtitle: 'ستتلقى هنا إشعارات فورية بكل جديد يخص التكاليف والمواعيد.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.notifications.length,
                    itemBuilder: (context, index) {
                      final notif = provider.notifications[index];
                      final icon = _getIconForType(notif.type);
                      final color = _getColorForType(notif.type);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        color: notif.isRead ? null : color.withOpacity(0.04),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: notif.isRead ? Colors.grey.shade200 : color.withOpacity(0.4),
                            width: notif.isRead ? 1 : 1.5,
                          ),
                        ),
                        child: ListTile(
                          onTap: () {
                            if (!notif.isRead) provider.markAsRead(notif.id);
                            if (notif.referenceId != null && notif.type != NotificationType.announcement) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AssignmentDetailScreen(assignmentId: notif.referenceId!),
                                ),
                              );
                            }
                          },
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 22),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notif.title,
                                  style: TextStyle(
                                    fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (!notif.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notif.body, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                              const SizedBox(height: 6),
                              Text(
                                dateFormat.format(notif.createdAtUtc.toLocal()),
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
