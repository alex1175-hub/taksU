import 'dart:async';
import 'dart:convert';
import 'dart:io' show SocketException;

import 'package:http/http.dart' as http;

import '../models/dia_festivo.dart';

/// Objeto de transferencia que representa un elemento de la respuesta JSON.
class FestivoDto {
  final String date;
  final String localName;
  final String name;
  final String countryCode;

  const FestivoDto({
    required this.date,
    required this.localName,
    required this.name,
    required this.countryCode,
  });

  factory FestivoDto.fromJson(Map<String, dynamic> j) => FestivoDto(
        date: j['date'] as String,
        localName: j['localName'] as String,
        name: j['name'] as String,
        countryCode: j['countryCode'] as String,
      );

  DiaFestivo aEntidad(int anio) {
    final p = date.split('-').map(int.parse).toList();
    return DiaFestivo(
      fecha: DateTime(p[0], p[1], p[2]),
      nombreLocal: localName,
      nombre: name,
      codigoPais: countryCode,
      anio: anio,
    );
  }
}

/// Tipos de problema al consumir el servicio externo.
enum TipoErrorFestivos { sinConexion, servidor, respuestaVacia, datosInvalidos }

class FestivosException implements Exception {
  final TipoErrorFestivos tipo;
  final String mensaje;
  const FestivosException(this.tipo, this.mensaje);

  @override
  String toString() => 'FestivosException($tipo): $mensaje';
}

/// API pública Nager.Date (sin registro ni llave):
/// GET https://date.nager.at/api/v3/PublicHolidays/{anio}/MX
class FestivosApi {
  FestivosApi({http.Client? cliente}) : _cliente = cliente ?? http.Client();
  final http.Client _cliente;

  Future<List<FestivoDto>> obtener(int anio, {String pais = 'MX'}) async {
    final uri = Uri.https('date.nager.at', '/api/v3/PublicHolidays/$anio/$pais');

    final http.Response r;
    try {
      r = await _cliente.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const FestivosException(
          TipoErrorFestivos.sinConexion, 'Se agotó el tiempo de espera');
    } on SocketException {
      throw const FestivosException(
          TipoErrorFestivos.sinConexion, 'No hay conexión a internet');
    } on http.ClientException {
      throw const FestivosException(
          TipoErrorFestivos.sinConexion, 'No se pudo conectar con el servicio');
    }

    if (r.statusCode != 200) {
      throw FestivosException(TipoErrorFestivos.servidor,
          'El servicio respondió con el código ${r.statusCode}');
    }

    final dtos = _interpretar(r.body);
    if (dtos.isEmpty) {
      throw const FestivosException(
          TipoErrorFestivos.respuestaVacia, 'El servicio no devolvió festivos');
    }
    return dtos;
  }

  List<FestivoDto> _interpretar(String cuerpo) {
    try {
      final lista = jsonDecode(cuerpo) as List<dynamic>;
      return lista
          .map((e) => FestivoDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      throw const FestivosException(
          TipoErrorFestivos.datosInvalidos, 'La respuesta no tiene el formato esperado');
    }
  }
}
