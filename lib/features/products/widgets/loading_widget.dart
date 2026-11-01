
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({
    super.key,
    this.message = 'Loading products...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
