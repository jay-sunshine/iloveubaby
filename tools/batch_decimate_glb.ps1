param(
    [Parameter(Mandatory = $true)]
    [string]$BlenderExe,

    [Parameter(Mandatory = $true)]
    [string]$InputDir,

    [Parameter(Mandatory = $true)]
    [string]$OutputDir,

    [int]$TargetFaces = 1000,

    [string]$BlenderScript = (Join-Path $PSScriptRoot "blender_decimate_glb.py"),

    [string]$LogCsv = "",

    [switch]$Overwrite,

    [switch]$StopOnError
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-NormalizedPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [switch]$AllowMissing
    )

    if (Test-Path -LiteralPath $Path) {
        return (Resolve-Path -LiteralPath $Path).Path
    }

    if ($AllowMissing) {
        $parent = Split-Path -Parent $Path
        if ($parent -and -not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        return [System.IO.Path]::GetFullPath($Path)
    }

    throw "Path not found: $Path"
}

$blenderExe = Resolve-NormalizedPath -Path $BlenderExe
$inputDir = Resolve-NormalizedPath -Path $InputDir
$blenderScript = Resolve-NormalizedPath -Path $BlenderScript

if (-not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}
$outputDir = Resolve-NormalizedPath -Path $OutputDir

if ([string]::IsNullOrWhiteSpace($LogCsv)) {
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $LogCsv = Join-Path $outputDir "decimate_log_$stamp.csv"
}
$logCsv = Resolve-NormalizedPath -Path $LogCsv -AllowMissing

$files = @(Get-ChildItem -LiteralPath $inputDir -Recurse -File -Filter "*.glb" | Sort-Object FullName)
if ($files.Count -eq 0) {
    Write-Host "No .glb files found under: $inputDir"
    exit 0
}

$rows = New-Object "System.Collections.Generic.List[object]"
$total = $files.Count
$index = 0

foreach ($file in $files) {
    $index++

    $relative = $file.FullName.Substring($inputDir.Length).TrimStart([char[]]@('\', '/'))
    $relativeDir = Split-Path -Parent $relative
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
    $outName = "{0}_{1}f.glb" -f $baseName, $TargetFaces

    if ([string]::IsNullOrWhiteSpace($relativeDir)) {
        $outPath = Join-Path $outputDir $outName
    }
    else {
        $outPath = Join-Path (Join-Path $outputDir $relativeDir) $outName
    }

    $outParent = Split-Path -Parent $outPath
    if (-not (Test-Path -LiteralPath $outParent)) {
        New-Item -ItemType Directory -Path $outParent -Force | Out-Null
    }

    if ((Test-Path -LiteralPath $outPath) -and -not $Overwrite) {
        Write-Host ("[{0}/{1}] SKIP existing: {2}" -f $index, $total, $relative)
        $rows.Add([pscustomobject]@{
                Timestamp  = (Get-Date).ToString("s")
                Status     = "SkippedExisting"
                ExitCode   = 0
                BeforeFaces = $null
                AfterFaces = $null
                TargetFaces = $TargetFaces
                InputPath  = $file.FullName
                OutputPath = $outPath
                Message    = "Output file already exists."
            }) | Out-Null
        continue
    }

    Write-Host ("[{0}/{1}] Processing: {2}" -f $index, $total, $relative)

    $outputLines = & $blenderExe -b -P $blenderScript -- --input $file.FullName --output $outPath --target $TargetFaces 2>&1
    $exitCode = $LASTEXITCODE
    $outputText = ($outputLines | ForEach-Object { $_.ToString() }) -join "`n"

    $beforeFaces = $null
    $afterFaces = $null
    $status = "Failed"
    $message = ""

    if ($exitCode -eq 0) {
        if ($outputText -match "\[done\] faces before=(\d+), after=(\d+), target=(\d+)") {
            $beforeFaces = [int]$Matches[1]
            $afterFaces = [int]$Matches[2]
            $status = "OK"
            $message = "Decimated."
            Write-Host ("    faces: {0} -> {1}" -f $beforeFaces, $afterFaces)
        }
        elseif ($outputText -match "\[done\] faces before=(\d+), already <= target=(\d+)") {
            $beforeFaces = [int]$Matches[1]
            $afterFaces = [int]$Matches[1]
            $status = "OK"
            $message = "Already below target."
            Write-Host ("    faces: {0} -> {1} (already below target)" -f $beforeFaces, $afterFaces)
        }
        else {
            $status = "OK"
            $message = "Completed, but face counts were not parsed."
            Write-Host "    completed (face counts not parsed)"
        }
    }
    else {
        $message = (($outputLines | Select-Object -Last 8) -join " | ")
        Write-Warning ("    failed (exit={0})" -f $exitCode)
    }

    $rows.Add([pscustomobject]@{
            Timestamp  = (Get-Date).ToString("s")
            Status     = $status
            ExitCode   = $exitCode
            BeforeFaces = $beforeFaces
            AfterFaces = $afterFaces
            TargetFaces = $TargetFaces
            InputPath  = $file.FullName
            OutputPath = $outPath
            Message    = $message
        }) | Out-Null

    if ($status -eq "Failed" -and $StopOnError) {
        break
    }
}

$rows | Export-Csv -LiteralPath $logCsv -NoTypeInformation -Encoding UTF8

$okCount = @($rows | Where-Object { $_.Status -eq "OK" }).Count
$failCount = @($rows | Where-Object { $_.Status -eq "Failed" }).Count
$skipCount = @($rows | Where-Object { $_.Status -eq "SkippedExisting" }).Count

Write-Host ""
Write-Host ("Done. ok={0}, fail={1}, skip={2}" -f $okCount, $failCount, $skipCount)
Write-Host ("CSV log: {0}" -f $logCsv)

if ($failCount -gt 0) {
    exit 1
}
