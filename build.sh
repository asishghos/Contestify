#!/bin/bash
# Build script for Vercel deployment

set -e

echo "🔍 Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Installing Flutter..."
    
    # Install Flutter
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$PATH:`pwd`/flutter/bin"
    
    # Verify installation
    flutter doctor
fi

echo "✅ Flutter found: $(flutter --version)"

echo "📦 Installing dependencies..."
cd code_hub
flutter pub get

echo "🏗️ Building web release..."
flutter build web --release

echo "✅ Build complete!"
echo "📁 Output directory: code_hub/build/web"

