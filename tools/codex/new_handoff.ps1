param(
    [string]$Owner = "Codex",
    [string]$Goal = "",
    [string]$Done = "",
    [string]$Risks = "",
    [string]$Next = ""
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$handoffPath = Join-Path $repoRoot "docs\codex\SESSION_HANDOFF.md"

if (-not (Test-Path $handoffPath)) {
    New-Item -ItemType Directory -Path (Split-Path $handoffPath -Parent) -Force | Out-Null
    Set-Content -Path $handoffPath -Value "# Session Handoff Log`r`n" -Encoding UTF8
}

$stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$tz = (Get-TimeZone).Id

$entry = @"

## $stamp ($tz)
- Owner: $Owner
- Goal:
  - $Goal
- Done:
  - $Done
- Risks:
  - $Risks
- Next:
  - $Next
"@

Add-Content -Path $handoffPath -Value $entry -Encoding UTF8
Write-Output "Appended handoff entry to: $handoffPath"

