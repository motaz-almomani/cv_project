import 'package:cv_project/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _currentPwController = TextEditingController();
  final _newPwController = TextEditingController();
  final _confirmPwController = TextEditingController();

  bool _savingName = false;
  bool _savingPw = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  static const _deep = Color(0xFF0F172A);
  static const _accent = Color(0xFF0EA5E9);
  static const _surface = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    final u = FirebaseAuth.instance.currentUser;
    _nameController.text = u?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPwController.dispose();
    _newPwController.dispose();
    _confirmPwController.dispose();
    super.dispose();
  }

  String _initials(User? user) {
    final n = user?.displayName?.trim();
    if (n != null && n.isNotEmpty) {
      final parts = n.split(RegExp(r'\s+'));
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return n.substring(0, n.length >= 2 ? 2 : 1).toUpperCase();
    }
    final e = user?.email ?? '?';
    return e.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2FE), Color(0xFFF8FAFC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.userChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
            if (user == null) {
              return const Center(child: Text('Not signed in'));
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: _deep,
                        backgroundImage: user.photoURL != null && user.photoURL!.isNotEmpty
                            ? NetworkImage(user.photoURL!)
                            : null,
                        child: user.photoURL == null || user.photoURL!.isEmpty
                            ? Text(
                                _initials(user),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user.displayName?.trim().isNotEmpty == true ? user.displayName! : 'No display name',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _deep,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email ?? '',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            user.emailVerified ? Icons.verified_rounded : Icons.mark_email_unread_outlined,
                            size: 18,
                            color: user.emailVerified ? const Color(0xFF22C55E) : Colors.orange.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.emailVerified ? 'Email verified' : 'Email not verified',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: user.emailVerified ? const Color(0xFF22C55E) : Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                      if (!user.emailVerified) ...[
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () async {
                            final err = await authService.sendEmailVerification();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  err ?? 'Verification email sent. Check your inbox.',
                                ),
                                backgroundColor: err == null ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          },
                          icon: const Icon(Icons.send_rounded, size: 20),
                          label: const Text('Send verification email'),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionCard(
                  title: 'Display name',
                  subtitle: 'Shown in greetings and on your profile.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          hintText: 'Your name',
                          prefixIcon: Icon(Icons.badge_outlined, color: _accent),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _savingName
                            ? null
                            : () async {
                                setState(() => _savingName = true);
                                final err = await authService.updateDisplayName(_nameController.text);
                                if (!context.mounted) return;
                                setState(() => _savingName = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(err ?? 'Display name saved'),
                                    backgroundColor: err == null ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                        child: _savingName
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Save display name'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _sectionCard(
                  title: 'Change password',
                  subtitle: 'Enter your current password, then choose a new one.',
                  child: Column(
                    children: [
                      TextField(
                        controller: _currentPwController,
                        obscureText: _obscureCurrent,
                        decoration: InputDecoration(
                          hintText: 'Current password',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: _accent),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureCurrent ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPwController,
                        obscureText: _obscureNew,
                        decoration: InputDecoration(
                          hintText: 'New password',
                          prefixIcon: const Icon(Icons.lock_rounded, color: _accent),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPwController,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          hintText: 'Confirm new password',
                          prefixIcon: const Icon(Icons.lock_rounded, color: _accent),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _savingPw
                            ? null
                            : () async {
                                final cur = _currentPwController.text;
                                final nw = _newPwController.text;
                                final cf = _confirmPwController.text;
                                if (cur.isEmpty || nw.isEmpty || cf.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Fill in all password fields'),
                                      backgroundColor: Colors.orange.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                  return;
                                }
                                if (nw != cf) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('New passwords do not match'),
                                      backgroundColor: const Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                  return;
                                }
                                if (nw.length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Use at least 6 characters'),
                                      backgroundColor: Colors.orange.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => _savingPw = true);
                                final err = await authService.updatePassword(
                                  currentPassword: cur,
                                  newPassword: nw,
                                );
                                if (!context.mounted) return;
                                setState(() => _savingPw = false);
                                if (err == null) {
                                  _currentPwController.clear();
                                  _newPwController.clear();
                                  _confirmPwController.clear();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(err ?? 'Password updated'),
                                    backgroundColor: err == null ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              },
                        child: _savingPw
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Update password'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: _surface,
                  child: ListTile(
                    leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                    title: const Text('Sign out', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('You can sign in again anytime'),
                    onTap: () => authService.signOut(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Card(
      color: _surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _deep)),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
