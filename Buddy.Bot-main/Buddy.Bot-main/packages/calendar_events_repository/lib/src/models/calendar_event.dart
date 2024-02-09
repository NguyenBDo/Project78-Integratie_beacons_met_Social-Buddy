import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:simple_date/simple_date.dart';

/// {@template calendar_event}
/// A calendar event in Firebase.
/// {@endtemplate}
@immutable
class CalendarEvent extends Equatable {
  /// {@macro calendar_event}
  const CalendarEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.response,
    required this.category,
    required this.type,
    required this.start,
    required this.end,
    required this.nextRemindDate,
    required this.positiveResponse,
    required this.negativeResponse,
    required this.isHandled,
  });

  /// Creates a [CalendarEvent] from a JSON map.
  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      response: json['response'] == null ? null : {...json['response']},
      category: CalendarEventCategoryX.byIndex(json['type'] as int),
      type: (json['question'] as bool)
          ? CalendarEventType.question
          : CalendarEventType.notification,
      start: (json['startDate'] as Timestamp).toDate(),
      end: (json['endDate'] as Timestamp).toDate(),
      nextRemindDate: (json['nextRemindDate'] as Timestamp?)?.toDate() ??
          (json['startDate'] as Timestamp).toDate(),
      positiveResponse: json['question_yes'] as String? ?? '',
      negativeResponse: json['question_no'] as String? ?? '',
      isHandled: json['isHandled'] as bool,
    );
  }

  /// Converts this [CalendarEvent] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'startDate': start,
      'endDate': end,
      'nextRemindDate': nextRemindDate,
      'description': description,
      'type': category.index,
      'question': type == CalendarEventType.question,
      'question_yes': positiveResponse,
      'question_no': negativeResponse,
      'response': response,
      'isHandled': isHandled,
    };
  }

  /// Read-only. The unique identifier for this event. This is auto-generated
  /// when a new event is created.
  final String id;

  /// The name of this event.
  final String name;

  /// The description for this event.
  final String description;

  /// The responses given to this event's question.
  ///
  /// The keys represent the ISO-8601 date string of the response date.
  /// The values represent a map indicating the `decision` taken at the time of
  /// the response and the `handling_day` map which is a serialized version of
  /// a [SimpleDate].
  final Map<String, Map<String, dynamic>>? response;

  /// The category of this event.
  final CalendarEventCategory category;

  /// The type of this event.
  ///
  /// Can either be a [CalendarEventType.notification], which cannot repeat and
  /// is displayed only once, or a [CalendarEventType.question], which can be
  /// repeated and may be displayed multiple times.
  final CalendarEventType type;

  /// Indicates when the event starts.
  final DateTime start;

  /// Indicates when the event ends.
  final DateTime end;

  /// Indicates when the user should be reminded of this event next.
  ///
  /// In most cases, this is equal to [start], but will differ if the event
  /// is a repeating event.
  final DateTime nextRemindDate;

  /// The response to the user when they provide a positive answer to this
  /// event's question.
  ///
  /// Only applicable if [type] is [CalendarEventType.question].
  final String positiveResponse;

  /// The response to the user when they provide a negative answer to this
  /// event's question.
  ///
  /// Only applicable if [type] is [CalendarEventType.question].
  final String negativeResponse;

  /// Indicates if this event may repeat in the future.
  ///
  /// Will only be `true` [isHandled] is `false` and the type is
  /// [CalendarEventType.question].
  bool get willRepeat => type == CalendarEventType.question && !isHandled;

  /// Indicates if this event has been handled, meaning it will not be repeated
  /// anymore.
  ///
  /// A handled event will not be shown to the user, and can be considered
  /// completed.
  ///
  /// An event of type [CalendarEventType.notification] will immediately be
  /// considered handled upon first display.
  final bool isHandled;

  /// Indicates if this event should be shown to the user, given the provided
  /// [date].
  ///
  /// Returns `true` if the given [date] is equal to or after this event's
  /// [nextRemindDate] and [isHandled] is `false`.
  bool shouldBeProcessedAt(DateTime date) {
    return !isHandled && date.isAfter(nextRemindDate);
  }

  /// Returns a copy of this event with a new [nextRemindDate].
  ///
  /// This can only be called if [isHandled] is `false`. Otherwise, it will
  /// throw a [StateError], as updating the next remind date of a handled event
  /// is useless.
  CalendarEvent copyWithNextRemindDate(DateTime nextRemindDate) {
    if (isHandled) {
      throw StateError(
        'Cannot update the next remind date of a handled event.',
      );
    }
    return copyWith(nextRemindDate: nextRemindDate);
  }

  /// Returns a copy of this event with the [isHandled] flag set to `true`.
  ///
  /// This means this event will not be repeated anymore, and may no longer be
  /// shown to the user.
  CalendarEvent copyAsHandledWithResponse() {
    return copyWith(isHandled: true);
  }

  @override
  List<Object?> get props {
    return [
      id,
      name,
      description,
      response,
      category,
      type,
      start,
      end,
      nextRemindDate,
      positiveResponse,
      negativeResponse,
      isHandled,
    ];
  }

  /// Creates a copy of this event with the given fields updated.
  CalendarEvent copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, Map<String, dynamic>>? response,
    CalendarEventCategory? category,
    CalendarEventType? type,
    DateTime? start,
    DateTime? end,
    DateTime? nextRemindDate,
    String? positiveResponse,
    String? negativeResponse,
    bool? isHandled,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      response: response ?? this.response,
      category: category ?? this.category,
      type: type ?? this.type,
      start: start ?? this.start,
      end: end ?? this.end,
      nextRemindDate: nextRemindDate ?? this.nextRemindDate,
      positiveResponse: positiveResponse ?? this.positiveResponse,
      negativeResponse: negativeResponse ?? this.negativeResponse,
      isHandled: isHandled ?? this.isHandled,
    );
  }
}

/// The type of event.
///
/// Can either be a [CalendarEventType.notification], which cannot repeat and
/// is displayed only once, or a [CalendarEventType.question], which can be
/// repeated and may be displayed multiple times.
enum CalendarEventType {
  /// A notification event.
  ///
  /// This event will only be displayed once, and will not be repeated.
  notification,

  /// A question event.
  ///
  /// This event can be repeated and may be displayed multiple times.
  question,
}

/// The category of calendar event.
enum CalendarEventCategory {
  /// A calendar event related to food.
  food,

  /// A calendar event related to a doctor's appointment.
  doctor,

  /// A calendar event related to music.
  music,

  /// A calendar event related to medication.
  medication,

  /// A calendar event related to meeting people, such as family visits.
  people,

  /// Other calendar events.
  unknown,
}

/// Extensions on [CalendarEventCategory] for convenience.
extension CalendarEventCategoryX on CalendarEventCategory {
  /// Returns the [CalendarEventCategory] represented by the given index.
  ///
  /// When no event type exists for the given index,
  /// [CalendarEventCategory.unknown] is returned.
  static CalendarEventCategory byIndex(int index) {
    try {
      return CalendarEventCategory.values.elementAt(index);
      // ignore: avoid_catching_errors
    } on RangeError {
      return CalendarEventCategory.unknown;
    }
  }
}
