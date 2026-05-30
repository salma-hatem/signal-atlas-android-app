import 'package:flutter/material.dart';

class TableColumn<T> {
  final String title;
  final String Function(T item)? valueBuilder;
  final Widget Function(T item)? widgetBuilder;
  final TextAlign align;

  final EdgeInsetsGeometry padding;
  final int flex;
  final double iconSize;

  const TableColumn({
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

class AppTable<T> extends StatelessWidget {
  final List<T> items;
  final List<TableColumn<T>> columns;
  final bool scrollable;
  final int? maxRows;

  const AppTable({
    super.key,
    required this.items,
    required this.columns,
    this.scrollable = true,
    this.maxRows,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final displayed =
    maxRows != null ? items.take(maxRows!).toList() : items;

    final list = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ListView.builder(
        physics: scrollable
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        shrinkWrap: !scrollable,
        itemCount: displayed.length,
        itemBuilder: (context, idx) {
          final item = displayed[idx];

          final bgColor = idx.isEven
              ? colorScheme.primary.withAlpha(15)
              : Colors.transparent;

          return Container(
            color: bgColor,
            child: Row(
              children:  [
                const SizedBox(width: 8),

                ...columns.map((col) {
                  return Expanded(
                    flex: col.flex,
                    child: Padding(
                      padding: col.padding,
                      child: col.widgetBuilder != null
                          ? col.widgetBuilder!(item)
                          : Text(
                        col.valueBuilder!(item),
                        textAlign: col.align,
                      ),
                    ),
                  );
                }),

                const SizedBox(width: 8),
              ],
            ),
          );
        },
      ),
    );

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(40),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),

              ...columns.map((col) {
                return Expanded(
                  flex: col.flex,
                  child: Padding(
                    padding: col.padding,
                    child: Text(
                      col.title,
                      textAlign: col.align,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),

              const SizedBox(width: 8),
            ],
          ),
        ),

        const SizedBox(height: 4),

        scrollable ? Expanded(child: list) : list,
      ],
    );
  }
}
