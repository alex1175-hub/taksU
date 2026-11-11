import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tasku/data/models/usuario.dart';
import 'package:tasku/data/repository/auth_repository.dart';
import 'package:tasku/ui/screens/login_screen.dart';
import 'package:tasku/viewmodels/auth_viewmodel.dart';

void main() {
  testWidgets('la pantalla de inicio de sesión valida campos vacíos',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthViewModel(_AuthRepositoryFalso()),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('TaskU'), findsOneWidget);
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Escribe tu correo'), findsOneWidget);
    expect(find.text('Escribe tu contraseña'), findsOneWidget);
  });
}

class _AuthRepositoryFalso implements AuthRepository {
  @override
  Future<void> cerrarSesion() async {}

  @override
  Future<bool> correoExiste(String correo) async => false;

  @override
  Future<void> guardarSesion(Usuario usuario) async {}

  @override
  Future<Usuario> registrar(String nombre, String correo, String password) {
    throw UnimplementedError();
  }

  @override
  Future<Usuario?> sesionGuardada() async => null;

  @override
  Future<Usuario?> verificarCredenciales(
          String correo, String password) async =>
      null;
}
