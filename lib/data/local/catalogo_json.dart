import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/materia.dart';

/// Lee el archivo JSON local con el catálogo de materias sugeridas.
class CatalogoJson {
  Future<List<MateriaSugerida>> leer() async {
    try {
      final texto = await rootBundle.loadString('assets/materias_sugeridas.json');
      final datos = jsonDecode(texto) as Map<String, dynamic>;
      final lista = datos['materias'] as List<dynamic>;
      return lista.map((e) {
        final m = e as Map<String, dynamic>;
        final hex = (m['color'] as String).replaceFirst('#', '');
        return MateriaSugerida(
          m['nombre'] as String,
          (m['profesor'] as String?) ?? '',
          0xFF000000 | int.parse(hex, radix: 16),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
