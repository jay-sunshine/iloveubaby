param(
    [int]$Seconds = 120,
    [int]$IntervalMs = 1000,
    [string]$OutFile = "tools/perf/cpu_watch_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
)

$dir = Split-Path -Parent $OutFile
if (-not [string]::IsNullOrWhiteSpace($dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}

$cpuCount = (Get-CimInstance Win32_ComputerSystem).NumberOfLogicalProcessors
$intervalSec = [math]::Max(0.2, $IntervalMs / 1000.0)

$header = @(
    'timestamp',
    'cpu_total_est',
    'godot_editor_cpu_est',
    'godot_headless_cpu_est',
    'codex_cpu_est',
    'top1_name','top1_cpu_est',
    'top2_name','top2_cpu_est',
    'top3_name','top3_cpu_est',
    'top4_name','top4_cpu_est',
    'top5_name','top5_cpu_est'
) -join ','
Set-Content -Path $OutFile -Value $header -Encoding utf8

$prev = @{}
$processes = Get-Process -ErrorAction SilentlyContinue
foreach ($p in $processes) {
    $prev[$p.Id] = [double]($p.CPU)
}

for ($i = 0; $i -lt $Seconds; $i++) {
    Start-Sleep -Milliseconds $IntervalMs
    $ts = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')

    $curr = @{}
    $deltas = @()
    $processes = Get-Process -ErrorAction SilentlyContinue
    foreach ($p in $processes) {
        $currCpu = [double]($p.CPU)
        $curr[$p.Id] = $currCpu
        if ($prev.ContainsKey($p.Id)) {
            $delta = $currCpu - [double]$prev[$p.Id]
            if ($delta -gt 0) {
                $cpuPct = [math]::Round(($delta / $intervalSec) * 100.0 / $cpuCount, 1)
                if ($cpuPct -gt 0) {
                    $deltas += [PSCustomObject]@{ Name = $p.ProcessName; PID = $p.Id; CpuPct = $cpuPct }
                }
            }
        }
    }
    $prev = $curr

    $total = [math]::Round((($deltas | Measure-Object CpuPct -Sum).Sum), 1)
    $godotEditor = [math]::Round((($deltas | Where-Object { $_.Name -like 'godot.windows.opt.tools.64*' } | Measure-Object CpuPct -Sum).Sum), 1)
    $godotHeadless = [math]::Round((($deltas | Where-Object { $_.Name -like 'godot4*' } | Measure-Object CpuPct -Sum).Sum), 1)
    $codex = [math]::Round((($deltas | Where-Object { $_.Name -like 'codex*' -or $_.Name -like 'Codex*' } | Measure-Object CpuPct -Sum).Sum), 1)

    $tops = $deltas | Sort-Object CpuPct -Descending | Select-Object -First 5 Name,CpuPct
    while ($tops.Count -lt 5) {
        $tops += [PSCustomObject]@{ Name = ''; CpuPct = 0 }
    }

    $line = @(
        $ts,
        $total,
        $godotEditor,
        $godotHeadless,
        $codex,
        $tops[0].Name, $tops[0].CpuPct,
        $tops[1].Name, $tops[1].CpuPct,
        $tops[2].Name, $tops[2].CpuPct,
        $tops[3].Name, $tops[3].CpuPct,
        $tops[4].Name, $tops[4].CpuPct
    ) -join ','

    Add-Content -Path $OutFile -Value $line -Encoding utf8
}

Write-Output "Saved: $OutFile"
