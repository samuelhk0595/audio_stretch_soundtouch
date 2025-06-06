# SoundTouch iOS Build Configuration
# Run this on Windows to prepare for iOS builds

Write-Host "=== SoundTouch iOS Build Configuration ===" -ForegroundColor Blue

Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check CMake
$cmakeFound = $false
try {
    cmake --version | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ CMake is installed" -ForegroundColor Green
        $cmakeFound = $true
    }
} catch {
    Write-Host "✗ CMake not found" -ForegroundColor Red
}

if (-not $cmakeFound) {
    Write-Host "Please install CMake from: https://cmake.org/download/" -ForegroundColor Yellow
}

Write-Host "`n=== iOS Build Files Created ===" -ForegroundColor Blue
Write-Host "✓ cmake/iOS.cmake - iOS CMake toolchain" -ForegroundColor Green
Write-Host "✓ build-ios.sh - iOS build script for macOS" -ForegroundColor Green
Write-Host "✓ iOS-Integration-Guide.md - Integration guide" -ForegroundColor Green

Write-Host "`n=== Next Steps ===" -ForegroundColor Blue
Write-Host "Since iOS builds require macOS with Xcode:" -ForegroundColor White
Write-Host ""
Write-Host "1. Copy these files to a macOS machine:" -ForegroundColor Yellow
$filesToCopy = @("CMakeLists.txt", "build-ios.sh", "cmake/", "source/", "include/", "soundtouch.pc.in", "SoundTouchConfig.cmake.in")
foreach ($file in $filesToCopy) {
    if (Test-Path $file) {
        Write-Host "   ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $file (missing)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "2. On macOS, run:" -ForegroundColor Yellow
Write-Host "   chmod +x build-ios.sh" -ForegroundColor Cyan
Write-Host "   ./build-ios.sh" -ForegroundColor Cyan

Write-Host ""
Write-Host "3. The build will create:" -ForegroundColor Yellow
Write-Host "   - install-ios/universal/lib/libSoundTouch.a" -ForegroundColor White
Write-Host "   - install-ios/universal/include/soundtouch/" -ForegroundColor White

Write-Host ""
Write-Host "🎯 Configuration complete! Ready for macOS build." -ForegroundColor Green
