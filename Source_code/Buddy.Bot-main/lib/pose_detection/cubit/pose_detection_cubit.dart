import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'pose_detection_state.dart';

class PoseDetectionCubit extends Cubit<PoseDetectionState> {
  PoseDetectionCubit() : super(const PoseDetectionState());

  void setPosition({
    double? x,
    double? y,
    double? leftHand,
    double? rightHand,
  }) {
    emit(
      state.copyWith(
        x: x,
        y: y,
        leftHand: leftHand,
        rightHand: rightHand,
        facesDetected: true,
        lastUpdated: DateTime.now(),
      ),
    );
  }

  void updateNoFacesDetected() {
    emit(
      state.copyWith(
        x: 0,
        y: 0,
        leftHand: 0,
        rightHand: 0,
        facesDetected: false,
        lastUpdated: DateTime.now(),
      ),
    );
  }
}
