import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/fechas.dart';
import '../../core/validadores.dart';
import '../../data/models/tarea.dart';
import '../../data/services/recordatorios_service.dart';
import '../../viewmodels/materias_viewmodel.dart';
import '../../viewmodels/tareas_viewmodel.dart';
import '../widgets/mensajes.dart';

/// Formulario para crear o editar una tarea.
class NuevaTareaScreen extends StatefulWidget {
  const NuevaTareaScreen({super.key, this.tarea});
  final Tarea? tarea;

  @override
  State<NuevaTareaScreen> createState() => _NuevaTareaScreenState();
}

class _NuevaTareaScreenState extends State<NuevaTareaScreen> {
  late final TextEditingController _titulo;
  late final TextEditingController _descripcion;
  int? _materiaId;
  DateTime? _fecha;
  Prioridad _prioridad = Prioridad.media;
  bool _recordatorio = false;
  bool _guardando = false;

  String? _errTitulo, _errMateria, _errFecha, _errDescripcion;

  bool get _esEdicion => widget.tarea != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tarea;
    _titulo = TextEditingController(text: t?.titulo ?? '');
    _descripcion = TextEditingController(text: t?.descripcion ?? '');
    _materiaId = t?.materiaId;
    _fecha = t?.fechaEntrega;
    _prioridad = t?.prioridad ?? Prioridad.media;
    _recordatorio = t?.recordatorio ?? false;
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = soloFecha(DateTime.now());
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fecha ?? hoy,
      firstDate: DateTime(hoy.year - 1),
      lastDate: DateTime(hoy.year + 3),
    );
    if (elegida != null) {
      setState(() {
        _fecha = elegida;
        _errFecha = null;
      });
    }
  }

  Future<void> _guardar() async {
    setState(() {
      _errTitulo = Validadores.titulo(_titulo.text);
      _errMateria = Validadores.materia(_materiaId);
      _errFecha = Validadores.fecha(_fecha, original: widget.tarea?.fechaEntrega);
      _errDescripcion = Validadores.descripcion(_descripcion.text);
    });
    if ([_errTitulo, _errMateria, _errFecha, _errDescripcion]
        .any((e) => e != null)) {
      return;
    }

    final tareasVm = context.read<TareasViewModel>();
    final materia = context.read<MateriasViewModel>().porId(_materiaId!);
    final navegador = Navigator.of(context);
    final mensajero = ScaffoldMessenger.of(context);

    setState(() => _guardando = true);
    final ok = await tareasVm.guardar(Tarea(
      id: widget.tarea?.id,
      materiaId: _materiaId!,
      titulo: _titulo.text.trim(),
      descripcion: _descripcion.text.trim(),
      fechaEntrega: soloFecha(_fecha!),
      prioridad: _prioridad,
      entregada: widget.tarea?.entregada ?? false,
      recordatorio: _recordatorio,
      materiaNombre: materia?.nombre ?? '',
      materiaColor: materia?.color ?? 0xFF3F51B5,
    ));
    if (!mounted) return;
    if (ok) {
      mostrarMensaje(
          mensajero, _esEdicion ? 'Tarea actualizada' : 'Tarea guardada');
      navegador.pop();
    } else {
      setState(() => _guardando = false);
      mostrarMensaje(
          mensajero, 'No se pudo guardar la tarea. Intenta de nuevo.',
          error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final materias = context.watch<MateriasViewModel>().materias;

    return Scaffold(
      appBar: AppBar(title: Text(_esEdicion ? 'Editar tarea' : 'Nueva tarea')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _titulo,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  InputDecoration(labelText: 'Título', errorText: _errTitulo),
            ),
            const SizedBox(height: 16),
            if (materias.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tema.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Aún no tienes materias. Crea una en la pestaña Materias para poder registrar tareas.',
                  style: TextStyle(color: tema.colorScheme.onErrorContainer),
                ),
              )
            else
              DropdownMenu<int>(
                initialSelection: _materiaId,
                label: const Text('Materia'),
                errorText: _errMateria,
                expandedInsets: EdgeInsets.zero,
                dropdownMenuEntries: [
                  for (final m in materias)
                    DropdownMenuEntry(value: m.id!, label: m.nombre),
                ],
                onSelected: (v) => setState(() {
                  _materiaId = v;
                  _errMateria = null;
                }),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.event),
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(_fecha == null
                    ? 'Fecha de entrega'
                    : fechaLarga(_fecha!)),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide(
                    color: _errFecha != null
                        ? tema.colorScheme.error
                        : tema.colorScheme.outline),
              ),
            ),
            if (_errFecha != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 0, 0),
                child: Text(_errFecha!,
                    style: tema.textTheme.bodySmall
                        ?.copyWith(color: tema.colorScheme.error)),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcion,
              maxLines: 4,
              maxLength: 300,
              maxLengthEnforcement: MaxLengthEnforcement.none,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) => setState(() => _errDescripcion = null),
              decoration: InputDecoration(
                labelText: 'Descripción (opcional)',
                alignLabelWithHint: true,
                errorText: _errDescripcion,
              ),
            ),
            const SizedBox(height: 8),
            Text('Prioridad', style: tema.textTheme.labelLarge),
            const SizedBox(height: 8),
            SegmentedButton<Prioridad>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: Prioridad.baja, label: Text('Baja')),
                ButtonSegment(value: Prioridad.media, label: Text('Media')),
                ButtonSegment(value: Prioridad.alta, label: Text('Alta')),
              ],
              selected: {_prioridad},
              onSelectionChanged: (s) => setState(() => _prioridad = s.first),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recordatorio'),
              subtitle: const Text('Te avisamos un día antes de la entrega'),
              value: _recordatorio,
              onChanged: (v) {
                setState(() => _recordatorio = v);
                if (v) context.read<RecordatoriosService>().pedirPermiso();
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: (_guardando || materias.isEmpty) ? null : _guardar,
              child: Text(_esEdicion ? 'Guardar cambios' : 'Guardar tarea'),
            ),
          ],
        ),
      ),
    );
  }
}
