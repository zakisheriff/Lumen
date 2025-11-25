#!/bin/bash

# Exit on error
set -e

APP_NAME="Lumen"
SCHEME="Lumen"
PROJECT="Lumen.xcodeproj"
BUILD_DIR="./build"
ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR"
DMG_NAME="$APP_NAME.dmg"

# Clean build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Check if project exists in current dir, else check parent
if [ -d "$PROJECT" ]; then
    echo "Found project in current directory"
elif [ -d "../$PROJECT" ]; then
    echo "Found project in parent directory"
    cd ..
else
    echo "Error: Could not find $PROJECT"
    exit 1
fi

echo "Building Archive..."
xcodebuild -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    archive \
    ARCHS=arm64 \
    HEADER_SEARCH_PATHS="/opt/homebrew/include" \
    LIBRARY_SEARCH_PATHS="/opt/homebrew/lib" \
    SWIFT_OBJC_BRIDGING_HEADER="Lumen/Lumen-Bridging-Header.h" \
    OTHER_LDFLAGS="-L/opt/homebrew/lib -lmtp -lusb-1.0" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

echo "Exporting Archive..."
# Note: Since we are not signing, we just copy the app from the archive
cp -R "$ARCHIVE_PATH/Products/Applications/$APP_NAME.app" "$EXPORT_PATH/"

echo "Creating DMG..."
hdiutil create -volname "$APP_NAME" -srcfolder "$EXPORT_PATH/$APP_NAME.app" -ov -format UDZO "$DMG_NAME"

echo "Done! DMG created at $DMG_NAME"
