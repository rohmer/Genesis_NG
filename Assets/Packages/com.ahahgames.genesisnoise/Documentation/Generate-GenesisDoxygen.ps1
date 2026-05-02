Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$packageRoot = Split-Path -Parent $scriptDir
$doxygenRoot = Join-Path $scriptDir "Doxygen"
$doxyfilePath = Join-Path $doxygenRoot "Doxyfile"
$htmlOutputDir = Join-Path $doxygenRoot "html"
$xmlOutputDir = Join-Path $doxygenRoot "xml"
$latexOutputDir = Join-Path $doxygenRoot "latex"

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Remove-DirectoryIfPresent {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        return
    }

    Get-ChildItem -LiteralPath $Path -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object {
        $_.IsReadOnly = $false
    }

    Remove-Item -LiteralPath $Path -Recurse -Force
}

function Resolve-DoxygenExecutable {
    $candidates = @(
        $env:DOXYGEN_EXECUTABLE,
        "doxygen",
        "doxygen.exe"
    ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

    foreach ($candidate in $candidates) {
        try {
            $command = Get-Command $candidate -ErrorAction Stop | Select-Object -First 1
            if ($null -ne $command -and -not [string]::IsNullOrWhiteSpace($command.Source)) {
                return $command.Source
            }
        }
        catch {
            continue
        }
    }

    $defaultWindowsPath = "C:\Program Files\doxygen\bin\doxygen.exe"
    if (Test-Path $defaultWindowsPath) {
        return $defaultWindowsPath
    }

    throw "Unable to locate a Doxygen executable. Install Doxygen or set the DOXYGEN_EXECUTABLE environment variable."
}

if (-not (Test-Path $doxyfilePath)) {
    throw "The Doxygen configuration file was not found: $doxyfilePath"
}

Ensure-Directory $doxygenRoot
Remove-DirectoryIfPresent $htmlOutputDir
Remove-DirectoryIfPresent $xmlOutputDir
Remove-DirectoryIfPresent $latexOutputDir

$doxygenExecutable = Resolve-DoxygenExecutable
Write-Host ("Running Doxygen via {0}" -f $doxygenExecutable)

$output = & $doxygenExecutable $doxyfilePath 2>&1
if ($output) {
    $output | ForEach-Object {
        Write-Host $_
    }
}

if ($LASTEXITCODE -ne 0) {
    throw ("Doxygen exited with code {0}." -f $LASTEXITCODE)
}

$htmlIndexPath = Join-Path $htmlOutputDir "index.html"
$xmlIndexPath = Join-Path $xmlOutputDir "index.xml"
if (-not (Test-Path $htmlIndexPath)) {
    throw "Doxygen completed without producing Documentation/Doxygen/html/index.html."
}

if (-not (Test-Path $xmlIndexPath)) {
    throw "Doxygen completed without producing Documentation/Doxygen/xml/index.xml."
}

Write-Host ("Generated Doxygen HTML at {0}" -f $htmlIndexPath)
Write-Host ("Generated Doxygen XML at {0}" -f $xmlIndexPath)
