#!/bin/bash

# SoundTouch iOS Build Script
# This script builds SoundTouch library for iOS devices and simulator

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== SoundTouch iOS Build Script ===${NC}"

# Configuration
IOS_DEPLOYMENT_TARGET="12.0"
PROJECT_ROOT="$(pwd)"
BUILD_DIR="build-ios"
INSTALL_DIR="install-ios"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "${BUILD_DIR}"
rm -rf "${INSTALL_DIR}"

# Create build directories
mkdir -p "${BUILD_DIR}"
mkdir -p "${INSTALL_DIR}"

# Function to build for specific configuration
build_for_config() {
    local config=$1
    local sdk=$2
    local arch=$3
    local build_subdir="${BUILD_DIR}/${config}"
    
    echo -e "${BLUE}Building for ${config} (${arch})...${NC}"
    
    mkdir -p "${build_subdir}"
    cd "${build_subdir}"
    
    # Configure CMake for iOS
    cmake ../.. \
        -DCMAKE_TOOLCHAIN_FILE="${PROJECT_ROOT}/cmake/iOS.cmake" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_OSX_DEPLOYMENT_TARGET="${IOS_DEPLOYMENT_TARGET}" \
        -DCMAKE_OSX_ARCHITECTURES="${arch}" \
        -DCMAKE_INSTALL_PREFIX="${PROJECT_ROOT}/${INSTALL_DIR}/${config}" \
        -DBUILD_SHARED_LIBS=OFF \
        -DSOUNDSTRETCH=OFF \
        -DSOUNDTOUCH_DLL=OFF \
        -DNEON=ON \
        -DOPENMP=OFF \
        -DINTEGER_SAMPLES=OFF
    
    # Build
    cmake --build . --config Release -j$(sysctl -n hw.ncpu)
    
    # Install
    cmake --install . --config Release
    
    cd "${PROJECT_ROOT}"
    echo -e "${GREEN}✓ ${config} build completed${NC}"
}

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error: iOS builds require macOS with Xcode${NC}"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcrun &> /dev/null; then
    echo -e "${RED}Error: Xcode command line tools not found${NC}"
    echo "Please install Xcode and run: xcode-select --install"
    exit 1
fi

# Build for iOS Device (ARM64)
echo -e "${BLUE}=== Building for iOS Device ===${NC}"
build_for_config "iphoneos" "iphoneos" "arm64"

# Build for iOS Simulator (x86_64 and arm64)
echo -e "${BLUE}=== Building for iOS Simulator ===${NC}"
build_for_config "iphonesimulator" "iphonesimulator" "x86_64;arm64"

# Create universal static library
echo -e "${BLUE}=== Creating Universal Library ===${NC}"
mkdir -p "${INSTALL_DIR}/universal/lib"
mkdir -p "${INSTALL_DIR}/universal/include"

# Copy headers (same for all platforms)
cp -r "${INSTALL_DIR}/iphoneos/include/" "${INSTALL_DIR}/universal/include/"

# Create universal library using lipo
lipo -create \
    "${INSTALL_DIR}/iphoneos/lib/libSoundTouch.a" \
    "${INSTALL_DIR}/iphonesimulator/lib/libSoundTouch.a" \
    -output "${INSTALL_DIR}/universal/lib/libSoundTouch.a"

echo -e "${GREEN}✓ Universal library created${NC}"

# Display library info
echo -e "${BLUE}=== Library Information ===${NC}"
echo "Universal library: ${INSTALL_DIR}/universal/lib/libSoundTouch.a"
file "${INSTALL_DIR}/universal/lib/libSoundTouch.a"
lipo -info "${INSTALL_DIR}/universal/lib/libSoundTouch.a"

echo -e "${BLUE}=== Build Summary ===${NC}"
echo -e "${GREEN}✓ iOS Device (arm64): ${INSTALL_DIR}/iphoneos/${NC}"
echo -e "${GREEN}✓ iOS Simulator (x86_64, arm64): ${INSTALL_DIR}/iphonesimulator/${NC}"
echo -e "${GREEN}✓ Universal Library: ${INSTALL_DIR}/universal/${NC}"
echo ""
echo -e "${YELLOW}Headers location: ${INSTALL_DIR}/universal/include/soundtouch/${NC}"
echo -e "${YELLOW}Library location: ${INSTALL_DIR}/universal/lib/libSoundTouch.a${NC}"
echo ""
echo -e "${GREEN}🎉 iOS build completed successfully!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Copy the universal library to your iOS project"
echo "2. Add the headers to your project's include path"
echo "3. Link against the libSoundTouch.a library"
echo "4. Use Objective-C++ (.mm files) to interface with the C++ library"