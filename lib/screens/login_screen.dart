import 'package:cv_project/screens/register_screen.dart';
import 'package:cv_project/services/auth_service.dart';
import 'package:cv_project/main.dart'; // لاستيراد FadeScaleAnimation
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
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
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // تطبيق الحركة على الأيقونة والعنوان
              FadeScaleAnimation(
                child: Column(
                  children: [
                    const Icon(Icons.account_circle, size: 100, color: Color(0xFFD4AF37)),
                    const SizedBox(height: 10),
                    const Text(
                      'MR.CV',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // تطبيق الحركة على حقول الإدخال
              FadeScaleAnimation(
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email, color: Color(0xFF3A2D5F)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF3A2D5F)),
                      ),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 10),
              FadeScaleAnimation(
                child: Row(
                  children: [
                    Checkbox(
                      value: _rememberMe,
                      activeColor: const Color(0xFFD4AF37),
                      onChanged: (value) => setState(() => _rememberMe = value ?? false),
                    ),
                    const Text('تذكرني', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // تطبيق الحركة على الزر الرئيسي
              FadeScaleAnimation(
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Color(0xFFD4AF37))
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        final error = await _authService.signIn(
                          _emailController.text,
                          _passwordController.text,
                        );
                        setState(() => _isLoading = false);
                        
                        if (error == null) {
                          await _saveRememberMe();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error), 
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                      child: const Text('تسجيل الدخول'),
                    ),
              ),
              
              const SizedBox(height: 16),
              FadeScaleAnimation(
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  ),
                  child: const Text(
                    'ليس لديك حساب؟ سجل الآن',
                    style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
