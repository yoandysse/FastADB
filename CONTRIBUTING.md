# Contributing to FastADB

Thanks for helping improve FastADB. This project is a Flutter desktop app for managing Android devices through ADB, so changes should be tested with desktop workflows in mind.

## Ways to Contribute

- Report reproducible bugs.
- Improve platform support for Windows, macOS, and Linux.
- Add tests around ADB parsing, process execution, repositories, and state management.
- Improve documentation for setup, troubleshooting, and releases.
- Pick an item from `ROADMAP.md` or an issue labeled `good first issue`.

## Development Setup

Requirements:

- Flutter `3.41.9` or compatible stable release.
- Dart SDK from Flutter.
- ADB installed locally.
- scrcpy installed locally for screen mirroring work.

Install dependencies:

```bash
flutter pub get
```

Generate localization files and Hive adapters when needed:

```bash
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

Run the app:

```bash
flutter run -d macos
flutter run -d windows
flutter run -d linux
```

## Checks Before Opening a PR

Run:

```bash
flutter analyze
flutter test
```

If you changed localization ARB files, run:

```bash
flutter gen-l10n
```

If you changed Hive models, run:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Pull Request Guidelines

- Keep PRs focused on one feature, fix, or documentation area.
- Include tests for parser, service, repository, or provider changes when practical.
- Update `README.md`, `ROADMAP.md`, or `RELEASE_NOTES.md` when behavior, setup, or release expectations change.
- Avoid committing generated local files, IDE settings, logs, screenshots, or build outputs.
- For UI changes, include screenshots or a short description of the tested platform.

## Code Style

- Follow the existing layered structure:
  - `lib/core`: models, services, repositories.
  - `lib/providers`: Riverpod state.
  - `lib/screens`: UI surfaces.
  - `lib/shared`: reusable theme, widgets, and utilities.
- Prefer testable services with `ProcessRunner` over direct process calls in UI code.
- Keep ADB output parsing centralized in `AdbOutputParser`.
- Keep user-facing strings localized through `lib/l10n`.

## Reporting Bugs

Use the bug report issue template and include:

- OS and version.
- FastADB version.
- ADB and scrcpy versions.
- What you expected.
- What happened.
- Logs, screenshots, or Sentry issue ID when available.

Do not include private device identifiers, access tokens, or sensitive paths unless they are redacted.

## Security Reports

Please do not open public issues for security vulnerabilities. Follow `SECURITY.md`.
