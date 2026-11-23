import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/assignment_provider.dart';
import '../providers/course_provider.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/main_drawer.dart';
import 'assignments_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
      context.read<AssignmentProvider>().fetchAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final courseProvider = context.watch<CourseProvider>();
    final assignmentProvider = context.watch<AssignmentProvider>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      drawer: const MainDrawer(currentRoute: 'courses'),
      appBar: AppBar(
        title: Text(l10n.courses),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => courseProvider.fetchCourses(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => courseProvider.fetchCourses(),
        child: courseProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : courseProvider.courses.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.school_outlined,
                    title: 'لا توجد مقررات دراسية',
                    subtitle: 'لم يتم تسجيل أي مقررات لهذه الدفعة الأكاديمية بعد.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: courseProvider.courses.length,
                    itemBuilder: (context, index) {
                      final c = courseProvider.courses[index];
                      final courseAssignments = assignmentProvider.assignments.where((a) => a.courseId == c.id).toList();

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Filter assignments by this course
                            context.read<AssignmentProvider>().setCourseFilter(c.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AssignmentsScreen()),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E56A0).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        c.code,
                                        style: const TextStyle(
                                          color: Color(0xFF1E56A0),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${courseAssignments.length} تكاليف',
                                        style: TextStyle(fontSize: 11, color: Colors.blue.shade800, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  c.localizedName(isAr ? 'ar' : 'en'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.person_pin, size: 16, color: Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(
                                      c.doctorName,
                                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
