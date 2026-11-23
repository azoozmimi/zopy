import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/main_drawer.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _users = [];
  List<dynamic> _hierarchy = [];
  List<dynamic> _auditLogs = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAdminData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    try {
      final resUsers = await ApiService.get(ApiEndpoints.adminUsers, queryParameters: {
        'search': _searchController.text.trim(),
      });
      final resHierarchy = await ApiService.get(ApiEndpoints.adminHierarchy);
      final resAudit = await ApiService.get(ApiEndpoints.adminAuditLogs);

      if (mounted) {
        setState(() {
          _users = resUsers.statusCode == 200 ? resUsers.data as List<dynamic> : [];
          _hierarchy = resHierarchy.statusCode == 200 ? resHierarchy.data as List<dynamic> : [];
          _auditLogs = resAudit.statusCode == 200 ? resAudit.data as List<dynamic> : [];
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _changeRoleDialog(int userId, String currentRole) async {
    String selectedRole = currentRole;
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.changeRole),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('طالب (Student)'),
                value: 'Student',
                groupValue: selectedRole,
                onChanged: (v) => setDialogState(() => selectedRole = v!),
              ),
              RadioListTile<String>(
                title: const Text('مندوب دفعة (Representative)'),
                value: 'Representative',
                groupValue: selectedRole,
                onChanged: (v) => setDialogState(() => selectedRole = v!),
              ),
              RadioListTile<String>(
                title: const Text('مدير نظام (Admin)'),
                value: 'Admin',
                groupValue: selectedRole,
                onChanged: (v) => setDialogState(() => selectedRole = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.save)),
          ],
        ),
      ),
    );

    if (confirm == true) {
      try {
        final res = await ApiService.post(
          ApiEndpoints.assignUserRole(userId),
          data: {'roleName': selectedRole},
        );
        if (res.statusCode == 200) {
          _loadAdminData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث دور المستخدم بنجاح')),
            );
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _toggleUserActive(int userId, bool currentStatus) async {
    try {
      final res = await ApiService.post(
        ApiEndpoints.updateUserStatus(userId),
        data: {'isActive': !currentStatus},
      );
      if (res.statusCode == 200) {
        _loadAdminData();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      drawer: const MainDrawer(currentRoute: 'admin'),
      appBar: AppBar(
        title: Text(l10n.admin),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.people_alt_outlined), text: l10n.userManagement),
            Tab(icon: const Icon(Icons.account_tree_outlined), text: l10n.academicHierarchy),
            Tab(icon: const Icon(Icons.history_outlined), text: l10n.auditLogs),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Users Management
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'بحث باسم المستخدم أو البريد...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadAdminData();
                            },
                          ),
                        ),
                        onSubmitted: (_) => _loadAdminData(),
                      ),
                    ),
                    Expanded(
                      child: _users.isEmpty
                          ? const Center(child: Text('لا يوجد مستخدمين مطابقين'))
                          : ListView.builder(
                              itemCount: _users.length,
                              itemBuilder: (context, index) {
                                final u = _users[index];
                                final isActive = u['isActive'] as bool? ?? true;
                                final role = u['role'] as String? ?? 'Student';

                                return Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isActive ? Colors.blue.shade100 : Colors.red.shade100,
                                      child: Icon(
                                        isActive ? Icons.person : Icons.person_off,
                                        color: isActive ? Colors.blue.shade800 : Colors.red.shade800,
                                      ),
                                    ),
                                    title: Text(u['fullName'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text('${u['email']} • $role\n${u['cohortName'] ?? ""}'),
                                    isThreeLine: true,
                                    trailing: PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'role') {
                                          _changeRoleDialog(u['id'] as int, role);
                                        } else if (val == 'status') {
                                          _toggleUserActive(u['id'] as int, isActive);
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        PopupMenuItem(value: 'role', child: Text(l10n.changeRole)),
                                        PopupMenuItem(
                                          value: 'status',
                                          child: Text(isActive ? 'تعطيل الحساب' : 'تفعيل الحساب'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),

                // Tab 2: Academic Hierarchy
                _hierarchy.isEmpty
                    ? EmptyStateWidget(
                        icon: Icons.account_tree_outlined,
                        title: 'الهيكل الأكاديمي',
                        subtitle: 'الجامعات والكليات والدفعات والمقررات المسجلة.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _hierarchy.length,
                        itemBuilder: (context, index) {
                          final univ = _hierarchy[index];
                          final colleges = univ['colleges'] as List<dynamic>? ?? [];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ExpansionTile(
                              leading: const Icon(Icons.account_balance, color: Color(0xFF1E56A0)),
                              title: Text(univ['nameAr'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(univ['code'] as String? ?? ''),
                              children: colleges.map((col) {
                                final cohorts = col['cohorts'] as List<dynamic>? ?? [];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  child: ExpansionTile(
                                    leading: const Icon(Icons.school, color: Colors.indigo),
                                    title: Text(col['nameAr'] as String? ?? ''),
                                    subtitle: Text(col['code'] as String? ?? ''),
                                    children: cohorts.map((coh) {
                                      final courses = coh['courses'] as List<dynamic>? ?? [];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'الدفعة: ${coh['nameAr']} (رمز الانضمام: ${coh['joiningCode']})',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            const SizedBox(height: 6),
                                            ...courses.map((cr) => Padding(
                                                  padding: const EdgeInsets.only(left: 12, bottom: 4),
                                                  child: Text('• ${cr['code']}: ${cr['nameAr']} (${cr['doctorName']})',
                                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                                                )),
                                            const Divider(),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),

                // Tab 3: Audit Logs
                _auditLogs.isEmpty
                    ? const Center(child: Text('لا توجد سجلات تدقيق حالياً'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _auditLogs.length,
                        itemBuilder: (context, index) {
                          final log = _auditLogs[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const Icon(Icons.security, color: Color(0xFF1E56A0)),
                              title: Text(log['action'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${log['details']}\nبواسطة: ${log['userName']} • ${log['timestampUtc']}'),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ],
            ),
    );
  }
}
