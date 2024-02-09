part of 'event_handling_cubit.dart';

enum EventHandlingStatus { idle, responding, responded }

class EventHandlingState extends Equatable {
  const EventHandlingState({
    this.status = EventHandlingStatus.idle,
    this.currentEvent,
    this.currentResponse,
    this.nextEvent,
  });

  final EventHandlingStatus status;
  final CalendarEvent? currentEvent;
  final bool? currentResponse;
  final CalendarEvent? nextEvent;

  @override
  List<Object?> get props => [status, currentEvent, currentResponse, nextEvent];

  EventHandlingState copyWith({
    EventHandlingStatus? status,
    CalendarEvent? currentEvent,
    bool? currentResponse,
    CalendarEvent? nextEvent,
  }) {
    return EventHandlingState(
      status: status ?? this.status,
      currentEvent: currentEvent ?? this.currentEvent,
      currentResponse: currentResponse ?? this.currentResponse,
      nextEvent: nextEvent ?? this.nextEvent,
    );
  }

  EventHandlingState copyWithout({
    bool currentEvent = false,
    bool currentResponse = false,
    bool nextEvent = false,
  }) {
    return EventHandlingState(
      status: status,
      currentEvent: currentEvent ? null : this.currentEvent,
      currentResponse: currentResponse ? null : this.currentResponse,
      nextEvent: nextEvent ? null : this.nextEvent,
    );
  }
}
