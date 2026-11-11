import 'package:flutter/foundation.dart';

import '../core/validadores.dart';
import '../data/models/usuario.dart';
import '../data/repository/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repo);
  final AuthRepository _repo;

  static const int _maxIntentos = 5;
  static const Duration _duracionBloqueo = Duration(seconds: 30);

  Usuario? usuario;
  bool inicializado = false;
  bool cargando = false;

  int _fallos = 0;
  DateTime? _bloqueadoHasta;

  Future<void> iniciar() async {
    try {
      usuario = await _repo.sesionGuardada();
    } catch (_) {
      usuario = null;
    }
    inicializado = true;
    notifyListeners();
  }

  bool get bloqueado => segundosBloqueo > 0;

  int get segundosBloqueo {
    final hasta = _bloqueadoHasta;
    if (hasta == null) return 0;
    final ms = hasta.difference(DateTime.now()).inMilliseconds;
    if (ms <= 0) {
      _bloqueadoHasta = null;
      return 0;
    }
    return (ms / 1000).ceil();
  }

  /// Devuelve el mensaje de error, o null si entró correctamente.
  Future<String?> iniciarSesion(String correo, String password) async {
    if (bloqueado) {
      return 'Demasiados intentos fallidos. Espera $segundosBloqueo s.';
    }
    cargando = true;
    notifyListeners();
    try {
      final u = await _repo.verificarCredenciales(
          correo.trim().toLowerCase(), password);
      if (u == null) {
        _fallos++;
        if (_fallos >= _maxIntentos) {
          _fallos = 0;
          _bloqueadoHasta = DateTime.now().add(_duracionBloqueo);
          return 'Demasiados intentos fallidos. Espera 30 s.';
        }
        return 'Correo o contraseña incorrectos';
      }
      _fallos = 0;
      await _repo.guardarSesion(u);
      usuario = u;
      return null;
    } catch (_) {
      return 'Ocurrió un error al iniciar sesión. Intenta de nuevo.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Devuelve un mapa campo → mensaje. Vacío significa que el registro fue exitoso.
  /// La clave `general` se usa para errores que no pertenecen a un campo.
  Future<Map<String, String>> registrar({
    required String nombre,
    required String correo,
    required String password,
    required String confirmar,
  }) async {
    final errores = <String, String>{};
    final eNombre = Validadores.nombre(nombre);
    final eCorreo = Validadores.correo(correo);
    final ePass = Validadores.password(password);
    final eConf = Validadores.confirmar(password, confirmar);
    if (eNombre != null) errores['nombre'] = eNombre;
    if (eCorreo != null) errores['correo'] = eCorreo;
    if (ePass != null) errores['password'] = ePass;
    if (eConf != null) errores['confirmar'] = eConf;

    cargando = true;
    notifyListeners();
    try {
      final correoLimpio = correo.trim().toLowerCase();
      if (eCorreo == null && await _repo.correoExiste(correoLimpio)) {
        errores['correo'] = 'Ese correo ya está registrado';
      }
      if (errores.isNotEmpty) return errores;

      final nuevo = await _repo.registrar(nombre, correoLimpio, password);
      await _repo.guardarSesion(nuevo);
      usuario = nuevo;
      return errores;
    } catch (_) {
      errores['general'] = 'No se pudo crear la cuenta. Intenta de nuevo.';
      return errores;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _repo.cerrarSesion();
    } finally {
      usuario = null;
      notifyListeners();
    }
  }
}
