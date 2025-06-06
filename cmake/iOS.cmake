# iOS CMake Toolchain File
# This file configures CMake for cross-compiling to iOS

set(CMAKE_SYSTEM_NAME iOS)
set(CMAKE_SYSTEM_VERSION 12.0)

# Set the architectures for iOS
# For universal build (device + simulator)
set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")

# iOS deployment target - minimum iOS version supported
set(CMAKE_OSX_DEPLOYMENT_TARGET "12.0")

# Set the iOS SDK path
execute_process(
    COMMAND xcrun --sdk iphoneos --show-sdk-path
    OUTPUT_VARIABLE CMAKE_OSX_SYSROOT
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

# Set compiler flags for iOS
set(CMAKE_C_FLAGS_INIT "-fembed-bitcode")
set(CMAKE_CXX_FLAGS_INIT "-fembed-bitcode")

# Configure for static library builds (recommended for iOS)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libraries" FORCE)

# Disable command line utility for iOS (not needed)
set(SOUNDSTRETCH OFF CACHE BOOL "Build soundstretch utility" FORCE)

# Disable DLL for iOS (not applicable)
set(SOUNDTOUCH_DLL OFF CACHE BOOL "Build SoundTouchDLL" FORCE)

# Enable ARM NEON optimizations for iOS devices
set(NEON ON CACHE BOOL "Use ARM Neon SIMD instructions" FORCE)

# Disable OpenMP for iOS (not typically available)
set(OPENMP OFF CACHE BOOL "Use OpenMP" FORCE)

# Use float samples (recommended for iOS audio processing)
set(INTEGER_SAMPLES OFF CACHE BOOL "Use integer samples" FORCE)

# iOS specific compiler and linker settings
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Set the install prefix for iOS builds
set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/install" CACHE PATH "Install prefix")

# Additional iOS-specific flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mios-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mios-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET}")

# Disable some optimizations that might cause issues on iOS
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fno-common")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-common")

message(STATUS "Configuring for iOS build")
message(STATUS "iOS SDK Path: ${CMAKE_OSX_SYSROOT}")
message(STATUS "iOS Architectures: ${CMAKE_OSX_ARCHITECTURES}")
message(STATUS "iOS Deployment Target: ${CMAKE_OSX_DEPLOYMENT_TARGET}")