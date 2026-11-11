import 'package:tasku/data/local/app_database.dart';
import 'package:tasku/data/local/daos.dart';
import 'package:tasku/data/local/sesion_store.dart';
import 'package:tasku/data/models/dia_festivo.dart';
import 'package:tasku/data/models/usuario.dart';
import 'package:tasku/data/repository/auth_repository.dart';

/// Repositorio de autenticación en memoria (no abre la base de datos).
class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository()
      : super(UsuarioDao(AppDatabase(sembrarDemo: false)), SesionStore());

  final Map<String, String> cuentas = {'demo@ucol.mx': 'Demo1234'};

  Usuario _usuario(int id, String correo) => Usuario(
      id: id, nombre: 'Demo', correo: correo, passwordHash: '', sal: '');

  @override
  Future<Usuario?> verificarCredenciales(String correo, String password) async =>
      cuentas[correo] == password ? _usuario(1, correo) : null;

  @override
  Future<bool> correoExiste(String correo) async => cuentas.containsKey(correo);

  @override
  Future<Usuario> registrar(String nombre, String correo, String password) async {
    cuentas[correo] = password;
    return _usuario(2, correo);
  }

  @override
  Future<void> guardarSesion(Usuario u) async {}

  @override
  Future<void> cerrarSesion() async {}
}

/// DAO de festivos en memoria.
class FakeFestivoDao extends FestivoDao {
  FakeFestivoDao() : super(AppDatabase(sembrarDemo: false));

  final Map<int, List<DiaFestivo>> datos = {};
  int guardados = 0;

  @override
  Future<List<DiaFestivo>> porAnio(int anio) async => datos[anio] ?? [];

  @override
  Future<void> reemplazarAnio(int anio, List<DiaFestivo> festivos) async {
    datos[anio] = festivos;
    guardados++;
  }
}
