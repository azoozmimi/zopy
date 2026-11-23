import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/assignment.dart';
import 'countdown_timer_widget.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onTap;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final courseName = isAr ? assignment.courseNameAr : assignment.courseNameEn;

    final isSubmitted = assignment.isSubmitted;
    final isSubmissionLate = assignment.isSubmissionLate;

    final statusColor = isSubmitted
        ? (isSubmissionLate ? Colors.orange : Colors.green)
        : (assignment.userStatus == AssignmentStatusType.completed
            ? Colors.green
            : (assignment.userStatus == AssignmentStatusType.inProgress ? Colors.orange : Colors.grey));

    final statusText = isSubmitted
        ? (isSubmissionLate ? l10n.submittedLate : l10n.submittedOnTime)
        : (assignment.userStatus == AssignmentStatusType.completed
            ? l10n.statusCompleted
            : (assignment.userStatus == AssignmentStatusType.inProgress ? l10n.statusInProgress : l10n.statusNotStarted));

    final dateFormat = DateFormat('yyyy-MM-dd • hh:mm a');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: assignment.isCancelled
              ? Colors.red.shade200
              : (assignment.isOverdue ? Colors.red.shade100 : Colors.grey.shade200),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Chip and Urgency
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${assignment.courseCode} • $courseName',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (assignment.isCancelled)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(color: Colors.red.shade900, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    CountdownTimerWidget(
                      deadlineUtc: assignment.deadlineUtc,
                      isCompleted: assignment.userStatus == AssignmentStatusType.completed,
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                assignment.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              if (assignment.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  assignment.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
              const SizedBox(height: 14),

              const Divider(height: 1, thickness: 0.5),
              const SizedBox(height: 10),

              // Footer: Deadline and Personal Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(assignment.deadlineUtc.toLocal()),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(radius: 3.5, backgroundColor: statusColor),
                        const SizedBox(width: 5),
                        Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
