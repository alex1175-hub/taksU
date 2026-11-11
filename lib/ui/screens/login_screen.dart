import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/auth_viewmodel.dart';
import '../widgets/campo_texto.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _correo = TextEditingController();
  final _password = TextEditingController();
  String? _errCorreo;
  String? _errPassword;
  String? _errGeneral;
  bool _ocultar = true;
  Timer? _temporizador;

  @override
  void dispose() {
    _temporizador?.cancel();
    _correo.dispose();
    _password.dispose();
    super.dispose();
  }

  /// Refresca la cuenta regresiva del bloqueo de 30 s.
  void _vigilarBloqueo() {
    _temporizador?.cancel();
    _temporizador = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      final bloqueado = context.read<AuthViewModel>().bloqueado;
      setState(() {
        if (!bloqueado) {
          _errGeneral = null;
          t.cancel();
        }
      });
    });
  }

  Future<void> _entrar() async {
    final auth = context.read<AuthViewModel>();
    setState(() {
      _errCorreo = _correo.text.trim().isEmpty ? 'Escribe tu correo' : null;
      _errPassword = _password.text.isEmpty ? 'Escribe tu contraseña' : null;
      _errGeneral = null;
    });
    if (_errCorreo != null || _errPassword != null) return;

    final error = await auth.iniciarSesion(_correo.text, _password.text);
    if (!mounted) return;
    if (error != null) {
      setState(() => _errGeneral = error);
      if (auth.bloqueado) _vigilarBloqueo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final tema = Theme.of(context);
    final mensaje = auth.bloqueado
        ? 'Demasiados intentos fallidos. Intenta de nuevo en ${auth.segundosBloqueo} s.'
        : _errGeneral;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: tema.colorScheme.primaryContainer,
                    child: Icon(Icons.task_alt,
                        size: 40, color: tema.colorScheme.primary),
                  ),
                  const SizedBox(height: 16),
                  Text('TaskU',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Organiza tus tareas escolares',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium),
                  const SizedBox(height: 32),
                  CampoTexto(
                    controller: _correo,
                    etiqueta: 'Correo institucional',
                    icono: Icons.mail_outline,
                    teclado: TextInputType.emailAddress,
                    error: _errCorreo,
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controller: _password,
                    etiqueta: 'Contraseña',
                    icono: Icons.lock_outline,
                    obscuro: _ocultar,
                    error: _errPassword,
                    accion: TextInputAction.done,
                    onEnviar: _entrar,
                    sufijo: IconButton(
                      icon: Icon(_ocultar
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _ocultar = !_ocultar),
                    ),
                  ),
                  if (mensaje != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: tema.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(mensaje,
                          style: TextStyle(
                              color: tema.colorScheme.onErrorContainer)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed:
                        (auth.cargando || auth.bloqueado) ? null : _entrar,
                    child: auth.cargando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegistroScreen()),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Crear cuenta'),
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
