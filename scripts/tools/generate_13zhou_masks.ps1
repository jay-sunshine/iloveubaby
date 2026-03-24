$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$regionPath = Join-Path $projectRoot 'data\config\han_13_zhou_regions.json'
$outputDir = Join-Path $projectRoot 'data\terrain\china_30km\political'
$fontPath = Join-Path $projectRoot '素材\汇文明朝体汇文明朝体.ttf'
$size = 4096

New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

Add-Type -AssemblyName System.Drawing

function Convert-UvToPoints {
    param(
        [Parameter(Mandatory = $true)] $UvList,
        [int] $CanvasSize
    )

    $points = New-Object 'System.Collections.Generic.List[System.Drawing.PointF]'
    foreach ($uv in $UvList) {
        $x = [single]([double]$uv[0] * $CanvasSize)
        $y = [single]([double]$uv[1] * $CanvasSize)
        $points.Add((New-Object System.Drawing.PointF($x, $y)))
    }
    return ,$points.ToArray()
}

function Get-LabelPoint {
    param(
        [Parameter(Mandatory = $true)] $Uv,
        [int] $CanvasSize
    )

    return New-Object System.Drawing.PointF(([single]([double]$Uv[0] * $CanvasSize)), ([single]([double]$Uv[1] * $CanvasSize)))
}

$regionDoc = Get-Content $regionPath -Raw -Encoding UTF8 | ConvertFrom-Json
$regions = @($regionDoc.regions)

$idMaskPath = Join-Path $outputDir 'zhou_id_mask.png'
$borderMaskPath = Join-Path $outputDir 'zhou_border_mask.png'
$labelMaskPath = Join-Path $outputDir 'zhou_label_overlay.png'
$previewPath = Join-Path $outputDir 'zhou_preview.png'
$metaPath = Join-Path $outputDir 'zhou_mask_meta.json'

$idBitmap = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$borderBitmap = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$labelBitmap = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$previewBitmap = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)

$gId = [System.Drawing.Graphics]::FromImage($idBitmap)
$gBorder = [System.Drawing.Graphics]::FromImage($borderBitmap)
$gLabel = [System.Drawing.Graphics]::FromImage($labelBitmap)
$gPreview = [System.Drawing.Graphics]::FromImage($previewBitmap)

$gId.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
$gBorder.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
$gLabel.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
$gPreview.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))

$gId.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
$gId.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$gBorder.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gPreview.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gLabel.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

$fontCollection = New-Object System.Drawing.Text.PrivateFontCollection
if (Test-Path $fontPath) {
    $fontCollection.AddFontFile($fontPath)
}
$fontFamily = if ($fontCollection.Families.Length -gt 0) { $fontCollection.Families[0] } else { New-Object System.Drawing.FontFamily('Microsoft YaHei') }
$font = New-Object System.Drawing.Font($fontFamily, 84, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$labelBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 34, 18, 10))
$labelOutlineBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 250, 245, 228))
$stringFormat = New-Object System.Drawing.StringFormat
$stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
$stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center

$borderPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(242, 74, 30, 14), 10)
$borderPen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

$metaRegions = @()
$index = 1
foreach ($region in $regions) {
    $points = Convert-UvToPoints -UvList $region.polygon_uvs -CanvasSize $size
    $idColor = [System.Drawing.Color]::FromArgb(255, $index, 0, 0)
    $idBrush = New-Object System.Drawing.SolidBrush($idColor)
    $gId.FillPolygon($idBrush, $points)

    $previewColor = [System.Drawing.Color]::FromArgb(232, [int]($region.color[0] * 255), [int]($region.color[1] * 255), [int]($region.color[2] * 255))
    $previewBrush = New-Object System.Drawing.SolidBrush($previewColor)
    $gPreview.FillPolygon($previewBrush, $points)

    $gBorder.DrawPolygon($borderPen, $points)
    $gPreview.DrawPolygon($borderPen, $points)

    $labelPoint = Get-LabelPoint -Uv $region.label_uv -CanvasSize $size
    foreach ($offset in @(@(-4,0), @(4,0), @(0,-4), @(0,4), @(-3,-3), @(3,-3), @(-3,3), @(3,3))) {
        $gLabel.DrawString([string]$region.name, $font, $labelOutlineBrush, (New-Object System.Drawing.PointF(($labelPoint.X + $offset[0]), ($labelPoint.Y + $offset[1]))), $stringFormat)
        $gPreview.DrawString([string]$region.name, $font, $labelOutlineBrush, (New-Object System.Drawing.PointF(($labelPoint.X + $offset[0]), ($labelPoint.Y + $offset[1]))), $stringFormat)
    }
    $gLabel.DrawString([string]$region.name, $font, $labelBrush, $labelPoint, $stringFormat)
    $gPreview.DrawString([string]$region.name, $font, $labelBrush, $labelPoint, $stringFormat)

    $metaRegions += [pscustomobject]@{
        index = $index
        id = [string]$region.id
        name = [string]$region.name
        mask_rgb = @($index, 0, 0)
    }

    $idBrush.Dispose()
    $previewBrush.Dispose()
    $index += 1
}

$idBitmap.Save($idMaskPath, [System.Drawing.Imaging.ImageFormat]::Png)
$borderBitmap.Save($borderMaskPath, [System.Drawing.Imaging.ImageFormat]::Png)
$labelBitmap.Save($labelMaskPath, [System.Drawing.Imaging.ImageFormat]::Png)
$previewBitmap.Save($previewPath, [System.Drawing.Imaging.ImageFormat]::Png)

$meta = [pscustomobject]@{
    size = $size
    id_mask = 'res://data/terrain/china_30km/political/zhou_id_mask.png'
    border_mask = 'res://data/terrain/china_30km/political/zhou_border_mask.png'
    label_overlay = 'res://data/terrain/china_30km/political/zhou_label_overlay.png'
    preview = 'res://data/terrain/china_30km/political/zhou_preview.png'
    regions = $metaRegions
}
$meta | ConvertTo-Json -Depth 4 | Set-Content -Path $metaPath -Encoding UTF8

$gId.Dispose()
$gBorder.Dispose()
$gLabel.Dispose()
$gPreview.Dispose()
$idBitmap.Dispose()
$borderBitmap.Dispose()
$labelBitmap.Dispose()
$previewBitmap.Dispose()
$font.Dispose()
$labelBrush.Dispose()
$labelOutlineBrush.Dispose()
$borderPen.Dispose()
$stringFormat.Dispose()
$fontCollection.Dispose()

Write-Host "Generated 13州遮罩到 $outputDir"
