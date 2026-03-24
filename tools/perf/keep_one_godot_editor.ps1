$editorName = "godot.windows.opt.tools.64"

$editors = Get-Process -Name $editorName -ErrorAction SilentlyContinue |
    Sort-Object StartTime

if (-not $editors) {
    Write-Output "No $editorName process found."
} elseif ($editors.Count -eq 1) {
    Write-Output "Already one editor instance: PID=$($editors[0].Id)"
} else {
    $keep = $editors[0]
    $killed = @()
    foreach ($p in $editors | Select-Object -Skip 1) {
        Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue
        $killed += $p.Id
    }
    Write-Output "Keep editor PID=$($keep.Id), killed extra=$($killed.Count): $($killed -join ',')"
}

$staleHeadless = Get-CimInstance Win32_Process |
    Where-Object { $_.Name -eq "godot4.exe" -and $_.CommandLine -like "*--headless*--check-only*" }

if ($staleHeadless) {
    foreach ($p in $staleHeadless) {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
    }
    Write-Output "Killed stale headless check processes: $($staleHeadless.Count)"
} else {
    Write-Output "No stale headless check processes found."
}
