import 'package:flutter/material.dart';

/// Campo de texto cuyo error aparece en rojo justo debajo (no en ventanas emergentes).
class CampoTexto extends StatelessWidget {
  const CampoTexto({
    super.key,
    required this.controller,
    required this.etiqueta,
    this.error,
    this.ayuda,
    this.icono,
    this.obscuro = false,
    this.sufijo,
    this.teclado,
    this.accion = TextInputAction.next,
    this.onEnviar,
    this.onCambio,
  });

  final TextEditingController controller;
  final String etiqueta;
  final String? error;
  final String? ayuda;
  final IconData? icono;
  final bool obscuro;
  final Widget? sufijo;
  final TextInputType? teclado;
  final TextInputAction accion;
  final VoidCallback? onEnviar;
  final ValueChanged<String>? onCambio;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscuro,
      keyboardType: teclado,
      textInputAction: accion,
      autocorrect: false,
      onSubmitted: onEnviar == null ? null : (_) => onEnviar!(),
      onChanged: onCambio,
      decoration: InputDecoration(
        labelText: etiqueta,
        errorText: error,
        helperText: ayuda,
        prefixIcon: icono == null ? null : Icon(icono),
        suffixIcon: sufijo,
      ),
    );
  }
}
