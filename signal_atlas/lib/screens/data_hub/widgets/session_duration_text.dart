import 'package:flutter/material.dart';
import 'dart:async';
import 'package:signal_atlas/providers/sessions_provider.dart';
import 'package:signal_atlas/utilities/timestamp_format.dart';

class SessionDurationText extends StatefulWidget {
  final SessionProvider provider;

  const SessionDurationText(this.provider, {super.key});

  @override
  State<SessionDurationText> createState() => _SessionDurationTextState();
}

class _SessionDurationTextState extends State<SessionDurationText> {
  late final Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.provider.liveDuration;

    return Text(
      formatDuration(d),
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
