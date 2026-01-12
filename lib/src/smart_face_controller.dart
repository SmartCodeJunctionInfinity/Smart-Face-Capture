import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import 'camera_service.dart';
import 'face_detector_service.dart';
import 'models.dart';

/// Controller for managing the face capture flow.
/// 
/// This controller orchestrates the camera service, face detector service,
/// and manages the state of the capture process.
class SmartFaceController {
  final CameraService _cameraService;
  final FaceDetectorService _faceDetectorService;
  final List<CustomCaptureRequest> _customCaptures;
  final Function(List<XFile>) _onCompleted;

  List<CaptureStep> _steps = [];
  int _currentStepIndex = 0;
  final List<XFile> _capturedImages = [];
  bool _isInCooldown = false;
  Timer? _cooldownTimer;
  StreamController<CaptureState>? _stateController;

  CameraDescription? _currentCamera;
  FaceDetectionStatus _currentFaceStatus = FaceDetectionStatus.noFace;
  double? _currentHeadYaw;
  bool _isPoseCorrect = false;

  /// Creates a new smart face controller.
  SmartFaceController({
    required List<CustomCaptureRequest> customCaptures,
    required Function(List<XFile>) onCompleted,
  })  : _cameraService = CameraService(),
        _faceDetectorService = FaceDetectorService(),
        _customCaptures = customCaptures,
        _onCompleted = onCompleted {
    _initializeSteps();
  }

  /// Gets the camera controller.
  CameraController? get cameraController => _cameraService.controller;

  /// Gets the stream of capture states.
  Stream<CaptureState> get stateStream {
    _stateController ??= StreamController<CaptureState>.broadcast();
    return _stateController!.stream;
  }

  /// Initializes the capture steps.
  void _initializeSteps() {
    _steps = [
      CaptureStep(
        type: CaptureType.front,
        instruction: 'Look Straight',
      ),
      CaptureStep(
        type: CaptureType.left,
        instruction: 'Turn Left',
      ),
      CaptureStep(
        type: CaptureType.right,
        instruction: 'Turn Right',
      ),
    ];

    // Add custom capture steps
    for (final custom in _customCaptures) {
      _steps.add(
        CaptureStep(
          type: CaptureType.custom,
          instruction: custom.instructionText,
          customRequest: custom,
        ),
      );
    }
  }

