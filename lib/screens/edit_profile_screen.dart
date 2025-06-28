// lib/screens/edit_profile_screen.dart
import 'dart:io'; // Para el tipo File
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // Importa image_picker

// Importa tus helpers de validación
import '../utils/firebase_crud_helper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();

  File? _pickedImage; // Para almacenar la imagen seleccionada/tomada
  String? _currentPhotoUrl; // Para almacenar la URL actual de la foto de perfil

  bool _isLoading = false; // Estado de carga para el botón de guardar

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  // Función para convertir enlace de Drive a directo
  String convertirEnlaceDriveADirecto(String? enlaceDrive) {
    if (enlaceDrive == null || enlaceDrive.isEmpty) return '';
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(enlaceDrive);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$id';
    } else {
      // Si ya es una URL directa (como una de picsum.photos o una de Drive ya convertida)
      // o una URL que no se ajusta al patrón, la retornamos tal cual.
      return enlaceDrive;
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('datos_cliente')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        _nombreController.text = data?['nombre'] ?? '';
        _emailController.text = data?['email'] ?? '';
        _telefonoController.text = data?['telefono'] ?? '';
        _direccionController.text = data?['direccion'] ?? '';
        setState(() {
          _currentPhotoUrl = data?['photoUrl'];
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
    ); // Comprime un poco

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no autenticado.')),
        );
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? newPhotoUrl =
        _currentPhotoUrl; // Mantener la URL actual por defecto

    if (_pickedImage != null) {
      // ===================================================================
      // !!! LÓGICA DE SIMULACIÓN PARA GOOGLE DRIVE !!!
      // Como no usaremos Firebase Storage ni un backend para subir a Drive,
      // simplemente actualizamos la URL de la foto de perfil en Firestore
      // con una URL de Google Drive predefinida o de prueba.
      //
      // Importante: Esta URL DEBE ser una URL directa de una imagen de Google Drive
      // que ya exista y sea accesible públicamente, O una URL de imagen genérica.
      //
      // Ejemplo con una URL de imagen genérica (la imagen cambiará visualmente
      // cada vez que se actualice si usas picsum.photos)
      newPhotoUrl =
          'https://picsum.photos/200/300?random=${DateTime.now().millisecondsSinceEpoch}';

      // Si tienes una URL DIRECTA de una imagen específica en tu Google Drive,
      // puedes usarla aquí en lugar de la de picsum.photos.
      // Por ejemplo:
      // newPhotoUrl = 'https://drive.google.com/uc?export=view&id=TU_ID_DE_IMAGEN_DE_DRIVE';
      // ===================================================================
    }

    try {
      await FirebaseFirestore.instance
          .collection('datos_cliente')
          .doc(user.uid)
          .update({
            'nombre': _nombreController.text.trim(),
            // 'email': _emailController.text.trim(), // El email de Firebase Auth no se cambia aquí directamente
            'telefono': _telefonoController.text.trim(),
            'direccion': _direccionController.text.trim(),
            'photoUrl': newPhotoUrl, // Guarda la URL de la foto
          });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado exitosamente.')),
        );
        Navigator.pop(context); // Regresar a la pantalla de perfil
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar perfil: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  // Opciones para seleccionar o tomar foto
                  showModalBottomSheet(
                    context: context,
                    builder: (ctx) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Tomar Foto'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Seleccionar de Galería'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.deepPurple.shade100,
                  backgroundImage: _pickedImage != null
                      ? FileImage(
                          _pickedImage!,
                        ) // Si se seleccionó una nueva imagen
                      : (_currentPhotoUrl != null &&
                                _currentPhotoUrl!.isNotEmpty
                            ? NetworkImage(
                                convertirEnlaceDriveADirecto(_currentPhotoUrl!),
                              ) // Si ya hay una URL de drive
                            : null),
                  child:
                      _pickedImage == null &&
                          (_currentPhotoUrl == null ||
                              _currentPhotoUrl!.isEmpty)
                      ? Icon(
                          Icons.camera_alt,
                          size: 80,
                          color: Colors.deepPurple.shade400,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => FirebaseCrudHelper.validateText(v, 'Nombre'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                readOnly: true, // El email de Firebase Auth no se cambia aquí
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _telefonoController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FirebaseCrudHelper.integerInputFormatter],
                validator: (v) =>
                    FirebaseCrudHelper.validateTelefono9Digitos(v, 'Teléfono'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (v) =>
                    FirebaseCrudHelper.validateString(v, 'Dirección'),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
