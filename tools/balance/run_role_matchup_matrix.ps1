param(
	[string]$GodotExe = "godot4",
	[string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path,
	[int]$MatchCountPerCell = 1,
	[string[]]$Roles = @("infantry", "shield", "spear", "archer", "crossbow", "cavalry", "scout", "siege", "strategist"),
	[int]$UnitsPerTeam = 1,
	[int]$SoldiersPerUnit = 5000,
	[double]$TeamFrontOffsetZ = 6.0,
	[double]$TeamSpacingX = 12.0,
	[double]$MaxSimSec = 240.0,
	[double]$TimeScale = 8.0,
	[int]$SeedStart = 20260318,
	[string]$WeatherState = "sunny",
	[switch]$DisableAutoRelease,
	[switch]$EnablePersonality,
	[switch]$NoForceSpawnTemplate,
	[double]$ReissueOrderIntervalSimSec = 10.0,
	[string]$Prefix = "role_matchup_matrix",
	[double]$AnomalyThreshold = 0.30
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $ProjectRoot)) {
	throw "ProjectRoot not found: $ProjectRoot"
}
if ($Roles.Count -lt 2) {
	throw "Roles must contain at least 2 entries."
}
if ($MatchCountPerCell -lt 1) {
	throw "MatchCountPerCell must be >= 1."
}

$disablePersonality = -not $EnablePersonality.IsPresent
$autoReleaseEnabled = -not $DisableAutoRelease.IsPresent
$forceSpawnTemplate = -not $NoForceSpawnTemplate.IsPresent
$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$runBasePrefix = "{0}_{1}" -f $Prefix, $stamp
$reportDir = Join-Path $ProjectRoot "tmp\reports"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

function Invoke-MatrixCell {
	param(
		[string]$RoleA,
		[string]$RoleB,
		[int]$CellSeed
	)

	$runPrefix = "{0}_{1}_vs_{2}" -f $runBasePrefix, $RoleA, $RoleB
	$runnerArgs = @(
		"--headless",
		"--path", $ProjectRoot,
		"-s", "res://scripts/tools/battle_duration_batch_runner.gd",
		"--",
		"--matches=$MatchCountPerCell",
		"--units_per_team=$UnitsPerTeam",
		"--soldiers_per_unit=$SoldiersPerUnit",
		"--team_a_roles=$RoleA",
		"--team_b_roles=$RoleB",
		"--symmetric=false",
		"--team_front_offset_z=$TeamFrontOffsetZ",
		"--team_spacing_x=$TeamSpacingX",
		"--max_sim_sec=$MaxSimSec",
		"--time_scale=$TimeScale",
		"--seed_start=$CellSeed",
		"--weather_state=$WeatherState",
		"--disable_personality=$($disablePersonality.ToString().ToLower())",
		"--auto_release_enabled=$($autoReleaseEnabled.ToString().ToLower())",
		"--force_spawn_template=$($forceSpawnTemplate.ToString().ToLower())",
		"--reissue_order_interval_sim_sec=$ReissueOrderIntervalSimSec",
		"--prefix=$runPrefix"
	)

	$cmdArgs = @("/c", $GodotExe) + $runnerArgs
	$proc = Start-Process -FilePath "cmd.exe" -ArgumentList $cmdArgs -Wait -NoNewWindow -PassThru
	$exitCode = [int]$proc.ExitCode
	if ($exitCode -ne 0) {
		throw "matrix cell failed: $RoleA vs $RoleB (exit=$exitCode)"
	}

	$summaryPattern = "{0}_summary_*.json" -f $runPrefix
	$summaryFile = Get-ChildItem -Path $reportDir -Filter $summaryPattern | Sort-Object LastWriteTime -Descending | Select-Object -First 1
	if ($null -eq $summaryFile) {
		throw "summary json not found for $RoleA vs $RoleB"
	}
	$summary = Get-Content -Raw $summaryFile.FullName | ConvertFrom-Json

	[PSCustomObject]@{
		team_a_role = $RoleA
		team_b_role = $RoleB
		matches = [int]$summary.matches
		team0_win_count = [int]$summary.team0_win_count
		team1_win_count = [int]$summary.team1_win_count
		draw_count = [int]$summary.draw_count
		timeout_count = [int]$summary.timeout_count
		team_a_win_rate = ([double]$summary.team0_win_count) / [math]::Max(1, [int]$summary.matches)
		duration_avg_sec = [double]$summary.duration_avg_sec
		duration_median_sec = [double]$summary.duration_median_sec
		duration_p90_sec = [double]$summary.duration_p90_sec
		summary_json = $summaryFile.FullName
	}
}

Write-Host "run_role_matchup_matrix:"
Write-Host "  roles=$($Roles -join ',') cells=$($Roles.Count * $Roles.Count) match_per_cell=$MatchCountPerCell"
Write-Host "  auto_release_enabled=$($autoReleaseEnabled.ToString().ToLower()) disable_personality=$($disablePersonality.ToString().ToLower()) force_spawn_template=$($forceSpawnTemplate.ToString().ToLower())"

$rows = New-Object System.Collections.Generic.List[object]
$seedCursor = $SeedStart
$totalCells = $Roles.Count * $Roles.Count
$cellIndex = 0

foreach ($roleA in $Roles) {
	foreach ($roleB in $Roles) {
		$cellIndex += 1
		Write-Host ("[{0}/{1}] {2} vs {3}" -f $cellIndex, $totalCells, $roleA, $roleB)
		$row = Invoke-MatrixCell -RoleA $roleA -RoleB $roleB -CellSeed $seedCursor
		$rows.Add($row)
		$seedCursor += 100
	}
}

