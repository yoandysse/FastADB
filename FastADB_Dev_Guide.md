# FastADB - Guia Tecnica

Version de la guia: `0.1.0-beta.4`

FastADB es una aplicacion Flutter desktop para gestionar conexiones Android Debug Bridge sin depender de la terminal. La app no incluye binarios de ADB ni scrcpy; el usuario configura rutas a herramientas instaladas en su sistema.

Plataformas objetivo:

- Windows
- macOS
- Linux

## Estado Actual

La beta actual cubre el MVP principal:

- Navegacion desktop con sidebar.
- Tema claro/oscuro/sistema.
- Localizacion `en` y `es`.
- Persistencia con Hive y SharedPreferences.
- Configuracion de ADB y scrcpy.
- Autodeteccion de herramientas con rutas comunes por plataforma.
- File picker nativo para seleccionar binarios.
- Deteccion USB periodica.
- CRUD de dispositivos WiFi.
- Conexion/desconexion ADB TCP.
- Activacion de WiFi ADB desde USB.
- Shortcuts configurables basicos.
- Ejecucion de shortcuts con `%DEVICE%`.
- Lanzamiento de scrcpy desde tarjetas de dispositivo.
- Iconos nativos de app.
- Release beta desde GitHub Actions.
- macOS DMG con arrastrar a Aplicaciones.

## Stack

| Paquete | Uso |
|---|---|
| `flutter` | UI desktop multiplataforma |
| `flutter_riverpod` | Estado reactivo |
| `hive` / `hive_flutter` | Persistencia de modelos |
| `shared_preferences` | Configuracion ligera |
| `go_router` | Navegacion |
| `file_picker` | Seleccion nativa de binarios |
| `process_run` | Dependencia disponible para procesos |
| `window_manager` | Pendiente de integracion desktop |
| `system_tray` | Pendiente de integracion tray |
| `marionette_flutter` | Automatizacion/debug en desarrollo |
| `marionette_mcp` | Servidor MCP para automatizar la app en debug |

La fuente de verdad de versiones esta en `pubspec.yaml`.

## Arquitectura

```text
Presentation Layer    -> Screens, widgets, dialogs
Application Layer     -> Providers y notifiers Riverpod
Domain Layer          -> Device, Shortcut, ToolsConfig, ConnectionStatus
Infrastructure Layer  -> Hive repositories, ProcessRunner, platform process APIs
```

Reglas:

- La UI no debe construir comandos ADB directamente.
- Los servicios no deben depender de widgets.
- Repositories son la unica capa que toca Hive directamente.
- `ProcessRunner` encapsula `Process.run` y `Process.start` para facilitar tests.
- Los paths de herramientas externas siempre vienen de `ToolsConfig` o autodeteccion.

## Estructura Principal

```text
lib/
├── config/
│   ├── app_info.dart
│   └── router.dart
├── core/
│   ├── models/
│   ├── repositories/
│   ├── services/
│   └── utils/
├── providers/
├── screens/
│   ├── devices/
│   ├── settings/
│   ├── shortcuts/
│   └── usb/
├── shared/
│   ├── theme/
│   └── widgets/
└── main.dart
```

## Modelos

### `Device`

Representa un dispositivo guardado o detectado.

Campos importantes:

- `id`
- `alias`
- `host`
- `port`
- `serial`
- `type`
- `autoReconnect`
- `shortcutIds`
- `lastConnected`

Nota: `shortcutIds` existe, pero todavia falta integrarlo completamente en la UI y en la ejecucion de shortcuts por dispositivo.

### `Shortcut`

Representa un acceso rapido configurable.

Campos:

- `id`
- `name`
- `icon`
- `commandTemplate`
- `isGlobal`

`commandTemplate` soporta `%DEVICE%`. Faltan placeholders adicionales como `%APK%` con selector de archivo.

### `ToolsConfig`

Configuracion persistente de herramientas y preferencias:

- `adbPath`
- `scrcpyPath`
- `autoReconnectOnStart`
- `startMinimized`
- `theme`

Nota: `startMinimized` se guarda, pero todavia falta aplicarlo al arranque con `window_manager`.

## Servicios

### `AdbService`

Wrapper de comandos ADB.

Responsabilidades:

- `connect`
- `disconnect`
- `listUsbDevices`
- `getDeviceState`
- `getModel`
- `getAndroidVersion`
- `enableTcpip`
- `getSuggestedIp`
- `startServer`
- `runShortcutCommand`

Pendiente:

- aumentar cobertura de tests.
- separar ejecucion streaming de shortcuts largos.

Notas Beta 0.1:

- Los errores comunes de ADB se normalizan en `AdbOutputParser.friendlyError`.
- `adb connect`, `tcpip`, shortcuts y verificacion de herramientas deben devolver mensajes accionables para `unauthorized`, `offline`, timeouts, binarios ausentes y permisos USB Linux.
- La UI no debe tragar silenciosamente fallos de connect o scrcpy.

### `ToolsConfigService`

Responsabilidades:

- cargar/guardar configuracion.
- autodetectar ADB y scrcpy.
- verificar binarios.
- resolver rutas comunes de macOS, Windows y Linux.

