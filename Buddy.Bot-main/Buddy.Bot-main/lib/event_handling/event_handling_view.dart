import 'package:buddy_bot/event_handling/event_handling.dart';
import 'package:calendar_events_repository/calendar_events_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';

class EventHandlingView extends StatelessWidget {
  const EventHandlingView({super.key});

  static const _positiveResponseColor = Color(0xFF3DA100);
  static const _negativeResponseColor = Color(0xFFDC8F00);

  IconData _getIconForEventCategory(CalendarEventCategory category) {
    switch (category) {
      case CalendarEventCategory.medication:
        return FontAwesomeIcons.pills;
      case CalendarEventCategory.people:
        return FontAwesomeIcons.userGroup;
      case CalendarEventCategory.music:
        return FontAwesomeIcons.music;
      case CalendarEventCategory.food:
        return FontAwesomeIcons.calendarDays;
      case CalendarEventCategory.doctor:
        return FontAwesomeIcons.userNurse;
      case CalendarEventCategory.unknown:
        return FontAwesomeIcons.question;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final state = context.watch<EventHandlingCubit>().state;

    final size = MediaQuery.of(context).size;
    final width = size.width / 3;

    final isQuestion = state.currentEvent?.type == CalendarEventType.question;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        height: double.infinity,
        width: width,
        child: Card(
          key: Key('eventHandlingView_drawer_status-${state.status.name}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DefaultTextStyle.merge(
              style: textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.status == EventHandlingStatus.idle) ...[
                    Text(
                      'Geen actief event',
                      style: textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    Text(
                      state.currentEvent!.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          _getIconForEventCategory(
                            state.currentEvent!.category,
                          ),
                          size: 100,
                          color: isQuestion &&
                                  state.status == EventHandlingStatus.responded
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black,
                        ),
                        if (isQuestion &&
                            state.status == EventHandlingStatus.responded)
                          Icon(
                            state.currentResponse == true
                                ? FontAwesomeIcons.check
                                : FontAwesomeIcons.xmark,
                            size: 100,
                            color: state.currentResponse == true
                                ? _positiveResponseColor
                                : _negativeResponseColor,
                          ),
                      ],
                    ),
                    const Spacer(),
                    if (isQuestion) ...[
                      _LargeElevatedButton(
                        color: _positiveResponseColor,
                        onPressed:
                            state.status != EventHandlingStatus.responding
                                ? null
                                : () {
                                    context
                                        .read<EventHandlingCubit>()
                                        .processResponse(response: true);
                                  },
                        // TODO(jeroen-meijer): Intl.
                        child: const Text('Gedaan'),
                      ),
                      const Gap(16),
                      _LargeElevatedButton(
                        color: _negativeResponseColor,
                        onPressed:
                            state.status != EventHandlingStatus.responding
                                ? null
                                : () {
                                    context
                                        .read<EventHandlingCubit>()
                                        .processResponse(response: false);
                                  },
                        // TODO(jeroen-meijer): Intl.
                        child: const Text('Vergeten'),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LargeElevatedButton extends StatelessWidget {
  const _LargeElevatedButton({
    required this.color,
    required this.onPressed,
    required this.child,
  });

  final Color color;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: 100,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: color,
        ),
        onPressed: onPressed,
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.headlineSmall?.fontSize,
          ),
          child: child,
        ),
      ),
    );
  }
}
