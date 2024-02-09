import 'dart:io';

import 'package:buddy_bot/animated_eyes/animated_eyes_view.dart';
import 'package:buddy_bot/calendar_events/calendar_events.dart';
import 'package:buddy_bot/event_handling/event_handling.dart';
import 'package:buddy_bot/pose_detection/pose_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const HomePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const PoseDetectionProvider(
      child: CalendarEventsProvider(
        child: HomeView(),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final poseState = context.watch<PoseDetectionCubit>().state;

    return Scaffold(
      // TODO(jeroen-meijer): Get actual background color from Rive design.
      backgroundColor: Color.lerp(
        const Color(0xFF6C6C6C),
        const Color(0xFF7E7E7E),
        0.5,
      ),
      drawer: const Drawer(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: DebugInfo(),
        ),
      ),
      body: Row(
        children: [
          const Expanded(
            child: AnimatedEyesView(),
          ),
          AnimatedSize(
            alignment: Alignment.centerLeft,
            duration: const Duration(milliseconds: 1250),
            curve: Curves.fastLinearToSlowEaseIn,
            child: !poseState.facesDetected
                ? const SizedBox(
                    key: Key('eventHandling_noFaces'),
                    height: double.infinity,
                  )
                : const EventHandlingProvider(
                    key: Key('eventHandling'),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: EventHandlingView(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class DebugInfo extends StatelessWidget {
  const DebugInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final monospaceFont = Platform.isIOS ? 'Menlo' : 'monospace';

    return DefaultTextStyle(
      style: theme.textTheme.titleSmall!.copyWith(
        fontFamily: monospaceFont,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _PoseDebugView(),
                  Gap(16),
                  _EventsDebugView(),
                ],
              ),
            ),
          ),
          FloatingActionButton.extended(
            onPressed: () {
              context.read<CalendarEventsCubit>().addDebugEvent();
            },
            label: DefaultTextStyle.merge(
              style: TextStyle(fontFamily: monospaceFont),
              child: const Text('Add test event'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PoseDebugView extends StatelessWidget {
  const _PoseDebugView();

  String _formatFloat(double value) {
    return value.toStringAsFixed(3).padLeft(6);
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) {
      return 'null';
    }
    return dt.toString().split('-').last.substring(3);
  }

  @override
  Widget build(BuildContext context) {
    final poseState = context.watch<PoseDetectionCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'PoseDetectionCubit',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text('X: ${_formatFloat(poseState.x)}'),
        Text('Y: ${_formatFloat(poseState.y)}'),
        Text('Faces detected: ${poseState.facesDetected ? 'YES' : 'NO'}'),
        Text('Last updated: ${_formatDateTime(poseState.lastUpdated)}'),
        Text('Left hand: ${_formatFloat(poseState.leftHand)}'),
        Text('Right hand: ${_formatFloat(poseState.rightHand)}'),
      ],
    );
  }
}

class _EventsDebugView extends StatelessWidget {
  const _EventsDebugView();

  String _formatDateTime(DateTime? dt) {
    if (dt == null) {
      return 'null';
    }
    return dt.toString().split('-').last.substring(3);
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = context.watch<CalendarEventsCubit>().state;

    final currentEvent = eventsState.currentEvent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'CalendarEventsCubit',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text('Status: ${eventsState.status}'),
        Text('Last queue time: ${_formatDateTime(eventsState.lastQueueTime)}'),
        Text('Events: ${eventsState.futureEvents.length}'),
        for (final event in eventsState.futureEvents)
          ListTile(
            title: Text(event.name),
            subtitle: Text(event.id),
            trailing: Text(_formatDateTime(event.nextRemindDate)),
          ),
        Text('Current event: ${eventsState.currentEvent?.id}'),
        if (eventsState.currentEvent != null)
          ListTile(
            title: Text(currentEvent!.name),
            subtitle: Text(currentEvent.id),
            trailing: Text(_formatDateTime(currentEvent.nextRemindDate)),
          ),
      ],
    );
  }
}
