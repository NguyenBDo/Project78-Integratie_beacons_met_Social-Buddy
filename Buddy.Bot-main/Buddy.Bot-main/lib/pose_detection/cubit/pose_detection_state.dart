// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'pose_detection_cubit.dart';

@immutable
class PoseDetectionState extends Equatable {
  const PoseDetectionState({
    this.x = 0,
    this.y = 0,
    this.leftHand = 0,
    this.rightHand = 0,
    this.facesDetected = false,
    this.lastUpdated,
  });

  final double x;
  final double y;
  final double leftHand;
  final double rightHand;
  final bool facesDetected;
  final DateTime? lastUpdated;

  bool get isLeftHandUp => leftHand > 0.0;
  bool get isRightHandUp => rightHand > 0.0;

  PoseDetectionState copyWith({
    double? x,
    double? y,
    double? leftHand,
    double? rightHand,
    bool? facesDetected,
    DateTime? lastUpdated,
  }) {
    return PoseDetectionState(
      x: x ?? this.x,
      y: y ?? this.y,
      leftHand: leftHand ?? this.leftHand,
      rightHand: rightHand ?? this.rightHand,
      facesDetected: facesDetected ?? this.facesDetected,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props =>
      [x, y, leftHand, rightHand, facesDetected, lastUpdated];
}
