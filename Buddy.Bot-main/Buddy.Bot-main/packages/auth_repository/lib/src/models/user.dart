import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// {@template user}
/// A user.
/// {@endtemplate}
@immutable
class User extends Equatable {
  /// {@macro user}
  const User({
    required this.id,
    this.emailAddress,
  });

  /// The user's unique Firebase ID.
  final String id;

  /// The user's email address, if available.
  final String? emailAddress;

  /// Converts this [User] to a JSON map.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      if (emailAddress != null) 'email_address': emailAddress,
    };
  }

  @override
  List<Object?> get props => [id, emailAddress];
}
