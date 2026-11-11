import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Contraseñas: hash SHA-256 con sal. Nunca se guardan en texto plano.
class Seguridad {
  static String generarSal() {
    final azar = Random.secure();
    final bytes = List<int>.generate(16, (_) => azar.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String password, String sal) =>
      sha256.convert(utf8.encode('$sal$password')).toString();

  static bool verificar(String password, String sal, String hashGuardado) =>
      hash(password, sal) == hashGuardado;
}
