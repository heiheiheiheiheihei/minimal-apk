#!/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUTPUT="$ROOT/output"
SRC="$ROOT/src"
BIN="$ROOT/bin"
OBJ="$ROOT/obj"

BUILD_TOOLS="$ANDROID_HOME/build-tools/34.0.0"
ANDROID_JAR="$ANDROID_HOME/platforms/android-34/android.jar"
PACKAGE="com.example.miniapp"
PACKAGE_PATH="com/example/miniapp"
MAIN_CLASS="MainActivity"

rm -rf "$OUTPUT" "$BIN" "$OBJ"
mkdir -p "$OUTPUT" "$BIN" "$OBJ"

echo "=== 1. Generate R.java ==="
"$BUILD_TOOLS/aapt2" compile \
    -o "$OBJ/compiled.flata" \
    "$ROOT/AndroidManifest.xml" 2>/dev/null || true

# Link without R.java (no resources needed)
"$BUILD_TOOLS/aapt2" link \
    -o "$BIN/base.apk" \
    --manifest "$ROOT/AndroidManifest.xml" \
    -I "$ANDROID_JAR" \
    --min-sdk-version 21 \
    --target-sdk-version 34

echo "=== 2. Compile Java ==="
javac -d "$OBJ" \
    -cp "$ANDROID_JAR" \
    -sourcepath "$SRC" \
    -g:none \
    "$SRC/$PACKAGE_PATH/$MAIN_CLASS.java"

echo "=== 3. DEX ==="
"$BUILD_TOOLS/d8" --lib "$ANDROID_JAR" \
    --output "$OBJ" \
    "$OBJ/$PACKAGE_PATH/$MAIN_CLASS.class"

echo "=== 4. Package ==="
cp "$BIN/base.apk" "$OUTPUT/unsigned.apk"
# Add classes.dex to the APK
cd "$OBJ"
zip -q "$OUTPUT/unsigned.apk" classes.dex

echo "=== 5. Sign ==="
# Generate debug keystore
keytool -genkey -v \
    -keystore "$OBJ/debug.keystore" \
    -alias debug \
    -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Debug, OU=Debug, O=Debug, L=Debug, ST=Debug, C=US" \
    -storepass android -keypass android \
    -noprompt 2>/dev/null

"$BUILD_TOOLS/apksigner" sign \
    --ks "$OBJ/debug.keystore" \
    --ks-pass pass:android \
    --ks-key-alias debug \
    --key-pass pass:android \
    --out "$OUTPUT/miniapp.apk" \
    "$OUTPUT/unsigned.apk"

echo "=== Done ==="
ls -lh "$OUTPUT/miniapp.apk"
