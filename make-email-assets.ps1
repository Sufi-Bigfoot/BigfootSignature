# Builds the hosted images for the "details as text" signature from background.png.
# Everything is cut from one 1400 x 530 copy of the banner: twice the 700 px the
# signature is shown at, so it stays sharp on high-resolution screens.
# Output: email/*.png  (upload that folder to the GitHub Pages site)
#
# Usage (PowerShell, in this folder):  .\make-email-assets.ps1

Add-Type -AssemblyName System.Drawing
$root = $PSScriptRoot
$out = Join-Path $root 'email'
New-Item -ItemType Directory -Force $out | Out-Null

$src = [System.Drawing.Bitmap]::FromFile((Join-Path $root 'background.png'))

function New-Resized($img, $w, $h) {
  $b = New-Object System.Drawing.Bitmap $w, $h
  $g = [System.Drawing.Graphics]::FromImage($b)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $attr = New-Object System.Drawing.Imaging.ImageAttributes
  $attr.SetWrapMode([System.Drawing.Drawing2D.WrapMode]::TileFlipXY)   # no dark edge
  $g.DrawImage($img, (New-Object System.Drawing.Rectangle 0, 0, $w, $h), 0, 0, $img.Width, $img.Height, [System.Drawing.GraphicsUnit]::Pixel, $attr)
  $g.Dispose()
  return $b
}

function Save-Crop($img, $x, $y, $w, $h, $name) {
  $c = $img.Clone((New-Object System.Drawing.Rectangle $x, $y, $w, $h), $img.PixelFormat)
  $c.Save((Join-Path $out $name), [System.Drawing.Imaging.ImageFormat]::Png)
  $c.Dispose()
  "{0,-14} {1} x {2}" -f $name, $w, $h
}

# 1400 x 530 master (the banner is 2038 x 772).
$m = New-Resized $src 1400 530

# Positions in master pixels (= 2 x the size shown in the email).
$LEFT  = 344   # details column ends here (just left of the vertical divider)
$BAR   = 258   # red/navy contact bar starts below this
$SPLIT = 394   # social row starts here (same cut as the image signature)
$xs = 0, 734, 866, 1000, 1134, 1266, 1400   # scam block, then one slot per social icon

Save-Crop $m $LEFT 0 (1400 - $LEFT) $BAR 'banner.png'
Save-Crop $m 0 $BAR 1400 ($SPLIT - $BAR) 'bar.png'
$names = 'scam.png', 'whatsapp.png', 'instagram.png', 'facebook.png', 'linkedin.png', 'youtube.png'
for ($i = 0; $i -lt 6; $i++) { Save-Crop $m $xs[$i] $SPLIT ($xs[$i + 1] - $xs[$i]) (530 - $SPLIT) $names[$i] }

# The three red contact icons, cut from the full-size banner as circles on white,
# 32 x 32 (shown at 16 x 16).
$icons = @{ 'icon-email.png' = 197.5; 'icon-phone.png' = 248; 'icon-mobile.png' = 298 }
foreach ($k in $icons.Keys) {
  $cy = $icons[$k]; $cx = 124; $r = 24
  $box = $src.Clone((New-Object System.Drawing.Rectangle ([int]($cx - $r)), ([int]($cy - $r)), (2 * $r), (2 * $r)), $src.PixelFormat)
  $small = New-Resized $box 32 32
  $ico = New-Object System.Drawing.Bitmap 32, 32
  $g = [System.Drawing.Graphics]::FromImage($ico)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::White)
  $brush = New-Object System.Drawing.TextureBrush $small
  $g.FillEllipse($brush, 0, 0, 32, 32)
  $g.Dispose(); $brush.Dispose(); $box.Dispose(); $small.Dispose()
  $ico.Save((Join-Path $out $k), [System.Drawing.Imaging.ImageFormat]::Png); $ico.Dispose()
  "{0,-14} 32 x 32" -f $k
}

$m.Dispose(); $src.Dispose()
