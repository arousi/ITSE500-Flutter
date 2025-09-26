# Windows packaging automation

Use the PowerShell script to create a local code-signing cert, trust it (optional), patch msix_config, and build an MSIX.

Quick start

- Open PowerShell
- Run:
  - `Set-ExecutionPolicy -Scope Process Bypass`
  - `./scripts/build-windows-msix.ps1 -TrustCert`

What it does

- Generates a self-signed Code Signing cert (PFX/CER) under `windows/certs`.
- Optionally trusts the cert locally (TrustedPeople + Root) to reduce SmartScreen/AV friction.
- Minimizes capabilities to `internetClient` and wires signing in `pubspec.yaml`.
- Builds an MSIX via `dart run msix:create`.
- Optionally signs raw EXEs with signtool if available (`-SignRawExe`).

Avast Hardened Mode

- Avast blocks unknown executables in Hardened Mode even if signed with a self-signed cert.
- Preferred: install the MSIX (signed package) instead of running the raw `flutter_app_itse500.exe` from build folders.
- If needed, add an exception for the runner folder: `build\windows\x64\runner\Debug` or `Release`.
- For external distribution, use a publicly trusted certificate or distribute via Microsoft Store.

Parameters

- `-Subject` Subject DN for the cert.
- `-CertPassword` PFX password.
- `-SkipCert` Don’t create a new cert.
- `-TrustCert` Import CER into TrustedPeople and Root.
- `-SignRawExe` Try to sign Debug/Release EXEs.

Outputs

- MSIX: `build\windows\x64\runner\Release\flutter_app_itse500.msix`
- Certs: `windows\certs\itse500-dev.pfx`, `...cer`
