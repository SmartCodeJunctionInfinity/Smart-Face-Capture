import 'package:flutter/foundation.dart';

/// Utility functions for the smart face capture package.

/// Logs a debug message if in debug mode.
void logDebug(String message) {
  if (kDebugMode) {
    debugPrint('[SmartFaceCapture] $message');
  }
}

/// Calculates the aspect ratio for camera preview.
double calculateAspectRatio(double width, double height) {
  return width / height;
}

/// Validates if a file path is valid.
bool isValidFilePath(String? path) {
  if (path == null || path.isEmpty) {
    return false;
  }
  return path.isNotEmpty;
}

/// Formats file size in human-readable format.
String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  } else {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Converts degrees to radians.
double degreesToRadians(double degrees) {
  return degrees * (3.14159265359 / 180.0);
}

/// Converts radians to degrees.
double radiansToDegrees(double radians) {
  return radians * (180.0 / 3.14159265359);
}
