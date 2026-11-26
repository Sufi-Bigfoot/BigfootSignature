# Builds the image pieces for the Grid signature from background-notext.png
# (the text-free banner, Layer 0 of Recreation.psd).
# In the Grid signature no text sits on an image: icons, logos and lines are
# images placed NEXT to solid-colour cells that hold the real text, so it
# survives Outlook and Gmail, which drop background images.
# Pieces are cut from a 1400 x 530 copy (twice the 700 px shown size).
# The contact bar's red and navy are made flat, so they match the text cells.
# Output: email/grid/*.png  (upload to GitHub Pages)
#
# Usage (PowerShell, in this folder):  .\make-grid-assets.ps1

Add-Type -AssemblyName System.Drawing
Add-Type -Path (Join-Path $PSScriptRoot 'GridTools.cs') -ReferencedAssemblies System.Drawing
$root = $PSScriptRoot
$out = Join-Path $root 'email\grid'
New-Item -ItemType Directory -Force $out | Out-Null

# Flat colours used by both the images and the text cells (keep in sync with combined.html).
$RED  = [System.Drawing.Color]::FromArgb(221, 0, 8)    # #dd0008
$NAVY = [System.Drawing.Color]::FromArgb(0, 33, 88)    # #002158

$src = [System.Drawing.Bitmap]::FromFile((Join-Path $root 'background-notext.png'))
$m = New-Object System.Drawing.Bitmap 1400, 530
$g = [System.Drawing.Graphics]::FromImage($m)
$g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'; $g.CompositingQuality = 'HighQuality'
$attr = New-Object System.Drawing.Imaging.ImageAttributes; $attr.SetWrapMode('TileFlipXY')
$g.Clear([System.Drawing.Color]::White)
$g.DrawImage($src, (New-Object System.Drawing.Rectangle 0, 0, 1400, 530), 0, 0, $src.Width, $src.Height, 'Pixel', $attr)
$g.Dispose(); $src.Dispose()

# Contact bar (rows 258-324): flat red left of the slant, flat navy right of it.
[GridTools]::FlattenBar($m, 258, 324, 600, $RED, $NAVY)

function Save-Piece($x, $y, $w, $h, $name) {
  $c = $m.Clone((New-Object System.Drawing.Rectangle $x, $y, $w, $h), [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
  $c.Save((Join-Path $out "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png); $c.Dispose()
  "{0,-10} {1} x {2}  (shown {3} x {4})" -f $name, $w, $h, ($w / 2), ($h / 2)
}

# Details column (shown 172 wide, rows 0-129). Text cells sit beside these.
Save-Piece 0   0 344  34 'd-top'     # diagonal, above the name
Save-Piece 0  34  68  36 'd-name'    # left of the name
Save-Piece 0  70 344   6 'd-gap'     # between name and title
Save-Piece 0  76  70  26 'd-title'   # left of the title
Save-Piece 0 102 344  18 'd-line'    # red line under the title
Save-Piece 0 120 114 102 'd-icons'   # the three red icons, left of the contacts
Save-Piece 0 222 344  36 'd-bottom'  # below the contacts

# Contact bar (shown rows 129-162). Text cells go between these.
Save-Piece    0 258  84 66 'b-mail'   # envelope icon
Save-Piece  312 258  82 66 'b-phone'  # divider + phone icon
Save-Piece  514 258 104 66 'b-globe'  # red/navy slant + globe icon
Save-Piece  800 258  90 66 'b-pin'    # divider + location icon
Save-Piece 1104 258 296 66 'b-logos'  # divider + bizSAFE, ISO, SLA logos

# Services row: icons as one image (shown rows 162-179); labels are text below.
Save-Piece 0 324 1400 34 's-icons'

$m.Dispose()
