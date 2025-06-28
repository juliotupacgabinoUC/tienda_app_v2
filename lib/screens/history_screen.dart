// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Center(
        child: Text('Inicia sesión para ver tu historial de compras.'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Compras')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ordenes')
            .where(
              'userId',
              isEqualTo: currentUser!.uid,
            ) // Filtra por el usuario actual
            .orderBy('fecha', descending: true) // Ordena por fecha descendente
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No tienes compras en tu historial.'),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].data() as Map<String, dynamic>;
              final List<dynamic> productos = order['productos'] ?? [];
              final Timestamp fechaTimestamp = order['fecha'];
              final DateTime fecha = fechaTimestamp.toDate();
              final String formattedDate = DateFormat(
                'dd/MM/yyyy HH:mm',
              ).format(fecha);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha: $formattedDate',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Total: S/ ${order['total'].toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      if (order['direccionEnvio'] != null &&
                          order['direccionEnvio'].isNotEmpty)
                        Text(
                          'Dirección: ${order['direccionEnvio']}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      if (order['referenciaEnvio'] != null &&
                          order['referenciaEnvio'].isNotEmpty)
                        Text(
                          'Referencia: ${order['referenciaEnvio']}',
                          style: const TextStyle(fontSize: 15),
                        ),
                      const SizedBox(height: 8),
                      const Text(
                        'Productos:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...productos.map(
                        (producto) => Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(
                            '- ${producto['nombre']} (S/ ${producto['precio'].toStringAsFixed(2)})',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
