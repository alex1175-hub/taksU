import '../local/daos.dart';
import '../models/dia_festivo.dart';
import '../remote/festivos_api.dart';

class ResultadoFestivos {
  final List<DiaFestivo> festivos;
  final TipoErrorFestivos? error;
  final String? mensajeError;

  const ResultadoFestivos(this.festivos, {this.error, this.mensajeError});

  bool get hayError => error != null;
  bool get sinConexion => error == TipoErrorFestivos.sinConexion;
}

/// Decide de dónde salen los festivos: caché local (SQLite) o API.
/// Solo se consulta internet una vez por año.
class FestivosRepository {
  FestivosRepository(this._dao, this._api);
  final FestivoDao _dao;
  final FestivosApi _api;

  Future<ResultadoFestivos> obtener(int anio) async {
    try {
      final cache = await _dao.porAnio(anio);
      if (cache.isNotEmpty) return ResultadoFestivos(cache);
    } catch (_) {
      // Si la caché falla se intenta con la API.
    }

    try {
      final dtos = await _api.obtener(anio);
      final entidades = dtos.map((d) => d.aEntidad(anio)).toList();
      try {
        await _dao.reemplazarAnio(anio, entidades);
      } catch (_) {
        // Un fallo al guardar la caché no debe ocultar los festivos recibidos.
      }
      return ResultadoFestivos(entidades);
    } on FestivosException catch (e) {
      return ResultadoFestivos(const [], error: e.tipo, mensajeError: e.mensaje);
    } catch (_) {
      return const ResultadoFestivos([],
          error: TipoErrorFestivos.datosInvalidos,
          mensajeError: 'Error inesperado');
    }
  }
}