La beta 2 incluye mitigacion importante para macOS: las apps abiertas desde Finder no heredan el `PATH` del shell, por eso `ProcessRunner` refuerza el entorno con rutas comunes como `/opt/homebrew/bin` y `/usr/local/bin`.

### `ProcessRunner`

Abstraccion sobre procesos.

- `run`: comandos cortos.
- `start`: procesos largos.
- `toolProcessEnvironment`: combina variables del sistema con rutas utiles para desktop.

### `ScrcpyService`

Pendiente. Actualmente `scrcpy` se lanza directamente desde `DevicesNotifier`. Debe moverse a un servicio dedicado.

Responsabilidades esperadas:

- construir argumentos.
- lanzar procesos no bloqueantes.
- controlar sesiones activas.
- retornar errores visibles.

## Providers

| Provider | Estado |
|---|---|
| `toolsConfigProvider` | Implementado |
| `devicesProvider` | Implementado |
| `usbDevicesProvider` | Implementado |
| `shortcutsProvider` | Implementado parcialmente |
| `localeProvider` | Implementado |

Pendientes:

- aplicar `startMinimized`.
- integrar `system_tray`.
- usar `Device.shortcutIds`.
- filtrar correctamente shortcuts globales vs por dispositivo.

## Pantallas

### Devices

Implementado:

- listas WiFi/USB.
- cards de dispositivo.
- connect/disconnect.
- scrcpy.
- barra de shortcuts globales.
- seleccion de dispositivo para shortcuts globales.

Pendiente:

- errores visibles al fallar scrcpy.
- shortcuts por dispositivo.
- terminal streaming.

### USB

Implementado:

- polling cada 5 segundos.
- deteccion de modelo/version.
- activar WiFi ADB.
- guardar dispositivo WiFi.

Pendiente:

- mejor diagnostico para `unauthorized`, permisos USB y Linux udev.

### Settings

Implementado:

- ADB/scrcpy paths.
- autodetect.
- file picker.
- verify.
- tema.
- idioma.
- auto reconnect.
- start minimized persistido.

Pendiente:

- aplicar start minimized en runtime.
- onboarding si ADB/scrcpy no estan configurados.

### Shortcuts

Implementado:

- CRUD basico.
- seed de shortcuts por defecto.
- copiar comando.
- crear/editar/eliminar.

Pendiente:

- asignacion real a dispositivos.
- placeholders extra.
- terminal streaming.
- cancelar procesos largos.
- selector de APK para `Install APK`.

## Empaquetado

GitHub Actions construye:

- Windows: ZIP
- macOS: DMG drag-to-Applications
- Linux: tar.gz

Pendiente:

- Windows MSIX o instalador EXE.
- Linux AppImage/deb.
- firma y notarizacion macOS.
- automatizar smoke tests sobre artefactos descargados.

## Release

Version actual:

```yaml
version: 0.1.0-beta.4+4
```

Tags:

```text
v0.1.0-beta.1
v0.1.0-beta.2
v0.1.0-beta.3
v0.1.0-beta.4
v0.2.0-beta.1
v1.0.0
```

Crear release:

```bash
git tag v0.1.0-beta.4
git push origin main --tags
```

El workflow crea una GitHub Release y marca como pre-release cualquier tag con sufijo `-beta`.

Mantener notas por beta en `RELEASE_NOTES.md`.

## Validacion Local

```bash
flutter pub get
flutter analyze
flutter test
flutter build macos --release
scripts/package_macos_dmg.sh \
  build/macos/Build/Products/Release/FastADB.app \
  build/macos/Build/Products/Release/FastADB-test.dmg
```

Despues de publicar una beta, descargar los artefactos desde GitHub Releases y validar macOS, Windows y Linux con `docs/beta_0_1_validation.md`.

## Marionette MCP

El proyecto incluye `marionette_mcp` como dependencia de desarrollo y configs MCP para Cursor y VS Code/Copilot:

- `.cursor/mcp.json`
- `.vscode/mcp.json`

Ambas lanzan:

```bash
dart run marionette_mcp
```

La app expone Marionette solo en `kDebugMode`. Para usarlo:

1. Ejecutar `flutter run -d macos` o la plataforma correspondiente.
2. Copiar el VM Service WebSocket URL.
3. Conectar desde el cliente MCP con la herramienta `connect`.

La guia operativa esta en `docs/marionette_mcp.md`.

## Riesgos

| Riesgo | Estado | Mitigacion |
|---|---|---|
| macOS Gatekeeper | Pendiente | Firmar y notarizar |
| PATH diferente en apps macOS | Mitigado parcialmente | `toolProcessEnvironment` y rutas Homebrew |
| Linux USB permissions | Mitigado parcialmente | documentacion udev y mensajes accionables |
| Shortcuts largos bloqueantes | Pendiente | terminal streaming con cancelacion |
| Packaging Windows/Linux | Pendiente | MSIX/AppImage o instaladores equivalentes |
| Baja cobertura de tests | Mitigado parcialmente | unit tests en servicios/parsers/repos criticos |

## Roadmap

El roadmap detallado vive en `ROADMAP.md`.
