$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[$timestamp] $Message"
}

try {
    Write-Log "PS1 script started"

    Add-Type -AssemblyName System.Windows.Forms
    Write-Log "Loaded System.Windows.Forms"

    # Check if DaVinci Resolve is running
    $resolve = Get-Process "Resolve" -ErrorAction SilentlyContinue
    if (-not $resolve) {
        Write-Log "WARNING: DaVinci Resolve process not found. The script may not work."
    } else {
        Write-Log "DaVinci Resolve is running (PID: $($resolve.Id))"
    }

    Write-Log "Sending Alt key..."
    Start-Sleep -Milliseconds 300
    [System.Windows.Forms.SendKeys]::SendWait("%")     # Alt

    Write-Log "Sending W key..."
    Start-Sleep -Milliseconds 200
    [System.Windows.Forms.SendKeys]::SendWait("w")     # Workspace

    Write-Log "Sending S key..."
    Start-Sleep -Milliseconds 300
    [System.Windows.Forms.SendKeys]::SendWait("s")     # Scripts

    Write-Log "Sending Enter key..."
    Start-Sleep -Milliseconds 300
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

    Write-Log "All keystrokes sent successfully"
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}
