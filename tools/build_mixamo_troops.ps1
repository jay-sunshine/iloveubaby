param(
    [string]$BlenderExe = "C:\Users\Admin\Downloads\blender-4.5.0-windows-x64\blender-4.5.0-windows-x64\blender.exe",
    [string]$MixamoRoot = "",
    [string]$OutDir = ""
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path $PSScriptRoot -Parent
if ([string]::IsNullOrWhiteSpace($MixamoRoot)) {
    $MixamoRoot = Join-Path $projectRoot "assets_imports\mixamo_troops"
}
if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $OutDir = Join-Path $MixamoRoot "out"
}

$script = Join-Path $PSScriptRoot "blender_merge_mixamo_actions.py"
New-Item -ItemType Directory -Force -Path $MixamoRoot | Out-Null
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function Build-OneRole {
    param(
        [string]$RoleId,
        [string]$AnimDir,
        [string]$BaseFbx = "",
        [string]$BaseGlb = "",
        [string]$BindFbx = "",
        [switch]$DisableWeaponSplit
    )
    if (!(Test-Path $AnimDir)) {
        Write-Warning "Skip [$RoleId] missing anim dir: $AnimDir"
        return
    }
    $animCount = (Get-ChildItem -Path $AnimDir -Filter *.fbx -File -ErrorAction SilentlyContinue | Measure-Object).Count
    if ($animCount -le 0) {
        Write-Warning "Skip [$RoleId] no anim fbx in: $AnimDir"
        return
    }

    $outFile = Join-Path $OutDir "$RoleId.glb"
    $extraArgs = @()
    if ($DisableWeaponSplit) {
        $extraArgs += "--disable-weapon-split"
    }

    if ((-not [string]::IsNullOrWhiteSpace($BaseFbx)) -and (Test-Path $BaseFbx)) {
        & $BlenderExe -b --python $script -- `
            --base-fbx $BaseFbx `
            --anim-dir $AnimDir `
            --out-glb $outFile `
            --name-prefix "$RoleId`_" `
            @extraArgs
        return
    }
    if ((-not [string]::IsNullOrWhiteSpace($BaseGlb)) -and (Test-Path $BaseGlb)) {
        if ((-not [string]::IsNullOrWhiteSpace($BindFbx)) -and (Test-Path $BindFbx)) {
            & $BlenderExe -b --python $script -- `
                --base-glb $BaseGlb `
                --bind-fbx $BindFbx `
                --anim-dir $AnimDir `
                --out-glb $outFile `
                --name-prefix "$RoleId`_" `
                @extraArgs
        }
        else {
            & $BlenderExe -b --python $script -- `
                --base-glb $BaseGlb `
                --anim-dir $AnimDir `
                --out-glb $outFile `
                --name-prefix "$RoleId`_" `
                @extraArgs
        }
        return
    }
    Write-Warning "Skip [$RoleId] missing base fbx and base glb."
}

$roles = @("infantry", "shield", "spear", "archer", "cavalry")
$fallbackGlb = @{
    "infantry" = (Join-Path $projectRoot "assets_imports\rpg_troops\troop_infantry.glb")
    "shield" = (Join-Path $projectRoot "assets_imports\rpg_troops\troop_infantry_shield.glb")
    "spear" = (Join-Path $projectRoot "assets_imports\rpg_troops\troop_spear.glb")
    "archer" = (Join-Path $projectRoot "assets_imports\rpg_troops\troop_archer.glb")
    "cavalry" = (Join-Path $projectRoot "assets_imports\rpg_troops\troop_cavalry.glb")
}

foreach ($role in $roles) {
    $baseDir = Join-Path $MixamoRoot "inbox\$role\base"
    $animDir = Join-Path $MixamoRoot "inbox\$role\anims"
    New-Item -ItemType Directory -Force -Path $baseDir | Out-Null
    New-Item -ItemType Directory -Force -Path $animDir | Out-Null

    $baseFbx = Get-ChildItem -Path $baseDir -Filter *.fbx -File -ErrorAction SilentlyContinue | Select-Object -First 1
    $baseFbxPath = ""
    if ($baseFbx -ne $null) {
        $baseFbxPath = $baseFbx.FullName
    }
    $baseGlbPath = ""
    if ($fallbackGlb.ContainsKey($role)) {
        $baseGlbPath = $fallbackGlb[$role]
    }
    $bindFbxPath = ""
    if ([string]::IsNullOrWhiteSpace($baseFbxPath)) {
        # Prefer largest animation FBX as bind source (usually the "with skin" file).
        $bindCandidate = Get-ChildItem -Path $animDir -Filter *.fbx -File -ErrorAction SilentlyContinue |
            Sort-Object Length -Descending |
            Select-Object -First 1
        if ($bindCandidate -ne $null) {
            $bindFbxPath = $bindCandidate.FullName
        }
    }

    $disableWeaponSplit = ($role -eq "shield")
    Build-OneRole -RoleId $role -AnimDir $animDir -BaseFbx $baseFbxPath -BaseGlb $baseGlbPath -BindFbx $bindFbxPath -DisableWeaponSplit:$disableWeaponSplit
}

Write-Host "Done. Output dir: $OutDir"
