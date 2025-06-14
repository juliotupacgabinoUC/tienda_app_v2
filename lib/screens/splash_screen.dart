import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Escuchar cambios de autenticación (recomendado)
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        if (user == null) {
          Navigator.pushReplacementNamed(context, '/auth');
        } else {
          Navigator.pushReplacementNamed(context, '/main');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Center(
        child: Text(
          'JTG Prints',
          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
