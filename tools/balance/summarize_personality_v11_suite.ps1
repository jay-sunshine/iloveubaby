param(
	[string]$ReportDir = (Resolve-Path (Join-Path $PSScriptRoot "..\\..\\tmp\\reports")).Path,
	[string]$PrefixBase = "ab200",
	[ValidateSet("front6", "legacy")]
	[string]$BaselineProfile = "front6",
	[double]$WinThresholdPP = 5.0,
	[double]$SimThresholdPct = 8.0,
	[double]$InfThresholdPct = 6.0,
	[switch]$FailOnThreshold
)

$ErrorActionPreference = "Stop"

function Get-LatestCsv {
	param(
		[string]$DirPath,
		[string]$Pattern
	)
	$item = Get-ChildItem -Path $DirPath -Filter $Pattern -File |
		Sort-Object LastWriteTime -Descending |
		Select-Object -First 1
	if ($null -eq $item) {
		throw "No file found for pattern: $Pattern"
	}
	return $item.FullName
}

function Get-Average {
	param([double[]]$Values)
	if ($null -eq $Values -or $Values.Count -eq 0) {
		return 0.0
	}
	return [double](($Values | Measure-Object -Average).Average)
}

if (-not (Test-Path $ReportDir)) {
	throw "ReportDir not found: $ReportDir"
}

$baselineProfiles = @{
	front6 = @{
		label = "lock_env=v11 front=6 relock (2x200, 2026-03-17)"
		targets = @{
			CTRL = @{
				win_rate = 33.75
				avg_sim_sec = 148.735
				avg_inf = 20946.992
			}
			XIONGLUE = @{
				win_rate = 37.25
				avg_sim_sec = 140.514
				avg_inf = 20796.85
			}
			HUOSHEN = @{
				win_rate = 38.5
				avg_sim_sec = 143.035
				avg_inf = 21450.205
			}
		}
	}
	legacy = @{
		label = "v1.1 legacy lock (2x200, 2026-03-16)"
		targets = @{
			CTRL = @{
				win_rate = 51.25
				avg_sim_sec = 9.2743333333333275
				avg_inf = 22697.8625
			}
			XIONGLUE = @{
				win_rate = 51.0
				avg_sim_sec = 9.309666666666665
				avg_inf = 23893.36625
			}
			HUOSHEN = @{
				win_rate = 51.5
				avg_sim_sec = 9.4103333333333268
				avg_inf = 22901.56
			}
		}
	}
}

if (-not $baselineProfiles.ContainsKey($BaselineProfile)) {
	throw "Unknown BaselineProfile: $BaselineProfile"
}
$baselineSpec = $baselineProfiles[$BaselineProfile]
$lockTargets = $baselineSpec.targets

$matchPatterns = @{
	CTRL = @(
		"${PrefixBase}_ctrl_tune1_matches_*.csv",
		"${PrefixBase}_ctrl_tune1_r2_matches_*.csv"
	)
	XIONGLUE = @(
		"${PrefixBase}_xionglue_tune1_matches_*.csv",
		"${PrefixBase}_xionglue_tune1_r2_matches_*.csv"
	)
	HUOSHEN = @(
		"${PrefixBase}_huoshen_tune1_matches_*.csv",
		"${PrefixBase}_huoshen_tune1_r2_matches_*.csv"
	)
}

$traitPatterns = @{
	XIONGLUE = @(
		"${PrefixBase}_xionglue_tune1_traits_*.csv",
		"${PrefixBase}_xionglue_tune1_r2_traits_*.csv"
	)
	HUOSHEN = @(
		"${PrefixBase}_huoshen_tune1_traits_*.csv",
		"${PrefixBase}_huoshen_tune1_r2_traits_*.csv"
	)
}

$matchSummary = @()
$fileMap = @{}

