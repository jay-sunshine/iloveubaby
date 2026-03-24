$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$inputPath = Join-Path $projectRoot 'china_dem.png'
$outputRoot = Join-Path $projectRoot 'data\terrain\china_30km'
$outputR16 = Join-Path $outputRoot 'china_height_30km.r16'
$outputPreview = Join-Path $outputRoot 'china_height_30km_preview.png'
$outputInfo = Join-Path $outputRoot 'china_height_30km_info.txt'

New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $outputRoot 'terrain_data') | Out-Null

Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies 'System.dll','System.Drawing.dll' -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

public static class ChinaTerrainGenerator {
    const float WorldSizeMeters = 30000f;
    const float SeaDepthMeters = -1200f;
    const float ShelfDepthMeters = -260f;
    const float LandMaxMeters = 1900f;
    const int SeedThreshold = 250;
    const int SeaTraverseThreshold = 244;
    const int EdgeSeedColumns = 48;
    const int CoastBlendPixels = 288;
    const int IslandRestoreThreshold = 242;
    const int IslandMinArea = 1800;
    const int IslandMinExtent = 28;
    const float TaiwanRegionMinXRatio = 0.74f;
    const float TaiwanRegionMinYRatio = 0.74f;
    const int CoastSmoothRadius = 6;
    const float WestFullRatio = 0.42f;
    const float WestFadeEndRatio = 0.68f;
    const int SmoothPasses = 6;
    const float SmoothBlendBase = 0.18f;
    const float SmoothBlendMax = 0.58f;
    const float SmoothRoughnessDivisor = 180f;
    const int PeakSuppressPasses = 4;
    const float PeakThresholdMeters = 56f;
    const float PeakReduceStrength = 0.64f;
    const float PeakMicroBlend = 0.12f;

