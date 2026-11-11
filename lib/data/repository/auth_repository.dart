import '../../core/seguridad.dart';
import '../local/daos.dart';
import '../local/sesion_store.dart';
import '../models/usuario.dart';

class AuthRepository {
  AuthRepository(this._dao, this._sesion);
  final UsuarioDao _dao;
  final SesionStore _sesion;

  /// Si hay sesión guardada, la app entra directo a Inicio.
  Future<Usuario?> sesionGuardada() async {
    final id = await _sesion.usuarioId();
    if (id == null) return null;
    return _dao.porId(id);
  }

  Future<bool> correoExiste(String correo) async =>
      (await _dao.porCorreo(correo)) != null;

  Future<Usuario?> verificarCredenciales(String correo, String password) async {
    final u = await _dao.porCorreo(correo);
    if (u == null) return null;
    return Seguridad.verificar(password, u.sal, u.passwordHash) ? u : null;
  }

  Future<Usuario> registrar(String nombre, String correo, String password) async {
    final sal = Seguridad.generarSal();
    final nuevo = Usuario(
      nombre: nombre.trim(),
      correo: correo,
      passwordHash: Seguridad.hash(password, sal),
      sal: sal,
    );
    final id = await _dao.insertar(nuevo);
    return Usuario(
      id: id,
      nombre: nuevo.nombre,
      correo: nuevo.correo,
      passwordHash: nuevo.passwordHash,
      sal: nuevo.sal,
    );
  }

  Future<void> guardarSesion(Usuario u) => _sesion.guardarUsuario(u.id!);

  Future<void> cerrarSesion() => _sesion.borrarUsuario();
}
