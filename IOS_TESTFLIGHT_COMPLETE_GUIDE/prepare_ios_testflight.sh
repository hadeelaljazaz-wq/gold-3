#!/bin/bash

# 🚀 iOS TestFlight Preparation Script
# Auto-prepare Flutter project for TestFlight

set -e

echo "════════════════════════════════════════════════════════"
echo "🚀 iOS TestFlight Preparation Script"
echo "════════════════════════════════════════════════════════"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if in Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}❌ Error: Not in a Flutter project directory${NC}"
    echo "Please run this script from your Flutter project root"
    exit 1
fi

echo "✅ Flutter project detected"
echo ""

# Get project info
echo "📋 Please provide the following information:"
echo ""

# App Name
read -p "App Name (e.g., AL KABOUS PRO): " APP_NAME
APP_NAME=${APP_NAME:-"AL KABOUS PRO"}

# Bundle ID
read -p "Bundle ID (e.g., com.yourcompany.goldnightmare): " BUNDLE_ID
if [ -z "$BUNDLE_ID" ]; then
    echo -e "${RED}❌ Bundle ID is required${NC}"
    exit 1
fi

# Version
read -p "Version (default: 1.0.0): " VERSION
VERSION=${VERSION:-"1.0.0"}

# Build Number
read -p "Build Number (default: 1): " BUILD_NUMBER
BUILD_NUMBER=${BUILD_NUMBER:-"1"}

echo ""
echo "════════════════════════════════════════════════════════"
echo "📦 Configuration Summary:"
echo "════════════════════════════════════════════════════════"
echo "App Name: $APP_NAME"
echo "Bundle ID: $BUNDLE_ID"
echo "Version: $VERSION"
echo "Build Number: $BUILD_NUMBER"
echo "════════════════════════════════════════════════════════"
echo ""

read -p "Continue with these settings? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "🔧 Step 1/7: Cleaning project..."
flutter clean
echo -e "${GREEN}✅ Clean complete${NC}"
echo ""

echo "📦 Step 2/7: Getting packages..."
flutter pub get
echo -e "${GREEN}✅ Packages updated${NC}"
echo ""

echo "🔍 Step 3/7: Analyzing code..."
flutter analyze --no-fatal-infos || true
echo -e "${GREEN}✅ Analysis complete${NC}"
echo ""

echo "📝 Step 4/7: Updating pubspec.yaml..."
# Update version in pubspec.yaml
sed -i.bak "s/^version:.*/version: $VERSION+$BUILD_NUMBER/" pubspec.yaml
rm -f pubspec.yaml.bak
echo -e "${GREEN}✅ Version updated to $VERSION+$BUILD_NUMBER${NC}"
echo ""

echo "🍎 Step 5/7: Updating iOS configuration..."

# Update Info.plist
INFO_PLIST="ios/Runner/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    # Backup
    cp "$INFO_PLIST" "${INFO_PLIST}.bak"
    
    # Update display name
    if grep -q "CFBundleDisplayName" "$INFO_PLIST"; then
        sed -i '' "s|<key>CFBundleDisplayName</key>.*|<key>CFBundleDisplayName</key>\n\t<string>$APP_NAME</string>|" "$INFO_PLIST"
    else
        # Add if doesn't exist
        sed -i '' "/<dict>/a\\
\t<key>CFBundleDisplayName</key>\\
\t<string>$APP_NAME</string>" "$INFO_PLIST"
    fi
    
    echo -e "${GREEN}✅ Info.plist updated${NC}"
else
    echo -e "${YELLOW}⚠️  Info.plist not found, skipping...${NC}"
fi

# Update project.pbxproj with Bundle ID
PBXPROJ="ios/Runner.xcodeproj/project.pbxproj"
if [ -f "$PBXPROJ" ]; then
    cp "$PBXPROJ" "${PBXPROJ}.bak"
    sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = .*/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID;/g" "$PBXPROJ"
    echo -e "${GREEN}✅ Bundle ID updated in project.pbxproj${NC}"