    public static string Run(string inputPath, string outputR16, string outputPreview, string outputInfo) {
        Bitmap source = null;
        Bitmap bitmap = null;
        try {
            source = new Bitmap(inputPath);
            int sourceWidth = source.Width;
            int sourceHeight = source.Height;
            int width = (sourceWidth == 4097) ? 4096 : sourceWidth;
            int height = (sourceHeight == 4097) ? 4096 : sourceHeight;
            Rectangle sourceRect = new Rectangle(0, 0, sourceWidth, sourceHeight);
            Rectangle rect = new Rectangle(0, 0, width, height);
            bitmap = new Bitmap(sourceWidth, sourceHeight, PixelFormat.Format32bppArgb);
            using (Graphics gfx = Graphics.FromImage(bitmap)) {
                gfx.DrawImage(source, sourceRect);
            }

            BitmapData data = bitmap.LockBits(sourceRect, ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
            byte[] pixels = new byte[data.Stride * sourceHeight];
            Marshal.Copy(data.Scan0, pixels, 0, pixels.Length);
            bitmap.UnlockBits(data);

            int pixelCount = width * height;
            int[] coastLineX;
            byte[] seaMask = BuildSeaMask(pixels, data.Stride, width, height, out coastLineX);

            int seaPixels = 0;
            for (int i = 0; i < pixelCount; i++) {
                if (seaMask[i] == 1) {
                    seaPixels++;
                }
            }

            int minValue = 255;
            int maxValue = 0;
            for (int y = 0; y < height; y++) {
                int rowOffset = y * data.Stride;
                int rowStart = y * width;
                for (int x = 0; x < width; x++) {
                    int idx = rowStart + x;
                    if (seaMask[idx] == 1) {
                        continue;
                    }
                    int red = pixels[rowOffset + x * 4 + 2];
                    if (red < minValue) {
                        minValue = red;
                    }
                    if (red > maxValue) {
                        maxValue = red;
                    }
                }
            }
            if (maxValue <= minValue) {
                maxValue = minValue + 1;
            }

            float[] heights = new float[pixelCount];
            float metersPerStep = LandMaxMeters / (maxValue - minValue);
            for (int y = 0; y < height; y++) {
                int rowOffset = y * data.Stride;
                int rowStart = y * width;
                for (int x = 0; x < width; x++) {
                    int idx = rowStart + x;
                    if (seaMask[idx] == 1) {
                        heights[idx] = SeaDepthMeters;
                        continue;
                    }
                    int red = pixels[rowOffset + x * 4 + 2];
                    heights[idx] = (red - minValue) * metersPerStep;
                }
            }

            ApplyCoastBlend(heights, seaMask, coastLineX, width, height);
            SmoothWesternLand(heights, seaMask, width, height);
            SuppressWesternPeaks(heights, seaMask, width, height);

            float minHeight = float.MaxValue;
            float maxHeight = float.MinValue;
            float maxLandHeight = float.MinValue;
            for (int idx = 0; idx < pixelCount; idx++) {
                if (seaMask[idx] == 1) {
                    heights[idx] = Math.Min(heights[idx], -8f);
                } else {
                    if (heights[idx] < 0f) {
                        heights[idx] = 0f;
                    }
                    if (heights[idx] > LandMaxMeters) {
                        heights[idx] = LandMaxMeters;
                    }
                    if (heights[idx] > maxLandHeight) {
                        maxLandHeight = heights[idx];
                    }
                }
                if (heights[idx] < minHeight) {
                    minHeight = heights[idx];
                }
                if (heights[idx] > maxHeight) {
                    maxHeight = heights[idx];
                }
            }

            using (BinaryWriter writer = new BinaryWriter(File.Open(outputR16, FileMode.Create, FileAccess.Write, FileShare.None))) {
                float span = LandMaxMeters - SeaDepthMeters;
                for (int idx = 0; idx < pixelCount; idx++) {
                    float normalized = (heights[idx] - SeaDepthMeters) / span;
                    if (normalized < 0f) {
                        normalized = 0f;
                    }
                    if (normalized > 1f) {
                        normalized = 1f;
                    }
                    ushort value = (ushort)Math.Round(normalized * 65535f);
                    writer.Write(value);
                }
            }

            using (Bitmap preview = new Bitmap(width, height, PixelFormat.Format24bppRgb)) {
                BitmapData previewData = preview.LockBits(rect, ImageLockMode.WriteOnly, PixelFormat.Format24bppRgb);
                byte[] previewBytes = new byte[previewData.Stride * height];
                float span = LandMaxMeters - SeaDepthMeters;
                for (int y = 0; y < height; y++) {
                    int rowStart = y * width;
                    int rowOffset = y * previewData.Stride;
                    for (int x = 0; x < width; x++) {
                        int idx = rowStart + x;
                        float normalized = (heights[idx] - SeaDepthMeters) / span;
                        if (normalized < 0f) {
                            normalized = 0f;
                        }
                        if (normalized > 1f) {
                            normalized = 1f;
                        }
                        byte value = (byte)Math.Round(normalized * 255f);
                        int offset = rowOffset + x * 3;
                        previewBytes[offset] = value;
                        previewBytes[offset + 1] = value;
                        previewBytes[offset + 2] = value;
                    }
                }
                Marshal.Copy(previewBytes, 0, previewData.Scan0, previewBytes.Length);
                preview.UnlockBits(previewData);
                preview.Save(outputPreview, ImageFormat.Png);
            }

            float vertexSpacing = WorldSizeMeters / (float)(width - 1);
            StringBuilder sb = new StringBuilder();
            sb.AppendLine(string.Format("source={0}", inputPath));
            sb.AppendLine(string.Format("world_size_m={0:F3}", WorldSizeMeters));
            sb.AppendLine(string.Format("resolution={0}x{1}", width, height));
            sb.AppendLine(string.Format("vertex_spacing_m={0:F6}", vertexSpacing));
            sb.AppendLine(string.Format("heightmap={0}", outputR16));
            sb.AppendLine(string.Format("preview={0}", outputPreview));
            sb.AppendLine(string.Format("sea_depth_m={0:F3}", SeaDepthMeters));
            sb.AppendLine(string.Format("shelf_depth_m={0:F3}", ShelfDepthMeters));
            sb.AppendLine(string.Format("land_max_height_m={0:F3}", LandMaxMeters));
            sb.AppendLine(string.Format("seed_threshold={0}", SeedThreshold));
            sb.AppendLine(string.Format("sea_traverse_threshold={0}", SeaTraverseThreshold));
            sb.AppendLine(string.Format("edge_seed_columns={0}", EdgeSeedColumns));
            sb.AppendLine(string.Format("source_gray_min={0}", minValue));
            sb.AppendLine(string.Format("source_gray_max={0}", maxValue));
            sb.AppendLine(string.Format("east_sea_pixels={0}", seaPixels));
            sb.AppendLine(string.Format("meters_per_gray_step={0:F6}", metersPerStep));
            sb.AppendLine(string.Format("final_height_min_m={0:F3}", minHeight));
            sb.AppendLine(string.Format("final_height_max_m={0:F3}", maxHeight));
            sb.AppendLine(string.Format("final_land_max_m={0:F3}", maxLandHeight));
            sb.AppendLine(string.Format("coast_blend_pixels={0}", CoastBlendPixels));
            sb.AppendLine(string.Format("coast_smooth_radius={0}", CoastSmoothRadius));
            sb.AppendLine(string.Format("west_full_ratio={0:F3}", WestFullRatio));
            sb.AppendLine(string.Format("west_fade_end_ratio={0:F3}", WestFadeEndRatio));
            sb.AppendLine(string.Format("smooth_passes={0}", SmoothPasses));
            sb.AppendLine(string.Format("peak_suppress_passes={0}", PeakSuppressPasses));
            sb.AppendLine(string.Format("peak_threshold_m={0:F3}", PeakThresholdMeters));
            File.WriteAllText(outputInfo, sb.ToString(), Encoding.UTF8);

            return string.Format("OK width={0} height={1} sea_pixels={2} vertex_spacing={3:F6} final_land_max={4:F3}", width, height, seaPixels, vertexSpacing, maxLandHeight);
        }
        finally {
            if (bitmap != null) {
                bitmap.Dispose();
            }
            if (source != null) {
                source.Dispose();
            }
        }
    }

    static byte[] BuildSeaMask(byte[] pixels, int stride, int width, int height, out int[] coastLineX) {
        int pixelCount = width * height;
        byte[] connectedSea = new byte[pixelCount];
        Queue<int> queue = new Queue<int>(width * 8);
        int seedStartX = Math.Max(0, width - EdgeSeedColumns);

        for (int y = 0; y < height; y++) {
            int rowOffset = y * stride;
            int rowStart = y * width;
            for (int x = seedStartX; x < width; x++) {
                int idx = rowStart + x;
                if (connectedSea[idx] == 1) {
                    continue;
                }
                int red = pixels[rowOffset + x * 4 + 2];
                if (red >= SeedThreshold) {
                    connectedSea[idx] = 1;
                    queue.Enqueue(idx);
                }
            }
        }

        int[] offsets = new int[] { -1, 1, -width, width, -width - 1, -width + 1, width - 1, width + 1 };
        while (queue.Count > 0) {
            int idx = queue.Dequeue();
            int x = idx % width;
            int y = idx / width;
            for (int i = 0; i < offsets.Length; i++) {
                int n = idx + offsets[i];
                if (n < 0 || n >= pixelCount) {
                    continue;
                }
                int nx = n % width;
                int ny = n / width;
                if (Math.Abs(nx - x) > 1 || Math.Abs(ny - y) > 1) {
                    continue;
                }
                if (connectedSea[n] == 1) {
                    continue;
                }
                int red = pixels[ny * stride + nx * 4 + 2];
                if (red >= SeaTraverseThreshold) {
                    connectedSea[n] = 1;
                    queue.Enqueue(n);
                }
            }
        }

        coastLineX = new int[height];
        const int NoCoast = int.MinValue;
        for (int y = 0; y < height; y++) {
            int rowStart = y * width;
            int leftMostSea = width;
            for (int x = 0; x < width; x++) {
                if (connectedSea[rowStart + x] == 1) {
                    leftMostSea = x;
                    break;
                }
            }
            coastLineX[y] = (leftMostSea < width) ? (leftMostSea - 1) : NoCoast;
        }

        for (int y = 0; y < height; y++) {
            if (coastLineX[y] != NoCoast) {
                continue;
            }
            int up = y - 1;
            while (up >= 0 && coastLineX[up] == NoCoast) {
                up--;
            }
            int down = y + 1;
            while (down < height && coastLineX[down] == NoCoast) {
                down++;
            }
            if (up >= 0 && down < height) {
                coastLineX[y] = (int)Math.Round((coastLineX[up] + coastLineX[down]) * 0.5f);
            } else if (up >= 0) {
                coastLineX[y] = coastLineX[up];
            } else if (down < height) {
                coastLineX[y] = coastLineX[down];
            } else {
                coastLineX[y] = width - 1;
            }
        }

        int[] smoothedCoast = new int[height];
        for (int y = 0; y < height; y++) {
            List<int> samples = new List<int>();
            for (int k = -CoastSmoothRadius; k <= CoastSmoothRadius; k++) {
                int sy = y + k;
                if (sy < 0 || sy >= height) {
                    continue;
                }
                samples.Add(coastLineX[sy]);
            }
            samples.Sort();
            int q1 = samples[samples.Count / 4];
            int median = samples[samples.Count / 2];
            smoothedCoast[y] = (int)Math.Round((q1 * 2f + median) / 3f);
        }
        coastLineX = smoothedCoast;
        for (int pass = 0; pass < 2; pass++) {
            int[] coastBlur = new int[height];
            for (int y = 0; y < height; y++) {
                int a = coastLineX[Math.Max(y - 1, 0)];
                int b = coastLineX[y];
                int c = coastLineX[Math.Min(y + 1, height - 1)];
                coastBlur[y] = (int)Math.Round((a + b * 2f + c) * 0.25f);
            }
            coastLineX = coastBlur;
        }

        byte[] seaMask = new byte[pixelCount];
        for (int y = 0; y < height; y++) {
            int rowStart = y * width;
            int coast = Math.Max(-1, Math.Min(width - 1, coastLineX[y]));
            for (int x = coast + 1; x < width; x++) {
                seaMask[rowStart + x] = 1;
            }
        }

        RestoreTaiwanIsland(seaMask, pixels, stride, width, height);
        return seaMask;
    }

    static void RestoreTaiwanIsland(byte[] seaMask, byte[] pixels, int stride, int width, int height) {
        int startX = (int)Math.Round(width * TaiwanRegionMinXRatio);
        int startY = (int)Math.Round(height * TaiwanRegionMinYRatio);
        bool[] visited = new bool[width * height];
        int[] offsets = new int[] { -1, 1, -width, width, -width - 1, -width + 1, width - 1, width + 1 };
        Queue<int> queue = new Queue<int>();
        List<int> component = new List<int>();

        for (int y = startY; y < height; y++) {
            int rowStart = y * width;
            int rowOffset = y * stride;
            for (int x = startX; x < width; x++) {
                int idx = rowStart + x;
                if (visited[idx]) {
                    continue;
                }
                visited[idx] = true;
                if (seaMask[idx] != 1) {
                    continue;
                }
                int red = pixels[rowOffset + x * 4 + 2];
                if (red >= IslandRestoreThreshold) {
                    continue;
                }

                queue.Enqueue(idx);
                component.Clear();
                int minX = x;
                int maxX = x;
                int minY = y;
                int maxY = y;

                while (queue.Count > 0) {
                    int cur = queue.Dequeue();
                    component.Add(cur);
                    int cx = cur % width;
                    int cy = cur / width;
                    if (cx < minX) minX = cx;
                    if (cx > maxX) maxX = cx;
                    if (cy < minY) minY = cy;
                    if (cy > maxY) maxY = cy;

                    for (int i = 0; i < offsets.Length; i++) {
                        int n = cur + offsets[i];
                        if (n < 0 || n >= width * height) {
                            continue;
                        }
                        int nx = n % width;
                        int ny = n / width;
                        if (Math.Abs(nx - cx) > 1 || Math.Abs(ny - cy) > 1) {
                            continue;
                        }
                        if (nx < startX || ny < startY) {
                            continue;
                        }
                        if (visited[n]) {
                            continue;
                        }
                        visited[n] = true;
                        if (seaMask[n] != 1) {
                            continue;
                        }
                        int nRed = pixels[ny * stride + nx * 4 + 2];
                        if (nRed < IslandRestoreThreshold) {
                            queue.Enqueue(n);
                        }
                    }
                }

                int componentWidth = maxX - minX + 1;
                int componentHeight = maxY - minY + 1;
                if (component.Count >= IslandMinArea && componentWidth >= IslandMinExtent && componentHeight >= IslandMinExtent) {
                    for (int i = 0; i < component.Count; i++) {
                        seaMask[component[i]] = 0;
                    }
                }
            }
        }
    }

    static void ApplyCoastBlend(float[] heights, byte[] seaMask, int[] coastLineX, int width, int height) {
        for (int y = 0; y < height; y++) {
            int coastX = coastLineX[y];
            if (coastX < 0 || coastX >= width - 1) {
                continue;
            }
            int rowStart = y * width;
            float shoreHeight = Math.Min(heights[rowStart + coastX], 4f);
            int blendLimit = Math.Min(width - 1, coastX + CoastBlendPixels);
            for (int x = coastX + 1; x <= blendLimit; x++) {
                int idx = rowStart + x;
                if (seaMask[idx] != 1) {
                    continue;
                }
                float t = (float)(x - coastX) / (float)CoastBlendPixels;
                float depth;
                if (t <= 0.58f) {
                    depth = Lerp(shoreHeight, ShelfDepthMeters, SmoothStep(t / 0.58f));
                } else {
                    depth = Lerp(ShelfDepthMeters, SeaDepthMeters, SmoothStep((t - 0.58f) / 0.42f));
                }
                heights[idx] = depth;
            }
        }
    }

    static void SmoothWesternLand(float[] heights, byte[] seaMask, int width, int height) {
        int pixelCount = width * height;
        float[] current = heights;
        float[] horizontal = new float[pixelCount];
        float[] next = new float[pixelCount];
        for (int pass = 0; pass < SmoothPasses; pass++) {
            for (int y = 0; y < height; y++) {
                int rowStart = y * width;
                horizontal[rowStart] = current[rowStart];
                for (int x = 1; x < width - 1; x++) {
                    int idx = rowStart + x;
                    horizontal[idx] = current[idx - 1] * 0.25f + current[idx] * 0.5f + current[idx + 1] * 0.25f;
                }
                horizontal[rowStart + width - 1] = current[rowStart + width - 1];
            }

            for (int y = 0; y < height; y++) {
                int rowStart = y * width;
                int upRow = Math.Max(y - 1, 0) * width;
                int downRow = Math.Min(y + 1, height - 1) * width;
                for (int x = 0; x < width; x++) {
                    int idx = rowStart + x;
                    float sourceHeight = current[idx];
                    if (seaMask[idx] == 1) {
                        next[idx] = sourceHeight;
                        continue;
                    }
                    float westWeight = WestWeight(x, width);
                    if (westWeight <= 0f) {
                        next[idx] = sourceHeight;
                        continue;
                    }
                    float blurred = horizontal[upRow + x] * 0.25f + horizontal[idx] * 0.5f + horizontal[downRow + x] * 0.25f;
                    float roughness = Math.Abs(sourceHeight - blurred);
                    float blend = Math.Min(SmoothBlendMax, SmoothBlendBase + roughness / SmoothRoughnessDivisor);
                    next[idx] = Lerp(sourceHeight, blurred, blend * westWeight);
                }
            }

            float[] swap = current;
            current = next;
            next = swap;
        }
        if (!object.ReferenceEquals(current, heights)) {
            Array.Copy(current, heights, pixelCount);
        }
    }

    static void SuppressWesternPeaks(float[] heights, byte[] seaMask, int width, int height) {
        int pixelCount = width * height;
        float[] current = heights;
        float[] next = new float[pixelCount];
        Array.Copy(current, next, pixelCount);
        for (int pass = 0; pass < PeakSuppressPasses; pass++) {
            for (int y = 0; y < height; y++) {
                int rowStart = y * width;
                for (int x = 0; x < width; x++) {
                    int idx = rowStart + x;
                    float sourceHeight = current[idx];
                    if (seaMask[idx] == 1) {
                        next[idx] = sourceHeight;
                        continue;
                    }
                    float westWeight = WestWeight(x, width);
                    if (westWeight <= 0f || x == 0 || y == 0 || x == width - 1 || y == height - 1) {
                        next[idx] = sourceHeight;
                        continue;
                    }
                    float neighborhood = (
                        current[idx] * 4f +
                        current[idx - 1] * 2f + current[idx + 1] * 2f +
                        current[idx - width] * 2f + current[idx + width] * 2f +
                        current[idx - width - 1] + current[idx - width + 1] +
                        current[idx + width - 1] + current[idx + width + 1]
                    ) / 16f;
                    float excess = sourceHeight - neighborhood;
                    if (excess > PeakThresholdMeters) {
                        next[idx] = sourceHeight - (excess - PeakThresholdMeters) * PeakReduceStrength * westWeight;
                    } else {
                        next[idx] = Lerp(sourceHeight, neighborhood, PeakMicroBlend * westWeight);
                    }
                }
            }
            float[] swap = current;
            current = next;
            next = swap;
        }
        if (!object.ReferenceEquals(current, heights)) {
            Array.Copy(current, heights, pixelCount);
        }
    }

    static float Lerp(float a, float b, float t) {
        return a + (b - a) * t;
    }

    static float SmoothStep(float t) {
        if (t < 0f) {
            t = 0f;
        }
        if (t > 1f) {
            t = 1f;
        }
        return t * t * (3f - 2f * t);
    }

    static float WestWeight(int x, int width) {
        float fullX = (width - 1) * WestFullRatio;
        float fadeEndX = (width - 1) * WestFadeEndRatio;
        if (x <= fullX) {
            return 1f;
        }
        if (x >= fadeEndX) {
            return 0f;
        }
        float t = (x - fullX) / (fadeEndX - fullX);
        return 1f - t * t * (3f - 2f * t);
    }
}
"@

$result = [ChinaTerrainGenerator]::Run($inputPath, $outputR16, $outputPreview, $outputInfo)
Write-Host $result
