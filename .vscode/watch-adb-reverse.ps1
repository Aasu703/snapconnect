Write-Host "Starting adb reverse watcher for tcp:5050..."
Write-Host "Watching adb reverse (tcp:5050)."

while ($true) {
    $list = & adb reverse --list 2>$null
    if (-not ($list -match '5050')) {
        & adb reverse tcp:5050 tcp:5050 | Out-Null
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] adb reverse tcp:5050 reapplied (tunnel had dropped)."
    }
    Start-Sleep -Seconds 2
}
