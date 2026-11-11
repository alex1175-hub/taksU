import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:tasku/ui/screens/login_screen.dart';
import 'package:tasku/viewmodels/auth_viewmodel.dart';

import 'fakes.dart';

Widget _app() => ChangeNotifierProvider(
      create: (_) => AuthViewModel(FakeAuthRepository()),
      child: const MaterialApp(home: LoginScreen()),
    );

void main() {
  testWidgets('campos vacíos: impide el envío y muestra errores', (tester) async {
    await tester.pumpWidget(_app());

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Escribe tu correo'), findsOneWidget);
    expect(find.text('Escribe tu contraseña'), findsOneWidget);
  });

  testWidgets('contraseña incorrecta: muestra el mensaje de error', (tester) async {
    await tester.pumpWidget(_app());

    await tester.enterText(find.byType(TextField).at(0), 'demo@ucol.mx');
    await tester.enterText(find.byType(TextField).at(1), 'incorrecta1');
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
  });
}
