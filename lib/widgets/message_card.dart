import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({required this.text, super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.red.shade50,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Text(text, style: TextStyle(color: Colors.red.shade900)),
    ),
  );
}
