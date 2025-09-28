# flutter_app_itse500

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 🚀 Automated Multi-Platform Releases

Push a version tag (e.g. `v1.2.3`) and GitHub Actions will build and attach artifacts for Android, Web, Linux, Windows, macOS, and optionally iOS.

### Setup Secrets (Settings → Secrets and variables → Actions)

Android (optional but recommended for signed builds):

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_ALIAS_PASSWORD`

Windows (MSIX optional):

- `WINDOWS_CERT_PFX` (Base64)
- `WINDOWS_CERT_PASSWORD`

iOS (optional; workflow skips if absent):

- `APPLE_CERTIFICATE_P12` (Base64)
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_PROVISIONING_PROFILE` (Base64)

### Release Steps

1. Update version in `pubspec.yaml`.
2. Commit changes.
3. Create & push tag:

```bash
git tag v1.2.3
git push origin v1.2.3
```

4. Wait for workflow `.github/workflows/release.yml` to finish.

### Artifacts

| Platform | Output |
|----------|--------|
| Android  | AAB + universal APK |
| Web      | Zipped `build/web` |
| Linux    | tar.gz bundle |
| Windows  | Zip (+ MSIX if signed) |
| macOS    | Zipped .app |
| iOS      | IPA (if signing secrets set) |

### Local Build Parity

```bash
flutter clean
flutter pub get
flutter build appbundle --release
flutter build apk --release
flutter build web --release
flutter build linux --release
flutter build windows --release
flutter build macos --release
# flutter build ipa --release  # requires macOS & signing
```

### Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| iOS job skipped | Missing iOS secrets | Add iOS secrets |
| Unsigned Android AAB | No keystore secrets | Add Android signing secrets |
| Linux deps error | Missing packages | Keep apt install step |
| Missing MSIX | No Windows cert | Add PFX secrets or ignore |

Never commit raw certificates/keystores—store them as Base64 in secrets.

Workflow file: `.github/workflows/release.yml`.
