# alt_w_s_enter

Sends the key sequence **Alt → W → S → Enter** to trigger **Workspace > Scripts** in DaVinci Resolve.

## Files

| File | Purpose |
|------|---------|
| `alt_w_s_enter.ps1` | PowerShell script that sends the keystrokes via `SendKeys` |
| `alt_w_s_enter.bat` | Batch wrapper — run this from Stream Deck or Explorer |

## Usage

### From Elgato Stream Deck

#### Option 1: System → Open (simplest)
1. Open the **Stream Deck** app
2. Drag the **System → Open** action onto a button
3. In the **App / File** field, click the `...` button and browse to:
   ```
   c:\projects\lua\marker_helpers\alt_w_s_enter\alt_w_s_enter.bat
   ```
4. Leave **Title** blank or set it to something like `Run Script`
5. Press the button — DaVinci Resolve **must be the focused window** when you press it

#### Option 2: Using the Multi Action (recommended)
This method brings DaVinci Resolve to the foreground first, then sends the keystrokes.

1. Drag a **Multi Action** onto a button
2. Add **System → Open** as the first action:
   - App / File: `C:\Windows\System32\cmd.exe`
   - Leave it — this is just to ensure focus isn't stolen
3. Replace that with a single **System → Open** pointing to the `.bat` file:
   ```
   c:\projects\lua\marker_helpers\alt_w_s_enter\alt_w_s_enter.bat
   ```
4. The initial `Start-Sleep` in the script gives DaVinci Resolve time to receive focus

#### Option 3: Using the Stream Deck "Open" plugin with `-WindowStyle Hidden`
If the cmd window flashing is distracting, create a **VBS wrapper** (see Troubleshooting below).

#### Troubleshooting

| Symptom | Fix |
|---------|-----|
| Nothing happens | Check `alt_w_s_enter.log` in the script folder for errors |
| CMD window flashes but no keystrokes | DaVinci Resolve was not the focused window. Increase `Start-Sleep` at the top of the `.ps1` |
| `Resolve process not found` in log | DaVinci Resolve is not running. Start it first |
| Execution policy error in log | The bat already uses `-ExecutionPolicy Bypass`. If it still fails, run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` once in PowerShell |
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

### From Explorer / Command Line
Double-click `alt_w_s_enter.bat` or run:
```bat
alt_w_s_enter.bat
```

## Key Sequence

| Step | Key | Action |
|------|-----|--------|
| 1 | `Alt` | Open menu bar |
| 2 | `W` | Workspace menu |
| 3 | `S` | Scripts submenu |
| 4 | `Enter` | Execute first script |

## Notes
- Focus must be on DaVinci Resolve before running the script.
- Delays between keystrokes are tuned for typical system speed; adjust `Start-Sleep` values if needed.
