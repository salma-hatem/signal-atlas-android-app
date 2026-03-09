import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final List<String> items;
  final String selectedItem;
  final Function(String) onChanged;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
  });

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final GlobalKey _buttonKey = GlobalKey();

  void _showDropdownMenu(Color selectedColor) {
    final RenderBox button = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    final Size size = button.size;

    showMenu<String>(
      context: context,
      constraints: BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
      ),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 5,
        offset.dx + size.width,
        offset.dy,
      ),
      items: widget.items.map((item) {
        final bool isSelected = item == widget.selectedItem;
        return PopupMenuItem<String>(
          value: item,
          height: 32,
          padding: EdgeInsets.zero,
          child: Container(
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              item,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected ? selectedColor : null,
              ),
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) widget.onChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final maxTextWidth = _getMaxTextWidth(context);

    return GestureDetector(
      key: _buttonKey,
      onTap: () {_showDropdownMenu(colorScheme.primary);},
      child: Container(
        width: maxTextWidth + 60,
        constraints: BoxConstraints(minWidth: 112),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(10),
          color: colorScheme.surfaceContainer,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.selectedItem,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
          ],
        ),
      ),
    );
  }

  double _getMaxTextWidth(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
    );

    double maxWidth = 0;

    for (var item in widget.items) {
      final tp = TextPainter(
        text: TextSpan(text: item, style: textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      if (tp.width > maxWidth) maxWidth = tp.width;
    }

    return maxWidth;
  }
}