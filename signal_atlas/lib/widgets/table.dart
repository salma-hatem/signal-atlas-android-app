import 'package:flutter/material.dart';
import 'package:signal_atlas/models/sessions.dart';

class SessionColumn {
  final String title;
  final String Function(Session session)? valueBuilder;
  final Widget Function(Session session)? widgetBuilder;
  final TextAlign align;

  final EdgeInsetsGeometry padding;
  final int flex;
  final double iconSize;

  const SessionColumn({
    required this.title,
    this.valueBuilder,
    this.widgetBuilder,
    this.align = TextAlign.center,
    this.padding = const EdgeInsets.symmetric(
      vertical: 10,
      horizontal: 2,
    ),
    this.flex = 1,
    this.iconSize = 28,
  });
}

class SessionsTable extends StatelessWidget {
  final List<Session> sessions;
  final List<SessionColumn> columns;
  final bool scrollable;
  final int? maxRows;

  const SessionsTable({
    super.key,
    required this.sessions,
    required this.columns,
    this.scrollable = true,
    this.maxRows,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final displayedSessions =
    maxRows != null ? sessions.take(maxRows!).toList() : sessions;

    Widget list = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ListView.builder(
        physics: scrollable
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        shrinkWrap: !scrollable,
        itemCount: displayedSessions.length,
        itemBuilder: (context, idx) {
          final s = displayedSessions[idx];

          final bgColor = idx.isEven
              ? colorScheme.primary.withAlpha(15)
              : Colors.transparent;

          return Container(
            color: bgColor,
            padding: EdgeInsets.zero,
            child: Row(
              children: columns.map((col) {
                return Expanded(
                  flex: col.flex,
                  child: Padding(
                    padding: col.padding,
                    child: col.widgetBuilder != null
                        ? col.widgetBuilder!(s)
                        : Text(
                      col.valueBuilder!(s),
                      textAlign: col.align,
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(40),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: columns.map((col) {
              return Expanded(
                flex: col.flex,
                child: Padding(
                  padding: col.padding,
                  child: col.title.isEmpty
                      ? SizedBox(
                    width: col.iconSize,
                    height: col.iconSize,
                  )
                      : Text(
                    col.title,
                    textAlign: col.align,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 4),

        // Rows
        scrollable
        ? Expanded(child: list)
        : list,
      ],
    );
  }
}
