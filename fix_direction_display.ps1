# 🔧 Fix Direction Display - Windows PowerShell Script
# Usage: .\fix_direction_display.ps1

Write-Host "🔧 Fixing direction display on Windows..." -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Stop"

function Fix-File {
    param(
        [string]$FilePath,
        [int]$LineNumber,
        [string]$NewText
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "❌ File not found: $FilePath" -ForegroundColor Red
        return
    }
    
    # Read all lines
    $lines = Get-Content $FilePath
    
    # Check if already fixed
    if ($lines[$LineNumber - 1] -match [regex]::Escape($NewText)) {
        Write-Host "⚠️  Already fixed: $FilePath (line $LineNumber)" -ForegroundColor Yellow
        return
    }
    
    # Make backup
    Copy-Item $FilePath "$FilePath.backup" -Force
    
    # Fix the line
    $lines[$LineNumber - 1] = "            $NewText"
    
    # Save
    $lines | Set-Content $FilePath -Encoding UTF8
    
    Write-Host "✅ Fixed: $FilePath (line $LineNumber)" -ForegroundColor Green
}

# 1️⃣ royal_scalp_card.dart
Write-Host "1️⃣ Fixing royal_scalp_card.dart..."
Fix-File `
    -FilePath "lib\features\unified_analysis\widgets\royal_scalp_card.dart" `
    -LineNumber 170 `
    -NewText "direction == 'BUY' ? 'شراء' : 'بيع',"

# 2️⃣ royal_swing_card.dart
Write-Host "2️⃣ Fixing royal_swing_card.dart..."
Fix-File `
    -FilePath "lib\features\unified_analysis\widgets\royal_swing_card.dart" `
    -LineNumber 179 `
    -NewText "direction == 'BUY' ? 'شراء' : direction == 'SELL' ? 'بيع' : direction,"

# 3️⃣ advanced_scalp_card.dart
Write-Host "3️⃣ Fixing advanced_scalp_card.dart..."
Fix-File `
    -FilePath "lib\features\unified_analysis\widgets\advanced_scalp_card.dart" `
    -LineNumber 177 `
    -NewText "direction == 'BUY' ? 'شراء' : 'بيع',"

# 4️⃣ kabous_master_engine.dart
Write-Host "4️⃣ Fixing kabous_master_engine.dart..."
$engineFile = "lib\services\kabous_master_engine.dart"

if (Test-Path $engineFile) {
    $content = Get-Content $engineFile -Raw
    
    if ($content -match "تحت الستوب → بيع") {
        Write-Host "⚠️  Already fixed: $engineFile" -ForegroundColor Yellow
    }
    elseif ($content -match "فوق الستوب → بيع") {
        Copy-Item $engineFile "$engineFile.backup" -Force
        
        $content = $content -replace `
            "direction == 'BUY' \? 'فوق الستوب → بيع' : 'تحت الستوب → شراء'", `
            "direction == 'BUY' ? 'تحت الستوب → بيع' : 'فوق الستوب → شراء'"
        
        $content | Set-Content $engineFile -Encoding UTF8 -NoNewline
        
        Write-Host "✅ Fixed: $engineFile" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  Pattern not found in: $engineFile" -ForegroundColor Yellow
    }
}
else {
    Write-Host "❌ File not found: $engineFile" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Direction display fix completed!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "  ✅ Fixed 4 files" -ForegroundColor Green
Write-Host "  💾 Backups created (*.backup)" -ForegroundColor Yellow
Write-Host ""
Write-Host "🚀 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Run: flutter run"
Write-Host "  2. Test the app"
Write-Host "  3. If everything works, delete .backup files"
Write-Host ""
