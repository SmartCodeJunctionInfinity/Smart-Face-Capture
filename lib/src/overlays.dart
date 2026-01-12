import 'package:flutter/material.dart';
import 'models.dart';

/// Circular face guide overlay widget.
/// 
/// Displays a circular guide in the center of the screen to help users
/// position their face correctly.
class FaceGuideOverlay extends StatelessWidget {
  const FaceGuideOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 3,
          ),
        ),
      ),
    );
  }
}

/// Instruction text overlay widget.
/// 
/// Displays the current instruction text to the user.
class InstructionOverlay extends StatelessWidget {
  /// The instruction text to display
  final String instruction;

  const InstructionOverlay({
    super.key,
    required this.instruction,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Text(
          instruction,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status text overlay widget.
/// 
/// Displays the current face detection status to the user.
class StatusOverlay extends StatelessWidget {
  /// The face detection status
  final FaceDetectionStatus status;
  
  /// Whether the correct pose is detected
  final bool isPoseCorrect;

  const StatusOverlay({
    super.key,
    required this.status,
    required this.isPoseCorrect,
  });

  /// Gets the status message based on the current state.
  String _getStatusMessage() {
    if (isPoseCorrect) {
      return 'Hold steady...';
    }

    switch (status) {
      case FaceDetectionStatus.noFace:
        return 'No face detected';
      case FaceDetectionStatus.multipleFaces:
        return 'Multiple faces detected';
      case FaceDetectionStatus.tooFar:
        return 'Move closer';
      case FaceDetectionStatus.singleFace:
        return '';
    }
  }

  /// Gets the status color based on the current state.
  Color _getStatusColor() {
    if (isPoseCorrect) {
      return Colors.green;
    }

    switch (status) {
      case FaceDetectionStatus.singleFace:
        return Colors.white;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = _getStatusMessage();
    if (message.isEmpty) return const SizedBox.shrink();

    return Positioned(
      bottom: 200,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _getStatusColor(),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Progress indicator overlay widget.
/// 
/// Shows the current progress through the capture steps.
class ProgressOverlay extends StatelessWidget {
  /// Current step index (0-based)
  final int currentStep;
  
  /// Total number of steps
  final int totalSteps;

  const ProgressOverlay({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalSteps,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: index <= currentStep
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}

/// Manual capture button widget.
/// 
/// Displayed during custom capture steps to allow manual image capture.
class CaptureButton extends StatelessWidget {
  /// Callback when the button is pressed
  final VoidCallback onPressed;
  
  /// Whether the button is enabled
  final bool enabled;

  const CaptureButton({
    super.key,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: enabled ? onPressed : null,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 4,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled ? Colors.blue : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skip button widget.
/// 
/// Allows users to skip remaining custom capture steps.
class SkipButton extends StatelessWidget {
  /// Callback when the button is pressed
  final VoidCallback onPressed;

  const SkipButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 20,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.black54,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Skip',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
