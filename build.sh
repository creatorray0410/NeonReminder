#!/bin/bash
# NeonReminder Build Script
# Usage: ./build.sh [debug|release]

set -e

MODE=${1:-release}
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="NeonReminder"
APP_BUNDLE="$PROJECT_DIR/$APP_NAME.app"

echo "🔨 Building NeonReminder ($MODE)..."

cd "$PROJECT_DIR"

if [ "$MODE" = "release" ]; then
    swift build -c release
    BINARY=".build/arm64-apple-macosx/release/$APP_NAME"
else
    swift build
    BINARY=".build/arm64-apple-macosx/debug/$APP_NAME"
fi

echo "📦 Creating app bundle..."

mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

cp "$BINARY" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
chmod +x "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

echo "✅ Build complete! App bundle at: $APP_BUNDLE"
echo "   Run with: open $APP_BUNDLE"
