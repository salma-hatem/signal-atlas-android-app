import 'package:flutter/material.dart';

OverlayEntry? _currentOverlay;
AnimationController? _currentController;

void showCustomSnackBar(
    BuildContext context,
    String message,
    {double maxWidth = 220}) {

  final overlay = Overlay.of(context);
  final colorScheme = Theme.of(context).colorScheme;

  // if one already exists, remove it
  _currentController?.stop();
  _currentController?.dispose();
  _currentOverlay?.remove();

  late OverlayEntry overlayEntry;
  late AnimationController controller;

  controller = AnimationController(
    vsync: Navigator.of(context),
    duration: const Duration(milliseconds: 350),
  );

  final offsetAnimation = Tween<Offset>(
    begin: const Offset(1.2, 0),  // off screen
    end: const Offset(0, 0),  // original position
  ).animate(
    CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ),
  );

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 45,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: offsetAnimation,
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withAlpha(100),
                width: 0.2,
              ),
            ),
            child: Text(
              message,
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ),
      ),
    ),
  );

  _currentOverlay = overlayEntry;
  _currentController = controller;

  overlay.insert(overlayEntry);
  controller.forward();

  Future.delayed(const Duration(seconds: 3)).then((_) async {
    if (_currentOverlay == overlayEntry) {
      await controller.reverse();
      overlayEntry.remove();
      controller.dispose();
      _currentOverlay = null;
      _currentController = null;
    }
  });
}
