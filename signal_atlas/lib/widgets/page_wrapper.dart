import 'package:flutter/material.dart';

class PageWrapper extends StatefulWidget {
  final String title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;
  final bool keepAlive;

  const PageWrapper({
    Key? key,
    required this.title,
    required this.child,
    this.padding,
    this.scrollable = true,
    this.keepAlive = true,
  }) : super(key: key);

  @override
  State<PageWrapper> createState() => _PageWrapperState();
}

class _PageWrapperState extends State<PageWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.keepAlive;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(widget.title, style: textTheme.headlineMedium),
        const SizedBox(height: 12),
        Container(
          width: 80,
          height: 2,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 16),
        widget.child,
      ],
    );

    if (widget.scrollable) {
      content = SingleChildScrollView(child: content);
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: content,
        ),
      ),
    );
  }
}