#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POWERSHELL_EXE="powershell.exe"
# Forward all args to the PowerShell script; default to trusting the cert
"$POWERSHELL_EXE" -NoProfile -ExecutionPolicy Bypass -File "$SCRIPT_DIR/build-windows-msix.ps1" "$@"
