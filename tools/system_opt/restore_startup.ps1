$ErrorActionPreference = "SilentlyContinue"

$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$backupKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run_Backup_Codex"

if (-not (Test-Path $backupKey)) {
    Write-Host "No startup backup key found."
    exit 0
}

$props = Get-ItemProperty -Path $backupKey | Select-Object -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider
$restored = @()
foreach ($p in $props.PSObject.Properties) {
    if ($null -eq $p.Value) { continue }
    New-ItemProperty -Path $runKey -Name $p.Name -Value ([string]$p.Value) -PropertyType String -Force | Out-Null
    $restored += $p.Name
}

Write-Host "Restored startup items:" $restored.Count
foreach ($n in $restored) { Write-Host (" - {0}" -f $n) }
