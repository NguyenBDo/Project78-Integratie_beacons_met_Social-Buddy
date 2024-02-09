part of 'calendar_events_cubit.dart';

enum CalendarEventsStatus { initial, loading, success, failure }

class CalendarEventsState extends Equatable {
  const CalendarEventsState({
    this.status = CalendarEventsStatus.initial,
    this.futureEvents = const [],
    this.currentEvent,
    this.lastQueueTime,
  });

  final CalendarEventsStatus status;

  /// Contains all unhandled events queued for the future.
  ///
  /// May include the [currentEvent].
  final List<CalendarEvent> futureEvents;

  /// The event that should be processed now, if any.
  final CalendarEvent? currentEvent;

  /// The last time the [futureEvents] were checked for an event that should be
  /// processed now.
  final DateTime? lastQueueTime;

  @override
  List<Object?> get props =>
      [status, futureEvents, currentEvent, lastQueueTime];
}
