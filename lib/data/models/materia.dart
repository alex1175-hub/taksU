import 'package:flutter/material.dart';

class Materia {
  final int? id;
  final int usuarioId;
  final String nombre;
  final String profesor;
  final int color; // ARGB

  const Materia({
    this.id,
    required this.usuarioId,
    required this.nombre,
    required this.profesor,
    required this.color,
  });

  Color get colorMaterial => Color(color);

  Map<String, Object?> toMap() => {
        'id': id,
        'usuario_id': usuarioId,
        'nombre': nombre,
        'profesor': profesor,
        'color': color,
      };

  factory Materia.fromMap(Map<String, Object?> m) => Materia(
        id: m['id'] as int?,
        usuarioId: m['usuario_id'] as int,
        nombre: m['nombre'] as String,
        profesor: m['profesor'] as String,
        color: m['color'] as int,
      );
}

/// Elemento del catálogo leído del archivo JSON local.
class MateriaSugerida {
  final String nombre;
  final String profesor;
  final int color;
  const MateriaSugerida(this.nombre, this.profesor, this.color);
}

const List<int> paletaColores = [
  0xFF3F51B5, 0xFF009688, 0xFFE65100, 0xFF8E24AA,
  0xFF2E7D32, 0xFFC62828, 0xFF00838F, 0xFF6D4C41,
];
