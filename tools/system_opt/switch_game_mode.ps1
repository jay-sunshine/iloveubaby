param(
    [switch]$CloseCodex
)

$ErrorActionPreference = "SilentlyContinue"

function Stop-Targets {
    param([string[]]$Names)
    $stopped = @()
    foreach ($name in $Names) {
        Get-Process -Name $name -ErrorAction SilentlyContinue | ForEach-Object {
            $stopped += "{0}({1})" -f $_.ProcessName, $_.Id
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        }
    }
    return $stopped
}

$highPerf = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
powercfg /S $highPerf | Out-Null

$killList = @(
    "godot4", "godot.windows.opt.tools.64",
    "QQ", "QQEX", "QQNT",
    "msedge", "msedgewebview2",
    "BaiduNetdisk", "BaiduNetdiskUnite", "baidunetdiskhost", "YunDetectService",
    "JianyingProTray", "360huabao",
    "steam"
)
$stopped = Stop-Targets -Names $killList

$codexStopped = @()
if ($CloseCodex) {
    $codexStopped = Stop-Targets -Names @("Codex")
}

$exp = Get-Process explorer -ErrorAction SilentlyContinue
if ($exp) {
    Stop-Process -Id ($exp | Select-Object -ExpandProperty Id) -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 700
}
Start-Process explorer.exe | Out-Null

$os = Get-CimInstance Win32_OperatingSystem
$freeRamGb = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$totalRamGb = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)

Write-Host "=== Game Mode Applied ==="
Write-Host "Power plan: High performance"
Write-Host ("RAM: {0} / {1} GB free" -f $freeRamGb, $totalRamGb)
Write-Host ("Stopped apps: {0}" -f $stopped.Count)
Write-Host ("Stopped Codex: {0}" -f $codexStopped.Count)
if (-not $CloseCodex) {
    Write-Host "Tip: add -CloseCodex if you want max FPS."
}
