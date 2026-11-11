import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/calendario_viewmodel.dart';
import '../../viewmodels/materias_viewmodel.dart';
import '../../viewmodels/navegacion_viewmodel.dart';
import '../../viewmodels/tareas_viewmodel.dart';
import 'calendario_screen.dart';
import 'materias_screen.dart';
import 'perfil_screen.dart';
import 'tareas_screen.dart';

/// Barra de navegación inferior con cuatro secciones:
/// Inicio, Materias, Calendario y Perfil.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final uid = context.read<AuthViewModel>().usuario?.id;
      if (uid == null) return;
      context.read<MateriasViewModel>().iniciar(uid);
      context.read<TareasViewModel>().iniciar(uid);
      context.read<CalendarioViewModel>().cargarAnio(DateTime.now().year);
    });
  }

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavegacionViewModel>();
    return Scaffold(
      body: IndexedStack(
        index: nav.indice,
        children: const [
          TareasScreen(),
          MateriasScreen(),
          CalendarioScreen(),
          PerfilScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.indice,
        onDestinationSelected: nav.ir,
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Materias'),
          NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Calendario'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Perfil'),
        ],
      ),
    );
  }
}
