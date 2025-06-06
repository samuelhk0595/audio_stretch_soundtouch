LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../include $(LOCAL_PATH)/../../SoundStretch
# *** Remember: Change -O0 into -O2 in add-applications.mk ***

LOCAL_MODULE    := soundtouch
LOCAL_SRC_FILES := soundtouch-jni.cpp soundtouch-ffi.cpp ../../SoundTouch/AAFilter.cpp  ../../SoundTouch/FIFOSampleBuffer.cpp \
                ../../SoundTouch/FIRFilter.cpp ../../SoundTouch/cpu_detect_x86.cpp \
                ../../SoundTouch/sse_optimized.cpp ../../SoundStretch/WavFile.cpp \
                ../../SoundTouch/RateTransposer.cpp ../../SoundTouch/SoundTouch.cpp \
                ../../SoundTouch/InterpolateCubic.cpp ../../SoundTouch/InterpolateLinear.cpp \
                ../../SoundTouch/InterpolateShannon.cpp ../../SoundTouch/TDStretch.cpp \
                ../../SoundTouch/BPMDetect.cpp ../../SoundTouch/PeakFinder.cpp 

# for logging
LOCAL_LDLIBS    += -llog -ldl

# Disable OpenMP by commenting out these flags
#LOCAL_CFLAGS += -fopenmp
#LOCAL_LDFLAGS += -fopenmp

# Custom Flags: 
# -fvisibility=hidden : don't export all symbols
LOCAL_CFLAGS += -fvisibility=hidden -fdata-sections -ffunction-sections -ffast-math

# Disable OpenMP support to avoid dependency on libomp.so
LOCAL_CFLAGS += -DSOUNDTOUCH_DISABLE_OPENMP

# Enable NEON optimization for ARM
LOCAL_CFLAGS += -DANDROID_ARM_NEON=ON

# Use ARM instruction set instead of Thumb for improved calculation performance in ARM CPUs	
LOCAL_ARM_MODE := arm

include $(BUILD_SHARED_LIBRARY)
