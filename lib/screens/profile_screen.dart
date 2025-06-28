// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/logout.dart';
import 'edit_profile_screen.dart'; // Importa la nueva pantalla de edición

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Función para convertir enlace de Drive a directo (puedes moverla a un util si la usas en varios sitios)
  String convertirEnlaceDriveADirecto(String? enlaceDrive) {
    if (enlaceDrive == null || enlaceDrive.isEmpty) return '';
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(enlaceDrive);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$id';
    } else {
      return enlaceDrive;
    }
  }

  Future<Map<String, dynamic>?> obtenerDatosCliente() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('datos_cliente')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  // Usamos un StreamBuilder para escuchar cambios en tiempo real del perfil
  // Esto es mejor si los datos pueden cambiar desde otras partes de la app
  Stream<DocumentSnapshot<Map<String, dynamic>>> _profileStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Retorna un stream vacío si no hay usuario loggeado
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('datos_cliente')
        .doc(user.uid)
        .snapshots();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar perfil',
            onPressed: () async {
              // Navegar a la pantalla de edición y esperar si hay un cambio
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const EditProfileScreen()),
              );
              // Si se regresa de EditProfileScreen, el StreamBuilder se encargará de actualizar.
              // setState para asegurar un re-render si no usas StreamBuilder o si quieres forzarlo.
              setState(() {});
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _profileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final datos = snapshot.data?.data();

          if (datos == null) {
            return const Center(
              child: Text(
                'No se encontraron datos del cliente. Edita tu perfil.',
              ),
            );
          }

          final String? photoUrl =
              datos['photoUrl']; // Nuevo campo para la URL de la foto
          final String displayPhotoUrl = convertirEnlaceDriveADirecto(photoUrl);

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: displayPhotoUrl.isNotEmpty
                      ? NetworkImage(displayPhotoUrl)
                      : null,
                  child: displayPhotoUrl.isEmpty
                      ? Icon(
                          Icons.account_circle,
                          size: 100,
                          color: Colors.deepPurple.shade400,
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  'Nombre: ${datos['nombre'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Correo: ${datos['email'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Teléfono: ${datos['telefono'] ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18),
                ),
                Text(
                  'Dirección: ${datos['direccion'] ?? 'N/A'}',
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
