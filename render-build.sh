#!/bin/bash
set -e

echo "🔨 Building Flutter Web with environment variables for Render..."
echo "=================================================="

# Install Flutter if not present
if ! command -v flutter &> /dev/null; then
    echo "📥 Flutter not found. Installing Flutter SDK..."
    
    # Clone Flutter SDK to local directory (stable channel)
    FLUTTER_HOME="$HOME/flutter"
    
    if [ ! -d "$FLUTTER_HOME" ]; then
        echo "📥 Cloning Flutter SDK..."
        git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_HOME"
    fi
    
    # Add Flutter to PATH
    export PATH="$FLUTTER_HOME/bin:$PATH"
    
    # Pre-download Flutter artifacts
    echo "⬇️  Downloading Flutter artifacts..."
    flutter precache --web
    
    echo "✅ Flutter installed successfully!"
else
    echo "✅ Flutter already installed"
    export PATH="$PATH:$(which flutter | xargs dirname)"
fi

# Print Flutter version
echo "📱 Flutter version:"
flutter --version

# Disable analytics (optional, for cleaner output)
flutter config --no-analytics

# Clean previous build (if any)
echo "🧹 Cleaning previous build..."
flutter clean || true

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build with --dart-define to pass API keys from Render environment variables
echo "🏗️  Building web app with environment variables..."
echo "   GOLD_PRICE_API_KEY: ${GOLD_PRICE_API_KEY:0:20}..."
echo "   ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY:0:20}..."

flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=GOLD_PRICE_API_KEY="${GOLD_PRICE_API_KEY:-}" \
  --dart-define=ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY:-}" \
  --dart-define=TWELVE_DATA_API_KEY="${TWELVE_DATA_API_KEY:-}" \
  --dart-define=OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-}" \
  --dart-define=GOLD_PRICE_BASE_URL="${GOLD_PRICE_BASE_URL:-https://www.goldapi.io/api}"

echo "=================================================="
echo "✅ Build complete!"
echo "📁 Output directory: build/web/"
echo "=================================================="

# Verify critical files exist
if [ -f "build/web/index.html" ] && [ -f "build/web/main.dart.js" ]; then
    echo "✅ Build verification passed!"
    echo "📋 Build output files:"
    ls -lh build/web/ | head -n 20
else
    echo "❌ Build verification failed! Missing critical files."
    exit 1
fi

