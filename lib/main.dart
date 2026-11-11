import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/local/app_database.dart';
import 'data/local/catalogo_json.dart';
import 'data/local/daos.dart';
import 'data/local/sesion_store.dart';
import 'data/remote/festivos_api.dart';
import 'data/repository/auth_repository.dart';
import 'data/repository/festivos_repository.dart';
import 'data/repository/materias_repository.dart';
import 'data/repository/tareas_repository.dart';
import 'data/services/recordatorios_service.dart';
import 'data/services/respaldo_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');

  // Capa de datos
  final baseDatos = AppDatabase();
  final sesion = SesionStore();
  final recordatorios = RecordatoriosService();
  await recordatorios.inicializar();

  final usuarioDao = UsuarioDao(baseDatos);
  final materiaDao = MateriaDao(baseDatos);
  final tareaDao = TareaDao(baseDatos);
  final festivoDao = FestivoDao(baseDatos);

  // Repositorios: deciden de dónde salen los datos.
  final dependencias = Dependencias(
    auth: AuthRepository(usuarioDao, sesion),
    tareas: TareasRepository(tareaDao, recordatorios, sesion),
    materias: MateriasRepository(
        materiaDao, tareaDao, CatalogoJson(), recordatorios),
    festivos: FestivosRepository(festivoDao, FestivosApi()),
    sesion: sesion,
    recordatorios: recordatorios,
    respaldo: RespaldoService(),
  );

  runApp(TaskUApp(dependencias: dependencias));
}
