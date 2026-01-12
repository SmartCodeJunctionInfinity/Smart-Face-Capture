# Smart Face Capture

A Flutter package for guided face photo capture with automatic pose detection. This package provides a reusable widget that captures mandatory front, left, and right face images using real-time face detection and head pose tracking, with support for optional custom capture steps.

## Features

- ✅ **Automatic Pose Detection**: Uses Google ML Kit to detect face orientation and head pose
- ✅ **Guided Capture Flow**: Step-by-step instructions for front, left, and right poses
- ✅ **Auto-Capture**: Automatically captures images when the correct pose is detected
- ✅ **Single Face Validation**: Ensures exactly one face is detected before capture
- ✅ **Custom Captures**: Support for additional custom capture steps with manual control
- ✅ **On-Device Processing**: All processing happens on-device, no server required
- ✅ **Cooldown Period**: 1.5 second cooldown between automatic captures
- ✅ **Cross-Platform**: Works on both iOS and Android

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  smart_face_capture: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Platform Configuration

### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Camera permission -->
    <uses-permission android:name="android.permission.CAMERA" />
    
    <!-- Storage permissions for saving images -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    
    <!-- Camera features -->
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
    
    <application>
        <!-- ... your app configuration ... -->
        
        <!-- ML Kit metadata -->
        <meta-data
            android:name="com.google.mlkit.vision.DEPENDENCIES"
            android:value="face" />
    </application>
</manifest>
```

**Minimum SDK Version**: Set `minSdkVersion` to at least 21 in `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

**Runtime Permissions**: The package handles runtime camera permissions automatically on Android 6.0+. However, you may want to add permission request handling in your app for better UX.

### iOS

Add camera usage description to your `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture face photos for verification purposes.</string>
```

**Minimum iOS Version**: Set the minimum deployment target to iOS 12.0 or higher in your `ios/Podfile`:

```ruby
platform :ios, '12.0'
```

## Usage

### Basic Usage (Mandatory Captures Only)

The simplest usage captures only the three mandatory face poses:

```dart
import 'package:flutter/material.dart';
import 'package:smart_face_capture/smart_face_capture.dart';

class FaceCaptureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartFaceCaptureView(
        onCompleted: (capturedFiles) {
          // capturedFiles[0] = Front face
          // capturedFiles[1] = Left face
          // capturedFiles[2] = Right face
          print('Captured ${capturedFiles.length} images');
          
          // Process the captured images
          // e.g., upload to server, save locally, etc.
        },
      ),
    );
  }
}
```

### Advanced Usage (With Custom Captures)

Add custom capture steps after the mandatory captures:

```dart
SmartFaceCaptureView(
  customCaptures: [
    CustomCaptureRequest(
      id: 'smile',
      label: 'Smile',
      instructionText: 'Please smile for the camera',
    ),
    CustomCaptureRequest(
      id: 'id_card',
      label: 'ID Card',
      instructionText: 'Hold your ID card next to your face',
    ),
  ],
  initialCamera: CameraLensDirection.front,
  onCompleted: (capturedFiles) {
    // capturedFiles[0] = Front face
    // capturedFiles[1] = Left face
    // capturedFiles[2] = Right face
    // capturedFiles[3] = Smile (custom)
    // capturedFiles[4] = ID Card (custom)
    
    for (var i = 0; i < capturedFiles.length; i++) {
      print('Image $i: ${capturedFiles[i].path}');
    }
  },
)
```

## How It Works

### Mandatory Capture Flow

1. **Front Face**: User must look straight at the camera (yaw angle between -15° and +15°)
2. **Left Face**: User must turn their head left (yaw angle > +20°)
3. **Right Face**: User must turn their head right (yaw angle < -20°)

For each mandatory step:
- The system continuously detects faces and head pose
- When exactly one face is detected with the correct pose, it automatically captures the image
- A 1.5 second cooldown prevents multiple captures
- The captured image is saved as an XFile
- The system moves to the next step

### Face Validation Rules

For all capture steps, the following rules apply:

- **Exactly One Face**: Only one face must be detected in the frame
- **Face Size**: The face must be large enough (at least 10% of the frame)
- **Status Messages**:
  - "No face detected" - No face in frame
  - "Multiple faces detected" - More than one face in frame
  - "Move closer" - Face detected but too far away
  - "Hold steady..." - Correct pose detected, capturing

### Custom Capture Flow

After completing the mandatory captures:

- Display custom instruction text
- Apply same single-face validation rules
- No automatic pose detection
- User presses manual capture button to take photo
- User can skip remaining custom captures using the Skip button

## Returned XFile List Format

The `onCompleted` callback receives a `List<XFile>` in the following order:

| Index | Description |
|-------|-------------|
| 0 | Front face (mandatory) |
| 1 | Left face (mandatory) |
| 2 | Right face (mandatory) |
| 3+ | Custom captures (in the order provided) |

Each `XFile` contains:
- `path`: Absolute file path to the captured image
- `name`: File name
- Methods to read bytes, length, etc.

Images are saved to temporary storage and compressed to approximately 300KB.

## API Reference

### SmartFaceCaptureView

The main widget for face capture.

**Properties:**

- `customCaptures` (List<CustomCaptureRequest>, optional): List of custom capture requests to perform after mandatory captures. Default: empty list.

- `initialCamera` (CameraLensDirection, optional): Initial camera lens direction. Default: `CameraLensDirection.front`.

- `onCompleted` (Function(List<XFile>), required): Callback invoked when all captures are completed. Receives list of captured image files.

### CustomCaptureRequest

Represents a custom capture step.

**Properties:**

- `id` (String, required): Unique identifier for this custom capture
- `label` (String, required): Label displayed in the UI
- `instructionText` (String, required): Detailed instruction text shown to the user

## Performance Notes

- **On-Device Processing**: All face detection and processing happens on-device using Google ML Kit
- **No Network Required**: Package works completely offline
- **Image Compression**: Captured images are compressed to approximately 300KB for reasonable file size
- **Resource Management**: Camera and ML Kit resources are properly disposed when done
- **Frame Processing**: Face detection runs on camera frames with automatic throttling to prevent overload

## Example App

A complete example app is included in the `example` folder. To run it:

```bash
cd example
flutter run
```

The example demonstrates:
- Basic mandatory captures (front, left, right)
- Custom capture steps with manual control
- Displaying captured images after completion

## Troubleshooting

### Camera Permission Denied

Make sure you've added the required permissions to your AndroidManifest.xml (Android) and Info.plist (iOS). On Android, you may need to request permissions at runtime.

### ML Kit Initialization Failed

Ensure you've added the ML Kit metadata to your AndroidManifest.xml:

```xml
<meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="face" />
```

### Face Detection Not Working

- Ensure there's adequate lighting
- Position face within the circular guide
- Make sure only one person is in frame
- Check that the camera has autofocus enabled

### Build Errors on iOS

Make sure your iOS deployment target is set to 12.0 or higher in your Podfile and Xcode project settings.

## Requirements

- Flutter SDK: >=3.0.0
- Dart SDK: >=3.0.0 <4.0.0
- Android: minSdkVersion 21 (Android 5.0)
- iOS: iOS 12.0 or higher

## Dependencies

- `camera`: ^0.10.5+5
- `google_mlkit_face_detection`: ^0.9.0
- `path_provider`: ^2.1.1

## License

See the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## Support

For issues, questions, or suggestions, please file an issue on the GitHub repository.
