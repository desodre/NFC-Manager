import 'package:flutter/material.dart';

import '../models/tag_result.dart';
import '../widgets/action_card.dart';
import '../widgets/message_card.dart';
import '../widgets/result_card.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({
    required this.running,
    required this.error,
    required this.lastResult,
    required this.onRead,
    required this.onEdit,
    required this.onClean,
    super.key,
  });
  final bool running;
  final String? error;
  final TagResult? lastResult;
  final VoidCallback onRead;
  final VoidCallback onEdit;
  final VoidCallback onClean;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      // const Text(
      //   'Gerencie suas tags NFC',
      //   style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
      // ),
      const SizedBox(height: 8),
      Text(
        'Leia, edite ou limpe tags NDEF diretamente no Android.',
        style: TextStyle(color: Colors.grey.shade700),
      ),
      const SizedBox(height: 24),
      ActionCard(
        icon: Icons.nfc,
        title: 'Read tag',
        subtitle: 'Ler conteúdo e informações da tag',
        color: Colors.teal,
        onTap: running ? null : onRead,
      ),
      ActionCard(
        icon: Icons.edit_note,
        title: 'Edit tag',
        subtitle: 'Gravar texto ou URL na tag',
        color: Colors.blue,
        onTap: running ? null : onEdit,
      ),
      ActionCard(
        icon: Icons.delete_outline,
        title: 'Clean tag',
        subtitle: 'Apagar todos os registros NDEF',
        color: Colors.deepOrange,
        onTap: running ? null : onClean,
      ),
      if (error != null) MessageCard(text: error!),
      if (lastResult != null) ResultCard(result: lastResult!),
    ],
  );
}
