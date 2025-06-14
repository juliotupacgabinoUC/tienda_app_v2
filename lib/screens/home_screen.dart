import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import '../utils/logout.dart'; // Si tienes la función cerrarSesion aquí

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? productoDestacado;

  @override
  void initState() {
    super.initState();
    cargarProductoAleatorio();
  }

  Future<void> cargarProductoAleatorio() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('productos').get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          productoDestacado = null;
        });
        return;
      }

      final productos = snapshot.docs;
      final random = Random();
      final index = random.nextInt(productos.length);
      final data = productos[index].data();

      setState(() {
        productoDestacado = {
          'nombre': data['nombre'],
          'precio': data['precio'],
          'imagen': data['imagen'],
        };
      });
    } catch (e) {
      print('❌ Error al cargar producto aleatorio: $e');
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
        child: productoDestacado == null
            ? const Center(child: Text('No hay productos para mostrar.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Artículo destacado',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        if (productoDestacado!['imagen'] != null)
                          Image.network(
                            productoDestacado!['imagen'],
                            height: 200,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                          ),
                        const SizedBox(height: 10),
                        Text(
                          productoDestacado!['nombre'],
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'S/ ${productoDestacado!['precio'].toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
