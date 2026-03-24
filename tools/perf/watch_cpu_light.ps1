param(
    [int]$Seconds = 600,
    [int]$IntervalMs = 2000,
    [string]$OutFile = "tools/perf/cpu_watch_light_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
)

$dir = Split-Path -Parent $OutFile
if (-not [string]::IsNullOrWhiteSpace($dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

$cpuCount = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
$intervalSec = [math]::Max(0.2, $IntervalMs / 1000.0)
$targets = @('godot.windows.opt.tools.64','godot4','Codex','codex','msedge')

Set-Content -Path $OutFile -Value 'timestamp,cpu_total,godot_editor,codex,godot_headless,msedge' -Encoding utf8

$prev = @{}
foreach ($name in $targets) {
    foreach ($p in (Get-Process -Name $name -ErrorAction SilentlyContinue)) {
        $prev[$p.Id] = [double]$p.CPU
    }
}

for ($i = 0; $i -lt $Seconds; $i++) {
    Start-Sleep -Milliseconds $IntervalMs
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
    $total = [math]::Round((Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue, 1)

    $curr = @{}
    $editor = 0.0
    $codex = 0.0
    $headless = 0.0
    $edge = 0.0

    foreach ($name in $targets) {
        foreach ($p in (Get-Process -Name $name -ErrorAction SilentlyContinue)) {
            $curr[$p.Id] = [double]$p.CPU
            if ($prev.ContainsKey($p.Id)) {
                $delta = [double]$p.CPU - [double]$prev[$p.Id]
                if ($delta -gt 0) {
                    $cpuPct = ($delta / $intervalSec) * 100.0 / $cpuCount
                    if ($name -eq 'godot.windows.opt.tools.64') { $editor += $cpuPct }
                    elseif ($name -eq 'godot4') { $headless += $cpuPct }
                    elseif ($name -eq 'msedge') { $edge += $cpuPct }
                    else { $codex += $cpuPct }
                }
            }
        }
    }

    $prev = $curr
    $line = '{0},{1},{2},{3},{4},{5}' -f $ts,$total,[math]::Round($editor,1),[math]::Round($codex,1),[math]::Round($headless,1),[math]::Round($edge,1)
    Add-Content -Path $OutFile -Value $line -Encoding utf8
}

Write-Output "Saved: $OutFile"
