// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Importa Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Importa FirebaseAuth
import '../utils/firebase_crud_helper.dart'; // Importa tu helper

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> carrito;

  const CheckoutScreen({super.key, required this.carrito});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _referenciaController = TextEditingController();

  Future<void> _confirmarCompra() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe iniciar sesión para confirmar la compra.'),
          ),
        );
      }
      return;
    }

    // Datos de la orden
    final List<Map<String, dynamic>> productosComprados = widget.carrito.map((
      item,
    ) {
      return {
        'id':
            item['id'], // Asegúrate de que el ID del producto esté en el carrito
        'nombre': item['nombre'],
        'precio': item['precio'],
        // Puedes añadir más detalles del producto si los tienes en el carrito,
        // por ejemplo, 'cantidad', 'imagenUrl', etc.
      };
    }).toList();

    final double total = widget.carrito.fold(
      0.0,
      (sum, item) => sum + (item['precio'] as double),
    );

    try {
      // Usamos el nuevo método saveTransaction del helper para guardar en 'transacciones'
      await FirebaseCrudHelper.saveTransaction({
        'userId': user.uid,
        'productos': productosComprados,
        'total': total,
        'fecha': Timestamp.now(), // Guarda la fecha y hora de la transacción
        'direccionEnvio': _direccionController.text.trim(),
        'referenciaEnvio': _referenciaController.text.trim(),
        'estado': 'Pendiente', // Un estado inicial para la transacción
      });

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Compra exitosa'),
            content: const Text(
              'Tu pedido ha sido registrado en "transacciones".',
            ), // Mensaje actualizado
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Cierra el diálogo
                  // Navegar a la pantalla principal después de la compra exitosa
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/main',
                    (route) => false,
                  ); // Esto limpia el stack y va a main
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la compra: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _direccionController.dispose();
    _referenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double total = widget.carrito.fold(
      0.0,
      (sum, item) => sum + (item['precio'] as double),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Compra')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Resumen de Productos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...widget.carrito.map(
              (item) => ListTile(
                title: Text(item['nombre']),
                trailing: Text('S/ ${item['precio'].toStringAsFixed(2)}'),
              ),
            ),
            const Divider(),
            Text(
              'Total: S/ ${total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Información de Envío', style: TextStyle(fontSize: 16)),
            TextField(
              controller: _direccionController,
              decoration: const InputDecoration(
                labelText: 'Dirección de Envío',
              ),
            ),
            TextField(
              controller: _referenciaController,
              decoration: const InputDecoration(labelText: 'Referencia'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Información de Pago (simulada)',
              style: TextStyle(fontSize: 16),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Nombre en la tarjeta'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Número de tarjeta'),
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Código de seguridad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _confirmarCompra,
              child: const Text('Confirmar compra'),
            ),
          ],
        ),
      ),
    );
  }
}
