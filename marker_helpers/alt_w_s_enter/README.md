# alt_w_s_enter

Sends the key sequence **Alt → W → S → Enter** to trigger **Workspace > Scripts** in DaVinci Resolve.

## Files

| File | Purpose |
|------|---------|
| `alt_w_s_enter.ps1` | PowerShell script that sends the keystrokes via `SendKeys` |
| `alt_w_s_enter.bat` | Batch wrapper — run this from Stream Deck or Explorer |

## Usage

### From Stream Deck
Use **System → Open** and point it to `alt_w_s_enter.bat`.

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
