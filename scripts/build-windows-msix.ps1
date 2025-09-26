param(
  [string]$Subject = 'CN=ITSE500 Dev (Local), O=ITSE500, C=LY',
  [string]$CertPassword = 'itse500-dev',
  [switch]$SkipCert,
  [switch]$TrustCert,
  [switch]$SignRawExe,
  [switch]$InstallMsix,
  [switch]$LaunchMsix,
  # Fallback: copy debug runner to a temp folder and launch it (helps if AV or removable-drive policies block execution in-place)
  [switch]$RunDebugRunner
)

$ErrorActionPreference = 'Stop'

function Write-Step($msg) { Write-Host "[+] $msg" -ForegroundColor Cyan }
function Ensure-Tool($cmd, $friendly) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    throw "Missing required tool: $friendly ($cmd)"
  }
}

$repoRoot = (Resolve-Path "$PSScriptRoot\..\\").Path.TrimEnd('\\')
$projDir = $repoRoot
$certDir = Join-Path $projDir 'windows\\certs'
$pfxPath = Join-Path $certDir 'itse500-dev.pfx'          # leaf signing cert (PFX)
$cerPath = Join-Path $certDir 'itse500-dev.cer'          # leaf signing cert (CER)
$rootCerPath = Join-Path $certDir 'itse500-dev-root.cer' # root CA (CER)
 $debugRunnerDir = Join-Path $projDir 'build\\windows\\x64\\runner\\Debug'
 $releaseRunnerDir = Join-Path $projDir 'build\\windows\\x64\\runner\\Release'

Write-Step "Project dir: $projDir"
Ensure-Tool dart 'Dart SDK'
Ensure-Tool flutter 'Flutter SDK'

New-Item -ItemType Directory -Force -Path $certDir | Out-Null

if (-not $SkipCert) {
  Write-Step "Creating root CA and code-signing certificate"
  # Create a root CA certificate
  $root = New-SelfSignedCertificate -Type Custom -Subject "CN=ITSE500 Dev Root CA, O=ITSE500, C=LY" -KeyExportPolicy Exportable -KeyLength 2048 -HashAlgorithm sha256 -CertStoreLocation 'Cert:\\CurrentUser\\My' -KeyUsage CertSign, CRLSign, DigitalSignature -TextExtension @('2.5.29.19={critical}{text}CA=true')
  # Create a leaf code-signing certificate issued by the root CA
  $leaf = New-SelfSignedCertificate -Type Custom -Subject $Subject -KeyExportPolicy Exportable -KeyLength 2048 -HashAlgorithm sha256 -CertStoreLocation 'Cert:\\CurrentUser\\My' -Signer $root -KeyUsage DigitalSignature -TextExtension @('2.5.29.19={text}CA=false','2.5.29.37={text}1.3.6.1.5.5.7.3.3')

  # Export certificates
  Export-PfxCertificate -Cert $leaf.PSPath -FilePath $pfxPath -Password (ConvertTo-SecureString $CertPassword -AsPlainText -Force) | Out-Null
  Export-Certificate -Cert $leaf.PSPath -FilePath $cerPath | Out-Null
  Export-Certificate -Cert $root.PSPath -FilePath $rootCerPath | Out-Null
  Write-Step "Certs created: $pfxPath (leaf), $rootCerPath (root)"

  if ($TrustCert) {
    Write-Step "Trusting root in CurrentUser\\Root and leaf in CurrentUser\\TrustedPeople"
    Import-Certificate -FilePath $rootCerPath -CertStoreLocation 'Cert:\\CurrentUser\\Root' | Out-Null
    Import-Certificate -FilePath $cerPath -CertStoreLocation 'Cert:\\CurrentUser\\TrustedPeople' | Out-Null
  }
}

if (-not $RunDebugRunner) {
  Write-Step "Patching pubspec msix_config for signing"
  $pubspec = Join-Path $projDir 'pubspec.yaml'
  $content = Get-Content $pubspec -Raw
  # make targeted line replacements
  $content = $content -replace '(?m)^\s*capabilities:.*$', '  capabilities: internetClient'
  $content = $content -replace '(?m)^\s*install_certificate:.*$', '  install_certificate: false'
  # ensure certificate_path and certificate_password exist under msix_config
  if ($content -notmatch '(?m)^\s*certificate_path:') {
    $content = $content -replace '(?m)(^\s*protocol_activation:.*$)', "$1`n  certificate_path: windows\\certs\\itse500-dev.pfx`n  certificate_password: $CertPassword"
  }
  Set-Content -Path $pubspec -Value $content -Encoding UTF8

  Write-Step "Building MSIX"
  Push-Location $projDir
  try {
    dart run msix:create
  }
  finally {
    Pop-Location
  }
}

