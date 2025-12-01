#!/bin/bash
set -e

# Configuration
ANDROID_SDK_ROOT=${ANDROID_HOME:-$HOME/Library/Android/sdk}
BUILD_TOOLS_DIR=$(ls -d "$ANDROID_SDK_ROOT/build-tools/"* | sort -V | tail -n 1)
AAPT2="$BUILD_TOOLS_DIR/aapt2"
APKSIGNER="$BUILD_TOOLS_DIR/apksigner"
ANDROID_JAR="$ANDROID_SDK_ROOT/platforms/$(ls "$ANDROID_SDK_ROOT/platforms/" | sort -V | tail -n 1)/android.jar"

# Output
OUT_DIR="build"
APK_NAME="DisableCloverKeyboxOverlay.apk"
UNSIGNED_APK="$OUT_DIR/$APK_NAME.unsigned"
SIGNED_APK="$OUT_DIR/$APK_NAME"

# Check tools
if [ ! -f "$AAPT2" ]; then
    echo "Error: aapt2 not found at $AAPT2"
    echo "Please set ANDROID_HOME or ensure Android SDK build-tools are installed."
    exit 1
fi

if [ ! -f "$ANDROID_JAR" ]; then
    echo "Error: android.jar not found at $ANDROID_JAR"
    echo "Please ensure Android SDK platforms are installed."
    exit 1
fi

echo "Using build-tools: $BUILD_TOOLS_DIR"
echo "Using platform: $ANDROID_JAR"

# Clean and Prepare
rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR/gen"

# 1. Compile resources
echo "Compiling resources..."
"$AAPT2" compile --dir res -o "$OUT_DIR/resources.zip"

# 2. Link APK
echo "Linking APK..."
"$AAPT2" link -o "$UNSIGNED_APK" \
    -I "$ANDROID_JAR" \
    --manifest AndroidManifest.xml \
    "$OUT_DIR/resources.zip"

# 3. Sign APK (using debug key)
echo "Signing APK..."
# Generate a dummy key if needed, or use apksigner with a debug key
# For simplicity, we'll use a debug keystore if available, or generate one.
KEYSTORE="$OUT_DIR/debug.keystore"
keytool -genkey -v -keystore "$KEYSTORE" -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"

"$APKSIGNER" sign --ks "$KEYSTORE" --ks-pass pass:android --key-pass pass:android --out "$SIGNED_APK" "$UNSIGNED_APK"

echo "Build complete: $SIGNED_APK"
echo "You can now push this to your device or include it in the Magisk module."
