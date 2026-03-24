$targets = Get-CimInstance Win32_Process |
    Where-Object { $_.Name -eq 'godot4.exe' -and $_.CommandLine -like '*--headless*--check-only*' }

if (-not $targets) {
    Write-Output 'No stale headless check-only godot4.exe processes found.'
    exit 0
}

$targets | Select-Object ProcessId,CommandLine
foreach ($p in $targets) {
    Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
}
Write-Output "Killed: $($targets.Count)"
