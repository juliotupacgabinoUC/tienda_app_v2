// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart'; // Importa url_launcher

import '../utils/logout.dart'; // función cerrarSesion

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> productosAleatorios = [];
  final PageController _pageController = PageController(
    viewportFraction: 0.8,
  ); // Para el carrusel
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    cargarProductosAleatorios();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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

      if (productos.isNotEmpty) {
        final random = Random();
        final List<Map<String, dynamic>> tempProductos = [];
        final List<int> indicesUsados = [];

        while (tempProductos.length < 3 &&
            tempProductos.length < productos.length) {
          int randomIndex = random.nextInt(productos.length);
          if (!indicesUsados.contains(randomIndex)) {
            tempProductos.add(productos[randomIndex].data());
            indicesUsados.add(randomIndex);
          }
        }
        setState(() {
          productosAleatorios = tempProductos;
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: $e')),
        );
      }
    }
  }

  /// Función para lanzar la URL de Google Maps
  Future<void> _launchMap(String address) async {
    // Es crucial que esta URL sea correcta para tu negocio.
    // Usaremos la dirección proporcionada por el usuario.
    // Por ejemplo: 'Plaza de Armas de Huancayo, Huancayo, Perú'
    // Para una ubicación más precisa, puedes usar latitud y longitud.
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$address';

    final Uri uri = Uri.parse(googleMapsUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la aplicación de mapas.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JTG Prints'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: () => cerrarSesion(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Necesitarías pasar el carrito desde productos_screen o gestionar estado global
              // Por ahora, solo navegamos a la pantalla del carrito vacía.
              Navigator.pushNamed(context, '/carrito', arguments: []);
            },
          ),
        ],
      ),
      body: productosAleatorios.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Bienvenido a JTG Prints!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Productos Destacados',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  // Carrusel de productos con PageView.builder
                  SizedBox(
                    height: 250, // Altura fija para el carrusel
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: productosAleatorios.length,
                      itemBuilder: (context, index) {
                        final producto = productosAleatorios[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  convertirEnlaceDriveADirecto(
                                    producto['imagenUrl'] ?? '',
                                  ),
                                  height: 150,
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
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Botones de navegación del carrusel
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: _currentPage > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              }
                            : null,
                      ),
                      Text('${_currentPage + 1}/${productosAleatorios.length}'),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: _currentPage < productosAleatorios.length - 1
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeIn,
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Botón "Encuéntranos"
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // AQUÍ NECESITO LA DIRECCIÓN REAL DE LA TIENDA
                        _launchMap(
                          'Plaza de Armas de Huancayo, Huancayo, Perú',
                        ); // Dirección de ejemplo
                      },
                      icon: const Icon(Icons.location_on),
                      label: const Text('Encuéntranos'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Puedes añadir más contenido aquí si es necesario
                ],
              ),
            ),
    );
  }
}
