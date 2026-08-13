import 'package:flutter/material.dart';

import '../models/tag_result.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({required this.result, super.key});
  final TagResult result;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resultado',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text('Tipo: \${result.type}'),
          Text('Capacidade: ${result.capacity} bytes'),
          Text('Gravável: ${result.writable ? 'sim' : 'não'}'),
          const Divider(),
          Text(
            result.records.isEmpty
                ? 'Tag sem registros NDEF.'
                : result.records.map((item) => '• \$item').join('\n'),
          ),
        ],
      ),
    ),
  );
}
