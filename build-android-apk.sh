#!/usr/bin/env bash
# ==============================================================================
# Build Standalone Android APK / AAB using Google's Official Bubblewrap CLI
# ==============================================================================

echo "=== Packaging E-Invoice Extractor for Android ==="

# Check Node.js & Bubblewrap CLI
if ! command -v bubblewrap &> /dev/null; then
    echo "Installing @bubblewrap/cli..."
    npm install -g @bubblewrap/cli
fi

# Initialize Bubblewrap project from web manifest
bubblewrap init --manifest="https://ais-dev-da3u6el3da7a5gm4bgr7uu-96805081502.asia-southeast1.run.app/manifest.webmanifest"

# Build signed APK and Android App Bundle (.aab)
bubblewrap build

echo "=== Build Complete! ==="
echo "Your signed APK is in: ./app-release-signed.apk"
echo "You can sideload this APK directly to any Android device with 'adb install app-release-signed.apk'"