foreach ($scenario in @("CTRL", "XIONGLUE", "HUOSHEN")) {
	$files = @()
	foreach ($pattern in $matchPatterns[$scenario]) {
		$files += Get-LatestCsv -DirPath $ReportDir -Pattern $pattern
	}
	$fileMap["${scenario}_MATCH"] = $files
	$rows = @()
	foreach ($f in $files) { $rows += Import-Csv -Path $f }
	if ($rows.Count -eq 0) {
		throw "Empty csv rows for scenario: $scenario"
	}

	$w = ($rows | Where-Object { $_.winner -eq "team_0" }).Count
	$l = ($rows | Where-Object { $_.winner -eq "team_1" }).Count
	$d = $rows.Count - $w - $l
	$winRate = ($w * 100.0) / $rows.Count

	$simValues = @()
	$infValues = @()
	$trgValues = @()
	$blkValues = @()
	$frcValues = @()
	foreach ($r in $rows) {
		$simValues += [double]$r.sim_elapsed_sec
		$infValues += (([double]$r.team0_inflicted_troops) + ([double]$r.team1_inflicted_troops)) / 2.0
		$trgValues += (([double]$r.team0_personality_trigger_total) + ([double]$r.team1_personality_trigger_total)) / 2.0
		$blkValues += (([double]$r.team0_personality_blocked_total) + ([double]$r.team1_personality_blocked_total)) / 2.0
		$frcValues += (([double]$r.team0_personality_forced_total) + ([double]$r.team1_personality_forced_total)) / 2.0
	}

	$avgSim = Get-Average -Values $simValues
	$avgInf = Get-Average -Values $infValues
	$avgTrg = Get-Average -Values $trgValues
	$avgBlk = Get-Average -Values $blkValues
	$avgFrc = Get-Average -Values $frcValues

	$target = $lockTargets[$scenario]
	$driftWin = $winRate - [double]$target.win_rate
	$driftSimPct = (($avgSim / [double]$target.avg_sim_sec) - 1.0) * 100.0
	$driftInfPct = (($avgInf / [double]$target.avg_inf) - 1.0) * 100.0
	$pass = ([math]::Abs($driftWin) -le $WinThresholdPP) -and
		([math]::Abs($driftSimPct) -le $SimThresholdPct) -and
		([math]::Abs($driftInfPct) -le $InfThresholdPct)

	$matchSummary += [pscustomobject]@{
		scenario = $scenario
		matches = $rows.Count
		W = $w
		L = $l
		D = $d
		win_rate = [math]::Round($winRate, 3)
		avg_sim_sec = [math]::Round($avgSim, 3)
		avg_inf = [math]::Round($avgInf, 3)
		avg_trigger = [math]::Round($avgTrg, 3)
		avg_blocked = [math]::Round($avgBlk, 3)
		avg_forced = [math]::Round($avgFrc, 3)
		drift_win_pp = [math]::Round($driftWin, 3)
		drift_sim_pct = [math]::Round($driftSimPct, 3)
		drift_inf_pct = [math]::Round($driftInfPct, 3)
		pass = $pass
	}
}

$traitSummary = @()
foreach ($scenario in @("XIONGLUE", "HUOSHEN")) {
	$files = @()
	foreach ($pattern in $traitPatterns[$scenario]) {
		$files += Get-LatestCsv -DirPath $ReportDir -Pattern $pattern
	}
	$fileMap["${scenario}_TRAIT"] = $files
	$rows = @()
	foreach ($f in $files) { $rows += Import-Csv -Path $f }

	$triggerTotal = 0
	$blockedTotal = 0
	$forcedTotal = 0
	foreach ($r in $rows) {
		$triggerTotal += [int]$r.trigger_count
		$blockedTotal += [int]$r.blocked_count
		$forcedTotal += [int]$r.forced_count
	}
	$blockedRate = if ($triggerTotal -gt 0) { ($blockedTotal * 100.0) / $triggerTotal } else { 0.0 }
	$forcedRate = if ($triggerTotal -gt 0) { ($forcedTotal * 100.0) / $triggerTotal } else { 0.0 }

	$traitSummary += [pscustomobject]@{
		scenario = $scenario
		rows = $rows.Count
		trigger_total = $triggerTotal
		blocked_total = $blockedTotal
		forced_total = $forcedTotal
		blocked_rate_pct = [math]::Round($blockedRate, 3)
		forced_rate_pct = [math]::Round($forcedRate, 3)
	}
}

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$jsonOut = Join-Path $ReportDir "personality_v11_lockcheck_$stamp.json"
$mdOut = Join-Path $ReportDir "personality_v11_lockcheck_$stamp.md"

