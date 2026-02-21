import 'package:flutter/material.dart';

class SignalBars extends StatelessWidget {
  final int strength; // 0 - 4
  final Color color;

  const SignalBars({
    super.key,
    required this.strength,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (index) {
        final isActive = index < strength;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1),
          width: 4,
          height: 6.0 + (index * 4),
          decoration: BoxDecoration(
            color: isActive
                ? color
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
