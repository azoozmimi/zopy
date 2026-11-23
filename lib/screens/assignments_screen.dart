import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/assignment_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/course_provider.dart';
import '../widgets/assignment_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/main_drawer.dart';
import 'assignment_detail_screen.dart';
import 'create_assignment_screen.dart';

class AssignmentsScreen extends StatefulWidget {
  final String? initialFilter;

  const AssignmentsScreen({super.key, this.initialFilter});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialFilter != null) {
        context.read<AssignmentProvider>().setFilter(widget.initialFilter!);
      } else {
        context.read<AssignmentProvider>().fetchAssignments();
      }
      context.read<CourseProvider>().fetchCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final assignmentProvider = context.watch<AssignmentProvider>();
    final courseProvider = context.watch<CourseProvider>();
    final auth = context.watch<AuthProvider>();
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final filters = [
      {'key': 'all', 'label': l10n.filterAll},
      {'key': 'new', 'label': l10n.filterNew},
      {'key': 'in_progress', 'label': l10n.filterInProgress},
      {'key': 'completed', 'label': l10n.filterCompleted},
      {'key': 'overdue', 'label': l10n.filterOverdue},
    ];

    return Scaffold(
      drawer: const MainDrawer(currentRoute: 'assignments'),
      appBar: AppBar(
        title: Text(l10n.assignments),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => assignmentProvider.fetchAssignments(),
          ),
        ],
      ),
      floatingActionButton: auth.user?.isRepresentative == true
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.createAssignment),
            )
          : null,
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              assignmentProvider.setSearchQuery('');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (val) => assignmentProvider.setSearchQuery(val),
                ),
                const SizedBox(height: 10),

                // Course Dropdown Selector
                if (courseProvider.courses.isNotEmpty)
                  DropdownButtonFormField<int?>(
                    value: assignmentProvider.selectedCourseId,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text(l10n.allCourses),
                      ),
                      ...courseProvider.courses.map(
                        (c) => DropdownMenuItem<int?>(
                          value: c.id,
                          child: Text('${c.code} - ${c.localizedName(isAr ? 'ar' : 'en')}'),
                        ),
                      ),
                    ],
                    onChanged: (val) => assignmentProvider.setCourseFilter(val),
                  ),
              ],
            ),
          ),

          // Filter Chips Row
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final f = filters[index];
                final isSelected = assignmentProvider.filter == f['key'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(f['label']!),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    selectedColor: Theme.of(context).colorScheme.primary,
                    onSelected: (_) => assignmentProvider.setFilter(f['key']!),
                  ),
                );
              },
            ),
          ),

          // Assignment List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => assignmentProvider.fetchAssignments(),
              child: assignmentProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : assignmentProvider.assignments.isEmpty
                      ? EmptyStateWidget(
                          icon: Icons.assignment_turned_in_outlined,
                          title: 'لا توجد تكاليف مطابقة',
                          subtitle: 'لم يتم العثور على تكاليف دراسية وفق التصفية الحالية.',
                          buttonText: l10n.filterAll,
                          onButtonPressed: () => assignmentProvider.setFilter('all'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: assignmentProvider.assignments.length,
                          itemBuilder: (context, index) {
                            final a = assignmentProvider.assignments[index];
                            return AssignmentCard(
                              assignment: a,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AssignmentDetailScreen(assignmentId: a.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
