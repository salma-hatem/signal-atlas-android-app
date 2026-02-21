import 'package:flutter/material.dart';

class SingleAccordion extends StatefulWidget {
  final Widget collapsedWidget;
  final Widget expandedWidget;
  final Color backgroundColor;
  final Color expandedColor;
  final Color arrowColor;
  final Color borderColor;

  const SingleAccordion({
    required this.collapsedWidget,
    required this.expandedWidget,
    required this.backgroundColor,
    required this.expandedColor,
    required this.arrowColor,
    required this.borderColor,
    super.key,
  });

  @override
  State<SingleAccordion> createState() => _SingleAccordionState();
}

class _SingleAccordionState extends State<SingleAccordion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  void toggle() {
    setState(() {
      isExpanded = !isExpanded;

      if (isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: isExpanded ? widget.expandedColor : widget.backgroundColor,
        borderRadius: BorderRadius.circular(16),
          // border: Border(
          //   left: BorderSide(
          //     color: widget.borderColor,
          //     width: 2,
          //   ),
          // )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------------
          // Collapsed / Header
          // ---------------------------------------------------
          InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: toggle,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 16,
                bottom: 0,
                right: 16,
                left: 16,
              ),
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.collapsedWidget,
                    // ---------------------------------------------------
                    // Arrow Icon
                    // ---------------------------------------------------
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        color: widget.arrowColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ---------------------------------------------------
          // Expanded Content
          // ---------------------------------------------------
          SizeTransition(
            axisAlignment: 1.0,
            sizeFactor: _animation,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 0,
                  bottom: 12,
                  right: 16,
                  left: 16,
                ),
                decoration: BoxDecoration(
                  // color: colorScheme.surface,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    widget.expandedWidget,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
