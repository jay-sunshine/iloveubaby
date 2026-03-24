param(
    [string]$BaseFbx = "C:\Users\Admin\Downloads\shield_manual.fbx",
    [string]$AnimDir = "E:\山河志风起汉末\assets_imports\mixamo_troops\inbox\shield\anims",
    [string]$OutGlb = "E:\山河志风起汉末\assets_imports\mixamo_troops\out\shield_final.glb",
    [string]$NamePrefix = "shield_"
)

$ErrorActionPreference = "Stop"

$blender = "C:\Users\Admin\Downloads\blender-4.5.0-windows-x64\blender-4.5.0-windows-x64\blender.exe"
$script = "E:\山河志风起汉末\tools\blender_merge_mixamo_actions.py"
$project = "E:\山河志风起汉末"

if (!(Test-Path $blender)) { throw "Blender not found: $blender" }
if (!(Test-Path $script)) { throw "Script not found: $script" }
if (!(Test-Path $BaseFbx)) { throw "Base FBX not found: $BaseFbx" }
if (!(Test-Path $AnimDir)) { throw "Anim dir not found: $AnimDir" }

Write-Host "[1/3] Build animated GLB from manual FBX..."
& $blender -b --python $script -- --base-fbx $BaseFbx --anim-dir $AnimDir --out-glb $OutGlb --name-prefix $NamePrefix
if ($LASTEXITCODE -ne 0) { throw "Blender build failed with code $LASTEXITCODE" }

Write-Host "[2/3] Godot import refresh..."
godot4 --headless --path $project --import
if ($LASTEXITCODE -ne 0) { throw "Godot import failed with code $LASTEXITCODE" }

Write-Host "[3/3] Done: $OutGlb"
