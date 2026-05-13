# FastADB - Desktop ADB Manager

A cross-platform Flutter desktop application to manage Android devices via ADB without the terminal.

**Current Status:** MVP Beta (`0.1.0-beta.4`)

FastADB is currently distributed as a beta pre-release. Expect the core ADB workflows to work, but treat the app as an MVP while installation, packaging, and edge cases continue to stabilize.

## Downloads

Beta builds are published from GitHub Releases:

- Open the repository **Releases** page.
- Download the artifact for your OS:
  - `FastADB-v0.1.0-beta.4-macos.dmg`
  - `FastADB-v0.1.0-beta.4-windows-x64.zip`
  - `FastADB-v0.1.0-beta.4-linux-x64.tar.gz`

The macOS download is a drag-to-Applications DMG. The current beta builds are not code-signed or notarized, so macOS and Windows may show a security warning the first time the app is opened.

## Features Implemented

### Phase 1: Foundation ✅
- Multi-platform support: Windows, macOS, Linux
- go_router-based navigation with 4 main screens
- Dark theme with FastADB colors (#0D1117, #161B22, #00D084)
- Persistent Hive database for devices and shortcuts
- AppShell with NavigationRail sidebar

### Phase 2: Tool Configuration ✅
- Auto-detection of ADB and scrcpy paths
- Platform-specific detection strategies (Windows, macOS, Linux)
- Tool verification with version extraction
- Settings screen with auto-detect and verify buttons
- Persistence via SharedPreferences

### Phase 3: Device Management & ADB ✅
- Manage WiFi-connected devices (add, edit, delete)
- Real-time USB device detection
- Connection status polling (8s for WiFi, 5s for USB)
- One-click connect/disconnect
- Auto-reconnect support for marked devices
- Device information display (model, Android version)

### Current Beta Integrations ⚠️
- scrcpy launches from device cards when configured
- Basic shortcuts CRUD with predefined commands
- `%DEVICE%` placeholder replacement for shortcut execution
- macOS drag-to-Applications DMG packaging
- Sentry error reporting for beta builds

## Architecture

The project follows a **layered architecture**:

```
Presentation Layer    → Screens, Widgets, Riverpod consumers
Application Layer     → Services (AdbService, ToolsConfigService)
Domain Layer          → Models (Device, Shortcut, ToolsConfig)
Infrastructure Layer  → Repositories, ProcessRunner abstraction
```

### Key Components

- **AdbService**: Wrapper around all ADB commands (40+ lines, testable via ProcessRunner)
- **ToolsConfigService**: Tool path detection, verification, persistence
- **DeviceRepository**: Hive CRUD operations for devices
- **DevicesNotifier**: Riverpod state management with polling
- **UsbDevicesProvider**: Real-time USB device streaming
- **ProcessRunner**: Abstraction for test-friendly process execution

## Prerequisites

- Flutter >= 3.22
- Dart 3.x
- ADB installed and in PATH (or configured via Settings)
- scrcpy installed (optional, for screen mirroring)

## Install ADB and scrcpy

FastADB does not bundle ADB or scrcpy. Install them with your OS package manager, then configure their paths in **Settings** if auto-detection does not find them.

### macOS

Recommended with Homebrew:

```bash
brew install android-platform-tools scrcpy
```

Common paths:

- Apple Silicon Homebrew: `/opt/homebrew/bin/adb`, `/opt/homebrew/bin/scrcpy`
- Intel Homebrew: `/usr/local/bin/adb`, `/usr/local/bin/scrcpy`

Unsigned beta builds may need approval in **System Settings > Privacy & Security** the first time they are opened.

### Windows

ADB:

- Install Android Studio, or download Android SDK Platform-Tools from Google.
- Common Android Studio path: `%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe`
- If using the standalone Platform-Tools ZIP, extract it into a stable folder and select `adb.exe` from FastADB Settings.

scrcpy:

- Download the Windows release from Genymobile scrcpy releases.
- Extract it into a stable folder and select `scrcpy.exe` from FastADB Settings.

Unsigned beta builds may show a SmartScreen warning on first launch.

### Linux

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install adb scrcpy
```

Fedora:

```bash
sudo dnf install android-tools scrcpy
```

Arch:

```bash
sudo pacman -S android-tools scrcpy
```

If USB devices appear as unauthorized or permission denied:

```bash
sudo usermod -aG plugdev "$USER"
```

Then install Android udev rules for your distro, log out and back in, reconnect the device, and accept the USB debugging prompt on the phone.

## Getting Started

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Generate Hive adapters
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run the app
```bash
# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

### 4. Configure tools (First launch)
1. Go to **Settings** tab
2. Click "Auto-detect ADB" - should find your ADB installation
3. Click "Verify" - should show ADB version
4. Same for scrcpy
5. Settings are automatically saved

### 5. Add and connect devices
1. Go to **Devices** tab
2. Click **+** button to add a WiFi device
3. Enter alias, IP address, and port (default: 5555)
4. Click "Connect" button
5. Status should change to "Connected"

### 6. Detect USB devices
1. Connect an Android device via USB
2. Go to **USB** tab
3. Device appears automatically
4. Click "Enable WiFi ADB" to convert to WiFi connection

## File Structure

```
lib/
├── core/
│   ├── models/              # Device, Shortcut, ToolsConfig + Hive adapters
│   ├── services/            # ADB, tools config, process runner
│   └── repositories/        # Hive CRUD for devices and shortcuts
├── providers/
│   ├── devices_provider.dart                # WiFi devices + polling
│   ├── tools_config_provider.dart           # Tools configuration
│   └── usb_devices_provider.dart            # USB detection (5s polling)
├── screens/
│   ├── devices/                             # WiFi device management
│   ├── usb/                                 # USB device detection
│   ├── settings/                            # ADB/scrcpy configuration
│   └── shortcuts/                           # Shortcut CRUD
├── shared/
│   ├── theme/                               # Colors and theme
│   ├── widgets/                             # AppShell, StatusPill, etc.
│   └── utils/                               # ADB output parsing
├── config/
│   └── router.dart                          # go_router navigation
└── main.dart                                # App entry, Hive init, Riverpod
```

## Development

## Release Process

FastADB uses semantic versioning with beta pre-releases:

```text
MAJOR.MINOR.PATCH-prerelease+build
```

Current app version:

```yaml
version: 0.1.0-beta.4+4
```

Release tag format:

```text
v0.1.0-beta.1
v0.1.0-beta.2
v0.1.0-beta.3
v0.1.0-beta.4
v0.1.1-beta.1
v0.2.0-beta.1
v1.0.0
```

Before publishing a beta:

```bash
flutter pub get
flutter analyze
flutter test
flutter build macos --release
```

After GitHub Actions publishes the artifacts, validate the downloaded builds with `docs/beta_0_1_validation.md` and add the result to `RELEASE_NOTES.md`.

Publish a beta release:

```bash
git tag v0.1.0-beta.4
git push origin main --tags
```

The GitHub Actions workflow builds Windows, macOS, and Linux packages, then creates a GitHub Release. Tags containing a prerelease suffix such as `-beta.1` are marked as pre-releases automatically.

### Adding new ADB commands

1. **Add method to AdbService**:
```dart
Future<String> newCommand(String serial) async {
  final result = await _runner.run([adbPath, '-s', serial, 'my-command']);
  // Parse result.stdout
  return parsed;
}
```

2. **Use in providers**:
```dart
final status = await _adbService.newCommand(device.serial);
```

3. **Update DevicesNotifier polling** if needed for real-time updates

### Testing commands

The `ProcessRunner` abstraction allows mocking:
```dart
class MockProcessRunner implements ProcessRunner {
  @override
  Future<ProcessResult> run(List<String> args, {...}) async {
    return ProcessResult(0, 0, 'mocked output', '');
  }
}
```

### Marionette MCP

FastADB includes Marionette automation for debug builds and a project-local MCP server configuration.

- MCP server dependency: `marionette_mcp`
- Cursor config: `.cursor/mcp.json`
- VS Code/Copilot config: `.vscode/mcp.json`
- Usage guide: `docs/marionette_mcp.md`

Run the app in debug mode, copy the VM Service WebSocket URL, then use the Marionette MCP `connect` tool.

### Debugging

```bash
# View logs
flutter logs

# Enable verbose mode
flutter run -v

# Open DevTools
flutter pub global run devtools

# Inspect Hive database
# Located at: ~/.local/share/fastadb/ (Linux) or AppData (Windows)
```

## Platform-Specific Notes

### Windows
- ADB path resolution: config → ANDROID_HOME → ANDROID_SDK_ROOT → LOCALAPPDATA → PATH
- Requires: Visual Studio Build Tools or MinGW for compilation
- Distribution: ZIP in beta; MSIX/installer planned

### macOS
- Supports Intel and Apple Silicon (M1/M2)
- Requires: Xcode Command Line Tools
- Gatekeeper: unsigned beta builds may require manual approval
- Distribution: drag-to-Applications DMG

### Linux
- Requires: libc, libstdc++
- USB permissions: May need `sudo usermod -aG plugdev $USER`
- Distribution: tar.gz in beta; AppImage/deb planned

## Known Limitations

- scrcpy is launched directly from the devices provider; a dedicated `ScrcpyService` is still pending.
- Shortcuts are basic: device-specific assignment, `%APK%`, and long-running command handling are not complete yet.
- Terminal output is not streamed in real time for long-running commands such as `logcat`.
- System tray, close-to-tray, and start-minimized behavior are not integrated yet.
- macOS has a DMG, but builds are not signed or notarized yet.
- Windows and Linux artifacts are still ZIP/tar.gz, not native installers.

## Roadmap

See [`ROADMAP.md`](ROADMAP.md) for the active release plan from beta to `1.0.0`.

## Project Resources

- **Roadmap**: `ROADMAP.md`
- **Technical Guide**: `FastADB_Dev_Guide.md`
- **Implementation Plan**: `FastADB_Plan_Implementacion.docx` (detailed requirements)
- **UI Design**: `desing.pen` (Pencil/Figma mockups)

## License

MIT - See LICENSE file

---

**FastADB MVP Beta 0.1.0-beta.4** - Built with Flutter 3.x, Riverpod, Hive, go_router
