# Approach Comparison: Triggering fill_last_marker

Three approaches were attempted to trigger the fill_last_marker script from an Elgato Stream Deck button. Here's how they compare.

---

## Side-by-Side Overview

| | Lua (Menu Click) | SendKeys (Keyboard Sim) | Python API (Final) |
|---|---|---|---|
| **Trigger method** | Workspace > Scripts > fill_last_marker (manual menu click) | PowerShell simulates Alt+W → S → Enter keystrokes | Python calls Resolve scripting API directly |
| **Automation** | None — requires manual mouse clicks | Fully automated via Stream Deck | Fully automated via Stream Deck |
| **Needs Resolve focused** | Yes | Yes | **No** |
| **Affected by custom shortcuts** | No | **Yes** — `Alt+W` mapped to Reference Wipe Invert | **No** |
| **Window focus issues** | N/A | **Yes** — CMD/PS window steals focus | **No** |
| **Timing-dependent** | No | **Yes** — needs `Start-Sleep` between keys | **No** |
| **Error reporting** | Resolve console only | Log file (but can't see Python/Lua errors) | **Full** — log file with project, timeline, marker details |
| **Can read data back** | Only in Resolve console | No | **Yes** — markers, subtitles, frame numbers |
| **Python version dependency** | None | None | **Yes** — requires Python 3.13 (3.14 not compatible with fusionscript.dll) |
| **Reliability** | High (but not automatable) | **Low** — fragile, fails silently | **High** |

---

## Approach 1: Lua Script (Manual Menu Click)

```
User clicks: Workspace > Scripts > fill_last_marker
                 ↓
DaVinci Resolve runs fill_last_marker.lua internally
                 ↓
Lua script uses Resolve() API to read markers/subtitles
                 ↓
Marker is updated
```

**File:** `fill_last_marker.lua`

**Pros:**
- Runs inside Resolve — full access to all APIs
- No external dependencies
- No environment variables needed

**Cons:**
- Requires 4 manual mouse clicks every time
- Cannot be automated from Stream Deck
- No external logging

---

## Approach 2: SendKeys (Keyboard Simulation)

```
Stream Deck → .bat → PowerShell → SendKeys → Resolve menu bar
                                      ↓
                               Alt (menu bar)
                               W   (Workspace) ← BLOCKED: Alt+W = Reference Wipe Invert
                               S   (Scripts)
                               Enter (execute)
```

**Files:** `alt_w_s_enter.bat` + `alt_w_s_enter.ps1`

**Pros:**
- Automatable from Stream Deck
- No Python dependency

**Cons:**
- `Alt+W` conflicts with SideshowFX keyboard layout (`viewReferenceWipeInvert := Alt+W`)
- CMD window steals focus from Resolve when launched
- Timing-dependent — needs sleep delays between keystrokes
- Fails silently — log says "success" even when nothing happened
- Fragile — menu structure changes break it

---

## Approach 3: Python API (Final Solution)

```
Stream Deck → .bat → PowerShell → py -3.13 → fusionscript.dll → Resolve
                                      ↓
                               Connects to running Resolve instance
                               Reads project, timeline, markers, subtitles
                               Updates marker directly
```

**Files:** `alt_w_s_enter.bat` + `alt_w_s_enter.ps1` + `fill_last_marker_api.py`

**Pros:**
- No window focus needed — works in background
- No shortcut conflicts — doesn't use keyboard at all
- Full error reporting with project/timeline context
- Can read and write data programmatically
- Deterministic — no timing dependencies

**Cons:**
- Requires Python 3.13 (3.14's `fusionscript.dll` initialization fails)
- Requires environment variables (`RESOLVE_SCRIPT_LIB`, `PYTHONPATH`)
- Extra file (Python script) to maintain alongside Lua version

---

## Execution Pipeline Comparison

### Lua (3 components, manual trigger)
```
Human → Mouse → Resolve Menu → Lua Script → Resolve API
```

### SendKeys (4 components, automated but broken)
```
Stream Deck → BAT → PowerShell → SendKeys → Resolve Menu → Lua Script → Resolve API
                                    ✗ focus lost
                                    ✗ Alt+W intercepted
```

### Python API (5 components, automated and working)
```
Stream Deck → BAT → PowerShell → Python 3.13 → fusionscript.dll → Resolve API
                                    ✓ no focus needed
                                    ✓ no shortcuts needed
                                    ✓ full error logging
```

---

## Key Lesson

The Lua script and the Python script do **exactly the same thing** — they both talk to Resolve's scripting API to read markers and subtitles. The difference:

- **Lua** runs *inside* Resolve (triggered via the menu)
- **Python** runs *outside* Resolve (triggered via Stream Deck → fusionscript.dll)

The SendKeys approach was a workaround to trigger the Lua script from outside, but it failed because it needed to navigate the UI. The Python approach eliminates the UI entirely.
