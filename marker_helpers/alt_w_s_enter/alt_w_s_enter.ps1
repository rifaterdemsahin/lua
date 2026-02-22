$ErrorActionPreference = "Stop"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "[$timestamp] $Message"
}

# Win32 API to bring DaVinci Resolve to foreground
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
    public const int SW_RESTORE = 9;
}
"@

try {
    Write-Log "PS1 script started"

    Add-Type -AssemblyName System.Windows.Forms
    Write-Log "Loaded System.Windows.Forms"

    # Check if DaVinci Resolve is running
    $resolve = Get-Process "Resolve" -ErrorAction SilentlyContinue
    if (-not $resolve) {
        Write-Log "ERROR: DaVinci Resolve is not running. Aborting."
        exit 1
    }
    Write-Log "DaVinci Resolve is running (PID: $($resolve.Id))"

    # Bring DaVinci Resolve window to foreground
    $hwnd = $resolve.MainWindowHandle
    Write-Log "Window handle: $hwnd"
    if ($hwnd -eq [IntPtr]::Zero) {
        Write-Log "ERROR: Could not get DaVinci Resolve window handle. Aborting."
        exit 1
    }
    [Win32]::ShowWindow($hwnd, [Win32]::SW_RESTORE) | Out-Null
    [Win32]::SetForegroundWindow($hwnd) | Out-Null
    Start-Sleep -Milliseconds 500

    # Verify focus
    $foreground = [Win32]::GetForegroundWindow()
    if ($foreground -eq $hwnd) {
        Write-Log "DaVinci Resolve is now in foreground"
    } else {
        Write-Log "WARNING: Foreground window ($foreground) is not DaVinci Resolve ($hwnd). Keystrokes may fail."
    }

    # Navigate: Alt > Workspace menu
    Write-Log "Sending Alt key (open menu bar)..."
    [System.Windows.Forms.SendKeys]::SendWait("%")
    Start-Sleep -Milliseconds 300

    Write-Log "Sending W key (Workspace menu)..."
    [System.Windows.Forms.SendKeys]::SendWait("w")
    Start-Sleep -Milliseconds 400

    # Navigate to Scripts: go to bottom of menu with End, then Up twice
    Write-Log "Sending End key (jump to bottom of menu)..."
    [System.Windows.Forms.SendKeys]::SendWait("{END}")
    Start-Sleep -Milliseconds 200

    Write-Log "Sending Up arrow (skip Workflow Integrations)..."
    [System.Windows.Forms.SendKeys]::SendWait("{UP}")
    Start-Sleep -Milliseconds 200

    # Now on Scripts — open its submenu
    Write-Log "Sending Right arrow (open Scripts submenu)..."
    [System.Windows.Forms.SendKeys]::SendWait("{RIGHT}")
    Start-Sleep -Milliseconds 400

    # Jump to fill_last_marker by typing 'f'
    Write-Log "Sending 'f' key (jump to fill_last_marker)..."
    [System.Windows.Forms.SendKeys]::SendWait("f")
    Start-Sleep -Milliseconds 200

    # In case 'f' doesn't jump, also send Down arrows as fallback navigation
    # The menu order is: Comp, chaptermarkers, fill_last_marker, ...
    # If 'f' jumped to fill_last_marker, Enter will trigger it
    Write-Log "Sending Enter (execute fill_last_marker)..."
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")

    Write-Log "All keystrokes sent successfully - fill_last_marker should be triggered"
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "Stack trace: $($_.ScriptStackTrace)"
    exit 1
}
