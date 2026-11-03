<#
.SYNOPSIS
  Build PandaPDF-<version>-Setup-windows-<arch>.exe with Inno Setup.

.DESCRIPTION
  Builds pdfcraft.exe and pdfcraft-cli.exe with the C runtime linked statically (no Visual C++
  redistributable needed), fetches the OCR models, stages everything with the app renamed to
  PandaPDF.exe, and compiles packaging/windows/pandapdf.iss into $env:DIST (default dist/release).

  Needs: Rust (MSVC toolchain), git, curl and the network (the OCR models), and Inno Setup 6:
  winget install JRSoftware.InnoSetup

.EXAMPLE
  powershell -File packaging/windows/pandapdf-setup.ps1
  powershell -File packaging/windows/pandapdf-setup.ps1 -SkipBuild
#>
param(
  [ValidateSet('x64', 'arm64')] [string] $Arch = 'x64',
  [switch] $SkipBuild
)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path

function Invoke-Native([string] $What, [scriptblock] $Block) {
  Write-Output "==> $What"
  & $Block
  if ($LASTEXITCODE -ne 0) { throw "$What failed with exit code $LASTEXITCODE" }
}

# The version lives in one place: [workspace.package] version in the root Cargo.toml.
$Version = $null
$inPkg = $false
foreach ($line in Get-Content (Join-Path $Root 'Cargo.toml')) {
  if ($line -match '^\s*\[') { $inPkg = ($line.Trim() -eq '[workspace.package]'); continue }
  if ($inPkg -and $line -match '^\s*version\s*=\s*"([^"]+)"') { $Version = $Matches[1]; break }
}
if (-not $Version) { throw 'could not read [workspace.package] version from Cargo.toml' }

$Iscc = @(
  (Get-Command iscc -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source),
  "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
  "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
  "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
) | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $Iscc) { throw 'Inno Setup 6 not found: winget install JRSoftware.InnoSetup' }

$Target = switch ($Arch) { 'x64' { 'x86_64-pc-windows-msvc' } 'arm64' { 'aarch64-pc-windows-msvc' } }
$Dist = if ($env:DIST) { $env:DIST } else { Join-Path $Root 'dist\release' }
$TargetDir = if ($env:CARGO_TARGET_DIR) { $env:CARGO_TARGET_DIR } else { Join-Path $Root 'target' }
New-Item -ItemType Directory -Force -Path $Dist | Out-Null
Write-Output "PandaPDF $Version for Windows $Arch ($Target)"

if (-not $SkipBuild) {
  if (-not $env:PDFCRAFT_BUILD_SHA) { $env:PDFCRAFT_BUILD_SHA = (git -C $Root rev-parse HEAD 2>$null) }
  if (-not $env:PDFCRAFT_BUILD_DATE) { $env:PDFCRAFT_BUILD_DATE = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd') }
  # Static CRT, scoped to the target so host build scripts and proc-macros are unaffected.
  $flagVar = 'CARGO_TARGET_' + ($Target.ToUpper() -replace '-', '_') + '_RUSTFLAGS'
  [Environment]::SetEnvironmentVariable($flagVar, '-C target-feature=+crt-static')
  # Fail the build (rather than warn) if the icon/VERSIONINFO can't be embedded.
  $env:PDFCRAFT_REQUIRE_WINRES = '1'
  Invoke-Native "cargo build ($Target)" { cargo build --release --locked -p pdfcraft -p pdfcraft-cli --target $Target }
  # Cargo also applies target flags to builds without --target when the target is the host, so
  # clear them: xtask below must not be rebuilt with a static CRT.
  [Environment]::SetEnvironmentVariable($flagVar, $null)
}
$Bin = Join-Path $TargetDir "$Target\release"

$Stage = Join-Path $TargetDir "pandapdf-setup\$Arch"
Remove-Item -Recurse -Force $Stage -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $Stage | Out-Null
Copy-Item (Join-Path $Bin 'pdfcraft.exe') (Join-Path $Stage 'PandaPDF.exe')
Copy-Item (Join-Path $Bin 'pdfcraft-cli.exe') $Stage
foreach ($f in 'LICENSE-MIT', 'LICENSE-APACHE', 'NOTICE', 'README.md') { Copy-Item (Join-Path $Root $f) $Stage }
Copy-Item (Join-Path $Root 'assets\app-icon\LICENSE-document.txt') $Stage

# OCR models: the app looks in models\ beside its exe (see package.ps1).
$Models = Join-Path $Stage 'models'
New-Item -ItemType Directory -Force -Path $Models | Out-Null
Push-Location $Root
try { Invoke-Native 'cargo xtask models' { cargo xtask models $Models } } finally { Pop-Location }
Remove-Item -Force (Join-Path $Models '*.part') -ErrorAction SilentlyContinue

Invoke-Native 'iscc' {
  & $Iscc /Qp "/DVersion=$Version" "/DStageDir=$Stage" "/DArch=$Arch" "/DOutDir=$Dist" (Join-Path $PSScriptRoot 'pandapdf.iss')
}
Get-Item (Join-Path $Dist "PandaPDF-$Version-Setup-windows-$Arch.exe") | Format-Table Name, Length
