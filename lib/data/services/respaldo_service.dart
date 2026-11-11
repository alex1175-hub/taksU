import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/materia.dart';
import '../models/tarea.dart';

class ResultadoRespaldo {
  final String ruta;
  final String json;
  const ResultadoRespaldo(this.ruta, this.json);
}

/// Exporta todas las materias y tareas del usuario a un archivo JSON.
class RespaldoService {
  Future<ResultadoRespaldo> exportar({
    required String correo,
    required List<Materia> materias,
    required List<Tarea> tareas,
  }) async {
    final datos = {
      'app': 'TaskU',
      'usuario': correo,
      'exportado': DateTime.now().toIso8601String(),
      'materias': materias
          .map((m) => {'nombre': m.nombre, 'profesor': m.profesor})
          .toList(),
      'tareas': tareas
          .map((t) => {
                'titulo': t.titulo,
                'materia': t.materiaNombre,
                'descripcion': t.descripcion,
                'fecha_entrega': t.fechaEntrega.toIso8601String().substring(0, 10),
                'prioridad': t.textoPrioridad,
                'entregada': t.entregada,
                'recordatorio': t.recordatorio,
              })
          .toList(),
    };
    final json = const JsonEncoder.withIndent('  ').convert(datos);
    final dir = await getApplicationDocumentsDirectory();
    final archivo = File('${dir.path}/tasku_respaldo.json');
    await archivo.writeAsString(json);
    return ResultadoRespaldo(archivo.path, json);
  }
}