  /// Initializes the camera and starts face detection.
  Future<bool> initialize({
    CameraLensDirection lensDirection = CameraLensDirection.front,
  }) async {
    try {
      // Initialize camera
      final initialized = await _cameraService.initialize(
        lensDirection: lensDirection,
      );

      if (!initialized) {
        debugPrint('Failed to initialize camera');
        return false;
      }

      // Get current camera for face detection
      final cameras = await availableCameras();
      _currentCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == lensDirection,
        orElse: () => cameras.first,
      );

      // Start image stream for face detection
      await _cameraService.startImageStream(_onImageFrame);

      // Emit initial state
      _emitState();

      return true;
    } catch (e) {
      debugPrint('Error initializing controller: $e');
      return false;
    }
  }

  /// Handles each camera frame for face detection.
  Future<void> _onImageFrame(CameraImage image) async {
    if (_currentCamera == null || _faceDetectorService.isProcessing) {
      return;
    }

    try {
      // Detect faces
      final result = await _faceDetectorService.detectFaces(
        image,
        _currentCamera!,
      );

      _currentFaceStatus = result.status;
      _currentHeadYaw = result.headYaw;

      // Check if pose is correct for current step
      if (_currentStepIndex < _steps.length) {
        final currentStep = _steps[_currentStepIndex];
        
        // Only check pose for mandatory steps (not custom)
        if (currentStep.type != CaptureType.custom) {
          _isPoseCorrect = _currentFaceStatus == FaceDetectionStatus.singleFace &&
              _faceDetectorService.isPoseCorrect(
                currentStep.type,
                _currentHeadYaw,
              );

          // Auto-capture if pose is correct and not in cooldown
          if (_isPoseCorrect && !_isInCooldown) {
            await _captureCurrentStep();
          }
        }
      }

      _emitState();
    } catch (e) {
      debugPrint('Error processing image frame: $e');
    }
  }

  /// Captures the current step image.
  Future<void> _captureCurrentStep() async {
    if (_isInCooldown || _currentStepIndex >= _steps.length) {
      return;
    }

    try {
      // Start cooldown
      _isInCooldown = true;
      _emitState();

      // Capture image
      final image = await _cameraService.captureImage();
      if (image != null) {
        _capturedImages.add(image);
        _steps[_currentStepIndex].isCompleted = true;

        // Wait for cooldown period
        await Future.delayed(const Duration(milliseconds: 1500));

        // Move to next step
        _currentStepIndex++;

        if (_currentStepIndex >= _steps.length) {
          // All steps completed
          await _complete();
        } else {
          // Reset for next step
          _isInCooldown = false;
          _isPoseCorrect = false;
          _emitState();
        }
      } else {
        // Capture failed, reset cooldown
        _isInCooldown = false;
        _emitState();
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      _isInCooldown = false;
      _emitState();
    }
  }

  /// Manually captures an image (for custom steps).
  Future<void> manualCapture() async {
    if (_currentStepIndex >= _steps.length) {
      return;
    }

    final currentStep = _steps[_currentStepIndex];
    
    // Manual capture only allowed for custom steps
    if (currentStep.type != CaptureType.custom) {
      return;
    }

    // Check if single face is detected
    if (_currentFaceStatus != FaceDetectionStatus.singleFace) {
      debugPrint('Cannot capture: invalid face status');
      return;
    }

    try {
      // Stop image stream temporarily
      await _cameraService.stopImageStream();

      // Capture image
      final image = await _cameraService.captureImage();
      if (image != null) {
        _capturedImages.add(image);
        _steps[_currentStepIndex].isCompleted = true;

        // Move to next step
        _currentStepIndex++;

        if (_currentStepIndex >= _steps.length) {
          // All steps completed
          await _complete();
        } else {
          // Restart image stream for next step
          await _cameraService.startImageStream(_onImageFrame);
          _emitState();
        }
      } else {
        // Capture failed, restart stream
        await _cameraService.startImageStream(_onImageFrame);
      }
    } catch (e) {
      debugPrint('Error in manual capture: $e');
      // Ensure stream is restarted
      await _cameraService.startImageStream(_onImageFrame);
    }
  }

  /// Skips all remaining custom capture steps.
  Future<void> skipCustomCaptures() async {
    if (_currentStepIndex >= _steps.length) {
      return;
    }

    // Find first custom step
    final firstCustomIndex = _steps.indexWhere(
      (step) => step.type == CaptureType.custom,
    );

    // Skip only if we're in custom capture phase
    if (_currentStepIndex >= firstCustomIndex) {
      await _complete();
    }
  }

  /// Completes the capture process.
  Future<void> _complete() async {
    try {
      await _cameraService.stopImageStream();
      _onCompleted(_capturedImages);
    } catch (e) {
      debugPrint('Error completing capture: $e');
    }
  }

  /// Emits the current state to the stream.
  void _emitState() {
    if (_stateController != null && _currentStepIndex < _steps.length) {
      final state = CaptureState(
        currentStep: _steps[_currentStepIndex],
        faceStatus: _currentFaceStatus,
        headYaw: _currentHeadYaw,
        isPoseCorrect: _isPoseCorrect,
        isInCooldown: _isInCooldown,
        totalSteps: _steps.length,
        currentStepIndex: _currentStepIndex,
      );
      _stateController!.add(state);
    }
  }

  /// Disposes of all resources.
  Future<void> dispose() async {
    try {
      _cooldownTimer?.cancel();
      await _cameraService.dispose();
      await _faceDetectorService.dispose();
      await _stateController?.close();
      _stateController = null;
    } catch (e) {
      debugPrint('Error disposing controller: $e');
    }
  }
}
