# FastADB Release Notes

## 0.1.0-beta.5

Focus: detected device workflows and public beta polish.

- Renamed the sidebar section from USB-only wording to detected devices.
- Added quick actions directly to detected USB and WiFi/TCP devices.
- Added direct scrcpy launch from detected device cards without requiring the device to be saved first.
- Fixed false `List / Android Unknown` devices caused by parsing the ADB devices header as a real device.
- Added macOS file picker entitlement for user-selected files.
- Enabled full Session Replay sampling for beta verification with text and image masking.
- Bumped the app version to `0.1.0-beta.5`.

## 0.1.0-beta.4

Focus: observability for beta builds.

- Added Sentry Flutter integration for desktop crash/error reporting.
- Enabled Sentry debug symbol and source map upload configuration.
- Added Sentry MCP project configuration for local development tools.
- Ignored local `sentry.properties` credentials.

Manual validation status:

- macOS GitHub Release artifact: pending on physical macOS release machine.
- Windows GitHub Release artifact: pending on physical/VM Windows release machine.
- Linux GitHub Release artifact: pending on physical/VM Linux release machine.

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
