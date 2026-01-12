# smart_face_capture_example

Example app demonstrating the usage of the `smart_face_capture` Flutter package.

## Features Demonstrated

- Mandatory face captures (Front, Left, Right)
- Custom capture steps with user-defined instructions
- Manual capture button for custom steps
- Skip functionality for custom captures
- Results screen showing all captured images

## Getting Started

1. Clone the repository
2. Navigate to the example directory:
   ```bash
   cd example
   ```

3. Get dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Platform Setup

### Android

Make sure you have the following in `android/app/src/main/AndroidManifest.xml`:
- Camera permission
- ML Kit metadata

These are already configured in this example.

### iOS

Make sure you have the following in `ios/Runner/Info.plist`:
- NSCameraUsageDescription

This is already configured in this example.

## Usage Flow

1. Launch the app
2. Tap "Start Face Capture" button
3. Follow the on-screen instructions:
   - Look straight (front face capture)
   - Turn left (left face capture)
   - Turn right (right face capture)
   - Custom captures (manual capture with button)
4. View the captured images on the results screen

## Code Structure

- `main.dart`: Contains all screens
  - `HomeScreen`: Landing page with start button
  - `FaceCaptureScreen`: Face capture view with custom captures
  - `ResultsScreen`: Displays all captured images

## Customization

You can customize the custom captures in `FaceCaptureScreen`:

```dart
customCaptures: [
  CustomCaptureRequest(
    id: 'your_custom_id',
    label: 'Your Label',
    instructionText: 'Your instruction text',
  ),
]
```

## Troubleshooting

If you encounter issues:

1. Make sure camera permissions are granted
2. Run on a physical device (camera required)
3. Ensure adequate lighting for face detection
4. Check that only one person is in frame
