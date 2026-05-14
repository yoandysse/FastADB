# Security Policy

## Supported Versions

FastADB is currently in beta. Security fixes target the latest beta release and the `main` branch.

| Version | Supported |
| --- | --- |
| Latest beta | Yes |
| Older beta releases | No |

## Reporting a Vulnerability

Do not open a public issue for vulnerabilities.

Use GitHub private vulnerability reporting if it is enabled for the repository. If it is not enabled, open a minimal public issue asking for a secure contact channel without disclosing technical details.

Please include:

- Affected FastADB version or commit.
- Operating system.
- Steps to reproduce.
- Impact and affected functionality.
- Whether the issue involves ADB, scrcpy, local file access, release artifacts, or Sentry telemetry.

## Scope

Security-sensitive areas include:

- Running ADB or scrcpy commands.
- Shortcut command execution.
- File picker access and local file handling.
- Release artifacts and update/download flows.
- Crash reporting and telemetry configuration.

## Disclosure

Please allow maintainers reasonable time to investigate and publish a fix before public disclosure.
