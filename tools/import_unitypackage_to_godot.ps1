param(
    [Parameter(Mandatory = $true)]
    [string]$UnityPackage,

    [Parameter(Mandatory = $true)]
    [string]$GodotProjectDir,

    [string]$TargetSubdir = 'unity_imports\\ImportedUnityPackage'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ExistingPath([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Path not found: $Path"
    }
    return (Resolve-Path -LiteralPath $Path).Path
}

$invalidCharsRegex = '[<>:"/\\|?*\x00-\x1F]'
function Sanitize-RelativePath([string]$relPath) {
    $parts = $relPath -replace '/', '\\' -split '\\'
    $safeParts = @()
    foreach ($part in $parts) {
        if ([string]::IsNullOrWhiteSpace($part)) { continue }
        $p = $part -replace $invalidCharsRegex, '_'
        # Windows disallows trailing dot/space in path segments.
        $p = $p.Trim().TrimEnd('.')
        if ([string]::IsNullOrWhiteSpace($p)) { $p = '_' }
        $safeParts += $p
    }
    if ($safeParts.Count -eq 0) { return '' }
    return ($safeParts -join '\\')
}

function Read-UnityPathname([string]$pathnameFile) {
    # Some stores append an extra "00" marker on a second line.
    # Keep only the first non-empty line as the asset path.
    $raw = [System.IO.File]::ReadAllText($pathnameFile)
    $raw = $raw -replace "`r", ''
    $line = $raw -split "`n" |
        Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
        Select-Object -First 1

    if ($null -eq $line) { return '' }
    return $line.Trim([char]0, [char]0xFEFF, [char]0xFFFE, ' ')
}

$unityPkg = Resolve-ExistingPath $UnityPackage
$projectDir = Resolve-ExistingPath $GodotProjectDir

if ([System.IO.Path]::GetExtension($unityPkg).ToLowerInvariant() -ne '.unitypackage') {
    throw "Input file must be a .unitypackage: $unityPkg"
}

$extractRoot = Join-Path $env:TEMP ('unitypkg_extract_' + [Guid]::NewGuid().ToString('N'))
$targetRoot = Join-Path $projectDir $TargetSubdir

New-Item -ItemType Directory -Path $extractRoot -Force | Out-Null
New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null

try {
    # .unitypackage is a tar archive of GUID folders (asset/pathname/asset.meta).
    & tar -xf $unityPkg -C $extractRoot
    if ($LASTEXITCODE -ne 0) {
        throw "tar extraction failed with exit code $LASTEXITCODE"
    }

    $count = 0
    $skipped = 0
    $entries = Get-ChildItem -LiteralPath $extractRoot -Directory -ErrorAction SilentlyContinue
    foreach ($entry in $entries) {
        $pathnameFile = Join-Path $entry.FullName 'pathname'
        $assetFile = Join-Path $entry.FullName 'asset'
        if (-not (Test-Path -LiteralPath $pathnameFile) -or -not (Test-Path -LiteralPath $assetFile)) {
            $skipped++
            continue
        }

        $relPath = Read-UnityPathname $pathnameFile
        if ([string]::IsNullOrWhiteSpace($relPath)) {
            $skipped++
            continue
        }

        # Normalize separators and strip leading "Assets/".
        $relPath = $relPath -replace '/', '\\'
        if ($relPath.StartsWith('Assets\\', [System.StringComparison]::OrdinalIgnoreCase)) {
            $relPath = $relPath.Substring(7)
        }

        $safeRelPath = Sanitize-RelativePath $relPath
        if ([string]::IsNullOrWhiteSpace($safeRelPath)) {
            $skipped++
            continue
        }

        $dstPath = Join-Path $targetRoot $safeRelPath
        $dstDir = Split-Path -Parent $dstPath
        if (-not (Test-Path -LiteralPath $dstDir)) {
            New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
        }

        Copy-Item -LiteralPath $assetFile -Destination $dstPath -Force
        $count++
    }

    Write-Host ('Imported files: {0}' -f $count)
    Write-Host ('Skipped entries: {0}' -f $skipped)
    Write-Host ('Target folder : {0}' -f $targetRoot)
}
finally {
    if (Test-Path -LiteralPath $extractRoot) {
        Remove-Item -LiteralPath $extractRoot -Recurse -Force
    }
}
