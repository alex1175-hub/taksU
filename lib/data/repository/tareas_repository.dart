import '../local/daos.dart';
import '../local/sesion_store.dart';
import '../models/tarea.dart';
import '../services/recordatorios_service.dart';

class TareasRepository {
  TareasRepository(this._dao, this._recordatorios, this._sesion);
  final TareaDao _dao;
  final RecordatoriosService _recordatorios;
  final SesionStore _sesion;

  Future<List<Tarea>> listar(int usuarioId) => _dao.listar(usuarioId);

  Future<void> guardar(Tarea t) async {
    final int id;
    if (t.id == null) {
      id = await _dao.insertar(t);
    } else {
      await _dao.actualizar(t);
      id = t.id!;
    }
    await _sincronizarRecordatorio(t.copiaCon(id: id));
  }

  Future<void> alternarEntregada(Tarea t) async {
    final actualizada = t.copiaCon(entregada: !t.entregada);
    await _dao.actualizar(actualizada);
    await _sincronizarRecordatorio(actualizada);
  }

  Future<void> eliminar(Tarea t) async {
    if (t.id == null) return;
    await _recordatorios.cancelar(t.id!);
    await _dao.eliminar(t.id!);
  }

  /// Se llama al activar o desactivar las notificaciones en Perfil.
  Future<void> reprogramarTodos(int usuarioId) async {
    final tareas = await _dao.listar(usuarioId);
    for (final t in tareas) {
      await _sincronizarRecordatorio(t);
    }
  }

  Future<void> cancelarTodos() => _recordatorios.cancelarTodos();

  Future<void> _sincronizarRecordatorio(Tarea t) async {
    final activas = await _sesion.notificacionesActivas();
    if (activas && t.recordatorio && !t.entregada) {
      await _recordatorios.programar(
        id: t.id!,
        titulo: t.titulo,
        materia: t.materiaNombre,
        fechaEntrega: t.fechaEntrega,
      );
    } else {
      await _recordatorios.cancelar(t.id!);
    }
  }
}
