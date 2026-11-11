import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/fechas.dart';
import '../../data/models/dia_festivo.dart';
import '../../data/models/tarea.dart';
import '../../data/remote/festivos_api.dart';
import '../../viewmodels/calendario_viewmodel.dart';
import '../../viewmodels/tareas_viewmodel.dart';

const Color _colorFestivo = Color(0xFFD32F2F);

class _Entrada {
  final DateTime fecha;
  final String titulo;
  final String subtitulo;
  final Color color;
  final IconData icono;
  const _Entrada(this.fecha, this.titulo, this.subtitulo, this.color, this.icono);
}

/// Vista mensual con un punto en cada día con entregas y los festivos oficiales.
class CalendarioScreen extends StatelessWidget {
  const CalendarioScreen({super.key});

  List<Tarea> _tareasDelDia(List<Tarea> tareas, DateTime dia) =>
      tareas.where((t) => !t.entregada && mismoDia(t.fechaEntrega, dia)).toList();

  List<_Entrada> _entradas(
      CalendarioViewModel cal, List<Tarea> tareas, DateTime? seleccionado) {
    final lista = <_Entrada>[];
    final hoy = soloFecha(DateTime.now());

    bool incluir(DateTime f) => seleccionado != null
        ? mismoDia(f, seleccionado)
        : !soloFecha(f).isBefore(hoy);

    for (final t in tareas.where((t) => !t.entregada && incluir(t.fechaEntrega))) {
      lista.add(_Entrada(t.fechaEntrega, t.titulo,
          '${t.materiaNombre} · ${t.textoVencimiento}', Color(t.materiaColor),
          Icons.assignment_outlined));
    }
    for (final DiaFestivo f in cal.todosFestivos.where((f) => incluir(f.fecha))) {
      lista.add(_Entrada(f.fecha, f.nombreLocal, 'Día festivo oficial',
          _colorFestivo, Icons.celebration_outlined));
    }
    lista.sort((a, b) => a.fecha.compareTo(b.fecha));
    return seleccionado != null ? lista : lista.take(12).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cal = context.watch<CalendarioViewModel>();
    final tareas = context.watch<TareasViewModel>().todas;
    final tema = Theme.of(context);
    final entradas = _entradas(cal, tareas, cal.diaSeleccionado);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: Column(
        children: [
          TableCalendar<Object>(
            locale: 'es_MX',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: cal.diaEnfocado,
            startingDayOfWeek: StartingDayOfWeek.monday,
            availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
            headerStyle: const HeaderStyle(
                formatButtonVisible: false, titleCentered: true),
            selectedDayPredicate: (d) =>
                cal.diaSeleccionado != null && mismoDia(cal.diaSeleccionado!, d),
            eventLoader: (dia) => <Object>[
              ..._tareasDelDia(tareas, dia),
              ...cal.festivosDe(dia),
            ],
            onDaySelected: cal.seleccionar,
            onPageChanged: cal.cambiarEnfoque,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: tema.colorScheme.primary.withAlpha(60),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(color: tema.colorScheme.onSurface),
              selectedDecoration: BoxDecoration(
                color: tema.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders<Object>(
              markerBuilder: (context, dia, eventos) {
                if (eventos.isEmpty) return null;
                final hayTarea = eventos.any((e) => e is Tarea);
                final hayFestivo = eventos.any((e) => e is DiaFestivo);
                Widget punto(Color c) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1.5),
                      decoration:
                          BoxDecoration(color: c, shape: BoxShape.circle),
                    );
                return Positioned(
                  bottom: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hayTarea) punto(tema.colorScheme.primary),
                      if (hayFestivo) punto(_colorFestivo),
                    ],
                  ),
                );
              },
            ),
          ),
          if (cal.avisoError != null)
            Container(
              width: double.infinity,
              color: tema.colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: Row(
                children: [
                  Icon(
                      cal.error == TipoErrorFestivos.sinConexion
                          ? Icons.cloud_off_outlined
                          : Icons.warning_amber_outlined,
                      size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(cal.avisoError!, style: tema.textTheme.bodySmall),
                  ),
                  TextButton(
                    onPressed: cal.cargando ? null : cal.reintentar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                cal.diaSeleccionado == null
                    ? 'Próximas fechas'
                    : fechaLarga(cal.diaSeleccionado!),
                style: tema.textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            child: entradas.isEmpty
                ? Center(
                    child: Text(
                      cal.diaSeleccionado == null
                          ? 'No hay entregas próximas'
                          : 'Nada programado este día',
                      style: tema.textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: entradas.length,
                    itemBuilder: (context, i) {
                      final e = entradas[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: e.color.withAlpha(40),
                          child: Icon(e.icono, color: e.color),
                        ),
                        title: Text(e.titulo),
                        subtitle: Text('${fechaCorta(e.fecha)} · ${e.subtitulo}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
