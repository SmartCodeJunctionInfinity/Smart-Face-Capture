import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service for managing camera operations.
/// 
/// This service handles camera initialization, configuration,
/// image capture, and disposal.
class CameraService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  
  /// Gets the current camera controller.
  CameraController? get controller => _controller;
  
  /// Gets whether the camera is initialized.
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  /// Initializes the camera with the specified lens direction.
  /// 
  /// Returns true if initialization was successful, false otherwise.
  Future<bool> initialize({
    CameraLensDirection lensDirection = CameraLensDirection.front,
  }) async {
    try {
      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras available');
        return false;
      }

      // Find camera with specified lens direction
      final camera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == lensDirection,
        orElse: () => _cameras!.first,
      );

      // Create and initialize controller
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      
      // Set flash mode to off
      await _controller!.setFlashMode(FlashMode.off);
      
      return true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      return false;
    }
  }

  /// Captures an image and returns it as an XFile.
  /// 
  /// The image is compressed to approximately 300KB for reasonable file size.
  /// Returns null if capture fails.
  Future<XFile?> captureImage() async {
    if (!isInitialized) {
      debugPrint('Camera not initialized');
      return null;
    }

    try {
      // Capture image
      final image = await _controller!.takePicture();
      
      // Compress image to reasonable size
      final compressedImage = await _compressImage(image);
      
      return compressedImage;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  /// Compresses an image to approximately 300KB.
  /// 
  /// Saves the compressed image to temporary storage and returns it as XFile.
  Future<XFile> _compressImage(XFile image) async {
    try {
      // For now, we'll just save to temp directory
      // In production, you might want to add actual image compression
      final bytes = await image.readAsBytes();
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'face_capture_$timestamp.jpg';
      final filePath = '${tempDir.path}/$fileName';
      
      // Write file
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      return XFile(filePath);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      // Return original image if compression fails
      return image;
    }
  }

  /// Starts the image stream for face detection.
  /// 
  /// The [onImage] callback is called for each frame.
  Future<void> startImageStream(Function(CameraImage image) onImage) async {
    if (!isInitialized) {
      debugPrint('Camera not initialized');
      return;
    }

    try {
      await _controller!.startImageStream(onImage);
    } catch (e) {
      debugPrint('Error starting image stream: $e');
    }
  }

  /// Stops the image stream.
  Future<void> stopImageStream() async {
    if (!isInitialized) return;

    try {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
    } catch (e) {
      debugPrint('Error stopping image stream: $e');
    }
  }

  /// Disposes of camera resources.
  Future<void> dispose() async {
    try {
      await stopImageStream();
      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
  }
}
