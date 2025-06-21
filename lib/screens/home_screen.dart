import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import '../utils/logout.dart'; // función cerrarSesion

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> productosAleatorios = [];

  @override
  void initState() {
    super.initState();
    cargarProductosAleatorios();
  }

  /// ✅ Convierte un enlace compartido de Google Drive en uno directo
  String convertirEnlaceDriveADirecto(String enlaceDrive) {
    final regExp = RegExp(r'/d/([a-zA-Z0-9_-]+)');
    final match = regExp.firstMatch(enlaceDrive);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      return 'https://drive.google.com/uc?export=view&id=$id';
    } else {
      return enlaceDrive;
    }
  }

  /// ✅ Cargar 3 productos aleatorios desde Firestore
  Future<void> cargarProductosAleatorios() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('productos')
          .get();

      final productos = snapshot.docs;

      if (productos.isEmpty) {
        setState(() {
          productosAleatorios = [];
        });
        return;
      }

      // Elegir 3 aleatorios
      final random = Random();
      final seleccionados = <Map<String, dynamic>>[];

      final indicesUsados = <int>{};
      while (seleccionados.length < 3 &&
          indicesUsados.length < productos.length) {
        final index = random.nextInt(productos.length);
        if (!indicesUsados.contains(index)) {
          final data = productos[index].data();
          final imagenConvertida = convertirEnlaceDriveADirecto(
            data['imagen'] ?? '',
          );

          seleccionados.add({
            'nombre': data['nombre'],
            'precio': data['precio'],
            'imagen': imagenConvertida,
          });

          indicesUsados.add(index);
        }
      }

      setState(() {
        productosAleatorios = seleccionados;
      });
    } catch (e) {
      print('❌ Error al cargar productos aleatorios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: () => cerrarSesion(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: productosAleatorios.isEmpty
            ? const Center(child: Text('No hay productos para mostrar.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productos destacados',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: PageView.builder(
                      itemCount: productosAleatorios.length,
                      itemBuilder: (context, index) {
                        final producto = productosAleatorios[index];
                        return Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  producto['imagen'],
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 100),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              producto['nombre'] ?? 'Sin nombre',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'S/ ${producto['precio'].toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
