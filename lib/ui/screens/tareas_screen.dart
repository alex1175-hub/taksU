import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/tarea.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/navegacion_viewmodel.dart';
import '../../viewmodels/tareas_viewmodel.dart';
import '../widgets/mensajes.dart';
import '../widgets/tarea_card.dart';
import 'nueva_tarea_screen.dart';

/// Pantalla de Inicio: presenta la app, resume tus tareas y da acceso rápido
/// a las funciones principales.
class TareasScreen extends StatelessWidget {
  const TareasScreen({super.key});

  void _abrirFormulario(BuildContext context, [Tarea? tarea]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NuevaTareaScreen(tarea: tarea)),
    );
  }

  Future<void> _alternar(BuildContext context, Tarea t) async {
    final vm = context.read<TareasViewModel>();
    final mensajero = ScaffoldMessenger.of(context);
    final ok = await vm.alternarEntregada(t);
    mostrarMensaje(
      mensajero,
      ok
          ? (t.entregada ? 'Marcada como pendiente' : 'Marcada como entregada')
          : 'No se pudo actualizar la tarea. Intenta de nuevo.',
      error: !ok,
    );
  }

  Future<void> _confirmarEliminar(BuildContext context, Tarea t) async {
    final vm = context.read<TareasViewModel>();
    final mensajero = ScaffoldMessenger.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Seguro que quieres eliminar "${t.titulo}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmado != true) return;
    final ok = await vm.eliminar(t);
    mostrarMensaje(
      mensajero,
      ok ? 'Tarea eliminada' : 'No se pudo eliminar la tarea. Intenta de nuevo.',
      error: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TareasViewModel>();
    final nombre =
        context.watch<AuthViewModel>().usuario?.nombre.split(' ').first ?? '';
    final tareas = vm.visibles;

    return Scaffold(
      appBar: AppBar(title: const Text('TaskU')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(context),
        tooltip: 'Nueva tarea',
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: 2 + (tareas.isEmpty ? 1 : tareas.length),
        itemBuilder: (context, i) {
          if (i == 0) {
            return _Bienvenida(
              nombre: nombre,
              pendientes: vm.totalPendientes,
              urgentes: vm.totalUrgentes,
              entregadas: vm.totalEntregadas,
              onNuevaTarea: () => _abrirFormulario(context),
            );
          }
          if (i == 1) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: SegmentedButton<FiltroTareas>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                      value: FiltroTareas.todas, label: Text('Todas')),
                  ButtonSegment(
                      value: FiltroTareas.pendientes,
                      label: Text('Pendientes')),
                  ButtonSegment(
                      value: FiltroTareas.entregadas,
                      label: Text('Entregadas')),
                ],
                selected: {vm.filtro},
                onSelectionChanged: (s) => vm.cambiarFiltro(s.first),
              ),
            );
          }
          if (tareas.isEmpty) {
            if (vm.cargando) {
              return const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return _SinTareas(
              errorCarga: vm.errorCarga,
              onReintentar: vm.recargar,
            );
          }
          final t = tareas[i - 2];
          return TareaCard(
            tarea: t,
            onTap: () => _abrirFormulario(context, t),
            onAlternar: () => _alternar(context, t),
            onEliminar: () => _confirmarEliminar(context, t),
          );
        },
      ),
    );
  }
}

class _Bienvenida extends StatelessWidget {
  const _Bienvenida({
    required this.nombre,
    required this.pendientes,
    required this.urgentes,
    required this.entregadas,
    required this.onNuevaTarea,
  });

  final String nombre;
  final int pendientes;
  final int urgentes;
  final int entregadas;
  final VoidCallback onNuevaTarea;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final nav = context.read<NavegacionViewModel>();
    final colorTexto = tema.colorScheme.onPrimaryContainer;

    return Card(
      color: tema.colorScheme.primaryContainer,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: tema.colorScheme.primary,
                  child: Icon(Icons.task_alt, color: tema.colorScheme.onPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hola, $nombre',
                          style: tema.textTheme.titleLarge
                              ?.copyWith(color: colorTexto)),
                      Text(
                        'TaskU reúne tus materias y tareas en un solo lugar.',
                        style: tema.textTheme.bodySmall
                            ?.copyWith(color: colorTexto),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _Dato(valor: pendientes, etiqueta: 'Pendientes', color: colorTexto),
                _Dato(valor: urgentes, etiqueta: 'Urgentes', color: colorTexto),
                _Dato(valor: entregadas, etiqueta: 'Entregadas', color: colorTexto),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.add_task, size: 18),
                  label: const Text('Nueva tarea'),
                  onPressed: onNuevaTarea,
                ),
                ActionChip(
                  avatar: const Icon(Icons.menu_book_outlined, size: 18),
                  label: const Text('Materias'),
                  onPressed: () => nav.ir(1),
                ),
                ActionChip(
                  avatar: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: const Text('Calendario'),
                  onPressed: () => nav.ir(2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.valor, required this.etiqueta, required this.color});
  final int valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text('$valor',
              style: tema.textTheme.headlineSmall
                  ?.copyWith(color: color, fontWeight: FontWeight.bold)),
          Text(etiqueta, style: tema.textTheme.bodySmall?.copyWith(color: color)),
        ],
      ),
    );
  }
}

class _SinTareas extends StatelessWidget {
  const _SinTareas({required this.errorCarga, required this.onReintentar});
  final bool errorCarga;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(errorCarga ? Icons.error_outline : Icons.inbox_outlined,
              size: 64, color: tema.colorScheme.outline),
          const SizedBox(height: 12),
          Text(errorCarga ? 'No se pudieron cargar tus tareas' : 'No hay tareas aquí',
              style: tema.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            errorCarga
                ? 'Revisa e intenta de nuevo.'
                : 'Crea una con el botón +. Antes necesitas al menos una materia.',
            textAlign: TextAlign.center,
            style: tema.textTheme.bodyMedium,
          ),
          if (errorCarga) ...[
            const SizedBox(height: 12),
            FilledButton.tonal(
                onPressed: onReintentar, child: const Text('Reintentar')),
          ],
        ],
      ),
    );
  }
}
