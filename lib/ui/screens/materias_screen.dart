import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/validadores.dart';
import '../../data/models/materia.dart';
import '../../viewmodels/materias_viewmodel.dart';
import '../../viewmodels/tareas_viewmodel.dart';
import '../widgets/mensajes.dart';

/// CRUD de materias con búsqueda y catálogo sugerido (leído de un JSON).
class MateriasScreen extends StatelessWidget {
  const MateriasScreen({super.key});

  void _abrirFormulario(BuildContext context, [Materia? materia]) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: _FormularioMateria(materia: materia),
      ),
    );
  }

  void _abrirSugeridas(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SugeridasSheet(),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context, Materia m) async {
    final vm = context.read<MateriasViewModel>();
    final tareasVm = context.read<TareasViewModel>();
    final mensajero = ScaffoldMessenger.of(context);
    final cuantas = tareasVm.todas.where((t) => t.materiaId == m.id).length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar materia'),
        content: Text(cuantas == 0
            ? '¿Eliminar "${m.nombre}"?'
            : '¿Eliminar "${m.nombre}"? También se eliminarán sus $cuantas '
                '${cuantas == 1 ? 'tarea' : 'tareas'}.'),
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
    if (ok == true) {
      final borrada = await vm.eliminar(m);
      await tareasVm.recargar(); // sus tareas se borraron en cascada
      mostrarMensaje(
        mensajero,
        borrada
            ? 'Materia eliminada'
            : 'No se pudo eliminar la materia. Intenta de nuevo.',
        error: !borrada,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MateriasViewModel>();
    final lista = vm.filtradas;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materias'),
        actions: [
          IconButton(
            tooltip: 'Materias sugeridas',
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () => _abrirSugeridas(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirFormulario(context),
        tooltip: 'Nueva materia',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: vm.buscar,
              decoration: InputDecoration(
                hintText: 'Buscar materia',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28)),
              ),
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            vm.materias.isEmpty
                                ? 'Aún no tienes materias'
                                : 'Sin resultados',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          if (vm.materias.isEmpty)
                            FilledButton.tonalIcon(
                              onPressed: () => _abrirSugeridas(context),
                              icon: const Icon(Icons.lightbulb_outline),
                              label: const Text('Ver materias sugeridas'),
                            ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: lista.length,
                    itemBuilder: (context, i) {
                      final m = lista[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: m.colorMaterial,
                          child: Text(m.nombre[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text(m.nombre),
                        subtitle: Text(m.profesor),
                        onTap: () => _abrirFormulario(context, m),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'editar') _abrirFormulario(context, m);
                            if (v == 'eliminar') _confirmarEliminar(context, m);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'editar', child: Text('Editar')),
                            PopupMenuItem(
                                value: 'eliminar', child: Text('Eliminar')),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FormularioMateria extends StatefulWidget {
  const _FormularioMateria({this.materia});
  final Materia? materia;

  @override
  State<_FormularioMateria> createState() => _FormularioMateriaState();
}

class _FormularioMateriaState extends State<_FormularioMateria> {
  late final TextEditingController _nombre;
  late final TextEditingController _profesor;
  late int _color;
  String? _errNombre;
  String? _errProfesor;

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.materia?.nombre ?? '');
    _profesor = TextEditingController(text: widget.materia?.profesor ?? '');
    _color = widget.materia?.color ?? paletaColores.first;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _profesor.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final vm = context.read<MateriasViewModel>();
    final navegador = Navigator.of(context);
    final mensajero = ScaffoldMessenger.of(context);
    var eNombre = Validadores.nombreMateria(_nombre.text);
    if (eNombre == null &&
        vm.existeNombre(_nombre.text, ignorarId: widget.materia?.id)) {
      eNombre = 'Ya tienes una materia con ese nombre';
    }
    final eProfesor = Validadores.profesor(_profesor.text);
    setState(() {
      _errNombre = eNombre;
      _errProfesor = eProfesor;
    });
    if (eNombre != null || eProfesor != null) return;

    final editando = widget.materia != null;
    final ok = await vm.guardar(
      id: widget.materia?.id,
      nombre: _nombre.text,
      profesor: _profesor.text,
      color: _color,
    );
    if (!mounted) return;
    if (ok) {
      navegador.pop();
    }
    mostrarMensaje(
      mensajero,
      ok
          ? (editando ? 'Materia actualizada' : 'Materia guardada')
          : 'No se pudo guardar la materia. Intenta de nuevo.',
      error: !ok,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.materia == null ? 'Nueva materia' : 'Editar materia',
              style: tema.textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nombre,
            textCapitalization: TextCapitalization.words,
            decoration:
                InputDecoration(labelText: 'Nombre', errorText: _errNombre),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _profesor,
            textCapitalization: TextCapitalization.words,
            decoration:
                InputDecoration(labelText: 'Profesor', errorText: _errProfesor),
          ),
          const SizedBox(height: 16),
          Text('Color', style: tema.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in paletaColores)
                GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(c),
                    child: _color == c
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _guardar, child: const Text('Guardar')),
        ],
      ),
    );
  }
}

/// Catálogo de materias sugeridas leído del archivo JSON incluido en la app.
class _SugeridasSheet extends StatefulWidget {
  const _SugeridasSheet();

  @override
  State<_SugeridasSheet> createState() => _SugeridasSheetState();
}

class _SugeridasSheetState extends State<_SugeridasSheet> {
  late Future<List<MateriaSugerida>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = context.read<MateriasViewModel>().sugeridasDisponibles();
  }

  Future<void> _agregar(MateriaSugerida s) async {
    final vm = context.read<MateriasViewModel>();
    final mensajero = ScaffoldMessenger.of(context);
    final ok = await vm.guardar(
      nombre: s.nombre,
      profesor: s.profesor.isEmpty ? 'Por asignar' : s.profesor,
      color: s.color,
    );
    if (!mounted) return;
    mostrarMensaje(
      mensajero,
      ok ? '${s.nombre} agregada' : 'No se pudo agregar la materia.',
      error: !ok,
    );
    setState(() => _futuro = vm.sugeridasDisponibles());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Materias sugeridas',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            Flexible(
              child: FutureBuilder<List<MateriaSugerida>>(
                future: _futuro,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    );
                  }
                  final lista = snap.data ?? [];
                  if (lista.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Ya agregaste todas las materias sugeridas.'),
                    );
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      for (final s in lista)
                        ListTile(
                          leading: CircleAvatar(
                              backgroundColor: Color(s.color),
                              radius: 12),
                          title: Text(s.nombre),
                          trailing: FilledButton.tonal(
                            onPressed: () => _agregar(s),
                            child: const Text('Agregar'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
