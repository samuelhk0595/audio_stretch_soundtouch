#
# Build library bilaries for all supported architectures
#

APP_ABI := arm64-v8a armeabi-v7a x86_64 x86
APP_OPTIM := release
APP_STL := c++_static
APP_CPPFLAGS := -fexceptions -O2 -DNDEBUG
APP_PLATFORM := android-21

