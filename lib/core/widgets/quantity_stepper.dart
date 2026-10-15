import 'package:flutter/material.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    this.compact = false,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 18.0 : 20.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            tooltip: 'Decrease quantity',
            onPressed: onDecrease,
            size: iconSize,
          ),
          SizedBox(
            width: compact ? 26 : 34,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                '$quantity',
                key: ValueKey(quantity),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            tooltip: 'Increase quantity',
            onPressed: onIncrease,
            size: iconSize,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.size,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      iconSize: size,
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}
