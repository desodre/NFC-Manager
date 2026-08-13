import 'package:flutter/material.dart';

import '../models/tag_action.dart';

class NfcWaitingDialog extends StatelessWidget {
  const NfcWaitingDialog({
    required this.action,
    required this.onCancel,
    super.key,
  });
  final NfcAction action;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final label = switch (action) {
      NfcAction.read => 'Lendo tag',
      NfcAction.edit => 'Preparando gravação',
      NfcAction.clean => 'Preparando limpeza',
    };
    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(label),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            Icon(Icons.nfc, size: 56, color: Colors.teal),
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Aproxime uma tag NFC da parte traseira do aparelho.\n\nVocê tem 5 segundos.',
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        ],
      ),
    );
  }
}
