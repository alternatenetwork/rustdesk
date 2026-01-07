#!/bin/bash

# Script to customize macOS app name and metadata
# Usage: ./customize_macos_app.sh <app_name> <manufacturer>

APP_NAME="${1:-ANTConnect}"
MANUFACTURER="${2:-Alternate Network Technologies}"

echo "Customizing macOS app with:"
echo "  App Name: $APP_NAME"
echo "  Manufacturer: $MANUFACTURER"
echo "  Bundle ID: com.carriez.rustdesk (keeping original)"

# Update Info.plist
echo "Updating Info.plist..."
# Note: macOS sed requires -i '' for in-place editing
# Only update the app name, keep the bundle ID and URL scheme as is
sed -i '' "s/<string>RustDesk<\/string>/<string>$APP_NAME<\/string>/g" flutter/macos/Runner/Info.plist

# Update project.pbxproj
echo "Updating project.pbxproj..."
sed -i '' "s/RustDesk\.app/$APP_NAME.app/g" flutter/macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/PRODUCT_NAME = \"RustDesk\"/PRODUCT_NAME = \"$APP_NAME\"/g" flutter/macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/productName = RustDesk/productName = $APP_NAME/g" flutter/macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/\"RustDesk\"/\"$APP_NAME\"/g" flutter/macos/Runner.xcodeproj/project.pbxproj
# Keep the original bundle identifier - don't change it
sed -i '' "s/PRODUCT_COPYRIGHT = \"Copyright © [^\"]*\"/PRODUCT_COPYRIGHT = \"Copyright © $(date +%Y) $MANUFACTURER\"/g" flutter/macos/Runner.xcodeproj/project.pbxproj

# Update Runner.xcworkspace if needed
if [ -f "flutter/macos/Runner.xcworkspace/contents.xcworkspacedata" ]; then
    echo "Updating Runner.xcworkspace..."
    sed -i '' "s/RustDesk\.xcodeproj/$APP_NAME.xcodeproj/g" flutter/macos/Runner.xcworkspace/contents.xcworkspacedata
fi

# Update Podfile if needed
if [ -f "flutter/macos/Podfile" ]; then
    echo "Updating Podfile..."
    sed -i '' "s/target 'Runner'/target '$APP_NAME'/g" flutter/macos/Podfile 2>/dev/null || true
fi

echo "macOS app customization complete!"