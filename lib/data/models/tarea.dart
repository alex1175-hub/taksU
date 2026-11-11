import 'package:flutter/material.dart';

import '../../core/fechas.dart';

enum Prioridad { baja, media, alta }

enum Urgencia {
  hoy(Color(0xFFD32F2F)),
  proxima(Color(0xFFF57C00)),
  holgada(Color(0xFF388E3C)),
  entregada(Color(0xFF9E9E9E));

  const Urgencia(this.color);
  final Color color;
}

class Tarea {
  final int? id;
  final int materiaId;
  final String titulo;
  final String descripcion;
  final DateTime fechaEntrega;
  final Prioridad prioridad;
  final bool entregada;
  final bool recordatorio;

  // Datos de la materia (vienen del JOIN, no se guardan en la tabla tareas).
  final String materiaNombre;
  final int materiaColor;

  const Tarea({
    this.id,
    required this.materiaId,
    required this.titulo,
    this.descripcion = '',
    required this.fechaEntrega,
    this.prioridad = Prioridad.media,
    this.entregada = false,
    this.recordatorio = false,
    this.materiaNombre = '',
    this.materiaColor = 0xFF3F51B5,
  });

  Tarea copiaCon({int? id, bool? entregada}) => Tarea(
        id: id ?? this.id,
        materiaId: materiaId,
        titulo: titulo,
        descripcion: descripcion,
        fechaEntrega: fechaEntrega,
        prioridad: prioridad,
        entregada: entregada ?? this.entregada,
        recordatorio: recordatorio,
        materiaNombre: materiaNombre,
        materiaColor: materiaColor,
      );

  int get diasRestantes => diasEntre(DateTime.now(), fechaEntrega);

  Urgencia get urgencia {
    if (entregada) return Urgencia.entregada;
    final d = diasRestantes;
    if (d <= 0) return Urgencia.hoy;
    if (d <= 7) return Urgencia.proxima;
    return Urgencia.holgada;
  }

  /// Además del color, cada tarjeta dice con texto cuándo vence.
  String get textoVencimiento {
    if (entregada) return 'Entregada';
    final d = diasRestantes;
    if (d < 0) return 'Venció hace ${-d} ${d == -1 ? 'día' : 'días'}';
    if (d == 0) return 'Vence hoy';
    if (d == 1) return 'Vence mañana';
    return 'Vence en $d días';
  }

  String get textoPrioridad => switch (prioridad) {
        Prioridad.baja => 'Baja',
        Prioridad.media => 'Media',
        Prioridad.alta => 'Alta',
      };

  Map<String, Object?> toMap() => {
        'id': id,
        'materia_id': materiaId,
        'titulo': titulo,
        'descripcion': descripcion,
        'fecha_entrega': soloFecha(fechaEntrega).millisecondsSinceEpoch,
        'prioridad': prioridad.index,
        'entregada': entregada ? 1 : 0,
        'recordatorio': recordatorio ? 1 : 0,
      };

  factory Tarea.fromMap(Map<String, Object?> m) => Tarea(
        id: m['id'] as int?,
        materiaId: m['materia_id'] as int,
        titulo: m['titulo'] as String,
        descripcion: (m['descripcion'] as String?) ?? '',
        fechaEntrega:
            DateTime.fromMillisecondsSinceEpoch(m['fecha_entrega'] as int),
        prioridad: Prioridad.values[m['prioridad'] as int],
        entregada: (m['entregada'] as int) == 1,
        recordatorio: (m['recordatorio'] as int) == 1,
        materiaNombre: (m['materia_nombre'] as String?) ?? '',
        materiaColor: (m['materia_color'] as int?) ?? 0xFF3F51B5,
      );
}
