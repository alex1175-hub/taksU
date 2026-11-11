import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'data/local/sesion_store.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/festivos_repository.dart';
import 'data/repository/materias_repository.dart';
import 'data/repository/tareas_repository.dart';
import 'data/services/recordatorios_service.dart';
import 'data/services/respaldo_service.dart';
import 'ui/screens/home_shell.dart';
import 'ui/screens/login_screen.dart';
import 'viewmodels/ajustes_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/calendario_viewmodel.dart';
import 'viewmodels/materias_viewmodel.dart';
import 'viewmodels/navegacion_viewmodel.dart';
import 'viewmodels/tareas_viewmodel.dart';

/// Contenedor sencillo de dependencias creadas en main().
class Dependencias {
  final AuthRepository auth;
  final TareasRepository tareas;
  final MateriasRepository materias;
  final FestivosRepository festivos;
  final SesionStore sesion;
  final RecordatoriosService recordatorios;
  final RespaldoService respaldo;

  const Dependencias({
    required this.auth,
    required this.tareas,
    required this.materias,
    required this.festivos,
    required this.sesion,
    required this.recordatorios,
    required this.respaldo,
  });
}

class TaskUApp extends StatelessWidget {
  const TaskUApp({super.key, required this.dependencias});
  final Dependencias dependencias;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RecordatoriosService>.value(value: dependencias.recordatorios),
        Provider<RespaldoService>.value(value: dependencias.respaldo),
        ChangeNotifierProvider(
            create: (_) => AuthViewModel(dependencias.auth)..iniciar()),
        ChangeNotifierProvider(
            create: (_) => AjustesViewModel(dependencias.sesion)..cargar()),
        ChangeNotifierProvider(create: (_) => NavegacionViewModel()),
        ChangeNotifierProvider(create: (_) => TareasViewModel(dependencias.tareas)),
        ChangeNotifierProvider(
            create: (_) => MateriasViewModel(dependencias.materias)),
        ChangeNotifierProvider(
            create: (_) => CalendarioViewModel(dependencias.festivos)),
      ],
      child: Consumer<AjustesViewModel>(
        builder: (context, ajustes, _) => MaterialApp(
          title: 'TaskU',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro(),
          darkTheme: AppTheme.oscuro(),
          themeMode: ajustes.themeMode,
          locale: const Locale('es', 'MX'),
          supportedLocales: const [Locale('es', 'MX'), Locale('es')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const _PuertaDeAcceso(),
        ),
      ),
    );
  }
}

/// Acceso controlado: solo entra quien tiene sesión activa.
class _PuertaDeAcceso extends StatelessWidget {
  const _PuertaDeAcceso();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    if (!auth.inicializado) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.usuario == null ? const LoginScreen() : const HomeShell();
  }
}
