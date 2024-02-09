import 'dart:async';

import 'package:flutter/material.dart';

class Rebuilder extends StatefulWidget {
  const Rebuilder({
    super.key,
    required this.interval,
    required this.builder,
  });

  final Duration interval;
  final WidgetBuilder builder;

  @override
  State<Rebuilder> createState() => _RebuilderState();
}

class _RebuilderState extends State<Rebuilder> {
  Timer? _rebuildTimer;

  @override
  void initState() {
    super.initState();
    _rebuildTimer = Timer.periodic(widget.interval, (_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _rebuildTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }
}
