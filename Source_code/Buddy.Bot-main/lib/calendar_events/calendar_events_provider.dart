import 'package:buddy_bot/auth/auth.dart';
import 'package:buddy_bot/calendar_events/calendar_events.dart';
import 'package:calendar_events_repository/calendar_events_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarEventsProvider extends StatelessWidget {
  const CalendarEventsProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      lazy: false,
      create: (context) => CalendarEventsRepository(
        userDocumentId:
            context.read<AuthCubit>().state.currentUser!.emailAddress!,
      ),
      child: BlocProvider(
        create: (context) => CalendarEventsCubit(
          calendarEventsRepository: context.read<CalendarEventsRepository>(),
        )..subscribeToEvents(),
        child: child,
      ),
    );
  }
}
