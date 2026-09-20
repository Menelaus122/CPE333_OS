# Trim a captured terminal screenshot down to the area that actually has output.
#
# The captured window is mostly empty space below the last line of output, and a
# Windows notification toast can drift into that empty area. Scanning from the top
# and stopping at the first long run of blank rows keeps the command output and
# drops everything after it, toast included.
#
# Usage: powershell -File crop_shot.ps1 -Path PS06\result\screenshots\s01_swap_baseline.png
param(
  [Parameter(Mandatory = $true)][string]$Path,
  [int]$Pad = 20,          # pixels of breathing room kept after the last content row
  [int]$GapRows = 90,      # a run of this many blank rows counts as "end of output"
  [int]$Tolerance = 24,    # per-channel difference that still counts as background
  [int]$MinPixels = 3      # non-background pixels needed for a row/column to count
)

Add-Type -AssemblyName System.Drawing

$full = (Resolve-Path $Path).Path
$src = [System.Drawing.Bitmap]::FromFile($full)
$w = $src.Width
$h = $src.Height

# Copy into a 32bpp bitmap so the pixel data can be read in one locked block.
$bmp = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($src, 0, 0, $w, $h)
$g.Dispose()
$src.Dispose()

$rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
$data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, $bmp.PixelFormat)
$stride = $data.Stride
$bytes = New-Object byte[] ($stride * $h)
[System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
$bmp.UnlockBits($data)

# Background = colour of a pixel well inside the terminal body, below the tab bar.
$bx = [int]($w * 0.85)
$by = [int]($h * 0.60)
$bi = $by * $stride + $bx * 4
$bgB = $bytes[$bi]; $bgG = $bytes[$bi + 1]; $bgR = $bytes[$bi + 2]

$lastRow = 0
$lastCol = 0
$gap = 0
$seenContent = $false

for ($y = 0; $y -lt $h; $y++) {
  $row = $y * $stride
  $count = 0
  $rowLast = 0
  for ($x = 0; $x -lt $w; $x++) {
    $i = $row + $x * 4
    if ([math]::Abs($bytes[$i] - $bgB) -gt $Tolerance -or
        [math]::Abs($bytes[$i + 1] - $bgG) -gt $Tolerance -or
        [math]::Abs($bytes[$i + 2] - $bgR) -gt $Tolerance) {
      $count++
      $rowLast = $x
    }
  }
  if ($count -ge $MinPixels) {
    $lastRow = $y
    if ($rowLast -gt $lastCol) { $lastCol = $rowLast }
    $seenContent = $true
    $gap = 0
  }
  elseif ($seenContent) {
    $gap++
    if ($gap -ge $GapRows) { break }
  }
}

$newH = [math]::Min($h, $lastRow + $Pad)
$newW = [math]::Min($w, $lastCol + $Pad)
if ($newH -lt 40) { $newH = $h }
if ($newW -lt 200) { $newW = $w }

if ($newH -eq $h -and $newW -eq $w) {
  $bmp.Dispose()
  Write-Output "unchanged $Path ($w x $h)"
  return
}

$crop = New-Object System.Drawing.Rectangle 0, 0, $newW, $newH
$out = $bmp.Clone($crop, $bmp.PixelFormat)
$bmp.Dispose()

$tmp = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($full), ([System.IO.Path]::GetFileNameWithoutExtension($full) + ".tmp.png"))
$out.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
$out.Dispose()
Move-Item -Force $tmp $full
Write-Output "cropped $Path : $w x $h -> $newW x $newH"
