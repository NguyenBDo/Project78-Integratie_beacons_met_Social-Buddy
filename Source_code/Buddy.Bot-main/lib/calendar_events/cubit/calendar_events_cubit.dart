import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:calendar_events_repository/calendar_events_repository.dart';
import 'package:equatable/equatable.dart';

part 'calendar_events_state.dart';

class CalendarEventsCubit extends Cubit<CalendarEventsState> {
  CalendarEventsCubit({
    required CalendarEventsRepository calendarEventsRepository,
  })  : _calendarEventsRepository = calendarEventsRepository,
        super(const CalendarEventsState());

  final CalendarEventsRepository _calendarEventsRepository;

  StreamSubscription<List<CalendarEvent>>? _currentEventsSubscription;

  Timer? _queueTimer;

  @override
  Future<void> close() async {
    _queueTimer?.cancel();
    await _currentEventsSubscription?.cancel();
    await super.close();
  }

  void _startQueueTimer() {
    _queueTimer?.cancel();
    _queueTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _queueCurrentEvent();
    });
  }

  /// Checks the state's [CalendarEventsState.futureEvents] for an event that
  /// should be handled now and places it in the
  /// [CalendarEventsState.currentEvent] field.
  void _queueCurrentEvent() {
    final now = DateTime.now();
    final currentEvent = state.futureEvents.cast<CalendarEvent?>().firstWhere(
          (e) => e!.shouldBeProcessedAt(now),
          orElse: () => null,
        );
    emit(
      CalendarEventsState(
        status: state.status,
        futureEvents: state.futureEvents,
        currentEvent: currentEvent,
        lastQueueTime: now,
      ),
    );
  }

  /// Subscribes to the [CalendarEventsRepository] to get updates on all future
  /// events and starts the queue timer.
  void subscribeToEvents() {
    _currentEventsSubscription =
        _calendarEventsRepository.futureEvents.listen((events) {
      emit(
        CalendarEventsState(
          status: CalendarEventsStatus.success,
          futureEvents: events,
          currentEvent: state.currentEvent,
        ),
      );
      _queueCurrentEvent();
    });
    _startQueueTimer();
  }

  void addDebugEvent() {
    _calendarEventsRepository.addDebugEvent();
  }

  void recordEventAcknowledgement({
    required CalendarEvent event,
    required bool? response,
  }) {
    _calendarEventsRepository.recordEventAcknowledgement(
      event: event,
      response: response,
    );
  }
}
