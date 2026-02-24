import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user => _auth.authStateChanges();

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return null; // نجاح
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found': return 'لا يوجد حساب بهذا البريد الإلكتروني';
        case 'wrong-password': return 'كلمة المرور غير صحيحة';
        case 'invalid-email': return 'صيغة البريد الإلكتروني غير صحيحة';
        case 'user-disabled': return 'هذا الحساب معطل';
        default: return 'خطأ في تسجيل الدخول: ${e.message}';
      }
    } catch (e) {
      return 'حدث خطأ غير متوقع';
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      return null; // نجاح
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use': return 'هذا البريد الإلكتروني مستخدم بالفعل';
        case 'weak-password': return 'كلمة المرور ضعيفة جداً';
        default: return 'خطأ في التسجيل: ${e.message}';
      }
    } catch (e) {
      return 'حدث خطأ غير متوقع';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
