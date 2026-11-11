import 'package:flutter_test/flutter_test.dart';
import 'package:tasku/data/models/tarea.dart';

Tarea _en(int dias, {bool entregada = false}) {
  final h = DateTime.now();
  return Tarea(
    materiaId: 1,
    titulo: 'Prueba',
    fechaEntrega: DateTime(h.year, h.month, h.day + dias),
    entregada: entregada,
  );
}

void main() {
  group('Urgencia de una tarea', () {
    test('vence hoy: rojo', () {
      expect(_en(0).urgencia, Urgencia.hoy);
      expect(_en(0).textoVencimiento, 'Vence hoy');
    });

    test('vencida: rojo y texto con días de retraso', () {
      expect(_en(-2).urgencia, Urgencia.hoy);
      expect(_en(-2).textoVencimiento, 'Venció hace 2 días');
    });

    test('próximos días: naranja', () {
      expect(_en(1).urgencia, Urgencia.proxima);
      expect(_en(1).textoVencimiento, 'Vence mañana');
      expect(_en(3).textoVencimiento, 'Vence en 3 días');
    });

    test('hay tiempo: verde', () {
      expect(_en(15).urgencia, Urgencia.holgada);
    });

    test('entregada: gris sin importar la fecha', () {
      expect(_en(0, entregada: true).urgencia, Urgencia.entregada);
      expect(_en(0, entregada: true).textoVencimiento, 'Entregada');
    });
  });

  group('Conversión a mapa (SQLite)', () {
    test('toMap y fromMap conservan los datos', () {
      final original = Tarea(
        id: 7,
        materiaId: 2,
        titulo: 'Reporte',
        descripcion: 'Detalle',
        fechaEntrega: DateTime(2026, 11, 20),
        prioridad: Prioridad.alta,
        entregada: true,
        recordatorio: true,
      );
      final copia = Tarea.fromMap({
        ...original.toMap(),
        'materia_nombre': 'Redes',
        'materia_color': 0xFF009688,
      });
      expect(copia.id, 7);
      expect(copia.materiaId, 2);
      expect(copia.titulo, 'Reporte');
      expect(copia.descripcion, 'Detalle');
      expect(copia.fechaEntrega, DateTime(2026, 11, 20));
      expect(copia.prioridad, Prioridad.alta);
      expect(copia.entregada, isTrue);
      expect(copia.recordatorio, isTrue);
      expect(copia.materiaNombre, 'Redes');
    });
  });
}
