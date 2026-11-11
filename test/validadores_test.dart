import 'package:flutter_test/flutter_test.dart';
import 'package:tasku/core/seguridad.dart';
import 'package:tasku/core/validadores.dart';

void main() {
  group('Validadores', () {
    test('correo debe ser @ucol.mx', () {
      expect(Validadores.correo('alumno@ucol.mx'), isNull);
      expect(Validadores.correo('alumno@gmail.com'), 'Usa un correo @ucol.mx válido');
      expect(Validadores.correo('sin-arroba'), 'Usa un correo @ucol.mx válido');
    });

    test('contraseña: 8+ caracteres, letra y número', () {
      expect(Validadores.password('abc12345'), isNull);
      expect(Validadores.password('abc1'), 'Mínimo 8 caracteres, 1 número');
      expect(Validadores.password('abcdefgh'), 'Mínimo 8 caracteres, 1 número');
      expect(Validadores.password('12345678'), 'Mínimo 8 caracteres, 1 número');
    });

    test('confirmar contraseña', () {
      expect(Validadores.confirmar('a', 'a'), isNull);
      expect(Validadores.confirmar('a', 'b'), 'Las contraseñas no coinciden');
    });

    test('título de 3 a 60 caracteres', () {
      expect(Validadores.titulo('ab'), isNotNull);
      expect(Validadores.titulo('Práctica 3'), isNull);
      expect(Validadores.titulo('x' * 61), isNotNull);
    });

    test('fecha no anterior a hoy', () {
      final ayer = DateTime.now().subtract(const Duration(days: 1));
      final manana = DateTime.now().add(const Duration(days: 1));
      expect(Validadores.fecha(ayer), 'La fecha no puede ser anterior a hoy');
      expect(Validadores.fecha(manana), isNull);
      expect(Validadores.fecha(null), isNotNull);
    });

    test('descripción máximo 300', () {
      expect(Validadores.descripcion('x' * 300), isNull);
      expect(Validadores.descripcion('x' * 301), 'Máximo 300 caracteres');
    });
  });

  group('Seguridad', () {
    test('hash con sal es verificable y no guarda texto plano', () {
      final sal = Seguridad.generarSal();
      final h = Seguridad.hash('clave1234', sal);
      expect(h, isNot(contains('clave1234')));
      expect(Seguridad.verificar('clave1234', sal, h), isTrue);
      expect(Seguridad.verificar('otra12345', sal, h), isFalse);
    });

    test('la misma contraseña con distinta sal da distinto hash', () {
      final h1 = Seguridad.hash('clave1234', Seguridad.generarSal());
      final h2 = Seguridad.hash('clave1234', Seguridad.generarSal());
      expect(h1, isNot(h2));
    });
  });
}
