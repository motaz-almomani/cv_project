import 'package:cv_project/main.dart';
import 'package:cv_project/models/cv_model.dart';
import 'package:cv_project/screens/edit_cv_screen.dart';
import 'package:cv_project/screens/profile_screen.dart';
import 'package:cv_project/screens/settings_screen.dart';
import 'package:cv_project/services/auth_service.dart';
import 'package:cv_project/services/database_service.dart';
import 'package:cv_project/services/pdf_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _searchQuery = '';
  final Set<String> _selectedCVs = {};
  bool _isSelectionMode = false;

  static const _surfaceCard = Color(0xFFF8FAFC);
  static const _accent = Color(0xFF0EA5E9);
  static const _deep = Color(0xFF0F172A);

  String _templateLabel(String id) {
    switch (id) {
      case 'classic':
        return 'Classic';
      case 'minimal':
        return 'Minimal';
      default:
        return 'Modern';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final dbService = Provider.of<DatabaseService>(context);
    final pdfService = Provider.of<PDFService>(context);
    final user = FirebaseAuth.instance.currentUser;
    final display = user?.displayName?.trim();
    final greetingName = (display != null && display.isNotEmpty)
        ? display
        : (user?.email?.split('@').first ?? 'there');

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not signed in')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() {
                  _isSelectionMode = false;
                  _selectedCVs.clear();
                }),
              )
            : null,
        title: Text(_isSelectionMode ? '${_selectedCVs.length} selected' : 'Dashboard'),
        actions: _isSelectionMode
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete CVs'),
                        content: Text('Delete ${_selectedCVs.length} selected CV(s)?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      for (final id in _selectedCVs) {
                        await dbService.deleteCV(id);
                      }
                      setState(() {
                        _isSelectionMode = false;
                        _selectedCVs.clear();
                      });
                    }
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.person_rounded),
                  tooltip: 'Profile',
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(builder: (context) => const ProfileScreen()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_rounded),
                  tooltip: 'Settings',
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(builder: (context) => const SettingsScreen()),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'More',
                  icon: const Icon(Icons.more_vert_rounded),
                  color: _surfaceCard,
                  onSelected: (value) {
                    if (value == 'logout') {
                      authService.signOut();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
                          SizedBox(width: 12),
                          Text('Sign out'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
      ),
      body: StreamBuilder<List<CVModel>>(
        stream: dbService.streamUserCVs(user.uid),
        builder: (context, snapshot) {
          final allCvs = snapshot.data ?? [];
          var cvs = List<CVModel>.from(allCvs);
          if (_searchQuery.isNotEmpty) {
            cvs = cvs.where((cv) => cv.cvName.toLowerCase().contains(_searchQuery)).toList();
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, $greetingName',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create multiple CVs, pick a PDF template, and edit anytime.',
                        style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85), height: 1.35),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.folder_open_rounded,
                              label: 'Your CVs',
                              value: snapshot.connectionState == ConnectionState.waiting ? '…' : '${allCvs.length}',
                              subtitle: 'Unlimited documents',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.palette_outlined,
                              label: 'Templates',
                              value: '3',
                              subtitle: 'Modern · Classic · Minimal',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditCVScreen()),
                          ),
                          icon: const Icon(Icons.add_rounded, size: 22),
                          label: const Text('New CV'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        style: const TextStyle(color: _deep),
                        decoration: InputDecoration(
                          hintText: 'Search CVs by name…',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          prefixIcon: const Icon(Icons.search_rounded, color: _accent),
                          filled: true,
                          fillColor: _surfaceCard,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'My CVs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (snapshot.connectionState == ConnectionState.waiting)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: _accent)),
                )
              else if (cvs.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        allCvs.isEmpty
                            ? 'No CVs yet. Tap “New CV” to create your first one.'
                            : 'No CVs match your search.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 16),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cv = cvs[index];
                        final isSelected = _selectedCVs.contains(cv.id);
                        return FadeScaleAnimation(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: isSelected ? _accent.withValues(alpha: 0.25) : _surfaceCard,
                              borderRadius: BorderRadius.circular(16),
                              elevation: isSelected ? 0 : 2,
                              shadowColor: Colors.black26,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onLongPress: () => setState(() {
                                  _isSelectionMode = true;
                                  _selectedCVs.add(cv.id);
                                }),
                                onTap: () {
                                  if (_isSelectionMode) {
                                    setState(() {
                                      if (_selectedCVs.contains(cv.id)) {
                                        _selectedCVs.remove(cv.id);
                                        if (_selectedCVs.isEmpty) _isSelectionMode = false;
                                      } else {
                                        _selectedCVs.add(cv.id);
                                      }
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EditCVScreen(initialCV: cv)),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: _deep,
                                        child: Icon(
                                          isSelected ? Icons.check_rounded : Icons.description_outlined,
                                          color: _accent,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cv.cvName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _deep),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(cv.jobTitle, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                                            const SizedBox(height: 4),
                                            Text(
                                              'PDF: ${_templateLabel(cv.pdfTemplate)}',
                                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!_isSelectionMode) ...[
                                        IconButton(
                                          icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626)),
                                          tooltip: 'Export PDF',
                                          onPressed: () => pdfService.generateAndPrintPDF(cv),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: cvs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0EA5E9), size: 26),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600], height: 1.2)),
        ],
      ),
    );
  }
}
