; PandaPDF setup for Windows (Inno Setup 6). Built by pandapdf-setup.ps1, which stages the files
; and passes Version, StageDir, Arch and OutDir.
;
; Installs for the current user by default (no administrator rights; the wizard offers
; "Install for all users" too), adds Start menu and optional desktop shortcuts, and can add
; PandaPDF to the "Open with" list for PDF files without changing the default PDF app.

#ifndef Version
  #error Pass /DVersion=x.y.z
#endif
#ifndef StageDir
  #error Pass /DStageDir=<folder with PandaPDF.exe>
#endif
#ifndef Arch
  #define Arch "x64"
#endif
#ifndef OutDir
  #define OutDir "."
#endif

[Setup]
; A new identity: never PdfCraft's, so PandaPDF installs beside PdfCraft and never replaces it.
AppId={{371C228C-80BB-43A5-9763-207385E0A0F5}
AppName=PandaPDF
AppVersion={#Version}
AppVerName=PandaPDF {#Version}
AppPublisher=Ganesh Panda
AppPublisherURL=https://github.com/ganeshpanda/PandaPDF
AppSupportURL=https://github.com/ganeshpanda/PandaPDF/issues
AppUpdatesURL=https://github.com/ganeshpanda/PandaPDF/releases
AppCopyright=PandaPDF is based on PdfCraft (MIT OR Apache-2.0)
VersionInfoVersion={#Version}
VersionInfoProductName=PandaPDF
VersionInfoDescription=PandaPDF Setup
DefaultDirName={autopf}\PandaPDF
DefaultGroupName=PandaPDF
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
#if Arch == "x64"
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
#elif Arch == "arm64"
ArchitecturesAllowed=arm64
ArchitecturesInstallIn64BitMode=arm64
#endif
MinVersion=10.0
SetupIconFile=..\..\assets\app-icon\pdfcraft.ico
UninstallDisplayIcon={app}\PandaPDF.exe
UninstallDisplayName=PandaPDF
WizardStyle=modern
Compression=lzma2/max
SolidCompression=yes
ChangesAssociations=yes
CloseApplications=yes
OutputDir={#OutDir}
OutputBaseFilename=PandaPDF-{#Version}-Setup-windows-{#Arch}
LicenseFile=..\..\LICENSE-MIT

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"
Name: "openwith"; Description: "Add PandaPDF to ""Open with"" for PDF files (keeps your default PDF app)"; GroupDescription: "File types:"

[Files]
Source: "{#StageDir}\PandaPDF.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\pdfcraft-cli.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\models\*"; DestDir: "{app}\models"; Flags: ignoreversion recursesubdirs createallsubdirs skipifsourcedoesntexist
Source: "{#StageDir}\LICENSE-MIT"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\LICENSE-APACHE"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\NOTICE"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\LICENSE-document.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#StageDir}\README.md"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{autoprograms}\PandaPDF"; Filename: "{app}\PandaPDF.exe"; Comment: "Read, organize and protect PDFs"
Name: "{autodesktop}\PandaPDF"; Filename: "{app}\PandaPDF.exe"; Tasks: desktopicon

[Registry]
; "Open with" only: a ProgId and an application entry, never the .pdf default. Resource 2 of the
; exe is the PDF document icon.
Root: HKA; Subkey: "Software\Classes\PandaPDF.Document"; ValueType: string; ValueData: "PDF Document"; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\PandaPDF.Document\DefaultIcon"; ValueType: string; ValueData: """{app}\PandaPDF.exe"",-2"; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\PandaPDF.Document\shell\open\command"; ValueType: string; ValueData: """{app}\PandaPDF.exe"" ""%1"""; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\.pdf\OpenWithProgids"; ValueType: string; ValueName: "PandaPDF.Document"; ValueData: ""; Flags: uninsdeletevalue; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\Applications\PandaPDF.exe"; ValueType: string; ValueName: "FriendlyAppName"; ValueData: "PandaPDF"; Flags: uninsdeletekey; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\Applications\PandaPDF.exe\SupportedTypes"; ValueType: string; ValueName: ".pdf"; ValueData: ""; Tasks: openwith
Root: HKA; Subkey: "Software\Classes\Applications\PandaPDF.exe\shell\open\command"; ValueType: string; ValueData: """{app}\PandaPDF.exe"" ""%1"""; Tasks: openwith

[Run]
Filename: "{app}\PandaPDF.exe"; Description: "{cm:LaunchProgram,PandaPDF}"; Flags: nowait postinstall skipifsilent
