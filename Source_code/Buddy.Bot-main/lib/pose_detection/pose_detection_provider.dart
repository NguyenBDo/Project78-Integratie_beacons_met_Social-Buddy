import 'dart:async';

import 'package:body_detection/body_detection.dart';
import 'package:body_detection/models/image_result.dart';
import 'package:body_detection/models/pose.dart';
import 'package:body_detection/models/pose_landmark.dart';
import 'package:body_detection/models/pose_landmark_type.dart';
import 'package:buddy_bot/pose_detection/pose_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'cubit/pose_detection_cubit.dart';

class PoseDetectionProvider extends StatelessWidget {
  const PoseDetectionProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PoseDetectionCubit(),
      child: _PoseDetectionProcessor(
        child: child,
      ),
    );
  }
}

class _PoseDetectionProcessor extends StatefulWidget {
  const _PoseDetectionProcessor({
    required this.child,
  });

  final Widget child;

  @override
  State<_PoseDetectionProcessor> createState() =>
      __PoseDetectionProcessorState();
}

class __PoseDetectionProcessorState extends State<_PoseDetectionProcessor> {
  Size? _totalImageSize;
  Timer? _poseDetectionTimer;
  var _shouldProcessPose = false;

  static const _poseDetectionFramerate = 4;
  Duration get _poseDetectionInterval {
    final millisecondInterval = (1000 / _poseDetectionFramerate).round();
    return Duration(milliseconds: millisecondInterval);
  }

  // these offsets are used for the speed
  // and accuracy of the eyes and hand movements
  static const _nosePositionOffsetMultiplier = 4.0;
  static const _handPositionOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initPoseDetection();
  }

  Future<void> _initPoseDetection() async {
    try {
      // await BodyDetection.stopCameraStream();
      await BodyDetection.startCameraStream(
        onFrameAvailable: _onFrame,
        onPoseAvailable: _onPose,
      );
    } catch (e) {
      // Do nothing.
    }

    _poseDetectionTimer = Timer.periodic(
      _poseDetectionInterval,
      (_) {
        _enablePoseDetection();
      },
    );
  }

  @override
  void dispose() {
    _poseDetectionTimer?.cancel();
    BodyDetection.disablePoseDetection();
    BodyDetection.stopCameraStream();
    super.dispose();
  }

  Future<void> _enablePoseDetection() async {
    _shouldProcessPose = true;
    await BodyDetection.enablePoseDetection();
  }

  Future<void> _disablePoseDetection() async {
    _shouldProcessPose = false;
    await BodyDetection.disablePoseDetection();
  }

  void _onFrame(ImageResult image) {
    _totalImageSize = image.size;
    // final cubit = context.read<PoseDetectionCubit>();
    // cubit.setPosition(
    //   x: cubit.state.x,
    //   y: cubit.state.y,
    // );
  }

  void _onPose(Pose? pose) {
    if (!_shouldProcessPose || _totalImageSize == null) {
      return;
    }

    _disablePoseDetection();

    final nosePosition = pose?.landmarks.cast<PoseLandmark?>().firstWhere(
          (landmark) => landmark!.type == PoseLandmarkType.nose,
          orElse: () => null,
        );
    final leftHandPosition = pose?.landmarks.cast<PoseLandmark?>().firstWhere(
          (landmark) => landmark!.type == PoseLandmarkType.rightWrist,
          orElse: () => null,
        );
    final rightHandPosition = pose?.landmarks.cast<PoseLandmark?>().firstWhere(
          (landmark) => landmark!.type == PoseLandmarkType.leftWrist,
          orElse: () => null,
        );

    final cubit = context.read<PoseDetectionCubit>();

    if (pose == null ||
        nosePosition == null ||
        leftHandPosition == null ||
        rightHandPosition == null) {
      cubit.updateNoFacesDetected();
      return;
    }

    final xPosition =
        (nosePosition.position.x / _totalImageSize!.width * 2 - 1) *
            _nosePositionOffsetMultiplier;
    final yPosition =
        (nosePosition.position.y / _totalImageSize!.height * 2 - 1) *
            _nosePositionOffsetMultiplier;
    var leftHandUp = (nosePosition.position.y -
            leftHandPosition.position.y +
            _handPositionOffset) /
        _totalImageSize!.height;
    var rightHandUp = (nosePosition.position.y -
            rightHandPosition.position.y +
            _handPositionOffset) /
        _totalImageSize!.height;
    if (leftHandUp < 0) {
      leftHandUp = 0;
    }
    if (rightHandUp < 0) {
      rightHandUp = 0;
    }

    cubit.setPosition(
      x: xPosition,
      y: yPosition,
      leftHand: leftHandUp,
      rightHand: rightHandUp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
