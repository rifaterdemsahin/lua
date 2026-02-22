Yes, a few options:

**1. Stream Deck Multi Action (no extra software)**

Same idea, just do it directly in Stream Deck:

1. Rename script to `!fill_last_marker_subtitle.lua`
2. Create a **Multi Action** on a button:
   - Hotkey: `Alt` (activates menu bar)
   - Delay: 200ms
   - Hotkey: `W`
   - Delay: 300ms
   - Hotkey: `S`
   - Delay: 300ms
   - Hotkey: `Enter`

No extra software at all. This is probably your best bet.

**2. PowerShell script + Stream Deck "Open" action**

You already know PowerShell. Create `fill_marker.ps1`:

```powershell
Add-Type -AssemblyName System.Windows.Forms
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("%")     # Alt
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait("w")     # Workspace
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("s")     # Scripts
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
```

In Stream Deck, use **System → Open** and point it to a `.bat` wrapper:

```bat
@echo off
powershell -ExecutionPolicy Bypass -File "C:\path\to\fill_marker.ps1"
```

**3. Microsoft Power Automate Desktop** — free, built into Windows 11, has UI automation with menu clicking by name (more reliable than key presses).

I'd go with option 1. Zero dependencies, already on your Stream Deck.
