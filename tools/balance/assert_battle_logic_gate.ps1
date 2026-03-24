param(
	[string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\\..")).Path,
	[string]$ReportDir = (Resolve-Path (Join-Path $PSScriptRoot "..\\..\\tmp\\reports")).Path,
	[ValidateSet("front6", "legacy")]
	[string]$BaselineProfile = "front6",
	[switch]$AutoRunQuickcheck
)

$ErrorActionPreference = "Stop"

$battlePaths = @(
	"scripts/battlefield_controller.gd",
	"scripts/unit_controller.gd",
	"scripts/tools/personality_batch_sim_runner.gd",
	"data/config/battle_rules.json"
)

function Get-LatestBattleLogicWriteTimeUtc {
	param([string]$RootPath, [string[]]$RelativePaths)
	$latest = [datetime]::MinValue
	foreach ($rel in $RelativePaths) {
		$abs = Join-Path $RootPath $rel
		if (-not (Test-Path $abs)) {
			Write-Warning "battle path missing: $rel"
			continue
		}
		$t = (Get-Item $abs).LastWriteTimeUtc
		if ($t -gt $latest) { $latest = $t }
	}
	return $latest
}

function Get-GateMarker {
	param([string]$MarkerPath)
	if (-not (Test-Path $MarkerPath)) { return $null }
	return Get-Content -Path $MarkerPath -Raw | ConvertFrom-Json
}

if (-not (Test-Path $ReportDir)) {
	New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
}

$markerPath = Join-Path $ReportDir ("battle_gate_{0}.json" -f $BaselineProfile)
$latestBattleUtc = Get-LatestBattleLogicWriteTimeUtc -RootPath $ProjectRoot -RelativePaths $battlePaths
if ($latestBattleUtc -eq [datetime]::MinValue) {
	throw "No battle logic files found; cannot assert gate."
}

$marker = Get-GateMarker -MarkerPath $markerPath
$isFresh = $false
if ($marker -ne $null) {
	$markerUtc = [datetime]::Parse($marker.generated_at).ToUniversalTime()
	$isFresh = $markerUtc -ge $latestBattleUtc
}

if (-not $isFresh -and $AutoRunQuickcheck) {
	$quickScript = Join-Path $PSScriptRoot "run_personality_v11_quickcheck.ps1"
	if (-not (Test-Path $quickScript)) {
		throw "quickcheck script not found: $quickScript"
	}
	$prefix = "gate_${BaselineProfile}_" + (Get-Date -Format "yyyyMMdd_HHmmss")
	Write-Host "gate stale -> autorun quickcheck: prefix=$prefix"
	& $quickScript -ProjectRoot $ProjectRoot -PrefixBase $prefix -BaselineProfile $BaselineProfile
	if ((-not $?) -or ($LASTEXITCODE -ne 0)) {
		$exitCode = if ($null -eq $LASTEXITCODE) { 1 } else { $LASTEXITCODE }
		throw "quickcheck failed during autorun (exit=$exitCode)"
	}
	$marker = Get-GateMarker -MarkerPath $markerPath
	if ($marker -ne $null) {
		$markerUtc = [datetime]::Parse($marker.generated_at).ToUniversalTime()
		$isFresh = $markerUtc -ge $latestBattleUtc
	}
}

if (-not $isFresh) {
	$latestBattleText = $latestBattleUtc.ToLocalTime().ToString("yyyy-MM-dd HH:mm:ss")
	throw "battle gate check failed: quickcheck is older than latest battle logic change ($latestBattleText). Run tools/balance/run_personality_v11_quickcheck.ps1 first."
}

$markerLocal = [datetime]::Parse($marker.generated_at).ToLocalTime().ToString("yyyy-MM-dd HH:mm:ss")
Write-Host "battle gate PASS: baseline=$BaselineProfile marker_time=$markerLocal"
