# FastADB Roadmap

Estado actual: `0.1.0-beta.6`

FastADB ya cubre el flujo MVP principal: configurar ADB/scrcpy, guardar dispositivos, detectar USB, conectar por WiFi/TCP, ejecutar shortcuts basicos y distribuir builds beta desde GitHub Releases. Este roadmap separa lo que falta para pasar de beta a una version estable.

## Principios de versionado

- `0.1.x-beta`: estabilizacion del MVP actual.
- `0.2.x-beta`: integraciones completas de scrcpy, shortcuts y terminal.
- `0.3.x-beta`: experiencia desktop completa: tray, onboarding, instaladores.
- `1.0.0`: release estable con instaladores confiables, tests criticos y documentacion de usuario.

## Beta 0.1.x - Estabilizacion del MVP

Objetivo: que los flujos existentes funcionen de forma predecible en macOS, Windows y Linux.

- [x] Mejorar mensajes de error para ADB/scrcpy y comandos fallidos.
- [ ] Validar manualmente builds descargados desde GitHub Releases en las tres plataformas. Checklist: `docs/beta_0_1_validation.md`.
- [x] Documentar instalacion de ADB/scrcpy por plataforma.
- [x] Agregar tests unitarios para `AdbOutputParser`, `AdbService`, `ToolsConfigService`, `DeviceRepository` y `ShortcutRepository`.
- [x] Revisar edge cases de `adb connect`, dispositivos `unauthorized`, `offline` y permisos USB Linux.
- [x] Mantener release notes por cada beta.
- [ ] Exponer estado de actualizaciones dentro de la app usando GitHub Releases.

## Beta 0.2.x - scrcpy, shortcuts y terminal

Objetivo: convertir las integraciones de desarrollo en una experiencia robusta.

- Crear `ScrcpyService`.
  - `launch(serial, options)`
  - `buildArgs(options)`
  - deteccion de sesiones activas
  - errores visibles si falta scrcpy, ADB o el dispositivo esta desconectado
- Completar shortcuts por dispositivo.
  - usar realmente `Device.shortcutIds`
  - filtrar `isGlobal`
  - selector real de shortcuts en el modal de dispositivo
  - evitar que todos los shortcuts aparezcan como globales
- Resolver placeholders adicionales.
  - `%DEVICE%`
  - `%APK%` con file picker
  - posible `%FILE%` para comandos personalizados
- Implementar terminal streaming.
  - usar `Process.start`
  - mostrar stdout/stderr en tiempo real
  - cancelar procesos largos como `logcat`
  - estado running/completed/failed
- Revisar comandos predefinidos.
  - Shell
  - Logcat
  - Screenshot
  - Reboot
  - Install APK

## Beta 0.3.x - Experiencia desktop

Objetivo: que la app se comporte como una aplicacion desktop nativa.

- Integrar `system_tray` y `window_manager`.
  - menu: Abrir, Reconectar todos, Salir
  - cerrar a bandeja
  - iniciar minimizado usando `ToolsConfig.startMinimized`
- Wizard de primera ejecucion.
  - paso 1: configurar/verificar ADB
  - paso 2: configurar/verificar scrcpy
  - acceso directo a documentacion si no se detectan herramientas
- Banner de estado cuando ADB no esta configurado.
- Accion "Reconectar todos".
- Preferencias persistentes para comportamiento de ventana.

## Beta 0.4.x - Distribucion

Objetivo: mejorar instalacion y confianza del usuario.

- macOS:
  - mantener DMG drag-to-Applications
  - firmar con Developer ID
  - notarizar para reducir bloqueos de Gatekeeper
- Windows:
  - reemplazar ZIP por MSIX o instalador EXE
  - metadatos de producto completos
- Linux:
  - generar AppImage y/o `.deb`
  - documentar udev rules para ADB
- Smoke tests por plataforma sobre artefactos descargados.

## Criterios para 1.0.0

- Los flujos principales pasan en Windows, macOS y Linux:
  - abrir app
  - configurar ADB
  - configurar scrcpy
  - detectar USB
  - activar WiFi ADB
  - conectar/desconectar dispositivo guardado
  - lanzar scrcpy
  - ejecutar shortcut con output visible
- `flutter analyze` y `flutter test` pasan en CI.
- Tests unitarios cubren parsing y servicios criticos.
- Instaladores disponibles y documentados.
- README y guia tecnica alineados con el estado real del codigo.

## Backlog posterior a 1.0

- Import/export de configuracion.
- Perfiles por workspace/proyecto.
- Diagnostico guiado de ADB.
- Historial de comandos.
- Actualizaciones automaticas.
- Tema visual mas nativo por plataforma.
