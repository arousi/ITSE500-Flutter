param(
  [string]$Subject = 'CN=ITSE500 Dev (Local), O=ITSE500, C=LY',
  [string]$PfxPath = 'e:\l-ozma-kapa-project\codebase\deploy\front-end\mobile\flutter_app_itse500\windows\certs\itse500-dev.pfx',
  [string]$CerPath = 'e:\l-ozma-kapa-project\codebase\deploy\front-end\mobile\flutter_app_itse500\windows\certs\itse500-dev.cer',
  [string]$Password = 'itse500-dev'
)

$ErrorActionPreference = 'Stop'

$cert = New-SelfSignedCertificate -Type CodeSigningCert -Subject $Subject -CertStoreLocation 'Cert:\CurrentUser\My' -KeyExportPolicy Exportable -KeyLength 2048 -HashAlgorithm sha256
Export-PfxCertificate -Cert $cert.PSPath -FilePath $PfxPath -Password (ConvertTo-SecureString $Password -AsPlainText -Force) | Out-Null
Export-Certificate -Cert $cert.PSPath -FilePath $CerPath | Out-Null

Write-Host "Created PFX: $PfxPath"
Write-Host "Created CER: $CerPath"
