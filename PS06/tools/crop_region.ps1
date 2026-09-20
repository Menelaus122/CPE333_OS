# Crop a fixed rectangle out of a screenshot.
#
# crop_shot.ps1 trims by scanning for blank rows, which fails on a window whose
# scrollbar runs the full height (Resource Monitor). This one takes the rectangle
# directly, and writes to -Out (or back over -Path when -Out is omitted).
#
# Usage: powershell -File crop_region.ps1 -Path in.png -X 0 -Y 0 -W 1920 -H 700 -Out out.png
param(
  [Parameter(Mandatory = $true)][string]$Path,
  [Parameter(Mandatory = $true)][int]$X,
  [Parameter(Mandatory = $true)][int]$Y,
  [Parameter(Mandatory = $true)][int]$W,
  [Parameter(Mandatory = $true)][int]$H,
  [string]$Out
)

Add-Type -AssemblyName System.Drawing

$full = (Resolve-Path $Path).Path
$src = [System.Drawing.Bitmap]::FromFile($full)

$x2 = [math]::Min($X + $W, $src.Width)
$y2 = [math]::Min($Y + $H, $src.Height)
$rect = New-Object System.Drawing.Rectangle $X, $Y, ($x2 - $X), ($y2 - $Y)

$crop = $src.Clone($rect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$src.Dispose()

if (-not $Out) { $Out = $full }
if (-not [System.IO.Path]::IsPathRooted($Out)) { $Out = Join-Path (Get-Location).Path $Out }
$dir = [System.IO.Path]::GetDirectoryName($Out)
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }
$tmp = [System.IO.Path]::Combine($dir, ([System.IO.Path]::GetFileNameWithoutExtension($Out) + ".tmp.png"))
$crop.Save($tmp, [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose()
Move-Item -Force $tmp $Out
Write-Output "cropped $Path -> $Out ($($rect.Width) x $($rect.Height) at $X,$Y)"
