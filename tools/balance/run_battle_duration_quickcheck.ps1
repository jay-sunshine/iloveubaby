param(
	[string]$GodotExe = "godot4",
	[string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\\..")).Path,
	[int]$MatchCount = 10,
	[int]$UnitsPerTeam = 1,
	[int]$SoldiersPerUnit = 5000,
	[string]$Role = "infantry",
	[double]$TeamFrontOffsetZ = 6.0,
	[double]$TeamSpacingX = 12.0,
	[double]$MaxSimSec = 240.0,
	[double]$TimeScale = 8.0,
	[int]$SeedStart = 20260318,
	[string]$WeatherState = "sunny",
	[switch]$DisableAutoRelease,
	[double]$UnitAttackDamageOverride = 0.0,
	[double]$UnitMaxHpOverride = 0.0,
	[string]$Prefix = "battle_duration_100s"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ProjectRoot)) {
	throw "ProjectRoot not found: $ProjectRoot"
}

$autoReleaseEnabled = -not $DisableAutoRelease.IsPresent

$runnerArgs = @(
	"--headless",
	"--path", $ProjectRoot,
	"-s", "res://scripts/tools/battle_duration_batch_runner.gd",
	"--",
	"--matches=$MatchCount",
	"--units_per_team=$UnitsPerTeam",
	"--soldiers_per_unit=$SoldiersPerUnit",
	"--role=$Role",
	"--symmetric=true",
	"--team_front_offset_z=$TeamFrontOffsetZ",
	"--team_spacing_x=$TeamSpacingX",
	"--max_sim_sec=$MaxSimSec",
	"--time_scale=$TimeScale",
	"--seed_start=$SeedStart",
	"--weather_state=$WeatherState",
	"--disable_personality=true",
	"--auto_release_enabled=$($autoReleaseEnabled.ToString().ToLower())",
	"--force_spawn_template=true",
	"--reissue_order_interval_sim_sec=10",
	"--prefix=$Prefix"
)
if ($UnitAttackDamageOverride -gt 0.0) {
	$runnerArgs += "--unit_attack_damage_override=$UnitAttackDamageOverride"
}
if ($UnitMaxHpOverride -gt 0.0) {
	$runnerArgs += "--unit_max_hp_override=$UnitMaxHpOverride"
}

Write-Host "run_battle_duration_quickcheck:"
Write-Host "  matches=$MatchCount units_per_team=$UnitsPerTeam soldiers_per_unit=$SoldiersPerUnit role=$Role"
Write-Host "  time_scale=$TimeScale max_sim_sec=$MaxSimSec seed_start=$SeedStart weather=$WeatherState auto_release_enabled=$($autoReleaseEnabled.ToString().ToLower())"

Push-Location $ProjectRoot
try {
	$cmdArgs = @("/c", $GodotExe) + $runnerArgs
	$proc = Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArgs -Wait -NoNewWindow -PassThru
	$nativeExit = [int]$proc.ExitCode
	if ($nativeExit -ne 0) {
		throw "quickcheck failed (exit=$nativeExit)"
	}
	Write-Host ""
	Write-Host "quickcheck finished. Check tmp/reports for CSV and summary JSON."
}
finally {
	Pop-Location
}
