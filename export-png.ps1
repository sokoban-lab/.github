<#
.SYNOPSIS
    Export an SVG to multiple PNG sizes using Inkscape.

.DESCRIPTION
    Renders the given SVG into PNG files at the requested sizes.
    Defaults to the common icon size set: 16, 24, 32, 48, 64, 128, 256, 512.

.PARAMETER Input
    Path to the source SVG file.

.PARAMETER OutputDir
    Directory to write PNG files into. Created if missing.

.PARAMETER Sizes
    Array of square sizes (in pixels) to render.

.EXAMPLE
    .\export-png.ps1 -Input .\sokoban-lab.svg -OutputDir .\png
#>
param(
    [Parameter(Mandatory = $true)]
    [Alias("Input")]
    [string]$Source,

    [string]$OutputDir = ".\png",

    [string]$Sizes = "16,24,32,48,64,128,256,512"
)

$ErrorActionPreference = "Stop"

$sizeList = $Sizes -split '[,\s]+' | Where-Object { $_ } | ForEach-Object { [int]$_ }

if (-not (Test-Path -LiteralPath $Source)) {
    throw "Input SVG not found: $Source"
}

if (-not (Get-Command inkscape -ErrorAction SilentlyContinue)) {
    throw "Inkscape is not installed or not on PATH."
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$base = [System.IO.Path]::GetFileNameWithoutExtension($Source)

foreach ($size in $sizeList) {
    if ($size -le 0) { continue }
    $out = Join-Path $OutputDir "$base-$size.png"
    & inkscape $Source --export-type=png `
        --export-width=$size --export-height=$size `
        --export-filename=$out 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Inkscape failed for size $size (exit $LASTEXITCODE)"
    }
    Write-Host "generated $size -> $out"
}

Write-Host "Done: $($sizeList.Count) sizes exported to $OutputDir"