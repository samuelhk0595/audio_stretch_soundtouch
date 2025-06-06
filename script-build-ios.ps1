# SoundTouch iOS Build Script for Windows
# This PowerShell script helps set up iOS builds when using WSL or cross-compilation tools

param(
    [string]$BuildType = "Release",
    [string]$DeploymentTarget = "12.0"
)

Write-Host "=== SoundTouch iOS Build Configuration ===" -ForegroundColor Blue

# Check if we're on Windows
if ($env:OS -ne "Windows_NT") {
    Write-Host "This script is designed for Windows environments" -ForegroundColor Red
    exit 1
}

Write-Host "Configuring iOS build environment..." -ForegroundColor Yellow

# Configuration variables
$ProjectRoot = Get-Location
$BuildDir = "build-ios"
$InstallDir = "install-ios"

Write-Host "Build configuration:" -ForegroundColor Green
Write-Host "  Build Type: $BuildType" -ForegroundColor White
Write-Host "  iOS Deployment Target: $DeploymentTarget" -ForegroundColor White
Write-Host "  Project Root: $ProjectRoot" -ForegroundColor White

Write-Host "`n=== Prerequisites Check ===" -ForegroundColor Blue

# Check for CMake
try {
    $cmakeVersion = cmake --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ CMake found: $($cmakeVersion[0])" -ForegroundColor Green
    } else {
        throw "CMake not found"
    }
} catch {
    Write-Host "✗ CMake not found. Please install CMake." -ForegroundColor Red
    Write-Host "  Download from: https://cmake.org/download/" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n=== Build Instructions ===" -ForegroundColor Blue
Write-Host "Since you are on Windows, here are your options for iOS builds:" -ForegroundColor White

Write-Host "`n1. Using macOS (Recommended):" -ForegroundColor Yellow
Write-Host "   Copy this project to a macOS machine and run:" -ForegroundColor White
Write-Host "   chmod +x build-ios.sh" -ForegroundColor Cyan
Write-Host "   ./build-ios.sh" -ForegroundColor Cyan

Write-Host "`n2. Using WSL with macOS cross-compilation tools:" -ForegroundColor Yellow
Write-Host "   This requires additional setup and is not recommended for beginners." -ForegroundColor White

Write-Host "`n3. Alternative - Build manually in Xcode:" -ForegroundColor Yellow
Write-Host "   a. Copy this project to macOS" -ForegroundColor White
Write-Host "   b. Create a new Xcode project" -ForegroundColor White
Write-Host "   c. Add all .cpp files from source/SoundTouch/ to your project" -ForegroundColor White
Write-Host "   d. Add all .h files from include/ to your project" -ForegroundColor White
Write-Host "   e. Configure build settings for iOS" -ForegroundColor White

Write-Host "`n=== Files Ready for macOS Build ===" -ForegroundColor Blue
Write-Host "✓ iOS CMake toolchain: cmake/iOS.cmake" -ForegroundColor Green
Write-Host "✓ iOS build script: build-ios.sh" -ForegroundColor Green

Write-Host "`n=== What to Copy to macOS ===" -ForegroundColor Blue
$filesToCopy = @(
    "CMakeLists.txt",
    "build-ios.sh",
    "cmake/iOS.cmake",
    "source/",
    "include/",
    "soundtouch.pc.in",
    "SoundTouchConfig.cmake.in"
)

foreach ($file in $filesToCopy) {
    if (Test-Path $file) {
        Write-Host "✓ $file" -ForegroundColor Green
    } else {
        Write-Host "✗ $file (missing)" -ForegroundColor Red
    }
}

Write-Host "`n=== Build Commands for macOS ===" -ForegroundColor Blue
Write-Host "Once on macOS, run these commands:" -ForegroundColor White
Write-Host "chmod +x build-ios.sh" -ForegroundColor Cyan
Write-Host "./build-ios.sh" -ForegroundColor Cyan

Write-Host "`nOr build manually with CMake:" -ForegroundColor White
Write-Host "mkdir build-ios && cd build-ios" -ForegroundColor Cyan
Write-Host "cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/iOS.cmake -DCMAKE_BUILD_TYPE=Release" -ForegroundColor Cyan
Write-Host "cmake --build . --config Release" -ForegroundColor Cyan

Write-Host "`n🎯 Ready for iOS build on macOS!" -ForegroundColor Green
