import 'package:flutter/material.dart';

import '../data/local/sesion_store.dart';

class AjustesViewModel extends ChangeNotifier {
  AjustesViewModel(this._store);
  final SesionStore _store;

  bool modoOscuro = false;
  bool notificaciones = true;

  ThemeMode get themeMode => modoOscuro ? ThemeMode.dark : ThemeMode.light;

  Future<void> cargar() async {
    modoOscuro = await _store.modoOscuro();
    notificaciones = await _store.notificacionesActivas();
    notifyListeners();
  }

  Future<void> cambiarModoOscuro(bool v) async {
    modoOscuro = v;
    notifyListeners();
    await _store.guardarModoOscuro(v);
  }

  Future<void> cambiarNotificaciones(bool v) async {
    notificaciones = v;
    notifyListeners();
    await _store.guardarNotificaciones(v);
  }
}
