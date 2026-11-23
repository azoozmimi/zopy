import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/countdown_timer_widget.dart';
import 'create_assignment_screen.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final int assignmentId;

  const AssignmentDetailScreen({super.key, required this.assignmentId});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  Assignment? _assignment;
  AssignmentSubmissionsStats? _submissionsStats;
  bool _isLoading = true;
  bool _isLoadingStats = false;

  // Student Submission Upload State
  File? _pickedFile;
  String? _pickedFileName;
  int _pickedFileSize = 0;
  final _submissionNotesController = TextEditingController();
  bool _isUploadingSubmission = false;

  // Downloading State
  String? _downloadingFileName;
  double _downloadProgress = 0.0;
  bool _isDownloadingZip = false;

  String _submissionsFilter = 'all'; // all, submitted, late

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _submissionNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    final provider = context.read<AssignmentProvider>();
    final auth = context.read<AuthProvider>();

    final assignment = await provider.fetchAssignmentDetails(widget.assignmentId);

    if (mounted) {
      setState(() {
        _assignment = assignment;
        _isLoading = false;
      });

      // If representative or admin, load submission statistics
      if (auth.user?.isRepresentative == true || auth.user?.isAdmin == true) {
        _loadSubmissionsStats();
      }
    }
  }

  Future<void> _loadSubmissionsStats() async {
    setState(() => _isLoadingStats = true);
    final provider = context.read<AssignmentProvider>();
    final stats = await provider.fetchSubmissionsStats(
      widget.assignmentId,
      statusFilter: _submissionsFilter == 'all' ? null : _submissionsFilter,
    );

    if (mounted) {
      setState(() {
        _submissionsStats = stats;
        _isLoadingStats = false;
      });
    }
  }

  // --- Student Pick & Validate File ---
  Future<void> _pickFile() async {
    if (_assignment == null) return;
    final a = _assignment!;

    // Parse allowed extensions
    final allowedExts = a.allowedExtensions
        .split(RegExp(r'[,; ]+'))
        .map((e) => e.trim().toLowerCase().replaceAll('.', ''))
        .where((e) => e.isNotEmpty)
        .toList();

    try {
      final result = await FilePicker.pickFiles(
        type: allowedExts.isNotEmpty ? FileType.custom : FileType.any,
        allowedExtensions: allowedExts.isNotEmpty ? allowedExts : null,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final file = File(path);
        final size = await file.length();
        final name = result.files.single.name;

        // Check file size
        final maxBytes = a.maxFileSizeMB * 1024 * 1024;
        if (size > maxBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('حجم الملف (${(size / (1024 * 1024)).toStringAsFixed(1)} ميجابايت) يتجاوز الحد الأقصى (${a.maxFileSizeMB} ميجابايت)'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        // Check extension
        final fileExt = name.contains('.') ? name.split('.').last.toLowerCase() : '';
        if (allowedExts.isNotEmpty && !allowedExts.contains(fileExt)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('امتداد الملف .$fileExt غير مسموح به. الامتدادات المقبولة: ${allowedExts.map((e) => '.$e').join(', ')}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _pickedFile = file;
          _pickedFileName = name;
          _pickedFileSize = size;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الملف: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Student Submit Assignment File ---
  Future<void> _submitAssignment() async {
    if (_pickedFile == null || _assignment == null) return;

    setState(() => _isUploadingSubmission = true);

    final error = await context.read<AssignmentProvider>().submitAssignmentFile(
          _assignment!.id,
          _pickedFile!,
          notes: _submissionNotesController.text,
        );

    if (mounted) {
      setState(() => _isUploadingSubmission = false);

      if (error == null) {
        setState(() {
          _pickedFile = null;
          _pickedFileName = null;
          _pickedFileSize = 0;
          _submissionNotesController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم تسليم الواجب بنجاح! تم حفظ الحل وتحديث الحالة.'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        await _loadDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Representative Download All as ZIP ---
  Future<void> _downloadAllSubmissionsZip() async {
    if (_assignment == null) return;
    final a = _assignment!;

    setState(() => _isDownloadingZip = true);

    try {
      final safeName = a.title.replaceAll(RegExp(r'[\\/:*?"<>| ]'), '_');
      final fileName = '${a.courseCode}_${safeName}_Submissions.zip';
      final url = ApiEndpoints.downloadSubmissionsZip(a.id);

      final file = await ApiService.downloadFile(
        url,
        fileName,
        onProgress: (rec, total) {
          if (total > 0 && mounted) {
            setState(() => _downloadProgress = rec / total);
          }
        },
      );

      if (mounted) {
        setState(() => _isDownloadingZip = false);
        if (file != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم تحميل ملف ZIP بنجاح في مجلد التطبيق:\n$fileName'),
              backgroundColor: Colors.green.shade700,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل تحميل ملف ZIP. تأكد من وجود تسليمات.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloadingZip = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء تحميل الحزمة: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Download Single File Helper ---
  Future<void> _downloadFile(String downloadUrl, String fileName) async {
    setState(() {
      _downloadingFileName = fileName;
      _downloadProgress = 0.0;
    });

    final file = await ApiService.downloadFile(
      downloadUrl,
      fileName,
      onProgress: (rec, total) {
        if (total > 0 && mounted) {
          setState(() {
            _downloadProgress = rec / total;
          });
        }
      },
    );

    if (mounted) {
      setState(() => _downloadingFileName = null);
      if (file != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تنزيل $fileName بنجاح في مجلد التطبيق'),
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

  Future<void> _cancelAssignmentDialog() async {
    final reasonController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.cancelAssignment),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.cancellationReason),
            const SizedBox(height: 8),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(hintText: 'سبب الإلغاء...'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirm == true && reasonController.text.trim().isNotEmpty && mounted) {
      final success = await context.read<AssignmentProvider>().cancelAssignment(
            widget.assignmentId,
            reasonController.text.trim(),
          );
      if (success) {
        await _loadDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إلغاء التكليف وإشعار الطلاب')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final dateFormat = DateFormat('yyyy-MM-dd • hh:mm a');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.assignmentDetails)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_assignment == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.assignmentDetails)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.retry),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _loadDetails, child: Text(l10n.refresh)),
            ],
          ),
        ),
      );
    }

    final a = _assignment!;
    final courseName = isAr ? a.courseNameAr : a.courseNameEn;
    final isRepOrAdmin = auth.user?.isRepresentative == true || auth.user?.isAdmin == true;
    final isDeadlinePassed = DateTime.now().toUtc().isAfter(a.deadlineUtc);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.assignmentDetails),
        actions: [
          if (auth.user?.isRepresentative == true && !a.isCancelled) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.edit,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateAssignmentScreen(assignmentToEdit: a),
                  ),
                ).then((_) => _loadDetails());
              },
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              tooltip: l10n.cancelAssignment,
              onPressed: _cancelAssignmentDialog,
            ),
          ],
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cancellation Notice
              if (a.isCancelled)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cancel, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.assignmentCancelledNotice,
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      if (a.cancellationReason != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${l10n.cancellationReason}: ${a.cancellationReason}',
                          style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),

              // Course Header
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.school, color: Theme.of(context).colorScheme.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              courseName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${a.courseCode} • ${a.doctorName}',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title & Deadline Countdown
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.remainingTime, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          CountdownTimerWidget(
                            deadlineUtc: a.deadlineUtc,
                            isCompleted: a.isSubmitted,
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(Icons.event, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            '${l10n.deadline}: ${dateFormat.format(a.deadlineUtc.toLocal())}',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            '${l10n.publishedBy}: ${a.createdByUserName}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Submission Policy summary badge chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.file_present, size: 16),
                            label: Text(a.allowedExtensions, style: const TextStyle(fontSize: 11)),
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            visualDensity: VisualDensity.compact,
                          ),
                          Chip(
                            avatar: const Icon(Icons.storage, size: 16),
                            label: Text('${a.maxFileSizeMB} MB', style: const TextStyle(fontSize: 11)),
                            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            visualDensity: VisualDensity.compact,
                          ),
                          if (a.allowLateSubmission)
                            const Chip(
                              avatar: Icon(Icons.schedule, size: 16, color: Colors.orange),
                              label: Text('يقبل التسليم المتأخر', style: TextStyle(fontSize: 11, color: Colors.orange)),
                              backgroundColor: Color(0xFFFFF3E0),
                              visualDensity: VisualDensity.compact,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==============================================================
              // SECTION 1: STUDENT SUBMISSION SECTION (OFFICIAL WORK SUBMISSION)
              // ==============================================================
              _buildStudentSubmissionSection(context, a, isAr, l10n, isDeadlinePassed),
              const SizedBox(height: 16),

              // ==============================================================
              // SECTION 2: REPRESENTATIVE & ADMIN MANAGEMENT SECTION
              // ==============================================================
              if (isRepOrAdmin) ...[
                _buildRepresentativeSection(context, a, isAr, l10n),
                const SizedBox(height: 16),
              ],

              // Instructions & Description
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.instructions,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      if (a.description.isNotEmpty) ...[
                        Text(
                          a.description,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        a.instructions.isNotEmpty ? a.instructions : 'يرجى مراجعة المقرر للمزيد من التفاصيل.',
                        style: TextStyle(fontSize: 14, height: 1.5, color: Colors.grey.shade800),
                      ),
                      if (a.externalLinks != null && a.externalLinks!.isNotEmpty) ...[
                        const Divider(height: 24),
                        Text(
                          l10n.externalLinks,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          a.externalLinks!,
                          style: const TextStyle(color: Colors.blue, fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Teacher / Representative Attachments
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${l10n.attachments} (${a.attachments.length})',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.attach_file, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (a.attachments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            l10n.noAttachments,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: a.attachments.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final att = a.attachments[index];
                            final isDownloading = _downloadingFileName == att.fileName;
                            final sizeMb = (att.fileSize / (1024 * 1024)).toStringAsFixed(2);

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.insert_drive_file, color: Colors.blue),
                              ),
                              title: Text(att.fileName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              subtitle: Text('$sizeMb MB', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              trailing: isDownloading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        value: _downloadProgress > 0 ? _downloadProgress : null,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : IconButton(
                                      icon: const Icon(Icons.download, color: Color(0xFF1E56A0)),
                                      onPressed: () => _downloadFile(att.downloadUrl, att.fileName),
                                    ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // WIDGET BUILDER: Student Official Submission Box
  // =========================================================================
  Widget _buildStudentSubmissionSection(
    BuildContext context,
    Assignment a,
    bool isAr,
    AppLocalizations l10n,
    bool isDeadlinePassed,
  ) {
    final sub = a.mySubmission;
    final isSubmitted = sub != null;
    final canReplace = isSubmitted && a.allowReplacement && (!isDeadlinePassed || a.allowLateSubmission);
    final canSubmitNew = !isSubmitted && (!isDeadlinePassed || a.allowLateSubmission);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSubmitted
              ? (sub.isLate ? Colors.orange.shade300 : Colors.green.shade400)
              : (isDeadlinePassed && !a.allowLateSubmission ? Colors.red.shade300 : Theme.of(context).colorScheme.primary.withOpacity(0.4)),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Icon + Title + Status Tag
            Row(
              children: [
                Icon(
                  isSubmitted ? Icons.check_circle : Icons.upload_file_outlined,
                  color: isSubmitted
                      ? (sub.isLate ? Colors.orange : Colors.green.shade700)
                      : (isDeadlinePassed && !a.allowLateSubmission ? Colors.red : Theme.of(context).colorScheme.primary),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr ? 'التسليم الرسمي للواجب' : 'Official Assignment Submission',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSubmitted
                        ? (sub.isLate ? Colors.orange.shade100 : Colors.green.shade100)
                        : (isDeadlinePassed && !a.allowLateSubmission ? Colors.red.shade100 : Colors.blue.shade50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isSubmitted
                        ? (sub.isLate ? l10n.submittedLate : l10n.submittedOnTime)
                        : (isDeadlinePassed && !a.allowLateSubmission ? l10n.submissionClosed : l10n.notSubmitted),
                    style: TextStyle(
                      color: isSubmitted
                          ? (sub.isLate ? Colors.orange.shade900 : Colors.green.shade900)
                          : (isDeadlinePassed && !a.allowLateSubmission ? Colors.red.shade900 : Colors.blue.shade900),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // SUBMITTED STATE
            if (isSubmitted) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sub.isLate ? Colors.orange.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.task_alt, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sub.formattedFileName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${isAr ? "الحجم:" : "Size:"} ${(sub.fileSize / (1024 * 1024)).toStringAsFixed(2)} MB  •  ${isAr ? "النسخة:" : "Revision:"} ${sub.version}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isAr ? "وقت التسليم:" : "Submitted at:"} ${DateFormat('yyyy-MM-dd • hh:mm a').format(sub.submittedAtUtc.toLocal())}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    ),
                    if (sub.studentNotes != null && sub.studentNotes!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${isAr ? "ملاحظتك:" : "Your note:"} ${sub.studentNotes}',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Button to download own submission
              OutlinedButton.icon(
                icon: const Icon(Icons.download, size: 18),
                label: Text(l10n.downloadMySubmission),
                onPressed: () => _downloadFile(sub.downloadUrl, sub.formattedFileName),
              ),
              const SizedBox(height: 8),
            ],

            // FILE UPLOAD FORM (For new submission or replacement)
            if (canSubmitNew || canReplace) ...[
              if (isSubmitted && canReplace)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 4),
                  child: Text(
                    isAr ? 'يمكنك استبدال الملف بنسخة أحدث قبل الموعد النهائي:' : 'You can upload an updated replacement file:',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),

              // File Selection Box
              InkWell(
                onTap: _isUploadingSubmission ? null : _pickFile,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _pickedFile != null ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _pickedFile != null ? Icons.file_present : Icons.add_circle_outline,
                        color: _pickedFile != null ? Theme.of(context).colorScheme.primary : Colors.grey.shade600,
                        size: 26,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pickedFileName ?? (isSubmitted ? l10n.replaceSubmissionFile : l10n.selectFile),
                              style: TextStyle(
                                fontWeight: _pickedFile != null ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_pickedFileSize > 0)
                              Text(
                                '${(_pickedFileSize / (1024 * 1024)).toStringAsFixed(2)} MB',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _isUploadingSubmission ? null : _pickFile,
                        child: Text(_pickedFile != null ? (isAr ? 'تغيير' : 'Change') : (isAr ? 'تصفح' : 'Browse')),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Optional Notes Text Field
              TextField(
                controller: _submissionNotesController,
                decoration: InputDecoration(
                  labelText: l10n.submissionNotes,
                  isDense: true,
                  prefixIcon: const Icon(Icons.note_alt_outlined, size: 20),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 14),

              // Submit Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                icon: _isUploadingSubmission
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(isSubmitted ? Icons.update : Icons.cloud_upload),
                label: Text(
                  _isUploadingSubmission
                      ? (isAr ? 'جارٍ الرفع والتسليم...' : 'Uploading...')
                      : (isSubmitted ? l10n.replaceSubmissionFile : l10n.submitAssignment),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: (_pickedFile == null || _isUploadingSubmission) ? null : _submitAssignment,
              ),
            ] else if (!isSubmitted && isDeadlinePassed && !a.allowLateSubmission) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'انتهى موعد التسليم الرسمي ولا يقبل هذا التكليف أي تسليمات متأخرة.'
                            : 'Submission deadline has passed and late submissions are closed.',
                        style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // WIDGET BUILDER: Representative / Doctor Submission Management
  // =========================================================================
  Widget _buildRepresentativeSection(
    BuildContext context,
    Assignment a,
    bool isAr,
    AppLocalizations l10n,
  ) {
    final stats = _submissionsStats;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.blue.shade300, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: Color(0xFF1E56A0), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isAr ? 'لوحة المندوب: إدارة وتجميع تسليمات الطلاب' : 'Representative: Submissions Management',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: l10n.refresh,
                  onPressed: _loadSubmissionsStats,
                ),
              ],
            ),
            const Divider(height: 20),

            if (_isLoadingStats) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (stats != null) ...[
              // Statistics 4-Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatMiniCard(
                      label: l10n.totalStudents,
                      count: stats.totalStudents,
                      color: Colors.blue,
                      icon: Icons.groups,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatMiniCard(
                      label: l10n.studentsSubmitted,
                      count: stats.submittedCount,
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatMiniCard(
                      label: l10n.studentsLate,
                      count: stats.lateCount,
                      color: Colors.orange,
                      icon: Icons.schedule,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatMiniCard(
                      label: l10n.studentsPending,
                      count: stats.pendingCount,
                      color: Colors.grey,
                      icon: Icons.pending_actions,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ZIP Download Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: const Color(0xFF1E56A0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isDownloadingZip
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.archive),
                label: Text(
                  _isDownloadingZip
                      ? (isAr ? 'جارٍ تجميع وتنزيل الحزمة (ZIP)...' : 'Packaging ZIP...')
                      : '${l10n.downloadSubmissionsZip} (${stats.submissions.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: (stats.submissions.isEmpty || _isDownloadingZip) ? null : _downloadAllSubmissionsZip,
              ),
              const SizedBox(height: 16),

              // Filter Chips (All, Submitted, Late)
              Row(
                children: [
                  Text(
                    '${l10n.submissionsList}:',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: Text(isAr ? 'الكل (${stats.submissions.length})' : 'All (${stats.submissions.length})'),
                    selected: _submissionsFilter == 'all',
                    onSelected: (val) {
                      if (val) {
                        setState(() => _submissionsFilter = 'all');
                        _loadSubmissionsStats();
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: Text(isAr ? 'في الموعد' : 'On Time'),
                    selected: _submissionsFilter == 'submitted',
                    onSelected: (val) {
                      if (val) {
                        setState(() => _submissionsFilter = 'submitted');
                        _loadSubmissionsStats();
                      }
                    },
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: Text(isAr ? 'متأخر' : 'Late'),
                    selected: _submissionsFilter == 'late',
                    onSelected: (val) {
                      if (val) {
                        setState(() => _submissionsFilter = 'late');
                        _loadSubmissionsStats();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Submissions List
              if (stats.submissions.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: Text(
                    l10n.noSubmissionsYet,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: stats.submissions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final s = stats.submissions[idx];
                    final isDownloadingThis = _downloadingFileName == s.formattedFileName;

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: s.isLate ? Colors.orange.shade100 : Colors.green.shade100,
                        child: Icon(
                          s.isLate ? Icons.timer_outlined : Icons.check,
                          color: s.isLate ? Colors.orange.shade800 : Colors.green.shade800,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        s.studentName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.studentId != null ? "${s.studentId} • " : ""}${s.formattedFileName}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${DateFormat('yyyy-MM-dd HH:mm').format(s.submittedAtUtc.toLocal())}  •  ${(s.fileSize / (1024 * 1024)).toStringAsFixed(2)} MB',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      trailing: isDownloadingThis
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : IconButton(
                              icon: const Icon(Icons.file_download, color: Color(0xFF1E56A0)),
                              tooltip: 'تحميل الحل',
                              onPressed: () => _downloadFile(s.downloadUrl, s.formattedFileName),
                            ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatMiniCard({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
