#!/bin/bash

# Script to customize macOS app name and metadata
# Usage: ./customize_macos_app.sh <app_name> <manufacturer>

APP_NAME="${1:-ANTConnect}"
MANUFACTURER="${2:-Alternate Network Technologies}"

echo "Customizing macOS app with:"
echo "  App Name: $APP_NAME"
echo "  Manufacturer: $MANUFACTURER"
echo "  Bundle ID: com.carriez.rustdesk (keeping original)"
echo ""
echo "Note: The app will be renamed post-build to avoid build system conflicts"

# For now, just update the copyright since renaming during build causes issues
# The actual app renaming happens after the build completes
echo "Updating copyright information..."
sed -i '' "s/PRODUCT_COPYRIGHT = \"Copyright © [^\"]*\"/PRODUCT_COPYRIGHT = \"Copyright © $(date +%Y) $MANUFACTURER\"/g" flutter/macos/Runner.xcodeproj/project.pbxproj

echo "macOS app customization complete!"