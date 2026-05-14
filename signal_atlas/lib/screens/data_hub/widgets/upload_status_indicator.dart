import 'package:flutter/material.dart';

import '../../../utilities/constants.dart';

class UploadStatusIndicator extends StatelessWidget {
  final UploadStatus status;
  final String? message;

  const UploadStatusIndicator({
    super.key,
    required this.status,
    this.message,
  });

  Color _color(ColorScheme scheme) {
    switch (status) {
      case UploadStatus.success:
        return scheme.primary;

      case UploadStatus.retrying:
        return scheme.secondary;

      case UploadStatus.failed:
        return scheme.error;

      case UploadStatus.idle:
        return scheme.outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final color = _color(colorScheme);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // animated dot
          status == UploadStatus.retrying
              ? _PulsingDot(color: color)
              : _StaticDot(color: color),

          const SizedBox(width: 8),

          // text
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              message ?? 'Idle',
              key: ValueKey(message),
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StaticDot extends StatelessWidget {
  final Color color;

  const _StaticDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;

  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller =
  AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final Animation<double> _scale =
  Tween(begin: 0.8, end: 1.3).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
