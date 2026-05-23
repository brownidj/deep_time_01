import 'package:flutter/material.dart';

Future<void> showTimelineExplanationDialog({
  required BuildContext context,
  required String title,
  required String explanation,
}) {
  if (explanation.trim().isEmpty) {
    return Future.value();
  }
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(explanation)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}
