# Why Python API Instead of SendKeys

## The Problem

```
Stream Deck → .bat → PowerShell → SendKeys (Alt+W, S, Enter) → DaVinci Resolve menu
```

This pipeline had **two fatal flaws**:

### 1. Shortcut Conflict: `Alt+W`

The SideshowFX Pro keyboard layout remaps `Alt+W` to **Reference Wipe Invert**:

```
viewReferenceWipeInvert := Alt+W
```

So pressing `Alt+W` never opened the **Workspace** menu — it toggled wipe invert instead.

### 2. Window Focus Stolen

When Stream Deck launches the `.bat` file:

```
Stream Deck triggers .bat
  → CMD window opens (steals focus)
    → PowerShell starts (still CMD/PS has focus)
      → SendKeys fires (goes to CMD/PS, NOT to Resolve)
```

Even with `SetForegroundWindow()` calls, Windows security policies prevent background processes from reliably stealing focus from the foreground window.

---

## The Solution

```
Stream Deck → .bat → PowerShell → Python → Resolve API (direct connection)
```

### How the Resolve Python API Works

DaVinci Resolve exposes a **local scripting API** via a shared library (`fusionscript.dll`). Any external process can connect to the running Resolve instance:

```python
import DaVinciResolveScript as dvr
resolve = dvr.scriptapp("Resolve")    # Connects to running Resolve
project = resolve.GetProjectManager().GetCurrentProject()
timeline = project.GetCurrentTimeline()
markers  = timeline.GetMarkers()       # Direct data access
```

This is **not** simulating keyboard input. It's a direct programmatic interface — like an API call to a web server, but local.

### Key Advantages

| Aspect | SendKeys | Python API |
|--------|----------|------------|
| Needs window focus | Yes | **No** |
| Affected by shortcut remaps | Yes | **No** |
| Timing-dependent | Yes (sleep between keys) | **No** |
| Can read data back | No | **Yes** (markers, subtitles, etc.) |
| Error reporting | None (silent fail) | **Full** (exceptions, return values) |

---

## Execution Flow

```
┌──────────────┐
│  Stream Deck │
│  (button)    │
└──────┬───────┘
       │ launches
       ▼
┌──────────────┐
│  .bat file   │
│  (wrapper)   │
└──────┬───────┘
       │ calls PowerShell
       ▼
┌──────────────────┐
│  .ps1 script     │
│  - checks Resolve│
│  - sets env vars │
│  - logs output   │
└──────┬───────────┘
       │ calls Python
       ▼
┌──────────────────────┐
│  .py script          │
│  - connects to API   │
│  - reads markers     │
│  - reads subtitles   │
│  - updates marker    │
└──────────────────────┘
       │ direct API
       ▼
┌──────────────────────┐
│  DaVinci Resolve     │
│  (running instance)  │
└──────────────────────┘
```

## Environment Variables Required

The Python API needs these to locate `fusionscript.dll`:

| Variable | Value |
|----------|-------|
| `RESOLVE_SCRIPT_LIB` | `C:\Program Files\Blackmagic Design\DaVinci Resolve\fusionscript.dll` |
| `RESOLVE_SCRIPT_API` | `%PROGRAMDATA%\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting` |
| `PYTHONPATH` | `%PROGRAMDATA%\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\Modules` |

These are set by the `.ps1` wrapper before calling Python.

## File Locations

| File | Path |
|------|------|
| API module | `C:\ProgramData\Blackmagic Design\DaVinci Resolve\Support\Developer\Scripting\Modules\DaVinciResolveScript.py` |
| Native lib | `C:\Program Files\Blackmagic Design\DaVinci Resolve\fusionscript.dll` |
| Our scripts | `c:\projects\lua\marker_helpers\alt_w_s_enter\` |
| Deploy to | `%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit\` |
| Log output | `c:\projects\lua\marker_helpers\alt_w_s_enter\alt_w_s_enter.log` |
