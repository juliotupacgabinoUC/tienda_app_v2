import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> productosFiltrados = [];
  List<Map<String, dynamic>> carrito = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    obtenerProductos();
  }

  Future<void> obtenerProductos() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('productos').get();

      if (snapshot.docs.isEmpty) {
        print('⚠️ No hay productos en la colección Firestore.');
        return;
      }

      final lista = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'nombre': data['nombre'],
          'precio': data['precio'],
          'imagen': data['imagen'],
        };
      }).toList();

      setState(() {
        productos = lista;
        productosFiltrados = lista;
      });
    } catch (e) {
      print('❌ Error al obtener productos: $e');
    }
  }

  void filtrarProductos(String texto) {
    final resultado = productos.where((producto) {
      final nombre = producto['nombre']?.toLowerCase() ?? '';
      return nombre.contains(texto.toLowerCase().trim());
    }).toList();

    setState(() {
      productosFiltrados = resultado;
    });
  }

  void agregarAlCarrito(Map<String, dynamic> producto) {
    setState(() {
      carrito.add(producto);
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${producto['nombre']} añadido al carrito'),
      duration: const Duration(seconds: 1),
    ));
  }

  void mostrarCarrito() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Carrito de Compras',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                carrito.isEmpty
                    ? const Text('El carrito está vacío.')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: carrito.length,
                        itemBuilder: (context, index) {
                          final item = carrito[index];
                          return ListTile(
                            title: Text(item['nombre']),
                            subtitle: Text(
                                'S/ ${item['precio'].toStringAsFixed(2)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setModalState(() {
                                  carrito.removeAt(index);
                                });
                                setState(() {}); // actualizar badge
                              },
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 10),
                if (carrito.isNotEmpty)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // cerrar modal
                      Navigator.pushNamed(context, '/checkout',
                          arguments: carrito);
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text('Comprar'),
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  void cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: cerrarSesion,
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                tooltip: 'Carrito',
                onPressed: mostrarCarrito,
              ),
              if (carrito.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${carrito.length}',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: searchController,
              onChanged: filtrarProductos,
              decoration: InputDecoration(
                labelText: 'Buscar producto...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: productosFiltrados.isEmpty
                ? const Center(child: Text('No se encontraron productos'))
                : ListView.builder(
                    itemCount: productosFiltrados.length,
                    itemBuilder: (context, index) {
                      final producto = productosFiltrados[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            producto['imagen'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const SizedBox(
                                width: 60,
                                height: 60,
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                          ),
                        ),
                        title: Text(producto['nombre']),
                        subtitle: Text(
                            'S/ ${producto['precio'].toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () => agregarAlCarrito(producto),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
