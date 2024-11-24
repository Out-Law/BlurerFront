import 'package:flutter/material.dart';

class HighlightedContainer extends StatelessWidget {
  final bool highlighted;
  final String message;
  final Widget child;

  const HighlightedContainer({
    Key? key,
    required this.highlighted,
    required this.message,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? Colors.red.shade100 : Colors.grey.shade900,
        border: Border.all(
          color: highlighted ? Colors.red : Colors.blueGrey.shade700,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          child, // Дочерний виджет передается извне
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.file_upload,
                  size: 50,
                  color: highlighted ? Colors.red : Colors.grey.shade400,
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: highlighted ? Colors.red : Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
