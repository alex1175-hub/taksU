import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../data/services/recordatorios_service.dart';
import '../../data/services/respaldo_service.dart';
import '../../viewmodels/ajustes_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/materias_viewmodel.dart';
import '../../viewmodels/navegacion_viewmodel.dart';
import '../../viewmodels/tareas_viewmodel.dart';
import '../widgets/mensajes.dart';

/// Estadísticas, ajustes, exportación a JSON y cierre de sesión.
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  Future<void> _exportar(BuildContext context) async {
    final correo = context.read<AuthViewModel>().usuario?.correo ?? '';
    final materias = context.read<MateriasViewModel>().materias;
    final tareas = context.read<TareasViewModel>().todas;
    final respaldo = context.read<RespaldoService>();
    final mensajero = ScaffoldMessenger.of(context);

    try {
      final r = await respaldo.exportar(
          correo: correo, materias: materias, tareas: tareas);
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Respaldo creado'),
          content: Text(
              'Se guardaron ${tareas.length} tareas y ${materias.length} materias en:\n\n${r.ruta}'),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: r.json));
                if (ctx.mounted) Navigator.pop(ctx);
                mensajero.showSnackBar(
                    const SnackBar(content: Text('JSON copiado al portapapeles')));
              },
              child: const Text('Copiar JSON'),
            ),
            FilledButton(
                onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
          ],
        ),
      );
    } catch (_) {
      mensajero.showSnackBar(
          const SnackBar(content: Text('No se pudo crear el respaldo')));
    }
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    final auth = context.read<AuthViewModel>();
    final tareas = context.read<TareasViewModel>();
    final materias = context.read<MateriasViewModel>();
    final nav = context.read<NavegacionViewModel>();
    final mensajero = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('Se borrará la sesión guardada en este dispositivo.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cerrar sesión')),
        ],
      ),
    );
    if (ok != true) return;
    await tareas.limpiar();
    materias.limpiar();
    nav.ir(0);
    await auth.cerrarSesion();
    mostrarMensaje(mensajero, 'Sesión cerrada');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final usuario = context.watch<AuthViewModel>().usuario;
    final tareas = context.watch<TareasViewModel>();
    final materias = context.watch<MateriasViewModel>();
    final ajustes = context.watch<AjustesViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: tema.colorScheme.primaryContainer,
              child: Text(usuario?.iniciales ?? '',
                  style: tema.textTheme.headlineSmall?.copyWith(
                      color: tema.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          Text(usuario?.nombre ?? '',
              textAlign: TextAlign.center, style: tema.textTheme.titleLarge),
          Text(usuario?.correo ?? '',
              textAlign: TextAlign.center, style: tema.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text('Estadísticas', style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              _Estadistica(
                  valor: tareas.totalEntregadas,
                  etiqueta: 'Entregadas',
                  color: const Color(0xFF388E3C)),
              _Estadistica(
                  valor: tareas.totalPendientes,
                  etiqueta: 'Pendientes',
                  color: const Color(0xFFF57C00)),
              _Estadistica(
                  valor: materias.materias.length,
                  etiqueta: 'Materias',
                  color: tema.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 24),
          Text('Ajustes', style: tema.textTheme.titleMedium),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.dark_mode_outlined),
            title: const Text('Modo oscuro'),
            value: ajustes.modoOscuro,
            onChanged: ajustes.cambiarModoOscuro,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Notificaciones'),
            subtitle: const Text('Recordatorio un día antes de cada entrega'),
            value: ajustes.notificaciones,
            onChanged: (v) async {
              final recordatorios = context.read<RecordatoriosService>();
              await ajustes.cambiarNotificaciones(v);
              if (v) await recordatorios.pedirPermiso();
              await tareas.reprogramarRecordatorios();
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.data_object),
            title: const Text('Exportar a JSON'),
            subtitle: const Text('Respaldo de todas tus tareas'),
            onTap: () => _exportar(context),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de TaskU'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'TaskU',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.task_alt, size: 40),
              children: const [
                Text('Aplicación móvil para la gestión de tareas escolares.\n\n'
                    'Proyecto final de Programación de Aplicaciones · '
                    'Facultad de Telemática, Universidad de Colima.'),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _cerrarSesion(context),
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar sesión'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  const _Estadistica(
      {required this.valor, required this.etiqueta, required this.color});
  final int valor;
  final String etiqueta;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text('$valor',
                  style: tema.textTheme.headlineMedium
                      ?.copyWith(color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(etiqueta, style: tema.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
