import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:calendar_events_repository/calendar_events_repository.dart';
import 'package:equatable/equatable.dart';

part 'event_handling_state.dart';

class EventHandlingCubit extends Cubit<EventHandlingState> {
  EventHandlingCubit({
    CalendarEvent? currentEvent,
  }) : super(
          EventHandlingState(
            status: currentEvent != null
                ? EventHandlingStatus.responding
                : EventHandlingStatus.idle,
            currentEvent: currentEvent,
          ),
        );

  /// A timer used to show the user the response they have given to an event.
  Timer? _postResponseTimer;

  /// The time to wait between showing the response for an event and showing the
  /// next event.
  static const _postResponseTimeout = Duration(seconds: 3);

  @override
  Future<void> close() async {
    _postResponseTimer?.cancel();
    await super.close();
  }

  void queueEvent(CalendarEvent? event) {
    // Reset the next event in any case.
    emit(state.copyWithout(nextEvent: true));
    if (event == null) {
      // If event is null, this means there either is no next event or
      // it has been removed from the user's calendar.
      return;
    }

    if (state.currentEvent == null) {
      // If there is no current event, this event becomes the current event.

      emit(
        state.copyWith(
          status: EventHandlingStatus.responding,
          currentEvent: event,
        ),
      );

      if (state.currentEvent!.type == CalendarEventType.notification) {
        // If this event is a notification, we can acknowledge and set a
        // response immediately.
        //
        // Otherwise we wait for the user to respond.
        processResponse(response: null);
      }
    } else {
      // Otherwise, queue it for later.
      emit(state.copyWith(nextEvent: event));
    }
  }

  void processResponse({
    required bool? response,
  }) {
    // If there is no current event, ignore the response.
    if (state.currentEvent == null ||
        state.status != EventHandlingStatus.responding) {
      return;
    }

    assert(
      state.currentEvent!.type != CalendarEventType.question ||
          response != null,
      'A response must be provided for a question event.',
    );

    // Save the response.
    emit(
      state.copyWith(
        status: EventHandlingStatus.responded,
        currentResponse: response,
      ),
    );

    // Wait a little while before moving on to the next event, allowing the
    // user to see the response.
    _postResponseTimer?.cancel();
    _postResponseTimer = Timer(
      _postResponseTimeout,
      () {
        // The current event has been dealt with, so remove it and reset the
        // status to idle.
        emit(
          state
              .copyWithout(
                currentEvent: true,
                currentResponse: true,
              )
              .copyWith(status: EventHandlingStatus.idle),
        );

        // Queue the next event, if any.
        queueEvent(state.nextEvent);
      },
    );
  }
}
