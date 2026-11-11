import 'package:flutter_test/flutter_test.dart';
import 'package:tasku/viewmodels/auth_viewmodel.dart';

import 'fakes.dart';

void main() {
  late AuthViewModel vm;

  setUp(() => vm = AuthViewModel(FakeAuthRepository()));

  group('Inicio de sesión', () {
    test('credenciales correctas dan acceso', () async {
      final error = await vm.iniciarSesion('demo@ucol.mx', 'Demo1234');
      expect(error, isNull);
      expect(vm.usuario, isNotNull);
    });

    test('contraseña incorrecta muestra mensaje y no da acceso', () async {
      final error = await vm.iniciarSesion('demo@ucol.mx', 'incorrecta1');
      expect(error, 'Correo o contraseña incorrectos');
      expect(vm.usuario, isNull);
    });

    test('5 intentos fallidos bloquean 30 s, incluso con datos correctos', () async {
      for (var i = 0; i < 5; i++) {
        await vm.iniciarSesion('demo@ucol.mx', 'mala$i');
      }
      expect(vm.bloqueado, isTrue);
      expect(vm.segundosBloqueo, inInclusiveRange(1, 30));

      final error = await vm.iniciarSesion('demo@ucol.mx', 'Demo1234');
      expect(error, isNotNull);
      expect(vm.usuario, isNull);
    });

    test('cerrar sesión borra el usuario activo', () async {
      await vm.iniciarSesion('demo@ucol.mx', 'Demo1234');
      await vm.cerrarSesion();
      expect(vm.usuario, isNull);
    });
  });

  group('Registro', () {
    test('rechaza datos inválidos campo por campo', () async {
      final errores = await vm.registrar(
        nombre: '',
        correo: 'alguien@gmail.com',
        password: 'corta',
        confirmar: 'distinta',
      );
      expect(errores.keys,
          containsAll(['nombre', 'correo', 'password', 'confirmar']));
      expect(vm.usuario, isNull);
    });

    test('rechaza un correo ya registrado', () async {
      final errores = await vm.registrar(
        nombre: 'Otra Persona',
        correo: 'demo@ucol.mx',
        password: 'Abcd1234',
        confirmar: 'Abcd1234',
      );
      expect(errores['correo'], 'Ese correo ya está registrado');
    });

    test('registro válido crea la sesión', () async {
      final errores = await vm.registrar(
        nombre: 'Nueva Persona',
        correo: 'nueva@ucol.mx',
        password: 'Abcd1234',
        confirmar: 'Abcd1234',
      );
      expect(errores, isEmpty);
      expect(vm.usuario, isNotNull);
    });
  });
}
