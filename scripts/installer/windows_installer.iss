; Inno Setup script for ITSE500 Windows Installer
; Uses /DMyAppVersion passed from CI to set version.

#ifndef MyAppVersion
#define MyAppVersion "0.0.0"
#endif
#define MyAppName "ITSE500"
#define MyAppPublisher "ITSE500 Project"
#define MyAppExeName "flutter_app_itse500.exe"

[Setup]
AppId={{5B9292B2-10FE-4B0D-9E3C-3F1D43B0E7AD}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=ITSE500-Setup-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop shortcut"; GroupDescription: "Additional icons:"; Flags: unchecked

[Files]
; Staged files copied by CI into installer_staging directory
Source: "installer_staging\\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\\{#MyAppExeName}"; Description: "Launch {#MyAppName} now"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}\\_dart_tool"

[Code]
// Optionally perform checks or logging here.
