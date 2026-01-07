#!/bin/bash

# Script to customize macOS app name and metadata
# Usage: ./customize_macos_app.sh <app_name> <manufacturer> <bundle_id_suffix>

APP_NAME="${1:-ANTConnect}"
MANUFACTURER="${2:-Alternate Network Technologies}"
BUNDLE_ID_SUFFIX="${3:-antconnect}"
BUNDLE_ID_PREFIX="${4:-com.alternatenetworktechnologies}"

echo "Customizing macOS app with:"
echo "  App Name: $APP_NAME"
echo "  Manufacturer: $MANUFACTURER"
echo "  Bundle ID: $BUNDLE_ID_PREFIX.$BUNDLE_ID_SUFFIX"

# Update Info.plist
echo "Updating Info.plist..."
# Note: macOS sed requires -i '' for in-place editing
sed -i '' "s/<string>RustDesk<\/string>/<string>$APP_NAME<\/string>/g" flutter/macos/Runner/Info.plist
sed -i '' "s/com\.carriez\.rustdesk/$BUNDLE_ID_PREFIX.$BUNDLE_ID_SUFFIX/g" flutter/macos/Runner/Info.plist
sed -i '' "s/<string>rustdesk<\/string>/<string>$BUNDLE_ID_SUFFIX<\/string>/g" flutter/macos/Runner/Info.plist

# Update project.pbxproj
echo "Updating project.pbxproj..."
sed -i '' "s/RustDesk\.app/$APP_NAME.app/g" flutter/macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/PRODUCT_NAME = \"RustDesk\"/PRODUCT_NAME = \"$APP_NAME\"/g" flutter/macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/productName = RustDesk/productName = $APP_NAME/g" flutter/macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/\"RustDesk\"/\"$APP_NAME\"/g" flutter/macos/Runner.xcodeproj/project.pbxproj
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.carriez\.rustdesk/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID_PREFIX.$BUNDLE_ID_SUFFIX/g" flutter/macos/Runner.xcodeproj/project.pbxproj
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