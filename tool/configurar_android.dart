// Aplica la configuración de Android que necesita TaskU (permisos, receptores
// de recordatorios y "core library desugaring"). Es seguro ejecutarlo más de
// una vez. Uso, desde la raíz del proyecto, después de `flutter create`:
//
//   dart run tool/configurar_android.dart
import 'dart:io';

const _permisos = '''<uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>''';

const _receptores = '''        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false"
            android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>''';

void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (!manifest.existsSync()) {
    stderr.writeln('No se encontró android/. Ejecuta primero: '
        'flutter create --org mx.ucol.telematica --project-name tasku --platforms android .');
    exit(1);
  }

  var m = manifest.readAsStringSync();
  if (!m.contains('POST_NOTIFICATIONS')) {
    m = m.replaceFirstMapped(
        RegExp(r'<manifest[^>]*>'), (x) => '${x[0]}\n    $_permisos');
  }
  if (!m.contains('ScheduledNotificationReceiver')) {
    m = m.replaceFirst('</application>', '$_receptores\n    </application>');
  }
  m = m.replaceFirst(RegExp(r'android:label="[^"]*"'), 'android:label="TaskU"');
  manifest.writeAsStringSync(m);
  stdout.writeln('✔ AndroidManifest.xml configurado');

  final kts = File('android/app/build.gradle.kts');
  final groovy = File('android/app/build.gradle');
  if (kts.existsSync()) {
    _parchearGradle(kts, kotlin: true);
  } else if (groovy.existsSync()) {
    _parchearGradle(groovy, kotlin: false);
  } else {
    stderr.writeln('No se encontró android/app/build.gradle(.kts); '
        'aplica el paso 2 del README manualmente.');
    exit(1);
  }
  stdout.writeln('Listo. Ahora ejecuta: flutter pub get && flutter run');
}

void _parchearGradle(File archivo, {required bool kotlin}) {
  var g = archivo.readAsStringSync();

  if (!g.contains('ibraryDesugaringEnabled')) {
    final compileOptions = RegExp(r'compileOptions\s*\{');
    if (!compileOptions.hasMatch(g)) {
      stderr.writeln('No se encontró el bloque compileOptions en ${archivo.path}; '
          'aplica el paso 2 del README manualmente.');
      exit(1);
    }
    final bandera = kotlin
        ? 'isCoreLibraryDesugaringEnabled = true'
        : 'coreLibraryDesugaringEnabled true';
    g = g.replaceFirstMapped(compileOptions, (x) => '${x[0]}\n        $bandera');
  }

  final dependencia = kotlin
      ? 'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")'
      : "coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.1.4'";
  final yaTiene =
      g.contains('coreLibraryDesugaring(') || g.contains("coreLibraryDesugaring '");
  if (!yaTiene) {
    final bloque = RegExp(r'^dependencies\s*\{', multiLine: true);
    if (bloque.hasMatch(g)) {
      g = g.replaceFirstMapped(bloque, (x) => '${x[0]}\n    $dependencia');
    } else {
      g = '$g\ndependencies {\n    $dependencia\n}\n';
    }
  }

  archivo.writeAsStringSync(g);
  stdout.writeln('✔ ${archivo.path} configurado');
}
