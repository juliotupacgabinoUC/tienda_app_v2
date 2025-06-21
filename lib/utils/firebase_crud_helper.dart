import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

/// Ayuda para operaciones CRUD en Firestore y validación de distintos tipos.
class FirebaseCrudHelper {
  //===============================================================
  // CRUD
  //===============================================================

  /// Crea un nuevo documento en la colección [collection] con los [data] proporcionados.
  static Future<void> create(String collection, Map<String, dynamic> data) {
    return FirebaseFirestore.instance.collection(collection).add(data);
  }

  /// Actualiza el documento con ID [docId] en la colección [collection] con los [newData].
  static Future<void> update(
    String collection,
    String docId,
    Map<String, dynamic> newData,
  ) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .update(newData);
  }

  /// Elimina el documento con ID [docId] en la colección [collection].
  static Future<void> delete(String collection, String docId) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .delete();
  }

  /// Devuelve un stream de lista de mapas { id, …data } de la colección.
  static Stream<List<Map<String, dynamic>>> stream(String collection) {
    return FirebaseFirestore.instance
        .collection(collection)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
        );
  }

  //===============================================================
  // Validadores para TextFormField según tipos Firestore
  //===============================================================

  /// Valida que el campo no esté vacío.
  static String? validateString(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatorio';
    return null;
  }

  /// Valida que el campo no esté vacío y contenga solo letras y espacios.
  static String? validateText(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatorio';
    if (!RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÑñ ]+$').hasMatch(v)) {
      return 'Solo letras y espacios permitidos';
    }
    return null;
  }

  /// Valida que el campo sea un número entero válido.
  static String? validateInteger(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatorio';
    final n = int.tryParse(v);
    if (n == null) return 'Debe ser un número entero válido';
    return null;
  }

  /// Valida que el campo sea un número decimal válido.
  static String? validateDouble(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatorio';
    final d = double.tryParse(v);
    if (d == null) return 'Debe ser un número decimal válido';
    return null;
  }

  /// Valida que el campo sea un booleano (true o false).
  static String? validateBoolean(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatorio';
    final low = v.toLowerCase();
    if (low != 'true' && low != 'false') return 'Debe ser "true" o "false"';
    return null;
  }

  /// Valida que el campo sea un JSON válido.
  static String? validateJson(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatorio';
    try {
      jsonDecode(v);
      return null;
    } catch (e) {
      return 'Debe ser un JSON válido';
    }
  }

  /// Valida que el campo sea una fecha ISO (ej. 2025-06-15).
  static String? validateTimestamp(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatorio';
    try {
      DateTime.parse(v);
      return null;
    } catch (e) {
      return 'Debe ser una fecha válida (formato: YYYY-MM-DD)';
    }
  }

  /// Valida que el campo sea un GeoPoint en formato "lat,lng".
  static String? validateGeoPoint(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatorio';
    final parts = v.split(',');
    if (parts.length != 2) return 'Debe ser formato lat,lng';
    final lat = double.tryParse(parts[0]), lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) {
      return 'Latitud y longitud deben ser números';
    }
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return 'Coordenadas fuera de rango';
    }
    return null;
  }

  /// Valida que sea un correo electrónico válido.
  static String? validateEmail(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatorio';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
      return 'Correo electrónico inválido';
    }
    return null;
  }

  /// Valida contraseña con longitud mínima (6 por defecto).
  static String? validatePassword(
    String? v,
    String fieldName, [
    int minLength = 6,
  ]) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatoria';
    if (v.length < minLength) return 'Mínimo $minLength caracteres';
    return null;
  }

  /// Valida un número de teléfono peruano (9 dígitos).
  static String? validateTelefono9Digitos(String? v, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatorio';
    if (!RegExp(r'^\d{9}$').hasMatch(v)) {
      return 'Debe tener exactamente 9 dígitos';
    }
    return null;
  }

  /// Valida que un campo tenga exactamente [length] caracteres.
  static String? validateExactLength(String? v, int length, String fieldName) {
    if (v == null || v.trim().isEmpty) return '$fieldName es obligatorio';
    if (v.trim().length != length) {
      return 'Debe tener exactamente $length caracteres';
    }
    return null;
  }

  //===============================================================
  // InputFormatters para restringir la entrada de usuario
  //===============================================================

  /// Solo letras y espacios.
  static final textInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÑñ ]'),
  );

  /// Solo dígitos (para enteros).
  static final integerInputFormatter = FilteringTextInputFormatter.digitsOnly;

  /// Dígitos y punto decimal (para doubles).
  static final doubleInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9.]'),
  );

  /// Para entradas de JSON (básicas).
  static final jsonInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9A-Za-z{}\[\]:,\"\s.-_]'),
  );

  /// Para coordenadas tipo GeoPoint.
  static final geoPointInputFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'[0-9.,-]'),
  );
}
