#!/bin/bash

# Build script for openclose
# Usage: ./build.sh [version]
# If no version is provided, it will try to get it from the latest git tag

set -e

# Get version from argument or git tag
if [ -n "$1" ]; then
    VERSION="$1"
else
    VERSION=$(git describe --tags --exact-match 2>/dev/null || echo "unknown")
fi

echo "Building openclose with version: $VERSION"

# Create build directory
mkdir -p build

# Build with version
odin build src -out:build/openclose -o:speed -vet -strict-style -define:VERSION="$VERSION"

echo "Build complete: build/openclose"
echo ""
echo "Test the version command:"
./build/openclose version
