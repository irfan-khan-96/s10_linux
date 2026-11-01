# Start Syncthing at Windows login, hidden, without opening a browser.
# Undo: delete "Syncthing" from shell:startup.
$st = "$env:LOCALAPPDATA\Microsoft\WinGet\Links\syncthing.exe"
$lnk = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Syncthing.lnk"
$sh = (New-Object -ComObject WScript.Shell).CreateShortcut($lnk)
$sh.TargetPath = $st
$sh.Arguments = "serve --no-browser --no-console"
$sh.WindowStyle = 7
$sh.Save()
"Created $lnk"
