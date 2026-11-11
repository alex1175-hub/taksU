import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tasku/data/remote/festivos_api.dart';
import 'package:tasku/data/repository/festivos_repository.dart';

import 'fakes.dart';

const _jsonOk =
    '[{"date":"2026-11-16","localName":"Día de la Revolución",'
    '"name":"Revolution Day","countryCode":"MX"}]';

http.Response _json(String cuerpo, [int codigo = 200]) => http.Response(
      cuerpo,
      codigo,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

void main() {
  test('sin caché: llama a la API y guarda el resultado', () async {
    final dao = FakeFestivoDao();
    final repo = FestivosRepository(
      dao,
      FestivosApi(cliente: MockClient((_) async => _json(_jsonOk))),
    );

    final r = await repo.obtener(2026);

    expect(r.hayError, isFalse);
    expect(r.festivos, hasLength(1));
    expect(dao.guardados, 1);
    expect(dao.datos[2026], hasLength(1));
  });

  test('con caché: no usa internet', () async {
    final dao = FakeFestivoDao();
    var llamadas = 0;
    final cliente = MockClient((_) async {
      llamadas++;
      return _json(_jsonOk);
    });
    final repo = FestivosRepository(dao, FestivosApi(cliente: cliente));

    await repo.obtener(2026); // llena la caché
    await repo.obtener(2026); // debe salir de la caché

    expect(llamadas, 1);
  });

  test('sin conexión: devuelve error y no guarda nada', () async {
    final dao = FakeFestivoDao();
    final repo = FestivosRepository(
      dao,
      FestivosApi(
        cliente: MockClient((_) async => throw const SocketException('x')),
      ),
    );

    final r = await repo.obtener(2027);

    expect(r.sinConexion, isTrue);
    expect(r.festivos, isEmpty);
    expect(dao.guardados, 0);
  });

  test('respuesta vacía: se reporta y no se guarda en caché', () async {
    final dao = FakeFestivoDao();
    final repo = FestivosRepository(
      dao,
      FestivosApi(cliente: MockClient((_) async => _json('[]'))),
    );

    final r = await repo.obtener(2026);

    expect(r.error, TipoErrorFestivos.respuestaVacia);
    expect(dao.guardados, 0);
  });
}
