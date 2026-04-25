#!/bin/bash
# Build script for GameUI-Desktop
# Usage: ./build.sh [debug|release]

set -e

MODE="${1:-release}"

echo "Building GameUI-Desktop in $MODE mode..."

# Compile with Odin
if [ "$MODE" = "debug" ]; then
    odin build . -file -debug
else
    odin build . -file
fi

echo "Build complete!"
echo "Output: ./GameUI-Desktop"