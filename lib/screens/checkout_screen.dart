import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> carrito =
        ModalRoute.of(context)?.settings.arguments as List<Map<String, dynamic>>;

    final double total = carrito.fold(0.0, (sum, item) => sum + (item['precio'] as double));

    return Scaffold(
      appBar: AppBar(title: const Text('Finalizar Compra')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Resumen de Productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...carrito.map((item) => ListTile(
                  title: Text(item['nombre']),
                  trailing: Text('S/ ${item['precio'].toStringAsFixed(2)}'),
                )),
            const Divider(),
            Text('Total: S/ ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text('Información de Entrega', style: TextStyle(fontSize: 16)),
            const TextField(decoration: InputDecoration(labelText: 'Dirección de envío')),
            const TextField(decoration: InputDecoration(labelText: 'Referencia')),
            const SizedBox(height: 20),
            const Text('Información de Pago (simulada)', style: TextStyle(fontSize: 16)),
            const TextField(decoration: InputDecoration(labelText: 'Nombre en la tarjeta')),
            const TextField(decoration: InputDecoration(labelText: 'Número de tarjeta')),
            const TextField(decoration: InputDecoration(labelText: 'Código de seguridad')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Compra exitosa'),
                    content: const Text('Tu pedido ha sido registrado.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.pop(context); // salir de checkout
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Confirmar compra'),
            )
          ],
        ),
      ),
    );
  }
}
