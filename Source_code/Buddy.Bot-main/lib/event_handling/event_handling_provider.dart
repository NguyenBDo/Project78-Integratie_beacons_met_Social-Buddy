import 'package:buddy_bot/calendar_events/calendar_events.dart';
import 'package:buddy_bot/event_handling/event_handling.dart';
import 'package:buddy_bot/pose_detection/pose_detection.dart';
import 'package:buddy_bot/text_to_speech/text_to_speech.dart';
import 'package:calendar_events_repository/calendar_events_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventHandlingProvider extends StatelessWidget {
  const EventHandlingProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EventHandlingCubit(
        currentEvent: context.read<CalendarEventsCubit>().state.currentEvent,
      ),
      child: MultiBlocListener(
        listeners: [
          // Listener used to notify the EventHandlingCubit when a new current
          // event has been set.
          BlocListener<CalendarEventsCubit, CalendarEventsState>(
            listenWhen: (prev, cur) => prev.currentEvent != cur.currentEvent,
            listener: (context, state) {
              context.read<EventHandlingCubit>().queueEvent(state.currentEvent);
            },
          ),
          // Listener used to notify the CalendarEventsCubit when a response has
          // been recorded for an event.
          BlocListener<EventHandlingCubit, EventHandlingState>(
            listenWhen: (prev, cur) {
              return cur.currentEvent != null &&
                  prev.currentResponse != cur.currentResponse &&
                  cur.currentResponse != null;
            },
            listener: (context, state) {
              context.read<CalendarEventsCubit>().recordEventAcknowledgement(
                    event: state.currentEvent!,
                    response: state.currentResponse,
                  );
            },
          ),
          // Listener used to notify the EventHandlingCubit when the user has
          // raised either hand.
          BlocListener<PoseDetectionCubit, PoseDetectionState>(
            listenWhen: (prev, cur) {
              // Either the left or right hand must have changed.
              final hasLeftHandChanged = prev.isLeftHandUp != cur.isLeftHandUp;
              final hasRightHandChanged =
                  prev.isRightHandUp != cur.isRightHandUp;

              // We should ignore the event if the user has both hands up, or if
              // they previously had both hands up. This is to prevent
              // inaccurate readings from being interpreted as a response.
              final hadBothHandsUpBefore =
                  prev.isLeftHandUp && prev.isRightHandUp;
              final hasBothHandsUp = cur.isLeftHandUp && cur.isRightHandUp;

              // We only care if either hand is currently up.
              final isEitherHandUp = cur.isLeftHandUp || cur.isRightHandUp;

              return (hasLeftHandChanged || hasRightHandChanged) &&
                  !hadBothHandsUpBefore &&
                  !hasBothHandsUp &&
                  isEitherHandUp;
            },
            listener: (context, state) {
              // We know either hand was raised. If the right hand was raised,
              // the response is positive. Otherwise, the response is negative.
              context.read<EventHandlingCubit>().processResponse(
                    response: state.isRightHandUp,
                  );
            },
          ),
          // Listener used to trigger text-to-speech when an action has
          // occurred.
          BlocListener<EventHandlingCubit, EventHandlingState>(
            listenWhen: (prev, cur) => prev.status != cur.status,
            listener: (context, state) {
              final ttsCubit = context.read<TextToSpeechCubit>();
              switch (state.status) {
                case EventHandlingStatus.responding:
                  ttsCubit.speak(state.currentEvent!.name);
                  break;
                case EventHandlingStatus.responded:
                  if (state.currentEvent!.type == CalendarEventType.question) {
                    ttsCubit.speak(
                      state.currentResponse == true
                          ? 'Netjes! Afgevinkt.'
                          : 'Geen probleem. Ik zal je later opnieuw herinneren.',
                    );
                  } else {
                    ttsCubit.speak(state.currentEvent!.name);
                  }
                  break;
                case EventHandlingStatus.idle:
                  break;
              }
            },
          ),
        ],
        child: child,
      ),
    );
  }
}
