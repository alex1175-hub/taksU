import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Notificaciones locales: un aviso un día antes de cada fecha de entrega
/// (equivalente a WorkManager en la versión Android). Sigue funcionando
/// aunque la app esté cerrada.
class RecordatoriosService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _listo = false;

  bool get _soportado => !kIsWeb && Platform.isAndroid;

  Future<void> inicializar() async {
    if (!_soportado) return;
    try {
      tzdata.initializeTimeZones();
      const ajustes = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _plugin.initialize(ajustes);
      _listo = true;
    } catch (_) {
      _listo = false;
    }
  }

  /// Android 13+ pide permiso para mostrar notificaciones.
  Future<void> pedirPermiso() async {
    if (!_listo) return;
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {}
  }

  /// Programa el aviso para las 9:00 a. m. del día anterior a la entrega.
  Future<void> programar({
    required int id,
    required String titulo,
    required String materia,
    required DateTime fechaEntrega,
  }) async {
    if (!_listo) return;
    final aviso = DateTime(
        fechaEntrega.year, fechaEntrega.month, fechaEntrega.day - 1, 9);
    if (!aviso.isAfter(DateTime.now())) {
      await cancelar(id);
      return;
    }
    try {
      await _plugin.zonedSchedule(
        id,
        'Mañana vence una tarea',
        materia.isEmpty ? titulo : '$titulo · $materia',
        // Se convierte el instante absoluto; así no depende de la zona horaria.
        tz.TZDateTime.from(aviso, tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'recordatorios_entrega',
            'Recordatorios de entrega',
            channelDescription: 'Aviso un día antes de la fecha de entrega',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  Future<void> cancelar(int id) async {
    if (!_listo) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  Future<void> cancelarTodos() async {
    if (!_listo) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }
}
