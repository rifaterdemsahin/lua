# Trigger fill_last_marker via DaVinci Resolve's Python scripting API
# No menu navigation needed — bypasses all shortcut conflicts and focus issues.

$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[$timestamp] $Message"
}

try {
    Write-Log "PS1 script started"

    # Check if DaVinci Resolve is running
    $resolve = Get-Process "Resolve" -ErrorAction SilentlyContinue
    if (-not $resolve) {
        Write-Log "ERROR: DaVinci Resolve is not running. Aborting."
        exit 1
    }
    Write-Log "DaVinci Resolve is running (PID: $($resolve.Id))"

    # Path to the Python trigger script (same folder as this PS1)
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $pythonScript = Join-Path $scriptDir "fill_last_marker_api.py"

    if (-not (Test-Path $pythonScript)) {
        Write-Log "ERROR: Python script not found at $pythonScript"
        exit 1
    }

    Write-Log "Running fill_last_marker via Resolve Python API..."

    # Set env vars so DaVinciResolveScript.py can find fusionscript.dll
    $env:RESOLVE_SCRIPT_LIB = "C:\Program Files\Blackmagic Design\DaVinci Resolve\fusionscript.dll"
    $env:RESOLVE_SCRIPT_API = "$env:PROGRAMDATA\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting"
    $env:PYTHONPATH = "$env:PROGRAMDATA\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\Modules"

    # Use Python 3.13 via the py launcher — Resolve's fusionscript.dll is not compatible with 3.14+
    $output = py -3.13 $pythonScript 2>&1
    $exitCode = $LASTEXITCODE

    foreach ($line in $output) {
        Write-Log "PYTHON: $line"
    }

    if ($exitCode -ne 0) {
        Write-Log "ERROR: Python exited with code $exitCode"
        exit 1
    }

    Write-Log "fill_last_marker completed successfully"
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}
