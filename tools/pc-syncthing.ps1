# Set up Syncthing on the PC: home network only, folders for the phone.
# Starting at login is separate: pc-syncthing-autostart.ps1.
$st = "$env:LOCALAPPDATA\Microsoft\WinGet\Links\syncthing.exe"   # stable across winget upgrades
$base = "$env:USERPROFILE\S10"
New-Item -ItemType Directory -Force "$base\notes", "$base\journal" | Out-Null

if (-not (Get-Process syncthing -ErrorAction SilentlyContinue)) {
	Start-Process $st -ArgumentList "serve --no-browser --no-console" -WindowStyle Hidden
	Start-Sleep 8
}
$opts = @(
	@("global-ann-enabled", "false"), @("relays-enabled", "false"), @("natenabled", "false"),
	@("auto-upgrade-intervalh", "0")
)
foreach ($o in $opts) { & $st cli config options $o[0] set $o[1] }
& $st cli config options uraccepted set -- -1
# crash reporting has no cli option; use the local REST API
$key = & $st cli config gui apikey get
Invoke-RestMethod -Method Patch -Uri http://127.0.0.1:8384/rest/config/options -Headers @{"X-API-Key" = $key} -Body '{"crashReportingEnabled": false}' -ContentType application/json | Out-Null
"crashReportingEnabled: " + (& $st cli config options dump-json | ConvertFrom-Json).crashReportingEnabled
"Device ID: " + (& $st cli show system | ConvertFrom-Json).myID
