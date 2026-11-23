import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/main_drawer.dart';

class FilesScreen extends StatefulWidget {
  const FilesScreen({super.key});

  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  String? _downloadingFileName;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AssignmentProvider>().fetchAssignments();
    });
  }

  Future<void> _download(AssignmentAttachment att) async {
    setState(() {
      _downloadingFileName = att.fileName;
      _progress = 0.0;
    });

    final file = await ApiService.downloadFile(
      att.downloadUrl,
      att.fileName,
      onProgress: (rec, total) {
        if (total > 0 && mounted) {
          setState(() => _progress = rec / total);
        }
      },
    );

    if (mounted) {
      setState(() => _downloadingFileName = null);
      if (file != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تنزيل ${att.fileName} بنجاح'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تنزيل الملف'), backgroundColor: Colors.red),
        );
      }
    }
  }

  IconData _getFileIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'zip':
      case 'rar':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final assignmentProvider = context.watch<AssignmentProvider>();

    // Collect all attachments across assignments
    final allAttachments = <Map<String, dynamic>>[];
    for (final a in assignmentProvider.assignments) {
      for (final att in a.attachments) {
        allAttachments.add({
          'attachment': att,
          'assignmentTitle': a.title,
          'courseCode': a.courseCode,
        });
      }
    }

    return Scaffold(
      drawer: const MainDrawer(currentRoute: 'files'),
      appBar: AppBar(
        title: Text(l10n.files),
      ),
      body: RefreshIndicator(
        onRefresh: () => assignmentProvider.fetchAssignments(),
        child: allAttachments.isEmpty
            ? EmptyStateWidget(
                icon: Icons.folder_open_outlined,
                title: 'لا توجد مرفقات حالياً',
                subtitle: 'الملفات والمستندات المرفقة بالتكاليف ستظهر هنا تلقائياً لسهولة الوصول إليها.',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: allAttachments.length,
                itemBuilder: (context, index) {
                  final item = allAttachments[index];
                  final att = item['attachment'] as AssignmentAttachment;
                  final assignmentTitle = item['assignmentTitle'] as String;
                  final courseCode = item['courseCode'] as String;

                  final ext = att.fileName.contains('.') ? att.fileName.split('.').last : '';
                  final icon = _getFileIcon(ext);
                  final color = _getFileColor(ext);
                  final sizeMb = (att.fileSize / (1024 * 1024)).toStringAsFixed(2);
                  final isDownloading = _downloadingFileName == att.fileName;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: color, size: 28),
                      ),
                      title: Text(
                        att.fileName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            '$courseCode • $assignmentTitle',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                          Text(
                            '$sizeMb MB • ${ext.toUpperCase()}',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                      trailing: isDownloading
                          ? SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                value: _progress > 0 ? _progress : null,
                                strokeWidth: 2.5,
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.download_rounded, color: Color(0xFF1E56A0)),
                              onPressed: () => _download(att),
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