else
    echo -e "${YELLOW}⚠️  project.pbxproj not found${NC}"
fi

echo ""

echo "🔨 Step 6/7: Building iOS release..."
flutter build ios --release --no-codesign
echo -e "${GREEN}✅ iOS build complete${NC}"
echo ""

echo "📱 Step 7/7: Installing iOS Pods..."
cd ios
pod install
cd ..
echo -e "${GREEN}✅ Pods installed${NC}"
echo ""

# Create README for next steps
cat > IOS_TESTFLIGHT_NEXT_STEPS.md << ENDOFFILE
# 📱 Next Steps for TestFlight

## ✅ Completed:
- [x] Flutter project cleaned
- [x] Packages updated
- [x] Version set to $VERSION ($BUILD_NUMBER)
- [x] Bundle ID: $BUNDLE_ID
- [x] App Name: $APP_NAME
- [x] iOS release built
- [x] Pods installed

## 🎯 Next Manual Steps:

### Step 1: Open in Xcode
\`\`\`bash
open ios/Runner.xcworkspace
\`\`\`

### Step 2: Configure Signing
1. Select **Runner** in project navigator
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. ✅ Check **Automatically manage signing**
5. Select your **Team** from dropdown
6. Verify **Bundle Identifier**: $BUNDLE_ID

### Step 3: Archive for TestFlight
1. **Product** → **Destination** → **Any iOS Device (arm64)**
2. **Product** → **Archive**
3. Wait for build to complete (5-15 minutes)

### Step 4: Upload to App Store Connect
1. When Organizer opens, select your archive
2. Click **Distribute App**
3. Select **App Store Connect** → **Upload**
4. Click **Next** → **Upload**
5. Wait for upload (5-10 minutes)

### Step 5: Configure TestFlight
1. Go to https://appstoreconnect.apple.com
2. Select your app
3. Go to **TestFlight** tab
4. Wait for build to appear (10-30 minutes)
5. Fill in **What to Test** information
6. Answer **Export Compliance** questions
7. Click **Start Internal Testing**

### Step 6: Add Testers
1. In **TestFlight** → **Internal Testing**
2. Click **+** next to Testers
3. Add Apple IDs of testers (up to 100)
4. Testers will receive email invitations

### Step 7: Test!
Testers should:
1. Install **TestFlight** app from App Store
2. Open invitation email on iPhone
3. Tap **View in TestFlight**
4. Tap **Install**
5. Test the app and provide feedback!

## 📞 Need Help?

- Check: TESTFLIGHT_GUIDE.md (full detailed guide)
- Apple Developer: https://developer.apple.com/support/
- Flutter iOS Deployment: https://docs.flutter.dev/deployment/ios

## 🎉 You're Almost There!

Your project is ready for Xcode. Follow the manual steps above to complete the TestFlight setup.

Good luck! 🚀
ENDOFFILE

echo "════════════════════════════════════════════════════════"
echo -e "${GREEN}🎉 Preparation Complete!${NC}"
echo "════════════════════════════════════════════════════════"
echo ""
echo "✅ Project is ready for TestFlight!"
echo ""
echo "📄 Next steps saved to: IOS_TESTFLIGHT_NEXT_STEPS.md"
echo ""
echo "🎯 Manual steps required:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Configure signing in Xcode"
echo "3. Archive: Product → Archive"
echo "4. Upload to TestFlight"
echo ""
echo "📚 Full guide: TESTFLIGHT_GUIDE.md"
echo ""
echo "════════════════════════════════════════════════════════"

# Open next steps in default editor (optional)
read -p "Open next steps file? (y/n): " OPEN_FILE
if [ "$OPEN_FILE" = "y" ]; then
    open IOS_TESTFLIGHT_NEXT_STEPS.md || cat IOS_TESTFLIGHT_NEXT_STEPS.md
fi
