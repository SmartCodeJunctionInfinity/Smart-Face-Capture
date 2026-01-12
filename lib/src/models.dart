import 'package:camera/camera.dart';

/// Represents a custom capture request with user-defined instructions.
/// 
/// This class defines a custom face capture step that can be added to the
/// standard mandatory captures (front, left, right).
class CustomCaptureRequest {
  /// Unique identifier for this custom capture
  final String id;
  
  /// Label displayed in the UI for this capture step
  final String label;
  
  /// Detailed instruction text shown to the user during capture
  final String instructionText;

  /// Creates a new custom capture request.
  /// 
  /// All parameters are required and must not be null.
  const CustomCaptureRequest({
    required this.id,
    required this.label,
    required this.instructionText,
  });
}

/// Enum representing the type of capture step.
enum CaptureType {
  /// Mandatory front-facing capture (yaw between -15° and +15°)
  front,
  
  /// Mandatory left-facing capture (yaw > +20°)
  left,
  
  /// Mandatory right-facing capture (yaw < -20°)
  right,
  
  /// Custom capture with manual trigger
  custom,
}

/// Represents a single capture step in the face capture flow.
/// 
/// This class encapsulates both mandatory and custom capture steps,
/// including their instructions and validation requirements.
class CaptureStep {
  /// Type of this capture step
  final CaptureType type;
  
  /// Instruction text to display to the user
  final String instruction;
  
  /// Custom capture request (only for custom type)
  final CustomCaptureRequest? customRequest;
  
  /// Whether this step has been completed
  bool isCompleted;

  /// Creates a new capture step.
  CaptureStep({
    required this.type,
    required this.instruction,
    this.customRequest,
    this.isCompleted = false,
  });
}

/// Enum representing face detection status.
enum FaceDetectionStatus {
  /// No face detected in the frame
  noFace,
  
  /// Multiple faces detected in the frame
  multipleFaces,
  
  /// Exactly one face detected (valid state)
  singleFace,
  
  /// Face detected but too far from camera
  tooFar,
}

/// Represents the current state of the face capture process.
class CaptureState {
  /// Current step being captured
  final CaptureStep currentStep;
  
  /// Face detection status
  final FaceDetectionStatus faceStatus;
  
  /// Current head yaw angle in degrees
  final double? headYaw;
  
  /// Whether the correct pose is detected for the current step
  final bool isPoseCorrect;
  
  /// Whether the system is in cooldown period after a capture
  final bool isInCooldown;
  
  /// Total number of steps (mandatory + custom)
  final int totalSteps;
  
  /// Current step index (0-based)
  final int currentStepIndex;

  /// Creates a new capture state.
  const CaptureState({
    required this.currentStep,
    required this.faceStatus,
    this.headYaw,
    this.isPoseCorrect = false,
    this.isInCooldown = false,
    required this.totalSteps,
    required this.currentStepIndex,
  });

  /// Creates a copy of this state with updated values.
  CaptureState copyWith({
    CaptureStep? currentStep,
    FaceDetectionStatus? faceStatus,
    double? headYaw,
    bool? isPoseCorrect,
    bool? isInCooldown,
    int? totalSteps,
    int? currentStepIndex,
  }) {
    return CaptureState(
      currentStep: currentStep ?? this.currentStep,
      faceStatus: faceStatus ?? this.faceStatus,
      headYaw: headYaw ?? this.headYaw,
      isPoseCorrect: isPoseCorrect ?? this.isPoseCorrect,
      isInCooldown: isInCooldown ?? this.isInCooldown,
      totalSteps: totalSteps ?? this.totalSteps,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
    );
  }
}
