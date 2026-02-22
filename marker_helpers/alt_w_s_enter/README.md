# fill_last_marker — Stream Deck Trigger

Runs the **fill_last_marker** script in DaVinci Resolve via the **Python scripting API** — no menu navigation or keyboard shortcuts needed.

## Why not use menu keystrokes?

The original approach used `Alt+W` → `S` → `Enter` to navigate **Workspace > Scripts**. This failed because:
- `Alt+W` is mapped to **Reference Wipe Invert** in the SideshowFX keyboard layout
- SendKeys loses focus when triggered from Stream Deck (CMD window steals it)

The Python API approach talks directly to DaVinci Resolve's scripting engine — no window focus or shortcut conflicts.

## Files

| File | Purpose |
|------|---------|
| `fill_last_marker_api.py` | Python script that runs fill_last_marker logic via Resolve API |
| `alt_w_s_enter.ps1` | PowerShell wrapper — sets up environment and calls the Python script |
| `alt_w_s_enter.bat` | Batch wrapper — run this from Stream Deck or Explorer |

## Requirements

- **Python 3.5+** installed and on PATH
- **DaVinci Resolve** running with a project/timeline open
- DaVinci Resolve scripting API (installed automatically with Resolve)

## Usage

### From Elgato Stream Deck

1. Open the **Stream Deck** app
2. Drag the **System → Open** action onto a button
3. In the **App / File** field, browse to:
   ```
   c:\projects\lua\marker_helpers\alt_w_s_enter\alt_w_s_enter.bat
   ```
4. Press the button — DaVinci Resolve does **not** need to be the focused window

> **Tip:** To hide the CMD window flash, use a VBS wrapper (see Troubleshooting).

### From Explorer / Command Line

Double-click `alt_w_s_enter.bat` or run:
```bat
alt_w_s_enter.bat
```

### Troubleshooting

| Symptom | Fix |
|---------|-----|
| Nothing happens | Check `alt_w_s_enter.log` in the script folder for errors |
| `Cannot import DaVinciResolveScript` | Ensure DaVinci Resolve is installed. Check that `fusionscript.dll` exists at `C:\Program Files\Blackmagic Design\DaVinci Resolve\` |
| `Could not connect to DaVinci Resolve` | DaVinci Resolve must be running. The API connects to the running instance |
| `No timeline open` | Open a timeline in DaVinci Resolve before pressing the button |
| `Resolve process not found` | DaVinci Resolve is not running. Start it first |
| Execution policy error | The bat uses `-ExecutionPolicy Bypass`. If it still fails, run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` once |
| CMD window is annoying | Create a VBS wrapper to hide it — see below |

**VBS wrapper to hide the CMD window** — save as `alt_w_s_enter.vbs` next to the `.bat`:
```vbs
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run Chr(34) & CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName) & "\alt_w_s_enter.bat" & Chr(34), 0, False
```
Then point the Stream Deck button to the `.vbs` file instead.

### Checking the Log

After pressing the Stream Deck button, open the log file to see what happened:
```
c:\projects\lua\marker_helpers\alt_w_s_enter\alt_w_s_enter.log
```
Or from PowerShell:
```powershell
Get-Content "c:\projects\lua\marker_helpers\alt_w_s_enter\alt_w_s_enter.log" -Tail 20
```

## Notes
- DaVinci Resolve does **not** need to be the focused window — the API connects directly.
- Python must be installed and accessible from PATH.
- The script finds the last unfilled marker and fills it with the subtitle text at that position.
