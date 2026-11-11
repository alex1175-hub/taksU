import 'package:flutter/foundation.dart';

import '../core/fechas.dart';
import '../data/models/dia_festivo.dart';
import '../data/remote/festivos_api.dart';
import '../data/repository/festivos_repository.dart';

class CalendarioViewModel extends ChangeNotifier {
  CalendarioViewModel(this._repo);
  final FestivosRepository _repo;

  final Map<int, List<DiaFestivo>> _porAnio = {};
  TipoErrorFestivos? error;
  bool cargando = false;

  DateTime diaEnfocado = DateTime.now();
  DateTime? diaSeleccionado;

  /// Mensaje discreto para el usuario según el tipo de problema.
  String? get avisoError => switch (error) {
        null => null,
        TipoErrorFestivos.sinConexion =>
          'Sin conexión: se muestran solo tus tareas.',
        TipoErrorFestivos.servidor =>
          'El servicio de festivos no está disponible por ahora.',
        TipoErrorFestivos.respuestaVacia =>
          'El servicio no devolvió festivos para este año.',
        TipoErrorFestivos.datosInvalidos =>
          'No se pudo interpretar la respuesta del servicio de festivos.',
      };

  Future<void> cargarAnio(int anio) async {
    if (_porAnio.containsKey(anio)) return;
    cargando = true;
    notifyListeners();
    final r = await _repo.obtener(anio);
    if (!r.hayError) {
      _porAnio[anio] = r.festivos;
    }
    error = r.error;
    cargando = false;
    notifyListeners();
  }

  Future<void> reintentar() => cargarAnio(diaEnfocado.year);

  List<DiaFestivo> get todosFestivos =>
      _porAnio.values.expand((l) => l).toList();

  List<DiaFestivo> festivosDe(DateTime dia) =>
      todosFestivos.where((f) => mismoDia(f.fecha, dia)).toList();

  void cambiarEnfoque(DateTime dia) {
    diaEnfocado = dia;
    cargarAnio(dia.year);
  }

  void seleccionar(DateTime dia, DateTime enfocado) {
    // Tocar de nuevo el mismo día quita la selección.
    diaSeleccionado =
        (diaSeleccionado != null && mismoDia(diaSeleccionado!, dia)) ? null : dia;
    diaEnfocado = enfocado;
    notifyListeners();
  }
}