if ($SignRawExe) {
  Write-Step "Attempting to sign raw runner EXEs (Debug/Release)"
  $signtool = Get-Command signtool.exe -ErrorAction SilentlyContinue
  if ($null -eq $signtool) {
    Write-Host "signtool.exe not found; skipping raw EXE signing" -ForegroundColor Yellow
  } else {
    $exePaths = @(
      (Join-Path $projDir 'build\\windows\\x64\\runner\\Release\\flutter_app_itse500.exe'),
      (Join-Path $projDir 'build\\windows\\x64\\runner\\Debug\\flutter_app_itse500.exe')
    )
    foreach ($exe in $exePaths) {
      if (Test-Path $exe) {
        & $signtool.FullName sign /f $pfxPath /p $CertPassword /fd SHA256 /tr http://timestamp.digicert.com /td SHA256 $exe
      }
    }
  }
}

if (-not $RunDebugRunner -and ($InstallMsix -or $LaunchMsix)) {
  Write-Step "Locating generated MSIX and installing"
  $msix = Get-ChildItem -Path (Join-Path $projDir 'build\\windows\\x64\\runner\\Release') -Filter *.msix -Recurse -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
  if ($null -eq $msix) { throw 'MSIX not found after build.' }
  if ($InstallMsix) {
    Add-AppxPackage -Path $msix.FullName -ForceApplicationShutdown
  }
  if ($LaunchMsix) {
    $pkg = Get-AppxPackage -Name 'com.itse500.ok.app' -ErrorAction SilentlyContinue
    if ($pkg) {
      $appId = "$($pkg.PackageFamilyName)!App"
      Start-Process "shell:AppsFolder/$appId"
    } else {
      Write-Host 'Package not found in appx list; launch skipped.' -ForegroundColor Yellow
    }
  }
}

if ($RunDebugRunner) {
  Write-Step "Preparing to run Debug runner from a trusted temp location"
  if (-not (Test-Path $debugRunnerDir)) {
    throw "Debug runner folder not found: $debugRunnerDir. Build Windows (Debug) first (e.g., 'flutter run -d windows' or 'flutter build windows --debug')."
  }

  $dstRoot = Join-Path $env:TEMP 'itse500_runner_debug'
  Write-Step "Copying runner to: $dstRoot"
  New-Item -ItemType Directory -Force -Path $dstRoot | Out-Null
  # Prefer robocopy when available for speed and preserving structure
  $robocopy = Get-Command robocopy.exe -ErrorAction SilentlyContinue
  if ($robocopy) {
    # /MIR mirrors content; /NFL /NDL /NJH /NJS keep output quiet; /NP no progress
    $rc = & $robocopy $debugRunnerDir $dstRoot /MIR /NFL /NDL /NJH /NJS /NP
    $exitCode = $LASTEXITCODE
    # Robocopy uses exit codes 0-7 for success/acceptable conditions
    if ($exitCode -gt 7) { throw "robocopy failed with exit code $exitCode" }
  } else {
    Copy-Item -Path (Join-Path $debugRunnerDir '*') -Destination $dstRoot -Recurse -Force
  }

  Write-Step "Unblocking copied files (removing MOTW)"
  try { Get-ChildItem -Path $dstRoot -Recurse -File | ForEach-Object { Unblock-File -Path $_.FullName -ErrorAction SilentlyContinue } } catch { Write-Host $_ -ForegroundColor Yellow }

  $dstExe = Join-Path $dstRoot 'flutter_app_itse500.exe'
  if (-not (Test-Path $dstExe)) { throw "Runner EXE not found at $dstExe" }

  Write-Step "Starting runner from temp with correct WorkingDirectory"
  try {
    $p = Start-Process -FilePath $dstExe -WorkingDirectory $dstRoot -PassThru -WindowStyle Normal
    Write-Host "Started PID $($p.Id). Close the window to end the app." -ForegroundColor Green
  } catch {
    Write-Host "Failed to start runner: $($_.Exception.Message)" -ForegroundColor Red
    throw
  }
}

Write-Step "Done. If Avast Hardened Mode or removable-drive policies block the raw EXE, use -InstallMsix/-LaunchMsix or add an AV exception, or run with -RunDebugRunner to copy+run from temp."
