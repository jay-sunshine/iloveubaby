$ErrorActionPreference = "Stop"
$project = "E:\山河志风起汉末"
$scene = "res://scenes/shield_close_preview.tscn"

Write-Host "Run preview: $scene"
godot4 --headless --path $project --scene $scene --quit-after 25