$payload = [ordered]@{
	generated_at = (Get-Date).ToString("s")
	report_dir = $ReportDir
	baseline_profile = [ordered]@{
		id = $BaselineProfile
		label = [string]$baselineSpec.label
	}
	threshold = [ordered]@{
		win_pp = $WinThresholdPP
		sim_pct = $SimThresholdPct
		inf_pct = $InfThresholdPct
	}
	match_summary = $matchSummary
	trait_summary = $traitSummary
	source_files = $fileMap
}
$payload | ConvertTo-Json -Depth 8 | Set-Content -Path $jsonOut -Encoding UTF8

$md = @()
$md += "# Personality V1.1 Lock Check"
$md += ""
$md += "- Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$md += "- Report dir: $ReportDir"
$md += "- Prefix base: $PrefixBase"
$md += "- Baseline profile: $BaselineProfile ($([string]$baselineSpec.label))"
$md += "- Threshold: win_pp<=${WinThresholdPP}, sim_pct<=${SimThresholdPct}, inf_pct<=${InfThresholdPct}"
$md += ""
$md += "## Match Summary"
$md += ""
$md += "| Scenario | W-L-D | avg_sim_sec | avg_inf | avg_trigger | avg_blocked | avg_forced | drift_win_pp | drift_sim_pct | drift_inf_pct | pass |"
$md += "|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|"
foreach ($row in $matchSummary) {
	$wld = "$($row.W)-$($row.L)-$($row.D)"
	$md += "| $($row.scenario) | $wld | $($row.avg_sim_sec) | $($row.avg_inf) | $($row.avg_trigger) | $($row.avg_blocked) | $($row.avg_forced) | $($row.drift_win_pp) | $($row.drift_sim_pct) | $($row.drift_inf_pct) | $($row.pass) |"
}
$md += ""
$md += "## Trait Summary"
$md += ""
$md += "| Scenario | trigger_total | blocked_total | forced_total | blocked_rate_pct | forced_rate_pct |"
$md += "|---|---:|---:|---:|---:|---:|"
foreach ($row in $traitSummary) {
	$md += "| $($row.scenario) | $($row.trigger_total) | $($row.blocked_total) | $($row.forced_total) | $($row.blocked_rate_pct) | $($row.forced_rate_pct) |"
}
$md += ""
$md += "## Source Files"
$md += ""
foreach ($k in ($fileMap.Keys | Sort-Object)) {
	$md += "- $k"
	foreach ($f in $fileMap[$k]) {
		$md += "  - $f"
	}
}
$md | Set-Content -Path $mdOut -Encoding UTF8

Write-Host ""
Write-Host "=== Personality V1.1 Lock Check ==="
$matchSummary |
	Select-Object scenario, @{Name="W-L-D";Expression={ "$($_.W)-$($_.L)-$($_.D)" }}, avg_sim_sec, avg_inf, avg_trigger, avg_blocked, avg_forced, drift_win_pp, drift_sim_pct, drift_inf_pct, pass |
	Format-Table -AutoSize

Write-Host ""
$traitSummary |
	Select-Object scenario, trigger_total, blocked_total, forced_total, blocked_rate_pct, forced_rate_pct |
	Format-Table -AutoSize

Write-Host ""
Write-Host "JSON: $jsonOut"
Write-Host "MD:   $mdOut"

$hasFail = ($matchSummary | Where-Object { -not $_.pass }).Count -gt 0
if ($hasFail -and $FailOnThreshold) {
	exit 2
}
