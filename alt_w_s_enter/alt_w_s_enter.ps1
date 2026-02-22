Add-Type -AssemblyName System.Windows.Forms
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("%")     # Alt
Start-Sleep -Milliseconds 200
[System.Windows.Forms.SendKeys]::SendWait("w")     # Workspace
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("s")     # Scripts
Start-Sleep -Milliseconds 300
[System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
