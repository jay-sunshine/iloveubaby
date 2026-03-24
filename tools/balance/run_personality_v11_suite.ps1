param(
	[string]$GodotExe = "godot4",
	[string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\\..")).Path,
	[Alias("Matches")]
	[int]$MatchCount = 200,
	[double]$MaxSimSec = 240,
	[double]$TimeScale = 8,
	[int]$SeedStartRun1 = 620000,
	[int]$SeedStartRun2 = 630000,
	[int]$SingleTraitLevel = 2,
	[string]$LockEnv = "v11",
	[string]$PrefixBase = "ab200",
	[switch]$SkipRun1,
	[switch]$SkipRun2
)

$ErrorActionPreference = "Stop"

function Invoke-BatchRun {
	param(
		[string]$Prefix,
		[int]$SeedStart,
		[string]$TraitId
	)

	$runnerArgs = @(
		"--headless",
		"--path", $ProjectRoot,
		"-s", "res://scripts/tools/personality_batch_sim_runner.gd",
		"--",
		"--matches=$MatchCount",
		"--max_sim_sec=$MaxSimSec",
		"--time_scale=$TimeScale",
		"--seed_start=$SeedStart",
		"--mirror=true",
		"--symmetric=true",
		"--mirror_swap_team=true",
		"--prefix=$Prefix"
	)
	if (-not [string]::IsNullOrWhiteSpace($LockEnv)) {
		$runnerArgs += "--lock_env=$LockEnv"
	}

	if ($TraitId -eq "ctrl") {
		$runnerArgs += "--disable_traits=true"
	} else {
		$runnerArgs += "--single_trait=$TraitId"
		$runnerArgs += "--single_trait_level=$SingleTraitLevel"
	}

	Write-Host ""
	Write-Host ">>> Running $Prefix (seed_start=$SeedStart, trait=$TraitId)"
	$cmdArgs = @("/c", $GodotExe) + $runnerArgs
	$proc = Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArgs -Wait -NoNewWindow -PassThru
	$nativeExit = [int]$proc.ExitCode
	if ($nativeExit -ne 0) {
		throw "Run failed: $Prefix (exit=$nativeExit)"
	}
}

if (-not (Test-Path $ProjectRoot)) {
	throw "ProjectRoot not found: $ProjectRoot"
}

Write-Host "run_personality_v11_suite: match_count=$MatchCount, run1=$(-not $SkipRun1), run2=$(-not $SkipRun2), prefix=$PrefixBase, lock_env=$LockEnv"

Push-Location $ProjectRoot
try {
	if (-not $SkipRun1) {
		Invoke-BatchRun -Prefix "${PrefixBase}_ctrl_tune1" -SeedStart $SeedStartRun1 -TraitId "ctrl"
		Invoke-BatchRun -Prefix "${PrefixBase}_xionglue_tune1" -SeedStart $SeedStartRun1 -TraitId "xionglue"
		Invoke-BatchRun -Prefix "${PrefixBase}_huoshen_tune1" -SeedStart $SeedStartRun1 -TraitId "huoshen"
	}

	if (-not $SkipRun2) {
		Invoke-BatchRun -Prefix "${PrefixBase}_ctrl_tune1_r2" -SeedStart $SeedStartRun2 -TraitId "ctrl"
		Invoke-BatchRun -Prefix "${PrefixBase}_xionglue_tune1_r2" -SeedStart $SeedStartRun2 -TraitId "xionglue"
		Invoke-BatchRun -Prefix "${PrefixBase}_huoshen_tune1_r2" -SeedStart $SeedStartRun2 -TraitId "huoshen"
	}

	Write-Host ""
	Write-Host "All requested runs finished."
	Write-Host "Next: run tools/balance/summarize_personality_v11_suite.ps1"
}
finally {
	Pop-Location
}
