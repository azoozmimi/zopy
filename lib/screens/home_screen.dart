import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../models/dashboard_stats.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/assignment_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/main_drawer.dart';
import 'assignment_detail_screen.dart';
import 'assignments_screen.dart';
import 'calendar_screen.dart';
import 'courses_screen.dart';
import 'files_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    context.read<NotificationProvider>().fetchUnreadCount();
  }

  Future<void> _loadDashboard() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get(ApiEndpoints.studentDashboard);
      if (res.statusCode == 200) {
        if (mounted) {
          setState(() {
            _stats = DashboardStats.fromJson(res.data);
            _isLoading = false;
          });
        }
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final user = auth.user;

    return Scaffold(
      drawer: const MainDrawer(currentRoute: 'home'),
      appBar: AppBar(
        title: const Text('usitask'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ).then((_) => _loadDashboard());
                },
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${notifProvider.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color ?? Colors.white,
                        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${l10n.welcome}، ${user?.fullName ?? ''}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.cohortName ?? 'دفعة تكنولوجيا المعلومات',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quick Stats Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: l10n.pendingTasks,
                              count: _stats?.totalPendingAssignments ?? 0,
                              icon: Icons.pending_actions,
                              color: const Color(0xFF1E56A0),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AssignmentsScreen(initialFilter: 'all')),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: l10n.dueSoon,
                              count: _stats?.dueSoonAssignments ?? 0,
                              icon: Icons.hourglass_top_rounded,
                              color: Colors.orange.shade800,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AssignmentsScreen(initialFilter: 'in_progress')),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildMetricCard(
                              title: l10n.overdue,
                              count: _stats?.overdueAssignments ?? 0,
                              icon: Icons.warning_amber_rounded,
                              color: Colors.red.shade700,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AssignmentsScreen(initialFilter: 'overdue')),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMetricCard(
                              title: l10n.completed,
                              count: _stats?.totalCompletedAssignments ?? 0,
                              icon: Icons.check_circle_outline,
                              color: Colors.green.shade700,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AssignmentsScreen(initialFilter: 'completed')),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quick Navigation Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickActionButton(
                            icon: Icons.school,
                            label: l10n.courses,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesScreen())),
                          ),
                          _buildQuickActionButton(
                            icon: Icons.calendar_month,
                            label: l10n.calendar,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen())),
                          ),
                          _buildQuickActionButton(
                            icon: Icons.folder,
                            label: l10n.files,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilesScreen())),
                          ),
                          _buildQuickActionButton(
                            icon: Icons.assignment,
                            label: l10n.assignments,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentsScreen())),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Upcoming Deadlines Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.upcomingDeadlines,
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AssignmentsScreen()),
                            ),
                            child: Text(l10n.filterAll),
                          ),
                        ],
                      ),
                    ),

                    if (_stats == null || _stats!.upcomingAssignments.isEmpty)
                      EmptyStateWidget(
                        icon: Icons.task_alt,
                        title: l10n.noUpcomingAssignments,
                        subtitle: 'أحسنت! لا توجد أي تكاليف مستحقة حالياً.',
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _stats!.upcomingAssignments.length,
                        itemBuilder: (context, index) {
                          final a = _stats!.upcomingAssignments[index];
                          return AssignmentCard(
                            assignment: a,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => AssignmentDetailScreen(assignmentId: a.id)),
                              ).then((_) => _loadDashboard());
                            },
                          );
                        },
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
