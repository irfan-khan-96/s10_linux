# Pull the phone user's home folder (except .cache) over SSH into a dated archive on the PC.
# Uses the existing key-only SSH login, so no new port or service on the phone.
# Kept outside the git project on purpose: personal files never go to GitHub.
# Skips quietly when the phone is not on the home network. Keeps the newest $Keep archives.
param([string]$Dest = "$env:USERPROFILE\S10-backups", [int]$Keep = 30)

New-Item -ItemType Directory -Force $Dest | Out-Null
$log = Join-Path $Dest "backup.log"
function Log($msg) { "$(Get-Date -Format 'yyyy-MM-dd HH:mm') $msg" | Add-Content $log }

ssh -o ConnectTimeout=8 -o BatchMode=yes s10 true 2>$null
if ($LASTEXITCODE -ne 0) { Log "phone not reachable, skipped"; exit 0 }

$name = "s10-home-$(Get-Date -Format 'yyyyMMdd-HHmm').tar.gz"
$file = Join-Path $Dest $name
# cmd's redirection keeps the archive byte-exact (PowerShell's may re-encode output)
cmd /c "ssh -o BatchMode=yes s10 `"tar czf - --exclude=./.cache -C /home/farmer .`" > `"$file`""
$entries = (tar -tzf $file 2>$null | Measure-Object).Count
if ($LASTEXITCODE -ne 0 -or $entries -eq 0) {
	Remove-Item $file -ErrorAction SilentlyContinue
	Log "FAILED: archive empty or unreadable"
	exit 1
}
Log "ok $name ($entries entries, $([math]::Round((Get-Item $file).Length / 1MB, 1)) MB)"
Get-ChildItem $Dest -Filter 's10-home-*.tar.gz' | Sort-Object Name -Descending | Select-Object -Skip $Keep | Remove-Item
