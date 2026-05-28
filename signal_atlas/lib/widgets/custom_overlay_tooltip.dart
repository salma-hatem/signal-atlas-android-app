import 'package:flutter/material.dart';

class CustomOverlayTooltip extends StatefulWidget {
  final Widget child;
  final String tooltip;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  final Duration showDuration;

  const CustomOverlayTooltip({
    super.key,
    required this.child,
    required this.tooltip,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.showDuration = const Duration(seconds: 2),
  });

  @override
  State<CustomOverlayTooltip> createState() =>
      _CustomOverlayTooltipState();
}

class _CustomOverlayTooltipState
    extends State<CustomOverlayTooltip> {
  OverlayEntry? _entry;

  void _showTooltip() async {
    if (_entry != null) return;

    final overlay = Overlay.of(context);
    final renderBox =
    context.findRenderObject() as RenderBox;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    final colorScheme = Theme.of(context).colorScheme;

    _entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: position.dx,
          top: position.dy - 50,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor ??
                    colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.borderColor ??
                      colorScheme.outline.withAlpha(100),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withAlpha(30),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.tooltip,
                style: TextStyle(
                  color: widget.textColor ??
                      colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_entry!);

    await Future.delayed(widget.showDuration);

    _hideTooltip();
  }

  void _hideTooltip() {
    _entry?.remove();
    _entry = null;
  }

  @override
  void dispose() {
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showTooltip,
      borderRadius: BorderRadius.circular(6),
      child: widget.child,
    );
  }
}
