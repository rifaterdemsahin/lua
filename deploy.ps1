# Deploy Lua scripts to DaVinci Resolve Edit Scripts folder
$source = "C:\projects\lua"
$destination = "$env:APPDATA\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit"

$scripts = Get-ChildItem "$source\*.lua"

if ($scripts.Count -eq 0) {
    Write-Host "No .lua files found in $source" -ForegroundColor Yellow
    return
}

Copy-Item $scripts -Destination $destination -Force

Write-Host "Deployed $($scripts.Count) script(s) to DaVinci Resolve:" -ForegroundColor Green
$scripts | ForEach-Object { Write-Host "  - $($_.Name)" }
