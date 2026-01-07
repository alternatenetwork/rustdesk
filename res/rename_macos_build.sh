#!/bin/bash

# Script to rename macOS build outputs
# This script should be run AFTER the build completes

OLD_NAME="RustDesk"
NEW_NAME="ANTConnect"

echo "Renaming macOS build outputs from $OLD_NAME to $NEW_NAME..."

# Check if the app exists
if [ -d "flutter/build/macos/Build/Products/Release/$OLD_NAME.app" ]; then
    # Rename the app bundle
    mv "flutter/build/macos/Build/Products/Release/$OLD_NAME.app" "flutter/build/macos/Build/Products/Release/$NEW_NAME.app"
    
    # Update Info.plist inside the app bundle
    PLIST_PATH="flutter/build/macos/Build/Products/Release/$NEW_NAME.app/Contents/Info.plist"
    if [ -f "$PLIST_PATH" ]; then
        # Use PlistBuddy if available, otherwise use sed
        if command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
            /usr/libexec/PlistBuddy -c "Set :CFBundleName $NEW_NAME" "$PLIST_PATH"
            /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $NEW_NAME" "$PLIST_PATH"
        else
            sed -i '' "s/>$OLD_NAME</>$NEW_NAME</g" "$PLIST_PATH"
        fi
    fi
    
    echo "Successfully renamed $OLD_NAME.app to $NEW_NAME.app"
else
    echo "Error: $OLD_NAME.app not found in expected location"
    exit 1
fi