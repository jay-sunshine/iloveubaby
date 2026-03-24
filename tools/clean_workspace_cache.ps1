param(
    [string]$ProjectDir = ".",
    [switch]$ClearGodotImported
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Clear-DirContents([string]$PathToClear) {
    if (-not (Test-Path -LiteralPath $PathToClear)) {
        Write-Host ("Skip (not found): {0}" -f $PathToClear)
        return
    }

    Write-Host ("Clearing: {0}" -f $PathToClear)
    Get-ChildItem -LiteralPath $PathToClear -Force -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

$resolvedProject = (Resolve-Path -LiteralPath $ProjectDir).Path

Clear-DirContents (Join-Path $resolvedProject "tmp")
Clear-DirContents (Join-Path $resolvedProject ".godot\editor")
Clear-DirContents (Join-Path $resolvedProject ".godot\shader_cache")

if ($ClearGodotImported) {
    Clear-DirContents (Join-Path $resolvedProject ".godot\imported")
}

Write-Host "Done. Reopen Codex/Godot to refresh indexing cache."
