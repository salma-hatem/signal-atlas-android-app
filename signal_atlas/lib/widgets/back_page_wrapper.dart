import 'package:flutter/material.dart';

class BackPageWrapper extends StatelessWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  final Future<void> Function()? onRefresh;

  const BackPageWrapper({
    super.key,
    required this.title,
    required this.child,
    this.padding,
    this.scrollable = true,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),

            const SizedBox(width: 4),

            Expanded(
              child: Text(
                title,
                style: textTheme.headlineMedium,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Container(
          width: 80,
          height: 2,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(height: 16),

        scrollable
            ? child
            : Expanded(child: child),
      ],
    );

    if (scrollable) {
      content = onRefresh == null
          ? SingleChildScrollView(
              child: content,
            )
          : RefreshIndicator(
            onRefresh: onRefresh!,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: content,
            ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,

      // Swipe back
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null &&
            details.primaryVelocity! > 300) {
          Navigator.pop(context);
        }
      },

      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
            child: content,
          ),
        ),
      ),
    );
  }
}
