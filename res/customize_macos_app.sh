#!/bin/bash

# Script to customize macOS app name and metadata
# Usage: ./customize_macos_app.sh <app_name> <manufacturer>

APP_NAME="${1:-ANTConnect}"
MANUFACTURER="${2:-Alternate Network Technologies}"
BUNDLE_ID="com.carriez.ANTConnect"

echo "Customizing macOS app with:"
echo "  App Name: $APP_NAME"
echo "  Manufacturer: $MANUFACTURER"
echo "  Bundle ID: $BUNDLE_ID"
echo ""
echo "Note: The app will be renamed post-build to avoid build system conflicts"

# Update bundle ID in Info.plist (this should work fine pre-build)
echo "Updating bundle identifier..."
sed -i '' "s/com\.carriez\.rustdesk/$BUNDLE_ID/g" flutter/macos/Runner/Info.plist

# Update bundle ID in project.pbxproj
sed -i '' "s/PRODUCT_BUNDLE_IDENTIFIER = com\.carriez\.rustdesk/PRODUCT_BUNDLE_IDENTIFIER = $BUNDLE_ID/g" flutter/macos/Runner.xcodeproj/project.pbxproj

# Update copyright information
echo "Updating copyright information..."
sed -i '' "s/PRODUCT_COPYRIGHT = \"Copyright © [^\"]*\"/PRODUCT_COPYRIGHT = \"Copyright © $(date +%Y) $MANUFACTURER\"/g" flutter/macos/Runner.xcodeproj/project.pbxproj

echo "macOS app customization complete!"