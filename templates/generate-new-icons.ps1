# Create PNG icons using .NET Bitmap (no Inkscape required)
Add-Type -AssemblyName System.Drawing

$icons = @(
    @{
        name = "makerpanel-4hp-1u"
        color = @(156, 204, 101)  # Green
        label = "4HP 1U"
    },
    @{
        name = "makerpanel-4hp-2u"
        color = @(255, 167, 38)   # Orange
        label = "4HP 2U"
    },
    @{
        name = "makerpanel-8hp-1u"
        color = @(100, 181, 246)  # Blue
        label = "8HP 1U"
    },
    @{
        name = "makerpanel-8hp-2u"
        color = @(239, 83, 80)    # Red
        label = "8HP 2U"
    }
)

foreach ($icon in $icons) {
    $pngPath = "s:\ws\makerpanel\templates\$($icon.name)\icon.png"
    Write-Host "Creating $($icon.name)..." -ForegroundColor Cyan
    
    # Create 128x128 bitmap
    $png = New-Object System.Drawing.Bitmap(128, 128)
    $g = [System.Drawing.Graphics]::FromImage($png)
    
    # Light gray background
    $g.Clear([System.Drawing.Color]::FromArgb(240, 240, 240))
    
    # Panel rectangle with color
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb($icon.color[0], $icon.color[1], $icon.color[2]))
    
    # Determine dimensions based on template
    if ($icon.name -like "*4hp*1u*") {
        $g.FillRectangle($brush, 40, 32, 48, 64)
        $g.DrawRectangle([System.Drawing.Pen]::Black, 40, 32, 48, 64)
    } elseif ($icon.name -like "*4hp*2u*") {
        $g.FillRectangle($brush, 40, 8, 48, 112)
        $g.DrawRectangle([System.Drawing.Pen]::Black, 40, 8, 48, 112)
    } elseif ($icon.name -like "*8hp*1u*") {
        $g.FillRectangle($brush, 24, 32, 80, 64)
        $g.DrawRectangle([System.Drawing.Pen]::Black, 24, 32, 80, 64)
    } elseif ($icon.name -like "*8hp*2u*") {
        $g.FillRectangle($brush, 24, 8, 80, 112)
        $g.DrawRectangle([System.Drawing.Pen]::Black, 24, 8, 80, 112)
    }
    
    # Draw text label
    $font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    $g.DrawString($icon.label, $font, $whiteBrush, 64, 60, $stringFormat)
    
    # Save PNG
    $png.Save($pngPath)
    $g.Dispose()
    $png.Dispose()
    
    if (Test-Path $pngPath) {
        Write-Host "  [OK] $pngPath" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Failed to create PNG" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Icon generation complete!" -ForegroundColor Cyan
