# FastADB - Desktop ADB Manager

A cross-platform Flutter desktop application to manage Android devices via ADB without the terminal.

**Current Status:** MVP (Phases 1-3 Completed) ✅

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
- scrcpy installed (optional, for screen mirroring in Phase 4)

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
│   ├── services/
│   │   ├── adb_service.dart                 # ADB command wrapper
│   │   ├── tools_config_service.dart        # Tool detection & verification
│   │   └── process_runner.dart              # Command execution abstraction
│   └── repositories/
│       └── device_repository.dart           # Hive CRUD operations
├── providers/
│   ├── devices_provider.dart                # WiFi devices + polling
│   ├── tools_config_provider.dart           # Tools configuration
│   └── usb_devices_provider.dart            # USB detection (5s polling)
├── screens/
│   ├── devices/                             # WiFi device management
│   ├── usb/                                 # USB device detection
│   ├── settings/                            # ADB/scrcpy configuration
│   └── shortcuts/                           # Future: custom shortcuts
├── shared/
│   ├── theme/                               # Colors and theme
│   ├── widgets/                             # AppShell, StatusPill, etc.
│   └── utils/                               # ADB output parsing
├── config/
│   └── router.dart                          # go_router navigation
└── main.dart                                # App entry, Hive init, Riverpod
```

## Development

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
- Distribution: MSIX packaging (Phase 5)

### macOS
- Supports Intel and Apple Silicon (M1/M2)
- Requires: Xcode Command Line Tools
- Gatekeeper: Unsigned binaries may need sandboxing entitlements
- Distribution: DMG creation (Phase 5)

### Linux
- Requires: libc, libstdc++
- USB permissions: May need `sudo usermod -aG plugdev $USER`
- Distribution: AppImage with appimagebuild

## Known Limitations

- ❌ No screen mirroring yet (Phase 4)
- ❌ No custom shortcuts execution (Phase 4)
- ❌ No integrated terminal output (Phase 4)
- ⚠️ Limited error context messages (improvements in progress)

## Next Phases

**Phase 4: scrcpy & Shortcuts** (3-4 days)
- Screen mirroring integration
- Custom shortcut builder and execution
- Terminal output streaming widget
- Predefined shortcuts (Logcat, Screenshot, etc.)

**Phase 5: Distribution** (4-5 days)
- Windows MSIX packaging and installer
- macOS DMG creation
- Linux AppImage bundling
- Automated release pipeline

## Project Resources

- **Technical Guide**: `FastADB_Dev_Guide.md` (comprehensive architecture, services, 5-phase plan)
- **Implementation Plan**: `FastADB_Plan_Implementacion.docx` (detailed requirements)
- **UI Design**: `desing.pen` (Pencil/Figma mockups)

## License

MIT - See LICENSE file

---

**FastADB MVP v1.0** — Built with Flutter 3.x, Riverpod, Hive, go_router