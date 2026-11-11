import 'package:flutter/foundation.dart';

import '../data/models/tarea.dart';
import '../data/repository/tareas_repository.dart';

enum FiltroTareas { todas, pendientes, entregadas }

class TareasViewModel extends ChangeNotifier {
  TareasViewModel(this._repo);
  final TareasRepository _repo;

  int? _usuarioId;
  List<Tarea> _todas = [];
  FiltroTareas filtro = FiltroTareas.todas;
  bool cargando = false;
  bool errorCarga = false;

  List<Tarea> get todas => _todas;

  /// Lista ya ordenada por fecha de entrega (el orden viene de la consulta).
  List<Tarea> get visibles => switch (filtro) {
        FiltroTareas.todas => _todas,
        FiltroTareas.pendientes => _todas.where((t) => !t.entregada).toList(),
        FiltroTareas.entregadas => _todas.where((t) => t.entregada).toList(),
      };

  int get totalEntregadas => _todas.where((t) => t.entregada).length;
  int get totalPendientes => _todas.where((t) => !t.entregada).length;
  int get totalUrgentes => _todas
      .where((t) => !t.entregada && t.urgencia == Urgencia.hoy)
      .length;

  Future<void> iniciar(int usuarioId) async {
    _usuarioId = usuarioId;
    await recargar();
  }

  Future<void> recargar() async {
    final id = _usuarioId;
    if (id == null) return;
    cargando = true;
    errorCarga = false;
    notifyListeners();
    try {
      _todas = await _repo.listar(id);
    } catch (_) {
      errorCarga = true;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  void cambiarFiltro(FiltroTareas nuevo) {
    filtro = nuevo;
    notifyListeners();
  }

  /// Las operaciones devuelven true si salieron bien, false si fallaron.
  Future<bool> _ejecutar(Future<void> Function() accion) async {
    try {
      await accion();
    } catch (_) {
      return false;
    }
    await recargar();
    return true;
  }

  Future<bool> guardar(Tarea t) => _ejecutar(() => _repo.guardar(t));

  Future<bool> alternarEntregada(Tarea t) =>
      _ejecutar(() => _repo.alternarEntregada(t));

  Future<bool> eliminar(Tarea t) => _ejecutar(() => _repo.eliminar(t));

  Future<void> reprogramarRecordatorios() async {
    final id = _usuarioId;
    if (id == null) return;
    try {
      await _repo.reprogramarTodos(id);
    } catch (_) {}
  }

  /// Al cerrar sesión se limpia todo y se cancelan los avisos del usuario.
  Future<void> limpiar() async {
    await _repo.cancelarTodos();
    _usuarioId = null;
    _todas = [];
    filtro = FiltroTareas.todas;
    errorCarga = false;
    notifyListeners();
  }
}
