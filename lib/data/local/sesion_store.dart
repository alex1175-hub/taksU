import 'package:shared_preferences/shared_preferences.dart';

/// Sesión y preferencias (equivalente a DataStore en la versión Android).
class SesionStore {
  static const _kUsuario = 'usuario_id';
  static const _kOscuro = 'modo_oscuro';
  static const _kNotificaciones = 'notificaciones';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<int?> usuarioId() async => (await _prefs).getInt(_kUsuario);

  Future<void> guardarUsuario(int id) async =>
      (await _prefs).setInt(_kUsuario, id);

  /// Cerrar sesión borra la sesión guardada.
  Future<void> borrarUsuario() async => (await _prefs).remove(_kUsuario);

  Future<bool> modoOscuro() async => (await _prefs).getBool(_kOscuro) ?? false;

  Future<void> guardarModoOscuro(bool v) async =>
      (await _prefs).setBool(_kOscuro, v);

  Future<bool> notificacionesActivas() async =>
      (await _prefs).getBool(_kNotificaciones) ?? true;

  Future<void> guardarNotificaciones(bool v) async =>
      (await _prefs).setBool(_kNotificaciones, v);
}
