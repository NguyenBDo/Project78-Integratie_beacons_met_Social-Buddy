import 'dart:async';

import 'package:buddy_bot/pose_detection/pose_detection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rive/rive.dart';

class AnimatedEyesView extends StatefulWidget {
  const AnimatedEyesView({super.key});

  @override
  State<AnimatedEyesView> createState() => _AnimatedEyesViewState();
}

class _AnimatedEyesViewState extends State<AnimatedEyesView> {
  Artboard? _riveArtboard;
  StateMachineController? _controller;
  StateMachineController? _leftHandController;
  StateMachineController? _rightHandController;
  SMIInput<double>? _leftValue;
  SMIInput<double>? _rightValue;
  SMIInput<double>? _topValue;
  SMIInput<double>? _bottomValue;
  SMIInput<bool>? _faceDetected;
  SMIInput<double>? _leftHandValue;
  SMIInput<double>? _rightHandValue;

  static const _riveUpdateFramerate = 30;
  Duration get _riveUpdateInterval {
    final millisecondInterval = (1000 / _riveUpdateFramerate).round();
    return Duration(milliseconds: millisecondInterval);
  }

  Timer? _riveFrameUpdateTimer;

  bool get _isInitialized => _riveArtboard != null;

  @override
  void initState() {
    super.initState();
    _initArtboard();
  }

  @override
  void dispose() {
    _riveFrameUpdateTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initArtboard() async {
    assert(!_isInitialized, 'Artboard already initialized');

    final riveByteData =
        // await rootBundle.load('assets/new_eyes_pose_animation.riv');
        await rootBundle.load('assets/buddybotwithhands.riv');
    final riveFile = RiveFile.import(riveByteData);
    _riveArtboard = riveFile.mainArtboard;
    _riveArtboard!.antialiasing = false;
    _controller = StateMachineController.fromArtboard(
      _riveArtboard!,
      'StateMachine',
    );
    if (_controller != null) {
      _riveArtboard!.addController(_controller!);
      _leftValue = _controller!.findInput('LeftValue');
      _rightValue = _controller!.findInput('RightValue');
      _topValue = _controller!.findInput('TopValue');
      _bottomValue = _controller!.findInput('BottomValue');
      _faceDetected = _controller!.findInput('FaceDetected');
    }
    _leftHandController = StateMachineController.fromArtboard(
      _riveArtboard!,
      'LeftHandStateMachine',
    );
    if (_leftHandController != null) {
      _riveArtboard!.addController(_leftHandController!);
      _leftHandValue = _leftHandController!.findInput('LeftHandValue');
    }
    _rightHandController = StateMachineController.fromArtboard(
      _riveArtboard!,
      'RightHandStateMachine',
    );
    if (_rightHandController != null) {
      _riveArtboard!.addController(_rightHandController!);
      _rightHandValue = _rightHandController!.findInput('RightHandValue');
    }
    if (mounted) {
      setState(() {});
    }

    _riveFrameUpdateTimer = Timer.periodic(_riveUpdateInterval, (_) {
      _updateArtboard();
    });
  }

  void _updateArtboard() {
    if (_riveArtboard == null) {
      return;
    }

    final state = context.read<PoseDetectionCubit>().state;
    final x = state.x;
    final y = state.y;
    final facesDetected = state.facesDetected;
    final leftHandValue = state.leftHand;
    final rightHandValue = state.rightHand;

    _faceDetected!.value = facesDetected;
    if (x < 0) {
      _leftValue!.value = x.abs();
      _rightValue!.value = 0;
    } else {
      _leftValue!.value = 0;
      _rightValue!.value = x;
    }
    if (y < 0) {
      _topValue!.value = y.abs();
      _bottomValue!.value = 0;
    } else {
      _topValue!.value = 0;
      _bottomValue!.value = y;
    }
    _rightHandValue!.value = rightHandValue;
    _leftHandValue!.value = leftHandValue;

    _controller!.isActive = true;
    _leftHandController!.isActive = true;
    _rightHandController!.isActive = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PoseDetectionCubit, PoseDetectionState>(
      listener: (context, state) => _updateArtboard(),
      child: _riveArtboard == null
          ? const Center(
              child: CupertinoActivityIndicator(),
            )
          : Rive(
              artboard: _riveArtboard!,
              fit: BoxFit.cover,
            ),
    );
  }
}
