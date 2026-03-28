import 'package:cv_project/main.dart';
import 'package:cv_project/screens/register_screen.dart';
import 'package:cv_project/services/auth_service.dart';
import 'package:cv_project/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('saved_email') ?? '';
      }
    });
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text);
    } else {
      await prefs.remove('saved_email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return AuthShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeScaleAnimation(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AuthShell.cyan,
                        AuthShell.accent,
                        AuthShell.indigo,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AuthShell.accent.withValues(alpha: 0.45),
                        blurRadius: 24,
                        spreadRadius: 0,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0F172A),
                    ),
                    child: const Icon(Icons.description_rounded, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFE0F2FE), Colors.white, Color(0xFFBAE6FD)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                  child: const Text(
                    'MR.CV',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'Build · edit · export',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Sign in to manage your CVs',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.35,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FadeScaleAnimation(
            child: AuthFormCard(
              children: [
                Text(
                  'Welcome back',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AuthShell.deep,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Enter your credentials to continue',
                  style: TextStyle(
                    fontSize: 14,
                    color: AuthShell.deep.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: AuthShell.deep, fontWeight: FontWeight.w500),
                  decoration: authInputDecoration(
                    label: 'Email',
                    hint: 'you@example.com',
                    prefixIcon: const Icon(Icons.alternate_email_rounded, color: AuthShell.accent, size: 22),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(authService),
                  style: const TextStyle(color: AuthShell.deep, fontWeight: FontWeight.w500),
                  decoration: authInputDecoration(
                    label: 'Password',
                    prefixIcon: const Icon(Icons.lock_rounded, color: AuthShell.accent, size: 22),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AuthShell.deep.withValues(alpha: 0.45),
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: Checkbox(
                        value: _rememberMe,
                        activeColor: AuthShell.accent,
                        checkColor: Colors.white,
                        side: BorderSide(color: AuthShell.deep.withValues(alpha: 0.25)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        onChanged: (value) => setState(() => _rememberMe = value ?? false),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AuthShell.deep.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), AuthShell.accent, Color(0xFF2563EB)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AuthShell.accent.withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : FilledButton(
                            onPressed: () => _submit(authService),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: Divider(color: AuthShell.deep.withValues(alpha: 0.12))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'New here?',
                        style: TextStyle(fontSize: 12, color: AuthShell.deep.withValues(alpha: 0.45)),
                      ),
                    ),
                    Expanded(child: Divider(color: AuthShell.deep.withValues(alpha: 0.12))),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(builder: (context) => const RegisterScreen()),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 15, color: AuthShell.deep.withValues(alpha: 0.55)),
                      children: const [
                        TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: 'Register',
                          style: TextStyle(
                            color: AuthShell.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(AuthService authService) async {
    setState(() => _isLoading = true);
    final error = await authService.signIn(
      _emailController.text,
      _passwordController.text,
    );
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context); // ignore: use_build_context_synchronously
    setState(() => _isLoading = false);
    if (error == null) {
      await _saveRememberMe();
      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
