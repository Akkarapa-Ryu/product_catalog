
import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onAction;
  final String actionLabel;

  const EmptyWidget({
    super.key,
    this.message = 'No products found.',
    this.onAction,
    this.actionLabel = 'Clear Filters',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'No Products Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
