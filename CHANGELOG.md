# Changelog

All notable changes to the smart_face_capture package will be documented in this file.

## [1.0.0] - 2026-01-12

### Added
- Initial release of smart_face_capture package
- Automatic face pose detection using Google ML Kit
- Mandatory guided captures: Front, Left, Right
- Auto-capture when correct pose is detected
- Single face validation (no face, multiple faces, face too far)
- Custom capture support with manual trigger
- Skip functionality for custom captures
- Fullscreen camera preview with circular face guide
- Real-time status indicators
- Progress indicator showing capture steps
- 1.5 second cooldown between captures
- Image compression to ~300KB
- Complete example app
- Comprehensive README with setup instructions
- Android and iOS platform support
- On-device processing (no server required)

### Features
- `SmartFaceCaptureView` widget for easy integration
- `CustomCaptureRequest` model for defining custom captures
- Proper camera and ML Kit resource management
- XFile output format for captured images
