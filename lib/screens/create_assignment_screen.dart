import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/assignment.dart';
import '../providers/assignment_provider.dart';
import '../providers/course_provider.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final Assignment? assignmentToEdit;

  const CreateAssignmentScreen({super.key, this.assignmentToEdit});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedCourseId;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _externalLinksController = TextEditingController();
  final _changeReasonController = TextEditingController();
  final _customExtensionController = TextEditingController();

  DateTime _deadlineDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _deadlineTime = const TimeOfDay(hour: 23, minute: 59);
  bool _isPublished = true;
  bool _isSubmitting = false;

  // Submission Policy Settings
  final List<String> _availableExtensions = ['.pdf', '.docx', '.zip', '.rar', '.cs', '.py', '.txt', '.xlsx'];
  final Set<String> _selectedExtensions = {'.pdf', '.docx', '.zip'};
  int _maxFileSizeMB = 25;
  bool _allowReplacement = true;
  bool _allowLateSubmission = false;

  bool get isEditing => widget.assignmentToEdit != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
    });

    if (isEditing) {
      final a = widget.assignmentToEdit!;
      _selectedCourseId = a.courseId;
      _titleController.text = a.title;
      _descriptionController.text = a.description;
      _instructionsController.text = a.instructions;
      _externalLinksController.text = a.externalLinks ?? '';
      _isPublished = a.isPublished;
      _deadlineDate = a.deadlineUtc.toLocal();
      _deadlineTime = TimeOfDay(hour: _deadlineDate.hour, minute: _deadlineDate.minute);

      _maxFileSizeMB = a.maxFileSizeMB;
      _allowReplacement = a.allowReplacement;
      _allowLateSubmission = a.allowLateSubmission;

      _selectedExtensions.clear();
      final parsed = a.allowedExtensions.split(RegExp(r'[,; ]+')).map((e) => e.trim().toLowerCase()).where((e) => e.isNotEmpty);
      for (final ext in parsed) {
        final formatted = ext.startsWith('.') ? ext : '.$ext';
        _selectedExtensions.add(formatted);
        if (!_availableExtensions.contains(formatted)) {
          _availableExtensions.add(formatted);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructionsController.dispose();
    _externalLinksController.dispose();
    _changeReasonController.dispose();
    _customExtensionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadlineDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadlineDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _deadlineTime,
    );
    if (picked != null) {
      setState(() => _deadlineTime = picked);
    }
  }

  DateTime _getCombinedDeadlineUtc() {
    final dt = DateTime(
      _deadlineDate.year,
      _deadlineDate.month,
      _deadlineDate.day,
      _deadlineTime.hour,
      _deadlineTime.minute,
    );
    return dt.toUtc();
  }

  void _addCustomExtension() {
    var ext = _customExtensionController.text.trim().toLowerCase();
    if (ext.isEmpty) return;
    if (!ext.startsWith('.')) ext = '.$ext';

    setState(() {
      if (!_availableExtensions.contains(ext)) {
        _availableExtensions.add(ext);
      }
      _selectedExtensions.add(ext);
      _customExtensionController.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourseId == null && !isEditing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار المقرر الدراسي')),
      );
      return;
    }

    if (_selectedExtensions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تحديد امتداد ملف واحد على الأقل مسموح برَفعه')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final deadlineUtc = _getCombinedDeadlineUtc();
    final provider = context.read<AssignmentProvider>();
    final allowedExtString = _selectedExtensions.join(',');

    bool success;
    if (isEditing) {
      success = await provider.updateAssignment(
        id: widget.assignmentToEdit!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim(),
        deadlineUtc: deadlineUtc,
        externalLinks: _externalLinksController.text.trim().isEmpty ? null : _externalLinksController.text.trim(),
        isPublished: _isPublished,
        changeReason: _changeReasonController.text.trim().isEmpty ? null : _changeReasonController.text.trim(),
        allowedExtensions: allowedExtString,
        maxFileSizeMB: _maxFileSizeMB,
        allowReplacement: _allowReplacement,
        allowLateSubmission: _allowLateSubmission,
      );
    } else {
      success = await provider.createAssignment(
        courseId: _selectedCourseId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        instructions: _instructionsController.text.trim(),
        deadlineUtc: deadlineUtc,
        externalLinks: _externalLinksController.text.trim().isEmpty ? null : _externalLinksController.text.trim(),
        isPublished: _isPublished,
        allowedExtensions: allowedExtString,
        maxFileSizeMB: _maxFileSizeMB,
        allowReplacement: _allowReplacement,
        allowLateSubmission: _allowLateSubmission,
      );
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'تم تحديث التكليف بنجاح' : 'تم نشر التكليف وإشعار الطلاب بنجاح'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء حفظ التكليف'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final courseProvider = context.watch<CourseProvider>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editAssignment : l10n.createAssignment),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Course Selector
              if (!isEditing) ...[
                DropdownButtonFormField<int>(
                  value: _selectedCourseId,
                  decoration: InputDecoration(
                    labelText: l10n.selectCourse,
                    prefixIcon: const Icon(Icons.school_outlined),
                  ),
                  items: courseProvider.courses.map((c) {
                    return DropdownMenuItem<int>(
                      value: c.id,
                      child: Text('${c.code} - ${c.localizedName(isAr ? 'ar' : 'en')}'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCourseId = val),
                  validator: (val) => val == null ? l10n.fieldRequired : null,
                ),
                const SizedBox(height: 16),
              ],

              // Assignment Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: l10n.assignmentTitle,
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  prefixIcon: const Icon(Icons.short_text),
                ),
              ),
              const SizedBox(height: 16),

              // Instructions
              TextFormField(
                controller: _instructionsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.instructions,
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),

              // Deadline Pickers
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: Text('${l10n.selectDeadlineDate}: ${dateFormat.format(_deadlineDate)}'),
                      onPressed: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text('${l10n.selectDeadlineTime}: ${_deadlineTime.format(context)}'),
                      onPressed: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Submission Policy Card
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.upload_file, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            isAr ? 'إعدادات تسليم الطلاب' : 'Student Submission Policy',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Allowed Extensions Chips
                      Text(
                        l10n.allowedExtensions,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _availableExtensions.map((ext) {
                          final isSelected = _selectedExtensions.contains(ext);
                          return FilterChip(
                            label: Text(ext, style: const TextStyle(fontWeight: FontWeight.bold)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedExtensions.add(ext);
                                } else {
                                  _selectedExtensions.remove(ext);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Custom Extension input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customExtensionController,
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: isAr ? 'إضافة امتداد آخر (مثل .cs, .sql)' : 'Add custom ext (e.g. .cs, .sql)',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onSubmitted: (_) => _addCustomExtension(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.add),
                            tooltip: isAr ? 'إضافة' : 'Add',
                            onPressed: _addCustomExtension,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Max File Size Dropdown
                      DropdownButtonFormField<int>(
                        value: _maxFileSizeMB,
                        decoration: InputDecoration(
                          labelText: l10n.maxFileSize,
                          prefixIcon: const Icon(Icons.data_usage),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 5, child: Text('5 MB')),
                          DropdownMenuItem(value: 10, child: Text('10 MB')),
                          DropdownMenuItem(value: 25, child: Text('25 MB (افتراضي / Default)')),
                          DropdownMenuItem(value: 50, child: Text('50 MB')),
                          DropdownMenuItem(value: 100, child: Text('100 MB')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _maxFileSizeMB = val);
                        },
                      ),
                      const SizedBox(height: 12),

                      // Allow Replacement Switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _allowReplacement,
                        title: Text(l10n.allowReplacement),
                        subtitle: Text(
                          isAr ? 'تمكين الطالب من استبدال وتحديث الملف قبل الموعد النهائي' : 'Allow students to update/replace file before deadline',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onChanged: (val) => setState(() => _allowReplacement = val),
                      ),

                      // Allow Late Submission Switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _allowLateSubmission,
                        title: Text(l10n.allowLateSubmission),
                        subtitle: Text(
                          isAr ? 'قبول تسليم الواجبات بعد الموعد النهائي مع وسمها كمتأخرة' : 'Accept submissions after deadline and tag them as late',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onChanged: (val) => setState(() => _allowLateSubmission = val),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // External Links
              TextFormField(
                controller: _externalLinksController,
                decoration: InputDecoration(
                  labelText: '${l10n.externalLinks} (اختياري)',
                  hintText: 'https://...',
                  prefixIcon: const Icon(Icons.link),
                ),
              ),
              const SizedBox(height: 16),

              // Change Reason (if editing)
              if (isEditing) ...[
                TextFormField(
                  controller: _changeReasonController,
                  decoration: InputDecoration(
                    labelText: l10n.changeReason,
                    prefixIcon: const Icon(Icons.edit_notifications_outlined),
                    helperText: 'يتم إرسال هذا السبب للطلاب في حال تعديل الموعد',
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Publish Toggle
              SwitchListTile(
                value: _isPublished,
                title: Text(l10n.publishNow),
                subtitle: const Text('نشر التكليف فوراً للطلاب وإرسال الإشعارات'),
                onChanged: (val) => setState(() => _isPublished = val),
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
