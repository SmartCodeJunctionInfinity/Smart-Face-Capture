/// Smart Face Capture - A Flutter package for guided face photo capture.
/// 
/// This package provides a reusable widget for capturing guided face photos
/// with automatic pose detection. It captures mandatory front, left, and right
/// face images, with support for optional custom capture steps.
/// 
/// ## Features
/// 
/// - **Automatic Pose Detection**: Uses Google ML Kit to detect face orientation
/// - **Guided Capture Flow**: Step-by-step instructions for front, left, right poses
/// - **Custom Captures**: Support for additional custom capture steps
/// - **On-Device Processing**: All processing happens on-device, no server required
/// - **Single Face Validation**: Ensures exactly one face is detected before capture
/// - **Cooldown Period**: 1.5 second cooldown between automatic captures
/// 
/// ## Usage
/// 
/// ```dart
/// import 'package:smart_face_capture/smart_face_capture.dart';
/// 
/// SmartFaceCaptureView(
///   customCaptures: [
///     CustomCaptureRequest(
///       id: 'smile',
///       label: 'Smile',
///       instructionText: 'Please smile for the camera',
///     ),
///   ],
///   onCompleted: (capturedFiles) {
///     // Process captured images
///     // capturedFiles[0] = Front
///     // capturedFiles[1] = Left
///     // capturedFiles[2] = Right
///     // capturedFiles[3] = Custom (smile)
///   },
/// )
/// ```
library smart_face_capture;

// Export models
export 'src/models.dart' show CustomCaptureRequest;

// Export main widget
export 'src/smart_face_view.dart' show SmartFaceCaptureView;

// Re-export necessary camera types
export 'package:camera/camera.dart' show CameraLensDirection, XFile;
