import 'package:cv_project/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF8100D1),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_add, size: 80, color: Color(0xFFB500B2)),
              const SizedBox(height: 20),
              const Text('انضم إلى MR.CV', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8100D1))),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock)),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('يرجى ملء جميع الحقول'), backgroundColor: Color(0xFFFFA47F)),
                        );
                        return;
                      }
                      
                      setState(() => _isLoading = true);
                      final error = await _authService.register(
                        _emailController.text,
                        _passwordController.text,
                      );
                      setState(() => _isLoading = false);
                      
                      if (error == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم إنشاء الحساب بنجاح'), backgroundColor: Colors.green),
                          );
                          Navigator.pop(context);
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error), backgroundColor: const Color(0xFFFFA47F)),
                          );
                        }
                      }
                    },
                    child: const Text('إنشاء الحساب'),
                  ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('لديك حساب بالفعل؟ سجل دخولك', style: TextStyle(color: Color(0xFF8100D1))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
