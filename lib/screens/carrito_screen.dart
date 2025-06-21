import 'package:flutter/material.dart';

class CarritoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> carrito;

  const CarritoScreen({super.key, required this.carrito});

  @override
  State<CarritoScreen> createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  late List<Map<String, dynamic>> carrito;

  @override
  void initState() {
    super.initState();
    carrito = List<Map<String, dynamic>>.from(widget.carrito);
  }

  void eliminarProducto(int index) {
    setState(() {
      carrito.removeAt(index);
    });
  }

  void irACheckout() {
    Navigator.pushNamed(context, '/checkout', arguments: carrito);
  }

  double calcularTotal() {
    return carrito.fold(0.0, (total, item) => total + (item['precio'] ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito de Compras')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: carrito.isEmpty
            ? const Center(child: Text('El carrito está vacío.'))
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: carrito.length,
                      itemBuilder: (context, index) {
                        final producto = carrito[index];
                        return ListTile(
                          title: Text(producto['nombre']),
                          subtitle: Text(
                            'S/ ${producto['precio'].toStringAsFixed(2)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => eliminarProducto(index),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: S/ ${calcularTotal().toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: carrito.isEmpty ? null : irACheckout,
                    icon: const Icon(Icons.payment),
                    label: const Text('Proceder al pago'),
                  ),
                ],
              ),
      ),
    );
  }
}
