# Windows desktop additions summary

- Window
  - Centered on primary screen by default, min size 960x640, persists size/position across runs.
  - Toggle hotkey: Ctrl+Shift+T.
- Tray
  - Basic tray with Show/Exit (icon path: assets/icon.ico). Place an ICO file there or update path.
- Protocol handler
  - myapp:// scheme registered at runtime; MSIX config includes protocol_activation: myapp.
- Single instance
  - Implemented in windows/runner/main.cpp: new launches dispatch to running instance.
- File dialogs and printing
  - Helpers in lib/core/desktop/desktop_io.dart for open/save and printing.
- Drag & drop
  - MainScreen wraps content in DropTarget on Windows; logs dropped file paths.

## MSIX notes

- Configure publisher with a real certificate subject for production.
- For local testing, msix_config.install_certificate: true will generate and install a dev cert.
- Build: flutter pub run msix:create
