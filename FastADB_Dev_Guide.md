# FastADB — Guía Técnica del Equipo

> Aplicación de escritorio Flutter multiplataforma para gestión de conexiones ADB (Android Debug Bridge).
> Plataformas: **Windows · macOS · Linux**

---

## Índice

1. [Visión general](#1-visión-general)
2. [Stack tecnológico](#2-stack-tecnológico)
3. [Arquitectura](#3-arquitectura)
4. [Estructura de directorios](#4-estructura-de-directorios)
5. [Setup del entorno de desarrollo](#5-setup-del-entorno-de-desarrollo)
6. [Modelos de datos](#6-modelos-de-datos)
7. [Servicios clave](#7-servicios-clave)
8. [Providers (Riverpod)](#8-providers-riverpod)
9. [Plan de fases](#9-plan-de-fases)
10. [Flujos críticos](#10-flujos-críticos)
11. [Convenciones del proyecto](#11-convenciones-del-proyecto)
12. [Riesgos conocidos](#12-riesgos-conocidos)

---

## 1. Visión General

FastADB permite gestionar dispositivos Android conectados por USB o WiFi/TCP-IP sin necesidad de usar la terminal. La app **no incluye binarios propios** de ADB ni scrcpy — el usuario configura las rutas a las herramientas instaladas en su sistema desde el panel de Configuración.

### Funcionalidades principales

- Guardar dispositivos con alias, IP/puerto y metadatos
- Conectar / desconectar con un clic (ADB TCP)
- Detectar dispositivos USB en tiempo real
- Activar WiFi ADB desde un dispositivo USB (`adb tcpip 5555`)
- Lanzar scrcpy sobre el dispositivo seleccionado
- Accesos rápidos configurables con placeholder `%DEVICE%`
- Reconexión automática al iniciar la app

---

## 2. Stack Tecnológico

| Paquete | Versión | Uso |
|---|---|---|
| `flutter` | `>=3.22` | Framework base (Dart 3.x) |
| `flutter_riverpod` | `^2.5` | Estado reactivo |
| `hive` + `hive_flutter` | `^2.2` | Persistencia embebida (sin servidor) |
| `go_router` | `^14.0` | Navegación declarativa |
| `file_picker` | `^8.0` | File picker nativo multiplataforma |
| `process_run` | `^0.14` | Ejecución de procesos + resolución de PATH |
| `path` + `path_provider` | latest | Rutas del sistema |
| `window_manager` | `^0.3` | Control de ventana desktop |
| `system_tray` | `^2.0` | Icono en bandeja del sistema |
| `shared_preferences` | `^2.2` | Config ligera (rutas de herramientas) |

> **Nota:** `fluent_ui` puede usarse opcionalmente en Windows para un look más nativo, pero no es obligatorio.

---

## 3. Arquitectura

El proyecto sigue una **arquitectura en capas** adaptada para desktop Flutter:

```
┌─────────────────────────────────────────┐
│           Presentation Layer            │
│   Screens · Widgets · Riverpod UI       │
├─────────────────────────────────────────┤
│           Application Layer             │
│   AdbService · ScrcpyService            │
│   ToolsConfigService · DeviceManager    │
├─────────────────────────────────────────┤
│             Domain Layer                │
│   Device · Shortcut · ToolsConfig       │
│   ConnectionStatus (enum)               │
├─────────────────────────────────────────┤
│          Infrastructure Layer           │
│   HiveRepository · ProcessRunner        │
│   FilePicker · SharedPreferences        │
└─────────────────────────────────────────┘
```

### Principios que seguimos

- **Screens** no contienen lógica de negocio — solo consumen providers
- **Services** no conocen la UI — devuelven resultados o lanzan excepciones tipadas
- **Repositories** son la única capa que toca Hive directamente
- **ProcessRunner** es una abstracción sobre `dart:io Process` → facilita el mock en tests

---

## 4. Estructura de Directorios

```
lib/
├── core/
│   ├── services/
│   │   ├── adb_service.dart           # Wrapper de comandos ADB
│   │   ├── scrcpy_service.dart        # Lanzador de scrcpy
│   │   ├── tools_config_service.dart  # Rutas configuradas + verificación
│   │   └── process_runner.dart        # Abstracción de Process.run/start
│   ├── repositories/
│   │   ├── device_repository.dart     # CRUD dispositivos en Hive
│   │   └── shortcut_repository.dart   # CRUD accesos rápidos en Hive
│   └── models/
│       ├── device.dart                # alias, host, port, type, serial
│       ├── shortcut.dart              # name, commandTemplate, icon
│       ├── tools_config.dart          # adbPath, scrcpyPath
│       └── connection_status.dart     # Enum: connected | reconnecting | offline
│
├── providers/
│   ├── devices_provider.dart          # Lista de dispositivos + estados
│   ├── usb_devices_provider.dart      # Detección USB en tiempo real
│   ├── tools_config_provider.dart     # Config de herramientas
│   └── connection_provider.dart       # Estado de cada conexión
│
├── screens/
│   ├── devices/
│   │   ├── devices_screen.dart
│   │   └── widgets/
│   │       ├── device_card.dart
│   │       └── add_device_modal.dart
│   ├── usb/
│   │   └── usb_screen.dart
│   ├── shortcuts/
│   │   ├── shortcuts_screen.dart
│   │   └── widgets/shortcut_editor.dart
│   └── settings/
│       ├── settings_screen.dart
│       └── widgets/tool_path_row.dart
│
├── shared/
│   ├── widgets/
│   │   ├── status_pill.dart           # Badge verde/amarillo/rojo
│   │   ├── terminal_output.dart       # Panel de output de procesos
│   │   └── app_shell.dart             # Shell con sidebar + área de contenido
│   ├── theme/
│   │   ├── app_theme.dart
│   │   └── app_colors.dart
│   └── utils/
│       ├── adb_output_parser.dart     # Parser de `adb devices`, etc.
│       └── path_resolver.dart         # Resolución multi-estrategia de rutas
│
└── main.dart
```

---

## 5. Setup del Entorno de Desarrollo

### Requisitos previos

- Flutter SDK `>=3.22` — [flutter.dev/docs/get-started](https://flutter.dev/docs/get-started)
- Dart SDK `>=3.0` (incluido con Flutter)
- ADB instalado y accesible (para desarrollo y pruebas)
- scrcpy instalado (para pruebas de Fase 4)

### Instalación rápida

```bash
# 1. Habilitar desktop
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop

# 2. Clonar y entrar al proyecto
git clone <repo-url> fastadb && cd fastadb

# 3. Instalar dependencias
flutter pub get

# 4. Verificar entorno
flutter doctor -v

# 5. Correr en desarrollo
flutter run -d windows   # o macos / linux
```

### Dependencias de pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  go_router: ^14.0.0
  file_picker: ^8.0.0
  process_run: ^0.14.0
  path: ^1.9.0
  path_provider: ^2.1.0
  window_manager: ^0.3.9
  system_tray: ^2.0.3
  shared_preferences: ^2.2.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  hive_generator: ^2.0.1
  build_runner: ^2.4.0
  mockito: ^5.4.0
  flutter_lints: ^3.0.0
```

### Generar adaptadores de Hive

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 6. Modelos de Datos

### `Device`

```dart
enum ConnectionType { wifi, usb }
enum ConnectionStatus { connected, reconnecting, offline, error }

class Device {
  final String id;           // UUID generado
  final String alias;        // Nombre amigable: "Pixel 7 — Estudio"
  final String? host;        // IP para WiFi: "192.168.1.101"
  final int? port;           // Puerto TCP: 5555
  final String? serial;      // Serial USB: "4XEVDNL12345"
  final ConnectionType type;
  final bool autoReconnect;
  final List<String> shortcutIds; // Accesos rápidos asignados
  final DateTime? lastConnected;
}
```

### `ToolsConfig`

```dart
class ToolsConfig {
  final String adbPath;      // "/usr/local/bin/adb" o "C:\platform-tools\adb.exe"
  final String scrcpyPath;   // "/opt/homebrew/bin/scrcpy"
  final bool autoReconnectOnStart;
  final bool startMinimized;
  final String theme;        // "system" | "dark" | "light"
}
```

### `Shortcut`

```dart
class Shortcut {
  final String id;
  final String name;         // "Logcat"
  final String icon;         // Nombre del ícono Material Symbols
  final String commandTemplate; // "adb -s %DEVICE% logcat"
  final bool isGlobal;       // Aparece en todos los dispositivos
}
```

---

## 7. Servicios Clave

### `AdbService`

Todos los métodos reciben la ruta del binario ADB desde `ToolsConfig`. Nunca hardcodean `"adb"`.

```dart
class AdbService {
  final ProcessRunner _runner;

  // Conexión WiFi
  Future<AdbResult> connect(String host, int port);
  Future<AdbResult> disconnect(String serial);

  // Detección USB
  Future<List<UsbDevice>> listUsbDevices();
  Future<String> getDeviceState(String serial);

  // Info del dispositivo
  Future<String> getModel(String serial);
  Future<String> getAndroidVersion(String serial);

  // Activar modo WiFi desde USB
  Future<AdbResult> enableTcpip(String serial, {int port = 5555});

  // Utilidades
  Future<String?> getSuggestedIp(String serial); // adb shell ip route
  Future<AdbResult> startServer();
}
```

**Regla de parsing:** siempre validar el `exitCode` del proceso Y analizar el `stdout`.
Un `exitCode == 0` con `"error:"` en stdout es un error ADB real.

```dart
// Ejemplo de parsing de `adb connect`
// stdout posibles:
//   "connected to 192.168.1.101:5555"   → éxito
//   "already connected to ..."          → éxito
//   "failed to connect to ..."          → error de red
//   "error: no devices/emulators found" → no autorizado
```

### `ProcessRunner`

Abstracción delgada sobre `dart:io`:

```dart
abstract class ProcessRunner {
  // Para comandos cortos (connect, get-state, devices)
  Future<ProcessResult> run(List<String> args);

  // Para procesos largos (scrcpy, logcat) — devuelve Stream
  Future<Process> start(List<String> args);
}
```

Tener esta abstracción permite mockear en tests sin tocar el sistema.

### `ToolsConfigService`

```dart
class ToolsConfigService {
  // Carga la config al arranque
  Future<ToolsConfig> load();
  Future<void> save(ToolsConfig config);

  // Autodetección en PATH del sistema
  Future<String?> autoDetectAdb();
  Future<String?> autoDetectScrcpy();

  // Verificación del binario
  Future<ToolVerifyResult> verifyAdb(String path);    // Ejecuta: adb version
  Future<ToolVerifyResult> verifyScrcpy(String path); // Ejecuta: scrcpy --version
}
```

**Resolución de ruta ADB en Windows** (orden de prioridad):

```
1. Ruta configurada por el usuario en Settings
2. Variable de entorno ANDROID_HOME\platform-tools\adb.exe
3. Variable de entorno ANDROID_SDK_ROOT\platform-tools\adb.exe
4. %LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe
5. which("adb") en PATH del sistema
```

---

## 8. Providers (Riverpod)

```dart
// Config de herramientas — se carga una vez al arranque
final toolsConfigProvider = StateNotifierProvider<ToolsConfigNotifier, ToolsConfig>(...);

// Lista de dispositivos guardados + su estado de conexión
final devicesProvider = StateNotifierProvider<DevicesNotifier, List<DeviceState>>(...);

// Dispositivos USB detectados en tiempo real (polling cada 5s)
final usbDevicesProvider = StreamProvider<List<UsbDevice>>(...);

// Estado de conexión de un dispositivo específico
final deviceStatusProvider = Provider.family<ConnectionStatus, String>((ref, serial) {
  return ref.watch(devicesProvider.select(
    (devices) => devices.firstWhere((d) => d.device.serial == serial).status,
  ));
});
```

### Polling de estado

```dart
class DevicesNotifier extends StateNotifier<List<DeviceState>> {
  Timer? _pollingTimer;

  void startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      _refreshAllWifiDevices(); // Ejecuta get-state para cada dispositivo WiFi
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
```

---

## 9. Plan de Fases

| # | Fase | Duración | Tipo | Entregable |
|---|---|---|---|---|
| 1 | Fundación y Scaffolding | 3-4 días | MVP | App arranca en 3 plataformas, navegación funcional |
| 2 | Configuración de Herramientas | 2-3 días | MVP | Settings con detección y verificación de ADB/scrcpy |
| 3 | Gestión de Dispositivos y ADB | 5-7 días | MVP | CRUD dispositivos, conexión WiFi y USB, polling |
| 4 | scrcpy e Integraciones | 3-4 días | Core | Espejo de pantalla, shortcuts configurables |
| 5 | Empaquetado y Distribución | 4-5 días | Release | Instaladores MSIX, DMG, AppImage |

> **MVP entregable:** Fases 1 + 2 + 3 (~10-14 días)

### Fase 1 — Fundación

```bash
# Checklist
[ ] flutter create --platforms=windows,macos,linux fastadb
[ ] ThemeData con paleta FastADB (#0D1117, #161B22, #00D084 accent)
[ ] AppShell con sidebar + NavigationRail
[ ] go_router: rutas /, /usb, /shortcuts, /settings
[ ] Modelos Dart: Device, Shortcut, ToolsConfig
[ ] Hive init en main.dart + adapters registrados
[ ] Verificar: flutter run en Windows, macOS y Linux
```

### Fase 2 — Configuración de Herramientas

```bash
# Checklist
[ ] ToolsConfigService con autoDetect + verify
[ ] ToolsConfigNotifier (Riverpod StateNotifier)
[ ] SettingsScreen con secciones: Herramientas, General, Apariencia
[ ] Widget ToolPathRow: icono + estado pill + input + Explorar + Verificar
[ ] Banner de advertencia en pantalla principal si ADB no está configurado
[ ] Persistencia en SharedPreferences
```

### Fase 3 — Dispositivos y ADB

```bash
# Checklist
[ ] DeviceRepository sobre Hive (CRUD)
[ ] AdbService con: connect, disconnect, listUsbDevices, getDeviceState, enableTcpip
[ ] DevicesNotifier con polling cada 8s
[ ] UsbDevicesNotifier con polling cada 5s
[ ] DevicesScreen: tarjetas WiFi + tarjetas USB + shortcuts bar
[ ] Widget DeviceCard con estados reactivos
[ ] Modal agregar/editar dispositivo
[ ] Flujo "Activar WiFi ADB desde USB"
[ ] Reconexión automática al iniciar la app
```

### Fase 4 — scrcpy y Shortcuts

```bash
# Checklist
[ ] ScrcpyService: launch(serial) como proceso no bloqueante
[ ] Modelo Shortcut con commandTemplate + %DEVICE%
[ ] ShortcutRepository sobre Hive
[ ] ShortcutsScreen con CRUD de accesos rápidos
[ ] Shortcuts integrados en DeviceCard
[ ] Panel terminal expandible con stdout en streaming
[ ] Shortcuts predefinidos al primer arranque (Logcat, Shell, Captura)
```

### Fase 5 — Empaquetado

```bash
# Windows
flutter build windows --release
# Generar MSIX con flutter_distributor o el package msix

# macOS
flutter build macos --release
create-dmg 'build/macos/Build/Products/Release/FastADB.app' .

# Linux
flutter build linux --release
# Empaquetar como AppImage con appimage-builder
```

---

## 10. Flujos Críticos

### Conexión WiFi

```
Usuario → "Conectar" en DeviceCard
  → DevicesNotifier.connect(device)
    → AdbService.connect(host, port)
      → ProcessRunner.run([adbPath, "connect", "host:port"])
        → Parsear stdout
          → "connected" o "already connected" → status = connected
          → cualquier otro → status = error
  → DeviceCard se reconstruye reactivamente
```

### Detección USB (polling)

```
Timer cada 5s
  → AdbService.listUsbDevices()
    → ProcessRunner.run([adbPath, "devices"])
      → Parsear líneas con estado "device" (excluir "unauthorized", "offline")
      → Para cada serial nuevo: getModel() + getAndroidVersion()
  → UsbDevicesNotifier.state = nuevaLista
  → UsbScreen se reconstruye reactivamente
```

### Activar WiFi ADB desde USB

```
Usuario → "Activar WiFi ADB" en UsbScreen
  → AdbService.enableTcpip(serial, port: 5555)
    → ProcessRunner.run([adbPath, "-s", serial, "tcpip", "5555"])
  → AdbService.getSuggestedIp(serial)
    → adb shell ip route → parsear la IP local del dispositivo
  → Mostrar diálogo con IP sugerida y campo editable
  → Usuario confirma
    → AdbService.connect(ip, 5555)
    → Guardar como nuevo Device en Hive
    → Navegar a DevicesScreen
```

### Ejecución de Shortcut

```
Usuario → presiona shortcut en DeviceCard
  → Resolver serial del dispositivo activo
  → Reemplazar %DEVICE% en commandTemplate
  → ProcessRunner.start(comando)          ← no bloqueante
  → Abrir TerminalOutput panel
    → Escuchar stdout stream y renderizar líneas en tiempo real
```

---

## 11. Convenciones del Proyecto

### Nomenclatura

- **Archivos:** `snake_case.dart`
- **Clases:** `PascalCase`
- **Variables/métodos:** `camelCase`
- **Constantes:** `kConstantName` (prefijo `k`)
- **Providers:** sufijo `Provider` — `devicesProvider`, `toolsConfigProvider`
- **Notifiers:** sufijo `Notifier` — `DevicesNotifier`

### Manejo de errores

Definir excepciones tipadas en lugar de usar `String` o `Exception` genérica:

```dart
sealed class AdbException implements Exception {
  const AdbException();
}

class AdbNotConfiguredException extends AdbException {}
class AdbConnectionException extends AdbException {
  final String message;
  const AdbConnectionException(this.message);
}
class AdbDeviceOfflineException extends AdbException {
  final String serial;
  const AdbDeviceOfflineException(this.serial);
}
```

### Git

- `main` — rama estable, solo merge con PR
- `develop` — integración continua
- `feature/nombre-feature` — desarrollo de funcionalidades
- `fix/descripcion-bug` — correcciones

Commits en español o inglés, prefijos convencionales:
```
feat: agregar detección automática de ADB en macOS
fix: corregir parsing de adb devices con serial que contiene guiones
chore: actualizar dependencias a versiones estables
```

### Tests

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Todos los tests
flutter test
```

Estructura de tests espeja la de `lib/`:

```
test/
├── unit/
│   ├── services/
│   │   ├── adb_service_test.dart
│   │   └── tools_config_service_test.dart
│   └── utils/
│       └── adb_output_parser_test.dart
└── widget/
    ├── device_card_test.dart
    └── tool_path_row_test.dart
```

---

## 12. Riesgos Conocidos

| Plataforma | Riesgo | Mitigación |
|---|---|---|
| **macOS** | Gatekeeper bloquea `Process.run` sobre binarios externos | Firmar con Developer ID + entitlement `cs.allow-unsigned-executable-memory` |
| **Windows** | ADB no está en PATH del proceso Flutter | Resolución multi-estrategia: config → ANDROID_HOME → LOCALAPPDATA → PATH |
| **Linux** | Permisos USB sin regla udev configurada | Detectar error `"no permissions"` en output y mostrar instrucciones: `sudo usermod -aG plugdev $USER` |
| **Todas** | Conflicto de servidor ADB (puerto 5037 ocupado) | Ejecutar `adb start-server` al arranque y manejar el error |
| **Todas** | Cambios en formato de output de `adb devices` | Tests unitarios sobre múltiples formatos de respuesta |
| **Linux** | scrcpy no disponible en AppImage sin dependencias del sistema | Detectar ausencia y mostrar instrucciones por distro (`apt`, `dnf`, `pacman`) |

---

## Links Útiles

- [Flutter Desktop — documentación oficial](https://docs.flutter.dev/platform-integration/desktop)
- [ADB — referencia de comandos](https://developer.android.com/tools/adb)
- [scrcpy — repositorio oficial](https://github.com/Genymobile/scrcpy)
- [Riverpod — documentación](https://riverpod.dev)
- [Hive — documentación](https://docs.hivedb.dev)
- [go_router — documentación](https://pub.dev/packages/go_router)

---

*FastADB Dev Guide · v1.0 · Mayo 2026*
