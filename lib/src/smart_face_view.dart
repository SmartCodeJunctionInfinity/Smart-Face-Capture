import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'models.dart';
import 'overlays.dart';
import 'smart_face_controller.dart';

/// Main widget for smart face capture.
/// 
/// This widget provides a fullscreen camera preview with guided face capture.
/// It automatically captures front, left, and right face images based on head
/// pose detection, followed by optional custom capture steps.
class SmartFaceCaptureView extends StatefulWidget {
  /// Optional list of custom capture requests to be performed after
  /// the mandatory front/left/right captures.
  final List<CustomCaptureRequest> customCaptures;

  /// Initial camera lens direction (default: front)
  final CameraLensDirection initialCamera;

  /// Callback invoked when all captures are completed.
  /// 
  /// The list contains captured images in order:
  /// - index 0: Front
  /// - index 1: Left
  /// - index 2: Right
  /// - followed by custom captures in the order provided
  final Function(List<XFile> allCapturedFiles) onCompleted;

  /// Creates a new smart face capture view.
  const SmartFaceCaptureView({
    super.key,
    this.customCaptures = const [],
    this.initialCamera = CameraLensDirection.front,
    required this.onCompleted,
  });

  @override
  State<SmartFaceCaptureView> createState() => _SmartFaceCaptureViewState();
}

class _SmartFaceCaptureViewState extends State<SmartFaceCaptureView> {
  SmartFaceController? _controller;
  bool _isInitialized = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  /// Initializes the smart face controller.
  Future<void> _initializeController() async {
    try {
      _controller = SmartFaceController(
        customCaptures: widget.customCaptures,
        onCompleted: widget.onCompleted,
      );

      final initialized = await _controller!.initialize(
        lensDirection: widget.initialCamera,
      );

      if (initialized) {
        setState(() {
          _isInitialized = true;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to initialize camera';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error if initialization failed
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              _errorMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    // Show loading if not initialized
    if (!_isInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // Show camera preview with overlays
    return Scaffold(
      backgroundColor: Colors.black,
      body: StreamBuilder<CaptureState>(
        stream: _controller!.stateStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          final state = snapshot.data!;
          final cameraController = _controller!.cameraController;

          if (cameraController == null || !cameraController.value.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera preview
              _buildCameraPreview(cameraController),

              // Face guide overlay
              const FaceGuideOverlay(),

              // Progress indicator
              ProgressOverlay(
                currentStep: state.currentStepIndex,
                totalSteps: state.totalSteps,
              ),

              // Instruction text
              InstructionOverlay(
                instruction: state.currentStep.instruction,
              ),

              // Status text
              StatusOverlay(
                status: state.faceStatus,
                isPoseCorrect: state.isPoseCorrect,
              ),

              // Show capture button for custom steps
              if (state.currentStep.type == CaptureType.custom)
                CaptureButton(
                  onPressed: () => _controller!.manualCapture(),
                  enabled: state.faceStatus == FaceDetectionStatus.singleFace,
                ),

              // Show skip button for custom steps
              if (state.currentStep.type == CaptureType.custom)
                SkipButton(
                  onPressed: () => _controller!.skipCustomCaptures(),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the camera preview widget.
  Widget _buildCameraPreview(CameraController controller) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    final cameraRatio = controller.value.aspectRatio;

    return Center(
      child: AspectRatio(
        aspectRatio: deviceRatio,
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.width,
              height: size.width / cameraRatio,
              child: CameraPreview(controller),
            ),
          ),
        ),
      ),
    );
  }
}
