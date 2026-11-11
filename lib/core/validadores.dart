import 'fechas.dart';

/// Reglas de validación de la sección "Cada campo se revisa".
/// Cada función devuelve el mensaje de error o null si el valor es válido.
class Validadores {
  static final RegExp _formatoCorreo = RegExp(r'^[\w.+\-]+@[\w\-]+(\.[\w\-]+)+$');
  static final RegExp _letra = RegExp(r'[A-Za-z]');
  static final RegExp _numero = RegExp(r'\d');

  static String? nombre(String v) =>
      v.trim().length < 2 ? 'Escribe tu nombre' : null;

  static String? correo(String v) {
    final c = v.trim().toLowerCase();
    if (!_formatoCorreo.hasMatch(c) || !c.endsWith('@ucol.mx')) {
      return 'Usa un correo @ucol.mx válido';
    }
    return null;
  }

  static String? password(String v) {
    final valor = v.trim();
    if (valor.length < 8 || !_letra.hasMatch(valor) || !_numero.hasMatch(valor)) {
      return 'Mínimo 8 caracteres, 1 número';
    }
    return null;
  }

  static String? confirmar(String pass, String confirmacion) {
    if (pass.isEmpty || confirmacion.isEmpty) {
      return 'Las contraseñas no coinciden';
    }
    return pass == confirmacion ? null : 'Las contraseñas no coinciden';
  }

  static String? titulo(String v) {
    final t = v.trim();
    return (t.length < 3 || t.length > 60)
        ? 'Escribe un título de 3 a 60 caracteres'
        : null;
  }

  static String? materia(int? id) => id == null ? 'Selecciona una materia' : null;

  /// [original] permite conservar la fecha de una tarea ya vencida al editarla.
  static String? fecha(DateTime? f, {DateTime? original}) {
    if (f == null) return 'Selecciona una fecha de entrega';
    final hoy = soloFecha(DateTime.now());
    final cambio = original == null || !mismoDia(f, original);
    if (cambio && soloFecha(f).isBefore(hoy)) {
      return 'La fecha no puede ser anterior a hoy';
    }
    return null;
  }

  static String? descripcion(String v) =>
      v.trim().length > 300 ? 'Máximo 300 caracteres' : null;

  static String? nombreMateria(String v) =>
      v.trim().length < 2 || v.trim().length > 40
          ? 'Escribe el nombre de la materia (2 a 40 caracteres)'
          : null;

  static String? profesor(String v) =>
      v.trim().length < 3 ? 'Escribe el nombre del profesor' : null;
}
