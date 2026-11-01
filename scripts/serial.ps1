param([string]$Port = "COM8", [string]$Cmd, [string]$Marker = "DONE42", [int]$Tries = 20, [int]$Wait = 3)
# Send a command to the phone's rescue shell until "$Marker" comes back intact
# (input is often scrambled because two shells read the same port).
$sp = New-Object System.IO.Ports.SerialPort $Port, 115200, None, 8, One
$sp.DtrEnable = $true; $sp.RtsEnable = $true; $sp.ReadTimeout = 500
$sp.Open()
Start-Sleep -Milliseconds 500; $null = $sp.ReadExisting()
$full = "$Cmd; echo DONE`$((40+2))"
for ($i = 0; $i -lt $Tries; $i++) {
    $sp.Write([string][char]0x15); Start-Sleep -Milliseconds 200
    $sp.Write("$full`r")
    Start-Sleep -Seconds $Wait
    $out = $sp.ReadExisting()
    if ($out -match $Marker) { $sp.Close(); Write-Output "[ok after $($i+1) tries]"; Write-Output $out; exit 0 }
}
$sp.Close(); Write-Output "[no intact reply after $Tries tries]"; Write-Output $out; exit 1
