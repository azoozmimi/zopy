import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../screens/admin_screen.dart';
import '../screens/announcements_screen.dart';
import '../screens/assignments_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/courses_screen.dart';
import '../screens/files_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/representative_dashboard_screen.dart';

class MainDrawer extends StatelessWidget {
  final String currentRoute;

  const MainDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final user = auth.user;

    return Drawer(
      child: Column(
        children: [
          // User Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  const Color(0xFF163172),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user != null && user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            accountName: Text(
              user?.fullName ?? l10n.welcome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user?.role ?? 'Student',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildItem(
                  context,
                  icon: Icons.dashboard_outlined,
                  title: l10n.dashboard,
                  isSelected: currentRoute == 'home',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'home') {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                    }
                  },
                ),
                _buildItem(
                  context,
                  icon: Icons.assignment_outlined,
                  title: l10n.assignments,
                  isSelected: currentRoute == 'assignments',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'assignments') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignmentsScreen()));
                    }
                  },
                ),
                _buildItem(
                  context,
                  icon: Icons.calendar_month_outlined,
                  title: l10n.calendar,
                  isSelected: currentRoute == 'calendar',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'calendar') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()));
                    }
                  },
                ),
                _buildItem(
                  context,
                  icon: Icons.school_outlined,
                  title: l10n.courses,
                  isSelected: currentRoute == 'courses',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'courses') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesScreen()));
                    }
                  },
                ),
                _buildItem(
                  context,
                  icon: Icons.campaign_outlined,
                  title: l10n.announcements,
                  isSelected: currentRoute == 'announcements',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'announcements') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementsScreen()));
                    }
                  },
                ),
                _buildItem(
                  context,
                  icon: Icons.folder_open_outlined,
                  title: l10n.files,
                  isSelected: currentRoute == 'files',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'files') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FilesScreen()));
                    }
                  },
                ),
                _buildItem(
                  context,
                  icon: Icons.notifications_none_outlined,
                  title: l10n.notifications,
                  badgeCount: notifProvider.unreadCount,
                  isSelected: currentRoute == 'notifications',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'notifications') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                    }
                  },
                ),

                const Divider(),

                // Rep Dashboard (if representative or admin)
                if (user?.isRepresentative == true)
                  _buildItem(
                    context,
                    icon: Icons.supervisor_account_outlined,
                    title: l10n.repDashboard,
                    isSelected: currentRoute == 'rep_hub',
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != 'rep_hub') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const RepresentativeDashboardScreen()));
                      }
                    },
                  ),

                // Admin Dashboard (if admin)
                if (user?.isAdmin == true)
                  _buildItem(
                    context,
                    icon: Icons.admin_panel_settings_outlined,
                    title: l10n.admin,
                    isSelected: currentRoute == 'admin',
                    onTap: () {
                      Navigator.pop(context);
                      if (currentRoute != 'admin') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
                      }
                    },
                  ),

                _buildItem(
                  context,
                  icon: Icons.settings_outlined,
                  title: l10n.profile,
                  isSelected: currentRoute == 'profile',
                  onTap: () {
                    Navigator.pop(context);
                    if (currentRoute != 'profile') {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    }
                  },
                ),
              ],
            ),
          ),

          // Logout
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(l10n.logout, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () async {
              Navigator.pop(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.logout),
                  content: Text(l10n.logoutConfirm),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.cancel)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text(l10n.logout),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    int badgeCount = 0,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return ListTile(
      leading: Icon(icon, color: isSelected ? primary : Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? primary : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      trailing: badgeCount > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      selected: isSelected,
      selectedTileColor: primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onTap: onTap,
    );
  }
}