$rowsByKey = @{}
foreach ($row in $rows) {
	$key = "{0}|{1}" -f $row.team_a_role, $row.team_b_role
	$rowsByKey[$key] = $row
}

$pairRows = New-Object System.Collections.Generic.List[object]
for ($i = 0; $i -lt $Roles.Count; $i += 1) {
	for ($j = $i; $j -lt $Roles.Count; $j += 1) {
		$a = $Roles[$i]
		$b = $Roles[$j]
		$rowAB = $rowsByKey["$a|$b"]
		$rowBA = $rowsByKey["$b|$a"]
		if ($null -eq $rowAB -or $null -eq $rowBA) {
			continue
		}
		$wa = [double]$rowAB.team_a_win_rate
		$wb = [double]$rowBA.team_a_win_rate
		$combinedA = ($wa + (1.0 - $wb)) / 2.0
		$combinedAdv = $combinedA - 0.5
		$biasGap = [math]::Abs($wa - (1.0 - $wb))
		$dominant = "balanced"
		if ([math]::Abs($combinedAdv) -ge 0.05) {
			$dominant = $a
			if ($combinedAdv -lt 0.0) {
				$dominant = $b
			}
		}
		$pairRows.Add([PSCustomObject]@{
			role_a = $a
			role_b = $b
			win_rate_a_vs_b = $wa
			win_rate_b_vs_a = $wb
			combined_advantage = $combinedAdv
			dominant_role = $dominant
			bias_gap = $biasGap
			timeout_total = [int]$rowAB.timeout_count + [int]$rowBA.timeout_count
			median_sec_avg = ([double]$rowAB.duration_median_sec + [double]$rowBA.duration_median_sec) / 2.0
		})
	}
}

$anomalies = $pairRows | Where-Object {
	$nonMirror = $_.role_a -ne $_.role_b
	$highAdv = [math]::Abs([double]$_.combined_advantage) -ge $AnomalyThreshold
	$highBias = [double]$_.bias_gap -ge 0.25
	$hasTimeout = [int]$_.timeout_total -gt 0
	$nonMirror -and ($highAdv -or $highBias -or $hasTimeout)
} | Sort-Object @{Expression = {[math]::Abs([double]$_.combined_advantage)}; Descending = $true}, @{Expression = {[double]$_.bias_gap}; Descending = $true}

$matrixRows = New-Object System.Collections.Generic.List[object]
foreach ($roleA in $Roles) {
	$obj = [ordered]@{ team_a_role = $roleA }
	foreach ($roleB in $Roles) {
		$key = "{0}|{1}" -f $roleA, $roleB
		$row = $rowsByKey[$key]
		$obj[$roleB] = [math]::Round(100.0 * [double]$row.team_a_win_rate, 2)
	}
	$matrixRows.Add([PSCustomObject]$obj)
}

$cellsCsv = Join-Path $reportDir ("{0}_cells.csv" -f $runBasePrefix)
$pairsCsv = Join-Path $reportDir ("{0}_pairs.csv" -f $runBasePrefix)
$anomalyCsv = Join-Path $reportDir ("{0}_anomalies.csv" -f $runBasePrefix)
$matrixCsv = Join-Path $reportDir ("{0}_matrix_winrate_pct.csv" -f $runBasePrefix)
$summaryJson = Join-Path $reportDir ("{0}_summary.json" -f $runBasePrefix)

$rows | Export-Csv -Path $cellsCsv -NoTypeInformation -Encoding UTF8
$pairRows | Export-Csv -Path $pairsCsv -NoTypeInformation -Encoding UTF8
$anomalies | Export-Csv -Path $anomalyCsv -NoTypeInformation -Encoding UTF8
$matrixRows | Export-Csv -Path $matrixCsv -NoTypeInformation -Encoding UTF8

$summaryPayload = [ordered]@{
	run_prefix = $runBasePrefix
	generated_at = (Get-Date).ToString("s")
	match_count_per_cell = $MatchCountPerCell
	roles = $Roles
	total_cells = $totalCells
	auto_release_enabled = $autoReleaseEnabled
	disable_personality = $disablePersonality
	force_spawn_template = $forceSpawnTemplate
	timeout_cells = @($rows | Where-Object { [int]$_.timeout_count -gt 0 }).Count
	duration_median_avg_sec = [math]::Round(([double]($rows | Measure-Object -Property duration_median_sec -Average).Average), 3)
	anomaly_threshold = $AnomalyThreshold
	top_anomalies = @($anomalies | Select-Object -First 12)
	files = @{
		cells_csv = $cellsCsv
		pairs_csv = $pairsCsv
		anomalies_csv = $anomalyCsv
		matrix_csv = $matrixCsv
		summary_json = $summaryJson
	}
}

$summaryPayload | ConvertTo-Json -Depth 7 | Set-Content -Path $summaryJson -Encoding UTF8

Write-Host ""
Write-Host "role matchup matrix finished."
Write-Host "  cells_csv=$cellsCsv"
Write-Host "  pairs_csv=$pairsCsv"
Write-Host "  anomalies_csv=$anomalyCsv"
Write-Host "  matrix_csv=$matrixCsv"
Write-Host "  summary_json=$summaryJson"
Write-Host ""
Write-Host "Top anomalies:"
$top = @($anomalies | Select-Object -First 8)
if ($top.Count -le 0) {
	Write-Host "  none"
}
else {
	foreach ($row in $top) {
		$advPct = [math]::Round(100.0 * [double]$row.combined_advantage, 1)
		$biasPct = [math]::Round(100.0 * [double]$row.bias_gap, 1)
		Write-Host ("  {0} vs {1} -> dominant={2} combined_adv={3}% bias_gap={4}%" -f $row.role_a, $row.role_b, $row.dominant_role, $advPct, $biasPct)
	}
}
