# Beta 0.1.x Manual Validation

Use this checklist for every Beta 0.1.x GitHub Release before marking the release as validated.

## Preconditions

- Download artifacts from the GitHub Release page, not from local build output.
- Test on clean or representative user environments.
- Install ADB and scrcpy using the platform instructions in `README.md`.
- Use at least one Android device with USB debugging enabled.
- Use one WiFi ADB target where TCP/IP mode is already enabled or can be enabled from USB.

## macOS

Artifact: `FastADB-v<version>-macos.dmg`

- Mount the DMG.
- Drag FastADB into Applications.
- Open the app from Applications.
- If Gatekeeper blocks the unsigned beta, open from System Settings > Privacy & Security.
- Open Settings and verify ADB.
- Open Settings and verify scrcpy.
- Detect a USB device.
- Confirm unauthorized devices show an actionable message until the phone prompt is accepted.
- Enable WiFi ADB from a USB device.
- Save the WiFi device.
- Connect and disconnect the saved WiFi device.
- Launch scrcpy from a connected device.
- Run a global shortcut against a connected device.

## Windows

Artifact: `FastADB-v<version>-windows-x64.zip`

- Extract the ZIP into a user-writable directory.
- Open FastADB.
- If SmartScreen warns about the unsigned beta, choose the manual run option for validation.
- Open Settings and verify ADB.
- Open Settings and verify scrcpy.
- Detect a USB device.
- Confirm unauthorized devices show an actionable message until the phone prompt is accepted.
- Enable WiFi ADB from a USB device.
- Save the WiFi device.
- Connect and disconnect the saved WiFi device.
- Launch scrcpy from a connected device.
- Run a global shortcut against a connected device.

## Linux

Artifact: `FastADB-v<version>-linux-x64.tar.gz`

- Extract the archive.
- Run the FastADB executable.
- Open Settings and verify ADB.
- Open Settings and verify scrcpy.
- Detect a USB device.
- If the device shows USB permission errors, install udev rules, add the user to `plugdev` or the distro equivalent group, log out, reconnect the device, and retest.
- Confirm unauthorized devices show an actionable message until the phone prompt is accepted.
- Enable WiFi ADB from a USB device.
- Save the WiFi device.
- Connect and disconnect the saved WiFi device.
- Launch scrcpy from a connected device.
- Run a global shortcut against a connected device.

## Result Template

```text
Version:
Date:
Tester:

macOS artifact:
- Status:
- OS version:
- Notes:

Windows artifact:
- Status:
- OS version:
- Notes:

Linux artifact:
- Status:
- Distro/version:
- Notes:
```
