import '../models/dia_festivo.dart';
import '../models/materia.dart';
import '../models/tarea.dart';
import '../models/usuario.dart';
import 'app_database.dart';

class UsuarioDao {
  UsuarioDao(this._adb);
  final AppDatabase _adb;

  Future<int> insertar(Usuario u) async =>
      (await _adb.db).insert('usuarios', u.toMap());

  Future<Usuario?> porCorreo(String correo) async {
    final filas = await (await _adb.db)
        .query('usuarios', where: 'correo = ?', whereArgs: [correo], limit: 1);
    return filas.isEmpty ? null : Usuario.fromMap(filas.first);
  }

  Future<Usuario?> porId(int id) async {
    final filas = await (await _adb.db)
        .query('usuarios', where: 'id = ?', whereArgs: [id], limit: 1);
    return filas.isEmpty ? null : Usuario.fromMap(filas.first);
  }
}

class MateriaDao {
  MateriaDao(this._adb);
  final AppDatabase _adb;

  /// Cada estudiante ve únicamente sus propias materias.
  Future<List<Materia>> listar(int usuarioId) async {
    final filas = await (await _adb.db).query('materias',
        where: 'usuario_id = ?',
        whereArgs: [usuarioId],
        orderBy: 'nombre COLLATE NOCASE ASC');
    return filas.map(Materia.fromMap).toList();
  }

  Future<int> insertar(Materia m) async =>
      (await _adb.db).insert('materias', m.toMap());

  Future<void> actualizar(Materia m) async {
    await (await _adb.db)
        .update('materias', m.toMap(), where: 'id = ?', whereArgs: [m.id]);
  }

  /// Al borrar una materia, sus tareas se eliminan en cascada.
  Future<void> eliminar(int id) async {
    await (await _adb.db).delete('materias', where: 'id = ?', whereArgs: [id]);
  }
}

class TareaDao {
  TareaDao(this._adb);
  final AppDatabase _adb;

  Future<List<Tarea>> listar(int usuarioId) async {
    final filas = await (await _adb.db).rawQuery('''
      SELECT t.*, m.nombre AS materia_nombre, m.color AS materia_color
      FROM tareas t
      INNER JOIN materias m ON m.id = t.materia_id
      WHERE m.usuario_id = ?
      ORDER BY t.fecha_entrega ASC, t.prioridad DESC
    ''', [usuarioId]);
    return filas.map(Tarea.fromMap).toList();
  }

  Future<List<int>> idsDeMateria(int materiaId) async {
    final filas = await (await _adb.db).query('tareas',
        columns: ['id'], where: 'materia_id = ?', whereArgs: [materiaId]);
    return filas.map((f) => f['id'] as int).toList();
  }

  Future<int> insertar(Tarea t) async =>
      (await _adb.db).insert('tareas', t.toMap());

  Future<void> actualizar(Tarea t) async {
    await (await _adb.db)
        .update('tareas', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<void> eliminar(int id) async {
    await (await _adb.db).delete('tareas', where: 'id = ?', whereArgs: [id]);
  }
}

/// Tabla independiente: funciona como caché de la API de festivos.
class FestivoDao {
  FestivoDao(this._adb);
  final AppDatabase _adb;

  Future<List<DiaFestivo>> porAnio(int anio) async {
    final filas = await (await _adb.db).query('dias_festivo',
        where: 'anio = ?', whereArgs: [anio], orderBy: 'fecha ASC');
    return filas.map(DiaFestivo.fromMap).toList();
  }

  Future<void> reemplazarAnio(int anio, List<DiaFestivo> festivos) async {
    final d = await _adb.db;
    await d.transaction((txn) async {
      await txn.delete('dias_festivo', where: 'anio = ?', whereArgs: [anio]);
      final lote = txn.batch();
      for (final f in festivos) {
        lote.insert('dias_festivo', f.toMap());
      }
      await lote.commit(noResult: true);
    });
  }
}
