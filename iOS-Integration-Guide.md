# SoundTouch iOS Integration Guide

This guide shows how to integrate the SoundTouch library into your iOS project after building it.

## Build Process

### Prerequisites
- macOS with Xcode installed
- CMake 3.5 or later
- Xcode Command Line Tools

### Building for iOS

1. **On macOS**, run the build script:
```bash
chmod +x build-ios.sh
./build-ios.sh
```

2. **On Windows**, copy the project to macOS first, then run the build script.

The build will create:
- `install-ios/universal/lib/libSoundTouch.a` - Universal static library
- `install-ios/universal/include/soundtouch/` - Header files

## iOS Project Integration

### 1. Add Library to Xcode Project

1. Drag `libSoundTouch.a` into your Xcode project
2. Add to "Link Binary With Libraries" in Build Phases
3. Add the `include/soundtouch` folder to your project

### 2. Configure Build Settings

In your target's Build Settings:
- **Header Search Paths**: Add path to SoundTouch headers
- **Library Search Paths**: Add path to libSoundTouch.a
- **Other Linker Flags**: Add `-lSoundTouch`

### 3. Create Objective-C++ Wrapper

Create a `.mm` file (Objective-C++) to wrap the C++ library:

```objc
// SoundTouchWrapper.h
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface SoundTouchWrapper : NSObject

- (instancetype)initWithSampleRate:(float)sampleRate channels:(int)channels;
- (void)setTempo:(float)tempo;
- (void)setPitch:(float)pitch;
- (void)setRate:(float)rate;
- (NSData *)processAudio:(NSData *)inputData;
- (void)flush;

@end
```

```objc
// SoundTouchWrapper.mm
#import "SoundTouchWrapper.h"
#include "SoundTouch.h"

using namespace soundtouch;

@interface SoundTouchWrapper ()
@property (nonatomic) SoundTouch *soundTouch;
@end

@implementation SoundTouchWrapper

- (instancetype)initWithSampleRate:(float)sampleRate channels:(int)channels {
    self = [super init];
    if (self) {
        _soundTouch = new SoundTouch();
        _soundTouch->setSampleRate(sampleRate);
        _soundTouch->setChannels(channels);
    }
    return self;
}

- (void)dealloc {
    delete _soundTouch;
}

- (void)setTempo:(float)tempo {
    _soundTouch->setTempo(tempo);
}

- (void)setPitch:(float)pitch {
    _soundTouch->setPitchSemiTones(pitch);
}

- (void)setRate:(float)rate {
    _soundTouch->setRate(rate);
}

- (NSData *)processAudio:(NSData *)inputData {
    const float *inputSamples = (const float *)inputData.bytes;
    int numSamples = (int)(inputData.length / sizeof(float));
    
    // Put samples into SoundTouch
    _soundTouch->putSamples(inputSamples, numSamples / _soundTouch->numChannels());
    
    // Prepare output buffer
    NSMutableData *outputData = [NSMutableData data];
    float outputBuffer[4096];
    
    // Receive processed samples
    int receivedSamples;
    do {
        receivedSamples = _soundTouch->receiveSamples(outputBuffer, 1024);
        if (receivedSamples > 0) {
            [outputData appendBytes:outputBuffer 
                             length:receivedSamples * _soundTouch->numChannels() * sizeof(float)];
        }
    } while (receivedSamples > 0);
    
    return outputData;
}

- (void)flush {
    _soundTouch->flush();
}

@end
```

### 4. Swift Integration

Create a Swift class to use the Objective-C++ wrapper:

```swift
import Foundation
import AVFoundation

class AudioProcessor {
    private let soundTouchWrapper: SoundTouchWrapper
    
    init(sampleRate: Float, channels: Int) {
        soundTouchWrapper = SoundTouchWrapper(sampleRate: sampleRate, channels: Int32(channels))
    }
    
    func setTempo(_ tempo: Float) {
        soundTouchWrapper.setTempo(tempo)
    }
    
    func setPitch(_ pitch: Float) {
        soundTouchWrapper.setPitch(pitch)
    }
    
    func processAudio(_ audioData: Data) -> Data {
        return soundTouchWrapper.processAudio(audioData)
    }
}
```

### 5. Usage Example

```swift
class ViewController: UIViewController {
    private var audioProcessor: AudioProcessor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize for 44.1kHz stereo audio
        audioProcessor = AudioProcessor(sampleRate: 44100, channels: 2)
        
        // Set audio effects
        audioProcessor?.setTempo(1.2)  // 20% faster
        audioProcessor?.setPitch(2.0)  // 2 semitones higher
    }
    
    func processAudioFile() {
        // Your audio processing code here
        // Read audio data, convert to Float32 PCM, process, and play
    }
}
```

## Important Notes

1. **Audio Format**: SoundTouch expects Float32 PCM audio data
2. **Thread Safety**: Create separate SoundTouch instances for different threads
3. **Memory Management**: The Objective-C++ wrapper handles C++ memory management
4. **Performance**: Consider processing audio in background threads for real-time applications

## Build Configurations

The iOS build includes these optimizations:
- ARM NEON SIMD instructions enabled
- Float samples (recommended for iOS)
- Static library linking
- iOS deployment target: 12.0+

## Troubleshooting

### Common Issues:
1. **Linker errors**: Ensure libSoundTouch.a is properly linked
2. **Header not found**: Check Header Search Paths in Build Settings
3. **Architecture mismatch**: Ensure universal library includes required architectures

### Verification:
Check library architectures:
```bash
lipo -info libSoundTouch.a
```

Should show: `arm64 x86_64` for universal iOS support.
