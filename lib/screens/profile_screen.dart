import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logout.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, dynamic>?> obtenerDatosCliente() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('datos_cliente')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: () => cerrarSesion(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: obtenerDatosCliente(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final datos = snapshot.data;

          if (datos == null) {
            return const Center(
              child: Text('No se encontraron datos del cliente'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 10),
                Text(
                  'Nombre: ${datos['nombre']}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Correo: ${datos['email']}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Teléfono: ${datos['telefono']}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Dirección: ${datos['direccion']}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
