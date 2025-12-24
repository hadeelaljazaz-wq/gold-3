#!/usr/bin/env pwsh
# Script to deploy Gold Nightmare Pro website to Netlify

Write-Host "================================" -ForegroundColor Cyan
Write-Host "  🚀 Netlify Deployment Script" -ForegroundColor Yellow
Write-Host "  Gold Nightmare Pro v3.1.1" -ForegroundColor Yellow
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if web directory exists
if (-not (Test-Path "web")) {
    Write-Host "❌ Error: 'web' directory not found!" -ForegroundColor Red
    exit 1
}

# Check if APK exists
if (-not (Test-Path "web\Gold_Nightmare_Pro_v3.1.1.apk")) {
    Write-Host "⚠️ Warning: APK file not found in web directory!" -ForegroundColor Yellow
    $continue = Read-Host "Continue without APK? (y/N)"
    if ($continue -ne "y") {
        exit 1
    }
}

# Show web directory contents
Write-Host "📁 Web directory contents:" -ForegroundColor Green
Get-ChildItem web | Format-Table Name, Length, LastWriteTime -AutoSize

Write-Host ""
Write-Host "Choose deployment method:" -ForegroundColor Cyan
Write-Host "1. Manual upload (Drag & Drop to Netlify)" -ForegroundColor White
Write-Host "2. Using Netlify CLI (requires netlify-cli installed)" -ForegroundColor White
Write-Host "3. Using Git push (requires Git repository)" -ForegroundColor White
Write-Host "4. Show deployment instructions" -ForegroundColor White
Write-Host "5. Exit" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-5)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "📋 Manual Upload Instructions:" -ForegroundColor Green
        Write-Host "1. Open https://app.netlify.com/" -ForegroundColor White
        Write-Host "2. Login to your account" -ForegroundColor White
        Write-Host "3. Click 'Add new site' → 'Deploy manually'" -ForegroundColor White
        Write-Host "4. Drag the 'web' folder to the upload area" -ForegroundColor White
        Write-Host "5. Wait for deployment to complete" -ForegroundColor White
        Write-Host ""
        Write-Host "Opening web directory..." -ForegroundColor Yellow
        explorer web
    }
    
    "2" {
        Write-Host ""
        Write-Host "🔧 Checking for Netlify CLI..." -ForegroundColor Yellow
        
        $netlify = Get-Command netlify -ErrorAction SilentlyContinue
        
        if ($null -eq $netlify) {
            Write-Host "❌ Netlify CLI not found!" -ForegroundColor Red
            Write-Host ""
            Write-Host "Install it using:" -ForegroundColor Yellow
            Write-Host "  npm install -g netlify-cli" -ForegroundColor Cyan
            Write-Host ""
            $install = Read-Host "Install now? (y/N)"
            if ($install -eq "y") {
                npm install -g netlify-cli
            } else {
                exit 1
            }
        }
        
        Write-Host "✅ Netlify CLI found!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Logging in to Netlify..." -ForegroundColor Yellow
        netlify login
        
        Write-Host ""
        Write-Host "Deploying to Netlify..." -ForegroundColor Yellow
        Set-Location web
        netlify deploy --prod
        Set-Location ..
        
        Write-Host ""
        Write-Host "✅ Deployment complete!" -ForegroundColor Green
    }
    
    "3" {
        Write-Host ""
        Write-Host "📦 Git Deployment Instructions:" -ForegroundColor Green
        Write-Host ""
        Write-Host "1. Initialize Git (if not already):" -ForegroundColor White
        Write-Host "   git init" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "2. Add all files:" -ForegroundColor White
        Write-Host "   git add ." -ForegroundColor Cyan
        Write-Host ""
        Write-Host "3. Commit changes:" -ForegroundColor White
        Write-Host "   git commit -m 'Update website v3.1.1'" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "4. Add remote repository:" -ForegroundColor White
        Write-Host "   git remote add origin YOUR_REPO_URL" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "5. Push to GitHub:" -ForegroundColor White
        Write-Host "   git push -u origin main" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "6. Connect repository in Netlify dashboard" -ForegroundColor White
        Write-Host ""
        
        $continue = Read-Host "Execute git commands now? (y/N)"
        if ($continue -eq "y") {
            if (-not (Test-Path ".git")) {
                git init
                Write-Host "✅ Git repository initialized" -ForegroundColor Green
            }
            
            git add .
            Write-Host "✅ Files staged" -ForegroundColor Green
            
            $message = Read-Host "Enter commit message (or press Enter for default)"
            if ($message -eq "") {
                $message = "Update Gold Nightmare Pro website v3.1.1"
            }
            
            git commit -m $message
            Write-Host "✅ Changes committed" -ForegroundColor Green
            
            Write-Host ""
            Write-Host "Now add your remote repository and push:" -ForegroundColor Yellow
            Write-Host "  git remote add origin YOUR_REPO_URL" -ForegroundColor Cyan
            Write-Host "  git push -u origin main" -ForegroundColor Cyan
        }
    }
    
    "4" {
        Write-Host ""
        Write-Host "📖 Full deployment instructions available in:" -ForegroundColor Green
        Write-Host "   NETLIFY_DEPLOY.md" -ForegroundColor Cyan
        Write-Host ""
        
        $open = Read-Host "Open instructions file? (y/N)"
        if ($open -eq "y") {
            notepad NETLIFY_DEPLOY.md
        }
    }
    
    "5" {
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit 0
    }
    
    default {
        Write-Host "❌ Invalid choice!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✅ Script completed!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📱 Your website: https://skalp-al-kabous.netlify.app" -ForegroundColor Yellow
Write-Host "📞 Telegram: https://t.me/Odai_xau" -ForegroundColor Yellow
Write-Host "📞 WhatsApp: https://wa.me/962786275654" -ForegroundColor Yellow
Write-Host ""


