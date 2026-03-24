param(
	[string]$GodotExe = "godot4",
	[string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\\..")).Path,
	[string]$PrefixBase = "quick20_front6",
	[int]$MatchCount = 20,
	[double]$MaxSimSec = 240,
	[double]$TimeScale = 8,
	[int]$SeedStartRun1 = 720000,
	[int]$SeedStartRun2 = 730000,
	[string]$LockEnv = "v11",
	[ValidateSet("front6", "legacy")]
	[string]$BaselineProfile = "front6",
	[switch]$NoGateMarker
)

$ErrorActionPreference = "Stop"

$runScript = Join-Path $PSScriptRoot "run_personality_v11_suite.ps1"
$sumScript = Join-Path $PSScriptRoot "summarize_personality_v11_suite.ps1"

if (-not (Test-Path $runScript)) {
	throw "Run script not found: $runScript"
}
if (-not (Test-Path $sumScript)) {
	throw "Summary script not found: $sumScript"
}

Write-Host "quickcheck: prefix=$PrefixBase match_count=$MatchCount baseline=$BaselineProfile lock_env=$LockEnv"

$runArgs = @{
	GodotExe = $GodotExe
	ProjectRoot = $ProjectRoot
	PrefixBase = $PrefixBase
	MatchCount = $MatchCount
	MaxSimSec = $MaxSimSec
	TimeScale = $TimeScale
	SeedStartRun1 = $SeedStartRun1
	SeedStartRun2 = $SeedStartRun2
	LockEnv = $LockEnv
}

& $runScript @runArgs
if (-not $?) {
	throw "run_personality_v11_suite.ps1 failed"
}

$sumArgs = @{
	PrefixBase = $PrefixBase
	BaselineProfile = $BaselineProfile
	FailOnThreshold = $true
}
& $sumScript @sumArgs
if ((-not $?) -or ($LASTEXITCODE -ne 0)) {
	$exitCode = if ($null -eq $LASTEXITCODE) { 1 } else { $LASTEXITCODE }
	throw "summarize_personality_v11_suite.ps1 failed threshold check (exit=$exitCode)"
}

if (-not $NoGateMarker) {
	$reportDir = Join-Path $ProjectRoot "tmp\\reports"
	if (-not (Test-Path $reportDir)) {
		New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
	}
	$markerPath = Join-Path $reportDir ("battle_gate_{0}.json" -f $BaselineProfile)
	$marker = [ordered]@{
		generated_at = (Get-Date).ToString("s")
		baseline_profile = $BaselineProfile
		prefix_base = $PrefixBase
		match_count = $MatchCount
		max_sim_sec = $MaxSimSec
		time_scale = $TimeScale
		lock_env = $LockEnv
		seed_start_run1 = $SeedStartRun1
		seed_start_run2 = $SeedStartRun2
	}
	$marker | ConvertTo-Json -Depth 4 | Set-Content -Path $markerPath -Encoding UTF8
	Write-Host "gate marker updated: $markerPath"
}

Write-Host ""
Write-Host "quickcheck finished: PASS"
