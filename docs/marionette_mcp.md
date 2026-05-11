# Marionette MCP

FastADB includes Marionette support for development builds.

## Project Setup

The project has:

- `marionette_flutter` as an app dependency.
- `marionette_mcp` as a dev dependency.
- MCP client configs:
  - `.cursor/mcp.json`
  - `.vscode/mcp.json`

Both configs run:

```bash
dart run marionette_mcp
```

## App Requirements

Run the app in debug mode. In `kDebugMode`, FastADB initializes:

- `MarionetteBinding`
- `PrintLogCollector`
- Flutter error forwarding to Marionette logs
- `debugPrint` forwarding to Marionette logs

Release builds use the normal Flutter binding and do not expose Marionette tooling.

## Connect From an MCP Client

Start the app:

```bash
flutter run -d macos
```

Copy the VM Service WebSocket URL from Flutter output. If Flutter prints an HTTP URL like:

```text
http://127.0.0.1:62116/9T1YhZArRLQ=/
```

Use this WebSocket URL in Marionette:

```text
ws://127.0.0.1:62116/9T1YhZArRLQ=/ws
```

Then call the MCP `connect` tool with that URL.

## Useful Marionette Tools

- `connect`: connect to the app VM Service.
- `get_interactive_elements`: inspect visible widgets.
- `tap`: tap by visible text or key.
- `enter_text`: type into a matched input.
- `scroll_to`: scroll until a text/key is visible.
- `take_screenshots`: capture app screenshots.
- `get_logs`: read logs collected since startup or hot restart.
- `hot_reload`: trigger Flutter hot reload.

## Smoke Test Prompt

```text
Connect to ws://127.0.0.1:<port>/<auth>/ws.
Navigate through Mis Dispositivos, USB Detectados, Accesos Rápidos and Configuración.
Verify each screen exposes expected labels.
Call get_logs and report any Flutter errors.
Take one screenshot.
```

## Troubleshooting

- If `get_logs` says log collection is not configured, hot restart the debug app so the latest `main.dart` initialization runs.
- If `connect` cannot find Marionette extensions, confirm the app is running in debug mode.
- If an element cannot be tapped by text, run `get_interactive_elements` and use the exact visible text or a widget key.
