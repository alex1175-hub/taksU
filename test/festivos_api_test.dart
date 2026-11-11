import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tasku/data/remote/festivos_api.dart';

const _jsonOk =
    '[{"date":"2026-11-16","localName":"Día de la Revolución",'
    '"name":"Revolution Day","countryCode":"MX"}]';

http.Response _json(String cuerpo, [int codigo = 200]) => http.Response(
      cuerpo,
      codigo,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

Matcher _falla(TipoErrorFestivos tipo) => throwsA(
      isA<FestivosException>().having((e) => e.tipo, 'tipo', tipo),
    );

void main() {
  test('consulta el endpoint correcto y procesa la respuesta JSON', () async {
    late Uri pedida;
    final api = FestivosApi(
      cliente: MockClient((req) async {
        pedida = req.url;
        return _json(_jsonOk);
      }),
    );

    final lista = await api.obtener(2026);

    expect(pedida.host, 'date.nager.at');
    expect(pedida.path, '/api/v3/PublicHolidays/2026/MX');
    expect(lista, hasLength(1));
    expect(lista.first.localName, 'Día de la Revolución');

    final entidad = lista.first.aEntidad(2026);
    expect(entidad.fecha, DateTime(2026, 11, 16));
    expect(entidad.codigoPais, 'MX');
    expect(entidad.anio, 2026);
  });

  test('error del servidor (500)', () {
    final api = FestivosApi(cliente: MockClient((_) async => _json('', 500)));
    expect(api.obtener(2026), _falla(TipoErrorFestivos.servidor));
  });

  test('respuesta vacía', () {
    final api = FestivosApi(cliente: MockClient((_) async => _json('[]')));
    expect(api.obtener(2026), _falla(TipoErrorFestivos.respuestaVacia));
  });

  test('respuesta con formato inválido', () {
    final api =
        FestivosApi(cliente: MockClient((_) async => _json('esto no es json')));
    expect(api.obtener(2026), _falla(TipoErrorFestivos.datosInvalidos));
  });

  test('falta de conexión (ClientException)', () {
    final api = FestivosApi(
      cliente: MockClient((_) async => throw http.ClientException('sin red')),
    );
    expect(api.obtener(2026), _falla(TipoErrorFestivos.sinConexion));
  });

  test('falta de conexión (SocketException)', () {
    final api = FestivosApi(
      cliente: MockClient((_) async => throw const SocketException('sin red')),
    );
    expect(api.obtener(2026), _falla(TipoErrorFestivos.sinConexion));
  });
}
