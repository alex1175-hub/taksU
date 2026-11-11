# TaskU — Gestión de tareas escolares

Aplicación móvil multiplataforma (Flutter/Dart) para organizar las tareas escolares por
materia. Proyecto final de *Programación de Aplicaciones*, Facultad de Telemática,
Universidad de Colima (Grupo 5.º B).

**Problema que resuelve:** las tareas, prácticas y fechas de entrega viven dispersas en la
plataforma institucional, grupos de mensajería, notas en papel y la memoria de cada alumno,
lo que provoca olvidos y entregas tardías. TaskU las concentra en un solo lugar.

## Funciones principales

| Módulo | Qué hace |
|---|---|
| Acceso | Registro e inicio de sesión (correo `@ucol.mx`), contraseña con hash SHA-256 + sal, bloqueo de 30 s tras 5 intentos fallidos, sesión recordada |
| Inicio | Presentación de la app, resumen (pendientes, urgentes, entregadas), accesos rápidos y lista de tareas filtrable con color por urgencia |
| Tareas | Alta, consulta, edición y eliminación (CRUD) con validaciones, prioridad y recordatorio |
| Materias | CRUD con nombre, profesor y color; búsqueda; catálogo sugerido leído de un archivo JSON |
| Calendario | Vista mensual con entregas y festivos oficiales de México (API Nager.Date) con caché local |
| Perfil | Estadísticas, modo oscuro, notificaciones, exportar respaldo a JSON y cerrar sesión |
| Recordatorios | Notificación local un día antes de cada fecha de entrega |

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (canal *stable*, Dart ≥ 3.4)
- Android Studio con Android SDK (o solo las *command-line tools*) y JDK 17
- Un emulador Android o un teléfono con Android 8.0 o superior
- Internet (solo para consultar los días festivos la primera vez de cada año)

Verifica tu instalación con `flutter doctor`.

## Instalación y ejecución

```bash
git clone <URL-DEL-REPOSITORIO>
cd tasku

# 1. Genera la carpeta android/ (no sobrescribe lib/ ni pubspec.yaml)
flutter create --org mx.ucol.telematica --project-name tasku --platforms android .

# 2. Borra la prueba de ejemplo que genera el comando anterior
#    Windows (PowerShell): Remove-Item test\widget_test.dart
#    macOS / Linux:        rm test/widget_test.dart

# 3. Aplica la configuración de Android (permisos, recordatorios, desugaring)
dart run tool/configurar_android.dart

# 4. Dependencias y ejecución
flutter pub get
flutter run
```

Si el paso 3 fallara, la configuración manual está en la sección
[Configuración manual de Android](#configuración-manual-de-android).

### Datos de acceso de prueba

La primera vez que se abre la app se crea un usuario de ejemplo con materias y tareas:

| Correo | Contraseña |
|---|---|
| `demo@ucol.mx` | `Demo1234` |

También se puede crear una cuenta propia con cualquier correo `@ucol.mx`.
(El usuario demo se define en `lib/data/local/app_database.dart`; para desactivarlo,
crea `AppDatabase(sembrarDemo: false)` en `lib/main.dart`.)

### Generar el APK

```bash
flutter build apk --release
# Resultado: build/app/outputs/flutter-apk/app-release.apk
```

Copia ese archivo al teléfono e instálalo (permite "instalar apps de orígenes desconocidos").

### Pruebas automatizadas

```bash
flutter test
```

Cubren validaciones, hash de contraseñas, urgencia de tareas, consumo y errores de la API
(con cliente HTTP simulado), caché de festivos, inicio de sesión/bloqueo/registro y la
pantalla de login. Las pruebas de almacenamiento, navegación y recordatorios se hacen
manualmente en el dispositivo (ver la matriz de pruebas del documento técnico).

## Tecnologías

| Área | Herramienta |
|---|---|
| Lenguaje / framework | Dart + Flutter, Material Design 3 |
| Arquitectura | MVVM (`ChangeNotifier` + `provider`) con capa de repositorios |
| Base de datos local | SQLite con `sqflite` (4 tablas, claves foráneas y borrado en cascada) |
| Sesión y preferencias | `shared_preferences` |
| API REST | [Nager.Date](https://date.nager.at) con `http` |
| Archivo JSON | `assets/materias_sugeridas.json` (lectura) y respaldo exportado (escritura) |
| Recordatorios | `flutter_local_notifications` + `timezone` |
| Calendario | `table_calendar` |
| Seguridad | `crypto` (SHA-256 con sal) |

## Estructura del proyecto

```
lib/
├── main.dart                 # arranque e inyección de dependencias
├── app.dart                  # MaterialApp, tema, providers y puerta de acceso
├── core/                     # tema, fechas, validadores, seguridad (hash)
├── data/
│   ├── models/               # Usuario, Materia, Tarea, DiaFestivo
│   ├── local/                # SQLite (AppDatabase, DAOs), sesión, catálogo JSON
│   ├── remote/               # Nager.Date: FestivosApi, FestivoDto, errores
│   ├── repository/           # Auth, Tareas, Materias, Festivos
│   └── services/             # recordatorios y respaldo JSON
├── viewmodels/               # Auth, Tareas, Materias, Calendario, Ajustes, Navegación
└── ui/
    ├── screens/              # Login, Registro, Inicio, Nueva tarea, Materias,
    │                         # Calendario, Perfil, HomeShell (barra inferior)
    └── widgets/              # TareaCard, CampoTexto, mensajes
test/                         # pruebas unitarias y de widget
tool/configurar_android.dart  # configuración de Android en un paso
docs/GUIA_ENTREGA.md          # lista de verificación de la entrega
```

Flujo de datos: `Pantalla → ViewModel → Repositorio → (SQLite | API | JSON)`.

## Manejo de errores y retroalimentación

- Validaciones por campo con el error en rojo bajo el campo.
- Mensajes de confirmación (SnackBar) al guardar, actualizar o eliminar.
- API: se distinguen *sin conexión*, *error del servidor*, *respuesta vacía* y *formato
  inválido*; el calendario muestra un aviso discreto con botón **Reintentar** y sigue
  mostrando las tareas.
- Fallos de base de datos: las operaciones devuelven error y se informa al usuario.

## Configuración manual de Android

Solo si `dart run tool/configurar_android.dart` no funcionó.

**`android/app/src/main/AndroidManifest.xml`** — antes de `<application>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

y dentro de `<application>`:

```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

**`android/app/build.gradle.kts`** (en `build.gradle`: `coreLibraryDesugaringEnabled true` y
`coreLibraryDesugaring '...'`):

```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

## Seguridad

El repositorio no contiene contraseñas, claves ni tokens reales. La API usada es pública y no
requiere llave. Las contraseñas de usuarios se guardan únicamente como hash con sal.

## Integrantes

- Joshua Aldebaharan Goytia Rivas
- Cristian Osiris Rodríguez Cortés
- Jesús Alberto Amador Martínez
- Alberto Alexander Guzmán Ramírez

Profesor: José Nabor Ramírez Morfín.

## Uso de herramientas de IA

Se utilizó Claude (Anthropic) como apoyo para generar la versión inicial del código Flutter a
partir de la presentación del proyecto y para redactar borradores de documentación. El detalle
(actividades, prompts y modificaciones realizadas) está en la bitácora y en el documento técnico.
