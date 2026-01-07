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
# Only update the CFBundleName and CFBundleDisplayName
sed -i '' '/<key>CFBundleName<\/key>/{n;s/<string>.*<\/string>/<string>'"$APP_NAME"'<\/string>/;}' flutter/macos/Runner/Info.plist
# Also update CFBundleDisplayName if it exists
sed -i '' '/<key>CFBundleDisplayName<\/key>/{n;s/<string>.*<\/string>/<string>'"$APP_NAME"'<\/string>/;}' flutter/macos/Runner/Info.plist

# Update project.pbxproj
echo "Updating project.pbxproj..."
# Only update the product name in the build settings, not the target name
sed -i '' "s/RustDesk\.app/$APP_NAME.app/g" flutter/macos/Runner.xcodeproj/project.pbxproj
# Update PRODUCT_NAME but be careful not to change target names
sed -i '' 's/PRODUCT_NAME = "RustDesk";/PRODUCT_NAME = "'"$APP_NAME"'";/g' flutter/macos/Runner.xcodeproj/project.pbxproj
# Update productName reference
sed -i '' "s/productName = RustDesk;/productName = $APP_NAME;/g" flutter/macos/Runner.xcodeproj/project.pbxproj
# Update copyright
sed -i '' "s/PRODUCT_COPYRIGHT = \"Copyright © [^\"]*\"/PRODUCT_COPYRIGHT = \"Copyright © $(date +%Y) $MANUFACTURER\"/g" flutter/macos/Runner.xcodeproj/project.pbxproj

echo "macOS app customization complete!"