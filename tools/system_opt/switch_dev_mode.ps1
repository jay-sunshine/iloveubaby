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

function Disable-StartupItems {
    param([string[]]$Items)
    $runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
    $backupKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run_Backup_Codex"
    if (-not (Test-Path $backupKey)) {
        New-Item -Path $backupKey -Force | Out-Null
    }
    $disabled = @()
    foreach ($name in $Items) {
        $value = (Get-ItemProperty -Path $runKey -Name $name -ErrorAction SilentlyContinue).$name
        if ($null -ne $value) {
            New-ItemProperty -Path $backupKey -Name $name -Value $value -PropertyType String -Force | Out-Null
            Remove-ItemProperty -Path $runKey -Name $name -ErrorAction SilentlyContinue
            $disabled += $name
        }
    }
    return $disabled
}

$highPerf = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
powercfg /S $highPerf | Out-Null

$killList = @(
    "QQ", "QQEX", "QQNT",
    "msedge", "msedgewebview2",
    "BaiduNetdisk", "BaiduNetdiskUnite", "baidunetdiskhost", "YunDetectService",
    "JianyingProTray", "360huabao"
)
$stopped = Stop-Targets -Names $killList

$godot = Get-Process godot4 -ErrorAction SilentlyContinue | Sort-Object StartTime -Descending
$godotStopped = @()
if ($godot.Count -gt 1) {
    $toStop = $godot | Select-Object -Skip 1
    foreach ($proc in $toStop) {
        $godotStopped += "{0}({1})" -f $proc.ProcessName, $proc.Id
        Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
    }
}

$startupTargets = @(
    "Steam",
    "BaiduYunDetect", "BaiduYunGuanjia",
    "sesvc", "360huabao",
    "JianyingPro", "QQNT",
    "MicrosoftEdgeAutoLaunch_5EFC0ECB77A7585FE9DCDD0B2E946A2B",
    "GoogleUpdaterTaskUser147.0.7703.0"
)
$disabledStartup = Disable-StartupItems -Items $startupTargets

$os = Get-CimInstance Win32_OperatingSystem
$freeRamGb = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$totalRamGb = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)

Write-Host "=== Dev Mode Applied ==="
Write-Host "Power plan: High performance"
Write-Host ("RAM: {0} / {1} GB free" -f $freeRamGb, $totalRamGb)
Write-Host ("Stopped apps: {0}" -f $stopped.Count)
Write-Host ("Stopped extra godot4: {0}" -f $godotStopped.Count)
Write-Host ("Disabled startup items: {0}" -f $disabledStartup.Count)
