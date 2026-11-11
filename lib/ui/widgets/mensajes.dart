import 'package:flutter/material.dart';

/// Retroalimentación al usuario: confirmaciones y errores de operación.
void mostrarMensaje(
  ScaffoldMessengerState mensajero,
  String texto, {
  bool error = false,
}) {
  mensajero
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? const Color(0xFFB3261E) : null,
        content: Row(
          children: [
            Icon(error ? Icons.error_outline : Icons.check_circle_outline,
                color: error ? Colors.white : null),
            const SizedBox(width: 12),
            Expanded(
              child: Text(texto,
                  style: error ? const TextStyle(color: Colors.white) : null),
            ),
          ],
        ),
      ),
    );
}
