# Environment Configuration

All environment settings required to run DaVinci Resolve scripts from outside Resolve (Stream Deck, command line, etc.).

---

## Python Version

| Requirement | Value |
|-------------|-------|
| **Required** | Python 3.13 |
| **Launcher** | `py -3.13` (Windows Python Launcher) |
| **Why not 3.14?** | `fusionscript.dll` fails to initialize on Python 3.14+ with `SystemError: initialization of fusionscript failed without raising an exception` |
| **Why not 3.11?** | Same `fusionscript.dll` initialization failure on this workstation |

Check installed versions:
```powershell
py -0p
```

---

## Environment Variables

These are set by the `.ps1` wrapper before calling Python. They tell the Resolve scripting module where to find `fusionscript.dll`.

| Variable | Value | Purpose |
|----------|-------|---------|
| `RESOLVE_SCRIPT_LIB` | `C:\Program Files\Blackmagic Design\DaVinci Resolve\fusionscript.dll` | Path to the native Resolve scripting DLL |
| `RESOLVE_SCRIPT_API` | `%PROGRAMDATA%\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting` | Root of the Resolve developer scripting folder |
| `PYTHONPATH` | `%PROGRAMDATA%\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\Modules` | Lets Python find `DaVinciResolveScript.py` |

PowerShell equivalent:
```powershell
$env:RESOLVE_SCRIPT_LIB = "C:\Program Files\Blackmagic Design\DaVinci Resolve\fusionscript.dll"
$env:RESOLVE_SCRIPT_API = "$env:PROGRAMDATA\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting"
$env:PYTHONPATH = "$env:PROGRAMDATA\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\Modules"
```

---

## File Paths

### Resolve Installed Files

| File | Path |
|------|------|
| Resolve executable | `C:\Program Files\Blackmagic Design\DaVinci Resolve\Resolve.exe` |
| `fusionscript.dll` | `C:\Program Files\Blackmagic Design\DaVinci Resolve\fusionscript.dll` |
| `DaVinciResolveScript.py` | `C:\ProgramData\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\Modules\DaVinciResolveScript.py` |
| API examples | `C:\ProgramData\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\Examples\` |

### Script Deploy Location

Scripts placed here appear in Resolve's **Workspace > Scripts** menu:

```
%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit\
```

Expands to:
```
C:\Users\Pexabo\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit\
```

Subfolders in the Scripts directory map to Resolve pages:

| Folder | Resolve Page |
|--------|-------------|
| `Edit\` | Edit page scripts |
| `Color\` | Color page scripts |
| `Comp\` | Fusion page scripts |
| `Deliver\` | Deliver page scripts |
| `Utility\` | Available on all pages |

### Project Source Files

```
c:\projects\lua\marker_helpers\alt_w_s_enter\
```

---

## Deployment

Copy scripts to the Resolve folder:
```powershell
$dest = "$env:APPDATA\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit"
Copy-Item "C:\projects\lua\marker_helpers\alt_w_s_enter\*.py" -Destination $dest -Force
Copy-Item "C:\projects\lua\marker_helpers\alt_w_s_enter\*.ps1" -Destination $dest -Force
Copy-Item "C:\projects\lua\marker_helpers\alt_w_s_enter\*.bat" -Destination $dest -Force
```

Or use the deploy script:
```powershell
.\deploy.ps1
```

---

## Stream Deck Configuration

| Setting | Value |
|---------|-------|
| Action type | System → Open |
| App / File | `c:\projects\lua\marker_helpers\alt_w_s_enter\alt_w_s_enter.bat` |
| Resolve focus required | **No** (Python API connects directly) |

---

## Runtime Prerequisites

1. **DaVinci Resolve** must be running with a project and timeline open
2. **Python 3.13** must be installed (`py -3.13` must work)
3. **Timeline must have subtitles** on at least one subtitle track
4. **Timeline must have markers** to process

---

## Troubleshooting

### Verify environment from PowerShell

```powershell
# Check Python 3.13 is available
py -3.13 --version

# Check fusionscript.dll exists
Test-Path "C:\Program Files\Blackmagic Design\DaVinci Resolve\fusionscript.dll"

# Check DaVinciResolveScript.py exists
Test-Path "$env:PROGRAMDATA\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\Modules\DaVinciResolveScript.py"

# Check Resolve is running
Get-Process "Resolve" -ErrorAction SilentlyContinue

# Test the API connection
$env:PYTHONPATH = "$env:PROGRAMDATA\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\Modules"
$env:RESOLVE_SCRIPT_LIB = "C:\Program Files\Blackmagic Design\DaVinci Resolve\fusionscript.dll"
py -3.13 -c "import DaVinciResolveScript as dvr; r = dvr.scriptapp('Resolve'); print('Connected' if r else 'FAILED')"
```

### Check the log
```powershell
Get-Content "c:\projects\lua\marker_helpers\alt_w_s_enter\alt_w_s_enter.log" -Tail 20
```
