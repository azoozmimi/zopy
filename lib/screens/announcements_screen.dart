import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/announcement.dart';
import '../providers/announcement_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/main_drawer.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().fetchAnnouncements();
    });
  }

  void _showCreateAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    AnnouncementPriority selectedPriority = AnnouncementPriority.normal;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.createAnnouncement),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: l10n.announcementTitle),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: l10n.announcementContent),
                ),
                const SizedBox(height: 14),
                Text(l10n.priority, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<AnnouncementPriority>(
                  value: selectedPriority,
                  items: [
                    DropdownMenuItem(value: AnnouncementPriority.normal, child: Text(l10n.priorityNormal)),
                    DropdownMenuItem(value: AnnouncementPriority.important, child: Text(l10n.priorityImportant)),
                    DropdownMenuItem(value: AnnouncementPriority.urgent, child: Text(l10n.priorityUrgent)),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedPriority = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                final success = await context.read<AnnouncementProvider>().createAnnouncement(
                      title: titleController.text.trim(),
                      content: contentController.text.trim(),
                      priority: selectedPriority,
                    );
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نشر الإعلان بنجاح')),
                  );
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final announcementProvider = context.watch<AnnouncementProvider>();
    final auth = context.watch<AuthProvider>();
    final dateFormat = DateFormat('yyyy-MM-dd • hh:mm a');

    return Scaffold(
      drawer: const MainDrawer(currentRoute: 'announcements'),
      appBar: AppBar(
        title: Text(l10n.announcements),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => announcementProvider.fetchAnnouncements(),
          ),
        ],
      ),
      floatingActionButton: auth.user?.isRepresentative == true
          ? FloatingActionButton.extended(
              onPressed: _showCreateAnnouncementDialog,
              icon: const Icon(Icons.campaign),
              label: Text(l10n.createAnnouncement),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => announcementProvider.fetchAnnouncements(),
        child: announcementProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : announcementProvider.announcements.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.campaign_outlined,
                    title: l10n.noAnnouncements,
                    subtitle: 'لم يتم نشر أي إعلانات أكاديمية لهذه الدفعة بعد.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: announcementProvider.announcements.length,
                    itemBuilder: (context, index) {
                      final item = announcementProvider.announcements[index];

                      final priorityColor = item.priority == AnnouncementPriority.urgent
                          ? Colors.red
                          : (item.priority == AnnouncementPriority.important ? Colors.orange : Colors.blue);

                      final priorityLabel = item.priority == AnnouncementPriority.urgent
                          ? l10n.priorityUrgent
                          : (item.priority == AnnouncementPriority.important
                              ? l10n.priorityImportant
                              : l10n.priorityNormal);

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: priorityColor.withOpacity(0.3), width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: priorityColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      priorityLabel,
                                      style: TextStyle(
                                        color: priorityColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    dateFormat.format(item.publicationDateUtc.toLocal()),
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.content,
                                style: TextStyle(fontSize: 14, height: 1.4, color: Colors.grey.shade800),
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.blue.shade100,
                                        child: const Icon(Icons.person, size: 14, color: Colors.blue),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        item.createdByUserName,
                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                  if (auth.user?.isRepresentative == true && !item.isCancelled)
                                    TextButton.icon(
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      icon: const Icon(Icons.delete_outline, size: 16),
                                      label: Text(l10n.cancel, style: const TextStyle(fontSize: 12)),
                                      onPressed: () async {
                                        final success = await announcementProvider.cancelAnnouncement(item.id);
                                        if (mounted && success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('تم إلغاء الإعلان')),
                                          );
                                        }
                                      },
                                    ),
                                ],
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
