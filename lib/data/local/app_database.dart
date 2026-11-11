import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../core/seguridad.dart';

/// Base de datos local SQLite.
/// Cuatro tablas: usuarios, materias, tareas y dias_festivo (caché de la API).
class AppDatabase {
  AppDatabase({this.sembrarDemo = true});

  /// Datos de acceso de prueba para la revisión del proyecto.
  static const String demoCorreo = 'demo@ucol.mx';
  static const String demoPassword = 'Demo1234';

  /// Si es true, al crear la base por primera vez se agrega un usuario de
  /// prueba con materias y tareas de ejemplo.
  final bool sembrarDemo;

  Future<Database>? _futuro;

  Future<Database> get db => _futuro ??= _abrir();

  Future<Database> _abrir() async {
    final ruta = p.join(await getDatabasesPath(), 'tasku.db');
    return openDatabase(
      ruta,
      version: 1,
      onConfigure: (d) async {
        await d.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (d, version) async {
        await d.execute('''
          CREATE TABLE usuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            correo TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            sal TEXT NOT NULL
          )''');
        await d.execute('''
          CREATE TABLE materias (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            usuario_id INTEGER NOT NULL,
            nombre TEXT NOT NULL,
            profesor TEXT NOT NULL,
            color INTEGER NOT NULL,
            FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
          )''');
        await d.execute('''
          CREATE TABLE tareas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            materia_id INTEGER NOT NULL,
            titulo TEXT NOT NULL,
            descripcion TEXT NOT NULL DEFAULT '',
            fecha_entrega INTEGER NOT NULL,
            prioridad INTEGER NOT NULL DEFAULT 1,
            entregada INTEGER NOT NULL DEFAULT 0,
            recordatorio INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY (materia_id) REFERENCES materias (id) ON DELETE CASCADE
          )''');
        await d.execute('''
          CREATE TABLE dias_festivo (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fecha INTEGER NOT NULL,
            nombre_local TEXT NOT NULL,
            nombre TEXT NOT NULL,
            codigo_pais TEXT NOT NULL,
            anio INTEGER NOT NULL
          )''');
        await d.execute('CREATE INDEX idx_materias_usuario ON materias (usuario_id)');
        await d.execute('CREATE INDEX idx_tareas_materia ON tareas (materia_id)');
        await d.execute('CREATE INDEX idx_festivo_anio ON dias_festivo (anio)');

        if (sembrarDemo) await _sembrarDatosDemo(d);
      },
    );
  }

  /// Usuario de prueba: demo@ucol.mx / Demo1234 (la contraseña se guarda con
  /// hash y sal, igual que las cuentas reales).
  Future<void> _sembrarDatosDemo(Database d) async {
    final sal = Seguridad.generarSal();
    final uid = await d.insert('usuarios', {
      'nombre': 'Estudiante Demo',
      'correo': demoCorreo,
      'password_hash': Seguridad.hash(demoPassword, sal),
      'sal': sal,
    });

    Future<int> materia(String nombre, int color) => d.insert('materias', {
          'usuario_id': uid,
          'nombre': nombre,
          'profesor': 'Profesor Demo',
          'color': color,
        });

    final prog = await materia('Programación de Aplicaciones', 0xFF3F51B5);
    final bd = await materia('Bases de Datos', 0xFF009688);
    final redes = await materia('Redes de Computadoras', 0xFFE65100);

    final hoy = DateTime.now();
    int dia(int n) =>
        DateTime(hoy.year, hoy.month, hoy.day + n).millisecondsSinceEpoch;

    Future<void> tarea(int materiaId, String titulo, int dias, int prioridad,
            {bool entregada = false}) =>
        d.insert('tareas', {
          'materia_id': materiaId,
          'titulo': titulo,
          'descripcion': '',
          'fecha_entrega': dia(dias),
          'prioridad': prioridad,
          'entregada': entregada ? 1 : 0,
          'recordatorio': 0,
        });

    await tarea(prog, 'Entregar práctica de Flutter', 0, 2);
    await tarea(bd, 'Diagrama entidad-relación', 2, 1);
    await tarea(redes, 'Reporte de topologías de red', 5, 1);
    await tarea(prog, 'Investigación sobre el patrón MVVM', 12, 0);
    await tarea(bd, 'Ejercicios de normalización', -3, 2, entregada: true);
  }
}
