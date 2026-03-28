import 'dart:ui';

import 'package:flutter/material.dart';

/// Shared gradient background and glass card for login / register.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.child,
    this.appBar,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;

  static const Color cyan = Color(0xFF22D3EE);
  static const Color accent = Color(0xFF0EA5E9);
  static const Color indigo = Color(0xFF6366F1);
  static const Color deep = Color(0xFF0F172A);

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF050B14),
              Color(0xFF0F172A),
              Color(0xFF1E3A5F),
              Color(0xFF0E7490),
            ],
            stops: [0.0, 0.25, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: h * 0.06,
              right: -50,
              child: _GlowOrb(
                size: 200,
                colors: [accent.withValues(alpha: 0.45), accent.withValues(alpha: 0)],
              ),
            ),
            Positioned(
              top: h * 0.35,
              left: -80,
              child: _GlowOrb(
                size: 260,
                colors: [indigo.withValues(alpha: 0.35), indigo.withValues(alpha: 0)],
              ),
            ),
            Positioned(
              bottom: h * 0.08,
              right: 20,
              child: _GlowOrb(
                size: 140,
                colors: [cyan.withValues(alpha: 0.3), cyan.withValues(alpha: 0)],
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

/// Frosted card wrapping the form fields.
class AuthFormCard extends StatelessWidget {
  const AuthFormCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 420),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0EA5E9).withValues(alpha: 0.18),
                blurRadius: 40,
                spreadRadius: -4,
                offset: const Offset(0, 20),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(26, 30, 26, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

InputDecoration authInputDecoration({
  required String label,
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  const accent = AuthShell.accent;
  const deep = AuthShell.deep;
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    labelStyle: TextStyle(color: deep.withValues(alpha: 0.65), fontWeight: FontWeight.w500),
    hintStyle: TextStyle(color: deep.withValues(alpha: 0.35)),
    filled: true,
    fillColor: const Color(0xFFF1F5F9),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: deep.withValues(alpha: 0.06)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: accent, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFEF4444)),
    ),
  );
}
