import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/main_drawer.dart';
import 'announcements_screen.dart';
import 'create_assignment_screen.dart';

class RepresentativeDashboardScreen extends StatefulWidget {
  const RepresentativeDashboardScreen({super.key});

  @override
  State<RepresentativeDashboardScreen> createState() => _RepresentativeDashboardScreenState();
}

class _RepresentativeDashboardScreenState extends State<RepresentativeDashboardScreen> {
  int _totalAssignments = 0;
  int _totalAnnouncements = 0;
  List<dynamic> _upcoming = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRepStats();
  }

  Future<void> _loadRepStats() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get(ApiEndpoints.representativeDashboard);
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _totalAssignments = res.data['totalPublishedAssignments'] as int? ?? 0;
          _totalAnnouncements = res.data['totalAnnouncements'] as int? ?? 0;
          _upcoming = res.data['upcomingAssignments'] as List<dynamic>? ?? [];
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      drawer: const MainDrawer(currentRoute: 'rep_hub'),
      appBar: AppBar(
        title: Text(l10n.repDashboard),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRepStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Representative Info Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E56A0), Color(0xFF163172)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.star, color: Colors.amber, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.fullName ?? '',
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'مندوب معتمد - ${user?.cohortName ?? ""}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'لديك صلاحية نشر التكاليف الأكاديمية والإعلانات وإشعار طلاب دفعتك مباشرة.',
                            style: TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Quick Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.add_task),
                            label: Text(l10n.createAssignment),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
                              ).then((_) => _loadRepStats());
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            icon: const Icon(Icons.campaign),
                            label: Text(l10n.createAnnouncement),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AnnouncementsScreen()),
                              ).then((_) => _loadRepStats());
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Metrics
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(Icons.assignment_turned_in, size: 32, color: Colors.blue.shade700),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_totalAssignments',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('تكاليف منشورة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(Icons.announcement, size: 32, color: Colors.indigo.shade700),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$_totalAnnouncements',
                                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('إعلانات منشورة', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent Active Tasks
                    const Text(
                      'التكاليف النشطة قيد المتابعة للدفعة:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    if (_upcoming.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('لا توجد تكاليف نشطة حالياً.', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _upcoming.length,
                        itemBuilder: (context, index) {
                          final item = _upcoming[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.assignment, color: Color(0xFF1E56A0)),
                              title: Text(item['title'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(item['courseName'] as String? ?? ''),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
