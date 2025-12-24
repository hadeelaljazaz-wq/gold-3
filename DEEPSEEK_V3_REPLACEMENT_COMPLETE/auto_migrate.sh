#!/bin/bash

# 🔥 Auto Migration Script: Claude → DeepSeek V3.2
# Usage: ./auto_migrate.sh /path/to/your/flutter/project

set -e

PROJECT_PATH="$1"

if [ -z "$PROJECT_PATH" ]; then
    echo "❌ Error: Project path required"
    echo "Usage: ./auto_migrate.sh /path/to/your/flutter/project"
    exit 1
fi

if [ ! -d "$PROJECT_PATH" ]; then
    echo "❌ Error: Project path does not exist: $PROJECT_PATH"
    exit 1
fi

echo "🔥 Starting Claude → DeepSeek V3.2 Migration"
echo "═══════════════════════════════════════════"
echo "Project: $PROJECT_PATH"
echo ""

# Step 1: Backup
echo "📦 Step 1/7: Creating backup..."
BACKUP_DIR="$PROJECT_PATH/backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r "$PROJECT_PATH/lib/services" "$BACKUP_DIR/" 2>/dev/null || true
echo "✅ Backup created: $BACKUP_DIR"
echo ""

# Step 2: Copy DeepSeek service
echo "📁 Step 2/7: Copying DeepSeek service..."
cp deepseek_service.dart "$PROJECT_PATH/lib/services/"
echo "✅ DeepSeek service copied"
echo ""

# Step 3: Rename old service
echo "🔄 Step 3/7: Renaming old Anthropic service..."
if [ -f "$PROJECT_PATH/lib/services/anthropic_service.dart" ]; then
    mv "$PROJECT_PATH/lib/services/anthropic_service.dart" \
       "$PROJECT_PATH/lib/services/anthropic_service_old_backup.dart"
    echo "✅ Old service renamed to: anthropic_service_old_backup.dart"
else
    echo "⚠️ anthropic_service.dart not found (maybe already migrated?)"
fi
echo ""

# Step 4: Update imports
echo "🔧 Step 4/7: Updating imports..."
find "$PROJECT_PATH/lib" -name "*.dart" -type f -exec sed -i.bak \
    "s/anthropic_service\.dart/deepseek_service.dart/g" {} \;
echo "✅ Imports updated"
echo ""

# Step 5: Update class names
echo "🔧 Step 5/7: Updating class names..."
find "$PROJECT_PATH/lib" -name "*.dart" -type f -exec sed -i.bak \
    "s/AnthropicServicePro/DeepSeekService/g" {} \;
echo "✅ Class names updated"
echo ""

# Step 6: Clean backup files
echo "🧹 Step 6/7: Cleaning backup files..."
find "$PROJECT_PATH/lib" -name "*.bak" -type f -delete
echo "✅ Backup files cleaned"
echo ""

# Step 7: Update main.dart
echo "📝 Step 7/7: Checking main.dart..."
MAIN_FILE="$PROJECT_PATH/lib/main.dart"
if [ -f "$MAIN_FILE" ]; then
    echo "⚠️ Please manually add to main.dart:"
    echo ""
    echo "  DeepSeekService.initialize('YOUR_OPENROUTER_API_KEY');"
    echo ""
    echo "Example:"
    echo "  void main() async {"
    echo "    WidgetsFlutterBinding.ensureInitialized();"
    echo "    DeepSeekService.initialize('sk-or-v1-...');"
    echo "    runApp(MyApp());"
    echo "  }"
else
    echo "⚠️ main.dart not found in expected location"
fi
echo ""

# Final steps
echo "═══════════════════════════════════════════"
echo "✅ Migration complete!"
echo ""
echo "📋 Next steps:"
echo "1. Get FREE API key from: https://openrouter.ai"
echo "2. Update main.dart with: DeepSeekService.initialize('YOUR_KEY')"
echo "3. Run: cd $PROJECT_PATH && flutter clean && flutter pub get"
echo "4. Test: flutter run"
echo ""
echo "💰 You're now using DeepSeek V3.2 (FREE!)"
echo "📊 Old code backed up in: $BACKUP_DIR"
echo ""
