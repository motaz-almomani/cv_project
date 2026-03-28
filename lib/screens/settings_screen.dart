import 'package:cv_project/screens/profile_screen.dart';
import 'package:cv_project/services/auth_service.dart';
import 'package:cv_project/services/user_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _deep = Color(0xFF0F172A);
  static const _accent = Color(0xFF0EA5E9);
  static const _surface = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<UserSettingsService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final template = settings.defaultPdfTemplate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2FE), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              color: _surface,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
                    child: Text(
                      'Account',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _accent, letterSpacing: 0.5),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_rounded, color: _deep),
                    title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Display name, password, email verification'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(builder: (context) => const ProfileScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: _surface,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CV defaults',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _accent, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Default PDF template for new CVs',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _deep),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Applied when you tap “New CV”. You can still change it per document.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.35),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(value: 'modern', label: Text('Modern')),
                        ButtonSegment<String>(value: 'classic', label: Text('Classic')),
                        ButtonSegment<String>(value: 'minimal', label: Text('Minimal')),
                      ],
                      selected: {template},
                      onSelectionChanged: (set) async {
                        final v = set.first;
                        await settings.setDefaultPdfTemplate(v);
                        if (context.mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: _surface,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(18, 18, 18, 8),
                    child: Text(
                      'About',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _accent, letterSpacing: 0.5),
                    ),
                  ),
                  const ListTile(
                    leading: Icon(Icons.info_outline_rounded, color: _deep),
                    title: Text('MR.CV'),
                    subtitle: Text('Version 1.0.0 · Build your CVs with templates and PDF export'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => authService.signOut(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
