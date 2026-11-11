import 'package:flutter/foundation.dart';

/// Controla la pestaña activa de la barra inferior, para que la pantalla de
/// Inicio pueda llevar al usuario a las demás secciones.
class NavegacionViewModel extends ChangeNotifier {
  int indice = 0;

  void ir(int nuevo) {
    if (nuevo == indice) return;
    indice = nuevo;
    notifyListeners();
  }
}
