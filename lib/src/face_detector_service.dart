import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'models.dart';

/// Service for detecting faces using Google ML Kit.
/// 
/// This service handles face detection, head pose analysis,
/// and validation of capture conditions.
class FaceDetectorService {
  final FaceDetector _faceDetector;
  bool _isProcessing = false;

  /// Creates a new face detector service with ML Kit face detector.
  FaceDetectorService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableClassification: false,
            enableLandmarks: false,
            enableTracking: false,
            enableContours: false,
            performanceMode: FaceDetectorMode.accurate,
          ),
        );

  /// Gets whether the service is currently processing an image.
  bool get isProcessing => _isProcessing;

  /// Processes a camera image and detects faces.
  /// 
  /// Returns the face detection status and head yaw angle (if available).
  Future<({FaceDetectionStatus status, double? headYaw})> detectFaces(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (_isProcessing) {
      return (status: FaceDetectionStatus.noFace, headYaw: null);
    }

    _isProcessing = true;

    try {
      // Convert CameraImage to InputImage
      final inputImage = _convertCameraImage(image, camera);
      if (inputImage == null) {
        _isProcessing = false;
        return (status: FaceDetectionStatus.noFace, headYaw: null);
      }

      // Detect faces
      final faces = await _faceDetector.processImage(inputImage);

      _isProcessing = false;

      // Check face count
      if (faces.isEmpty) {
        return (status: FaceDetectionStatus.noFace, headYaw: null);
      } else if (faces.length > 1) {
        return (status: FaceDetectionStatus.multipleFaces, headYaw: null);
      }

      // Single face detected
      final face = faces.first;
      final headYaw = face.headEulerAngleY;

      // Check if face is too far (bounding box too small)
      final boundingBox = face.boundingBox;
      final faceArea = boundingBox.width * boundingBox.height;
      final imageArea = image.width * image.height;
      final faceRatio = faceArea / imageArea;

      if (faceRatio < 0.1) {
        // Face takes up less than 10% of the image
        return (status: FaceDetectionStatus.tooFar, headYaw: headYaw);
      }

      return (status: FaceDetectionStatus.singleFace, headYaw: headYaw);
    } catch (e) {
      debugPrint('Error detecting faces: $e');
      _isProcessing = false;
      return (status: FaceDetectionStatus.noFace, headYaw: null);
    }
  }

  /// Converts a CameraImage to InputImage for ML Kit processing.
  InputImage? _convertCameraImage(
    CameraImage image,
    CameraDescription camera,
  ) {
    try {
      // Get image rotation
      final sensorOrientation = camera.sensorOrientation;
      InputImageRotation? rotation;

      if (Platform.isIOS) {
        rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
      } else if (Platform.isAndroid) {
        var rotationCompensation = sensorOrientation;
        if (camera.lensDirection == CameraLensDirection.front) {
          rotationCompensation = (sensorOrientation + 90) % 360;
        }
        rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
      }

      if (rotation == null) return null;

      // Get image format
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      if (format == null) return null;

      // Get plane data
      if (image.planes.isEmpty) return null;
      final plane = image.planes.first;

      // Create InputImage
      return InputImage.fromBytes(
        bytes: plane.bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: format,
          bytesPerRow: plane.bytesPerRow,
        ),
      );
    } catch (e) {
      debugPrint('Error converting camera image: $e');
      return null;
    }
  }

  /// Validates if the current head pose matches the required capture type.
  /// 
  /// Returns true if the pose is correct for the given capture type.
  bool isPoseCorrect(CaptureType type, double? headYaw) {
    if (headYaw == null) return false;

    switch (type) {
      case CaptureType.front:
        // Front: yaw between -15° and +15°
        return headYaw >= -15 && headYaw <= 15;
      case CaptureType.left:
        // Left: yaw > +20°
        return headYaw > 20;
      case CaptureType.right:
        // Right: yaw < -20°
        return headYaw < -20;
      case CaptureType.custom:
        // Custom: no pose restriction
        return true;
    }
  }

  /// Disposes of the face detector resources.
  Future<void> dispose() async {
    try {
      await _faceDetector.close();
    } catch (e) {
      debugPrint('Error disposing face detector: $e');
    }
  }
}
