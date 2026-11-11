import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/campo_texto.dart';
import '../widgets/mensajes.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _confirmar = TextEditingController();
  Map<String, String> _errores = {};
  bool _ocultar = true;

  @override
  void dispose() {
    _nombre.dispose();
    _correo.dispose();
    _password.dispose();
    _confirmar.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    final auth = context.read<AuthViewModel>();
    final navegador = Navigator.of(context);
    final mensajero = ScaffoldMessenger.of(context);
    final errores = await auth.registrar(
      nombre: _nombre.text,
      correo: _correo.text,
      password: _password.text,
      confirmar: _confirmar.text,
    );
    if (!mounted) return;
    if (errores.isEmpty) {
      // La puerta de acceso ya mostró Inicio; se cierra esta pantalla.
      navegador.popUntil((r) => r.isFirst);
      mostrarMensaje(mensajero, 'Cuenta creada. ¡Bienvenido a TaskU!');
    } else {
      setState(() => _errores = errores);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CampoTexto(
                    controller: _nombre,
                    etiqueta: 'Nombre completo',
                    icono: Icons.person_outline,
                    error: _errores['nombre'],
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: _correo,
                    etiqueta: 'Correo institucional',
                    ayuda: 'Debe terminar en @ucol.mx',
                    icono: Icons.mail_outline,
                    teclado: TextInputType.emailAddress,
                    error: _errores['correo'],
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: _password,
                    etiqueta: 'Contraseña',
                    ayuda: '8 caracteres o más, con letra y número',
                    icono: Icons.lock_outline,
                    obscuro: _ocultar,
                    error: _errores['password'],
                    sufijo: IconButton(
                      icon: Icon(_ocultar
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _ocultar = !_ocultar),
                    ),
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: _confirmar,
                    etiqueta: 'Confirmar contraseña',
                    icono: Icons.lock_reset_outlined,
                    obscuro: _ocultar,
                    error: _errores['confirmar'],
                    accion: TextInputAction.done,
                    onEnviar: _registrar,
                  ),
                  if (_errores['general'] != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_errores['general']!,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onErrorContainer)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: auth.cargando ? null : _registrar,
                    child: auth.cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Registrarme'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
