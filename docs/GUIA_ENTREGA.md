# Guía de entrega — lista de verificación

Basada en *Especificaciones para la entrega del proyecto final*.

## 1. Requisitos de la app (sección 2 del PDF)

| # | Requisito | Dónde está |
|---|---|---|
| 1 | Pantalla de inicio: presentación y acceso a funciones | `ui/screens/tareas_screen.dart` (tarjeta de bienvenida, resumen, accesos rápidos) |
| 2 | Autenticación | `login_screen`, `registro_screen`, `auth_viewmodel`, `core/seguridad.dart` |
| 3 | Navegación | `home_shell.dart` (barra inferior), `navegacion_viewmodel.dart`, rutas de formularios |
| 4 | Formularios y validaciones | `core/validadores.dart`, `nueva_tarea_screen`, `materias_screen`, registro |
| 5 | Consumo de datos (API / JSON) | `data/remote/festivos_api.dart`, `data/local/catalogo_json.dart`, `respaldo_service.dart` |
| 6 | Persistencia | `data/local/app_database.dart`, `daos.dart` (SQLite) |
| 7 | Manejo de errores | errores tipados de la API, avisos con *Reintentar*, SnackBars, `try/catch` en ViewModels |
| 8 | Diseño UI/UX | Material 3, tema claro/oscuro, `ui/` |
| 9 | Pruebas | carpeta `test/` + matriz de pruebas del documento técnico |

## 2. Lo que solo el equipo puede completar

Estos puntos requieren ejecutar la app o aportar información real; **no están hechos**:

- [ ] Ejecutar `flutter test` y anotar el resultado.
- [ ] Generar el APK (`flutter build apk --release`) y probarlo en teléfono o emulador.
- [ ] Capturas de **todas** las pantallas de la app real (no de los prototipos de Stitch).
- [ ] Video de demostración de 3 a 5 minutos con la app funcionando.
- [ ] Ejecutar la matriz de pruebas y llenar *resultado obtenido* y *aprobada / no aprobada* con evidencia.
- [ ] Bitácora: fechas y responsables reales, y al menos 5 prompts reales con sus modificaciones.
- [ ] Subir el código a GitHub con commits reales de cada integrante.
- [ ] Completar los campos marcados con `[COMPLETAR]` en el documento técnico y exportarlo a PDF.
- [ ] Que cada integrante pueda explicar el código (defensa individual).

## 3. Carpeta de entrega sugerida

```
ProyectoFinal_TaskU/
├── Aplicacion/proyecto.apk              ← app-release.apk renombrado
├── Documentacion/DocumentoTecnico.pdf
├── Evidencias/
│   ├── Capturas/                        ← una captura por pantalla
│   ├── VideoDemostracion.mp4
│   ├── Pruebas/                         ← capturas de la matriz y salida de `flutter test`
│   └── EvidenciasAPI/                   ← calendario con festivos, caso sin conexión, JSON de Postman
├── Bitacora/BitacoraDesarrollo.pdf
└── README.txt                           ← usa entrega/README.txt de este proyecto
```

## 4. Cómo obtener cada evidencia

| Evidencia | Cómo |
|---|---|
| Consumo de API | Calendario con festivos (16 de noviembre). Petición en Postman: `GET https://date.nager.at/api/v3/PublicHolidays/2026/MX` |
| Falta de conexión | Activa modo avión, abre **Calendario** y avanza a un año que no se haya consultado (la caché evita internet en años ya cargados). Debe verse el aviso con *Reintentar* |
| Almacenamiento y recuperación | Crea una tarea, cierra la app por completo, ábrela de nuevo: la tarea sigue ahí. Exporta el JSON desde Perfil |
| Procesamiento de JSON | Materias → ícono de foco → catálogo sugerido (lee `assets/materias_sugeridas.json`) |
| Validaciones | Registro con correo `@gmail.com`, contraseña corta, confirmación distinta; tarea con título de 1 letra y fecha pasada |
| Pruebas fallidas | Si alguna prueba falla, **inclúyela** y explica cómo se corrigió; el PDF pide pruebas exitosas y fallidas |
| Recordatorios | Crea una tarea con recordatorio para mañana y verifica la notificación (para una prueba rápida, ajusta temporalmente la hora en `recordatorios_service.dart`) |

## 5. Propuesta de historial de commits

El PDF pide evidencia del historial de cambios. Que cada integrante haga commits de su parte
(en ramas por funcionalidad, como indica la presentación). Ejemplo de reparto:

| Área | Archivos | Mensaje de commit sugerido |
|---|---|---|
| Base de datos | `data/local/*`, `data/models/*` | `feat(db): tablas SQLite, DAOs y modelos` |
| Servicios | `data/remote/*`, `data/services/*`, repositorios de festivos | `feat(api): consumo de Nager.Date con caché y errores tipados` |
| Acceso y validaciones | `core/validadores.dart`, `core/seguridad.dart`, `auth_*`, login/registro | `feat(auth): registro, login con hash y bloqueo` |
| Interfaz e integración | `ui/*`, `viewmodels/*`, `app.dart`, `main.dart` | `feat(ui): pantallas con Material 3 y navegación` |
| Pruebas y documentación | `test/*`, `README.md`, `docs/*` | `test: pruebas unitarias y de widget` |

> No reescribas ni inventes el historial: debe reflejar el trabajo real del equipo.
