import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

void cerrarSesion(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  if (context.mounted) {
    Navigator.pushReplacementNamed(context, '/auth');
  }
}
