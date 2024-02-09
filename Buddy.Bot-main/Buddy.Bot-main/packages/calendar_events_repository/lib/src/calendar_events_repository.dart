import 'dart:async';
import 'dart:math';

import 'package:calendar_events_repository/calendar_events_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as db;
import 'package:rxdart/rxdart.dart';

/// {@template calendar_events_repository}
/// A repository responsible for managing events.
/// {@endtemplate}
class CalendarEventsRepository {
  /// {@macro calendar_events_repository}
  CalendarEventsRepository({
    required String userDocumentId,
  }) : _userDocumentId = userDocumentId {
    _startEventsSubscription();
  }

  final String _userDocumentId;
  final _futureEvents = BehaviorSubject<List<CalendarEvent>>.seeded([]);

  db.FirebaseFirestore get _db => db.FirebaseFirestore.instance;

  late StreamSubscription<db.QuerySnapshot<Map<String, dynamic>>>
      _eventsSubscription;

  static const _usersCollection = 'bots';
  static const _eventsSubcollection = 'Events';

  void _startEventsSubscription() {
    _eventsSubscription = _db
        .collection(_usersCollection)
        .doc(_userDocumentId)
        .collection(_eventsSubcollection)
        .where('isHandled', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      final events = snapshot.docs.map((doc) {
        return CalendarEvent.fromJson(doc.data());
      });
      _futureEvents.add(events.toList());
    });
  }

  /// The amount of time between a repeatable calendar event being shown for the
  /// first time and the next time it will be shown.
  static const repetitionInterval = Duration(minutes: 30);

  /// A stream of all unhandled events queued for the future.
  ///
  /// Can be listened to, but the current value can also be retrieved using
  /// `futureEvents.value`.
  ValueStream<List<CalendarEvent>> get futureEvents => _futureEvents.stream;

  /// Adds an event to the current user's events collection for debugging
  /// purposes.
  Future<void> addDebugEvent() async {
    final doc = _db
        .collection(_usersCollection)
        .doc(_userDocumentId)
        .collection(_eventsSubcollection)
        .doc();

    final startDate = DateTime.now();

    await doc.set(
      CalendarEvent(
        id: doc.id,
        name: 'Debug event ${DateTime.now()}',
        start: startDate,
        nextRemindDate: startDate,
        end: startDate.add(const Duration(hours: 1)),
        description: 'A debug event used for testing purposes.',
        response: const {},
        category: CalendarEventCategory
            .values[Random().nextInt(CalendarEventCategory.values.length)],
        type: CalendarEventType.question,
        positiveResponse: 'Positive response string.',
        negativeResponse: 'Negative response string.',
        isHandled: false,
      ).toJson(),
    );
  }

  /// Records a response for the given event.
  ///
  /// If the event is a question, has repetitions queued and the response is
  /// negative, the event will not be marked as handled, but instead will be
  /// repeated with the next repetition date.
  ///
  /// See [repetitionInterval] for the interval between repetitions.
  Future<void> recordEventAcknowledgement({
    required CalendarEvent event,
    required bool? response,
  }) async {
    assert(
      event.type != CalendarEventType.question || response != null,
      'A response must be provided for a question event.',
    );

    final doc = _db
        .collection(_usersCollection)
        .doc(_userDocumentId)
        .collection(_eventsSubcollection)
        .doc(event.id);

    if (!(await doc.get()).exists) {
      return;
    }

    final newEvent = (event.type == CalendarEventType.notification || response!)
        ? event.copyAsHandledWithResponse()
        : event.copyWithNextRemindDate(DateTime.now().add(repetitionInterval));

    await doc.set(newEvent.toJson());
  }

  /// Disposes the repository.
  void dispose() {
    _eventsSubscription.cancel();
  }
}
