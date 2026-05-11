# FastADB Release Notes

## 0.1.0-beta.3

Focus: MVP stabilization for ADB/scrcpy flows across macOS, Windows and Linux.

- Improved actionable error messages for ADB failures:
  - WiFi `adb connect` timeouts and refused connections.
  - `unauthorized` devices.
  - `offline` devices.
  - Linux USB permission and udev issues.
  - missing ADB/scrcpy binaries.
- Surfaced connect and scrcpy launch failures in the desktop UI instead of silently ignoring them.
- Added unit tests for:
  - `AdbOutputParser`
  - `AdbService`
  - `ToolsConfigService`
  - `DeviceRepository`
  - `ShortcutRepository`
- Added manual release validation checklist for downloaded GitHub Release artifacts.
- Expanded ADB/scrcpy installation documentation by platform.
- Added project-local Marionette MCP development tooling and documentation.

Manual validation status:

- macOS GitHub Release artifact: pending on physical macOS release machine.
- Windows GitHub Release artifact: pending on physical/VM Windows release machine.
- Linux GitHub Release artifact: pending on physical/VM Linux release machine.

## 0.1.0-beta.2

- Published MVP beta builds from GitHub Actions.
- Added macOS DMG packaging.
- Improved tool autodetection for desktop launches where shell `PATH` is not inherited.
- Documented beta distribution and platform notes.
