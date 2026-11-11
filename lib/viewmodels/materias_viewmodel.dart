import 'package:flutter/foundation.dart';

import '../data/models/materia.dart';
import '../data/repository/materias_repository.dart';

class MateriasViewModel extends ChangeNotifier {
  MateriasViewModel(this._repo);
  final MateriasRepository _repo;

  int? _usuarioId;
  List<Materia> _materias = [];
  String _busqueda = '';
  bool cargando = false;
  bool errorCarga = false;

  List<Materia> get materias => _materias;
  String get busqueda => _busqueda;

  List<Materia> get filtradas {
    final q = _busqueda.trim().toLowerCase();
    if (q.isEmpty) return _materias;
    return _materias.where((m) => m.nombre.toLowerCase().contains(q)).toList();
  }

  Materia? porId(int id) {
    for (final m in _materias) {
      if (m.id == id) return m;
    }
    return null;
  }

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
      _materias = await _repo.listar(id);
    } catch (_) {
      errorCarga = true;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  void buscar(String texto) {
    _busqueda = texto;
    notifyListeners();
  }

  bool existeNombre(String nombre, {int? ignorarId}) {
    final n = nombre.trim().toLowerCase();
    return _materias.any((m) => m.id != ignorarId && m.nombre.toLowerCase() == n);
  }

  /// Devuelve true si la operación salió bien.
  Future<bool> guardar({
    int? id,
    required String nombre,
    required String profesor,
    required int color,
  }) async {
    final uid = _usuarioId;
    if (uid == null) return false;
    try {
      await _repo.guardar(Materia(
        id: id,
        usuarioId: uid,
        nombre: nombre.trim(),
        profesor: profesor.trim(),
        color: color,
      ));
    } catch (_) {
      return false;
    }
    await recargar();
    return true;
  }

  Future<bool> eliminar(Materia m) async {
    try {
      await _repo.eliminar(m);
    } catch (_) {
      return false;
    }
    await recargar();
    return true;
  }

  Future<List<MateriaSugerida>> sugeridasDisponibles() async {
    final catalogo = await _repo.catalogoSugerido();
    return catalogo.where((s) => !existeNombre(s.nombre)).toList();
  }

  void limpiar() {
    _usuarioId = null;
    _materias = [];
    _busqueda = '';
    errorCarga = false;
    notifyListeners();
  }
}
