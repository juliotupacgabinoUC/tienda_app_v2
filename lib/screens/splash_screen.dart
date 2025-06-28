// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Usamos un Timer para navegar después de la animación.
    // Considera que el enfoque anterior con authStateChanges().listen
    // es más reactivo a los cambios de autenticación.
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return; // Asegurarse de que el widget sigue montado

      final user = FirebaseAuth.instance.currentUser;
      // Navega a la ruta de autenticación o a la pantalla principal
      Navigator.pushReplacementNamed(context, user != null ? '/main' : '/auth');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: _animation,
          child: Image.asset('assets/logo.png', height: 150),
        ),
      ),
    );
  }
}
