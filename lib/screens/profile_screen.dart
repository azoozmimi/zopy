import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/api_endpoints.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/main_drawer.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _remind3Days = true;
  bool _remind1Day = true;
  bool _remind3Hours = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final res = await ApiService.get(ApiEndpoints.notificationPreferences);
      if (res.statusCode == 200 && mounted) {
        setState(() {
          _remind3Days = res.data['remindThreeDaysBefore'] as bool? ?? true;
          _remind1Day = res.data['remindOneDayBefore'] as bool? ?? true;
          _remind3Hours = res.data['remindThreeHoursBefore'] as bool? ?? true;
        });
        return;
      }
    } catch (_) {}
  }

  Future<void> _updatePref(String key, bool val) async {
    setState(() {
      if (key == '3days') _remind3Days = val;
      if (key == '1day') _remind1Day = val;
      if (key == '3hours') _remind3Hours = val;
    });

    try {
      await ApiService.put(
        ApiEndpoints.notificationPreferences,
        data: {
          'remindThreeDaysBefore': _remind3Days,
          'remindOneDayBefore': _remind1Day,
          'remindThreeHoursBefore': _remind3Hours,
          'inAppNotificationsEnabled': true,
        },
      );
    } catch (_) {}
  }

  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newPassword),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.currentPassword),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.newPassword),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (currentPassController.text.isEmpty || newPassController.text.length < 6) return;
              Navigator.pop(ctx);
              final success = await context.read<AuthProvider>().changePassword(
                    currentPassController.text,
                    newPassController.text,
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'تم تغيير كلمة المرور بنجاح' : 'كلمة المرور الحالية غير صحيحة'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showServerConfigDialog() {
    final controller = TextEditingController(text: ApiEndpoints.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعداد خادم الـ API / Server URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'للمحاكي: http://10.0.2.2:5000\nللجهاز الحقيقي: ضع عنوان IP لحاسوبك (مثال: http://192.168.1.15:5000)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                ApiEndpoints.setBaseUrl(newUrl);
                await StorageService.saveBaseUrl(newUrl);
                setState(() {});
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.user;

    return Scaffold(
      drawer: const MainDrawer(currentRoute: 'profile'),
      appBar: AppBar(
        title: Text(l10n.profile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user != null && user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? '',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(user?.email ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E56A0).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'الدور: ${user?.role ?? "Student"} • ${user?.cohortName ?? ""}',
                              style: const TextStyle(color: Color(0xFF1E56A0), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Language & Appearance Section
            Text(
              l10n.language,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('العربية (RTL)'),
                    value: 'ar',
                    groupValue: localeProvider.locale.languageCode,
                    onChanged: (val) {
                      if (val != null) localeProvider.setLocale(Locale(val));
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('English (LTR)'),
                    value: 'en',
                    groupValue: localeProvider.locale.languageCode,
                    onChanged: (val) {
                      if (val != null) localeProvider.setLocale(Locale(val));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Theme Mode Section
            Text(
              l10n.theme,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.systemTheme),
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    onChanged: (val) {
                      if (val != null) themeProvider.setThemeMode(val);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.lightTheme),
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    onChanged: (val) {
                      if (val != null) themeProvider.setThemeMode(val);
                    },
                  ),
                  const Divider(height: 1),
                  RadioListTile<ThemeMode>(
                    title: Text(l10n.darkTheme),
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    onChanged: (val) {
                      if (val != null) themeProvider.setThemeMode(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Smart Reminders Preferences
            Text(
              l10n.notificationPreferences,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l10n.remind3Days),
                    subtitle: const Text('تنبيه مبكر لتنظيم وقت التسليم'),
                    value: _remind3Days,
                    onChanged: (v) => _updatePref('3days', v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.remind1Day),
                    subtitle: const Text('تذكير اقتراب موعد التسليم النهائي'),
                    value: _remind1Day,
                    onChanged: (v) => _updatePref('1day', v),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(l10n.remind3Hours),
                    subtitle: const Text('تنبيه عاجل قبل إغلاق التسليم بـ 3 ساعات'),
                    value: _remind3Hours,
                    onChanged: (v) => _updatePref('3hours', v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Security & Settings
            Text(
              'الأمان والاتصال',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.password_outlined),
                    title: Text(l10n.newPassword),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.dns_outlined),
                    title: const Text('عنوان خادم الـ API'),
                    subtitle: Text(ApiEndpoints.baseUrl, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.edit, size: 18),
                    onTap: _showServerConfigDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // About Application Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school, color: Color(0xFF1E56A0)),
                        const SizedBox(width: 8),
                        Text(
                          l10n.appName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(l10n.aboutAppDesc, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
                    const SizedBox(height: 8),
                    Text(l10n.version, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
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

                if (confirm == true && mounted) {
                  await auth.logout();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
              child: Text(l10n.logout),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
