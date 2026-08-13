import 'package:flutter/material.dart';

import '../models/tag_action.dart';
import '../models/tag_history_entry.dart';

class RecentTagsScreen extends StatelessWidget {
  const RecentTagsScreen({
    required this.entries,
    required this.loading,
    required this.onDelete,
    required this.onClear,
    super.key,
  });
  final List<TagHistoryEntry> entries;
  final bool loading;
  final Future<void> Function(TagHistoryEntry entry) onDelete;
  final Future<void> Function() onClear;

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Nenhuma tag recente',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('As operações realizadas aparecerão aqui.'),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            // const Expanded(
            //   child: Text(
            //     'Tags recentes',
            //     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            //   ),
            // ),
            TextButton.icon(
              onPressed: () => _confirmClear(context),
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Limpar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...entries.map(
          (entry) => Card(
            child: ListTile(
              leading: CircleAvatar(child: Icon(_icon(entry.action))),
              title: Text('\${_label(entry.action)} • \${entry.type}'),
              subtitle: Text(
                '${entry.records.isEmpty ? 'Sem registros NDEF' : entry.records.first}\\n\${_date(entry.timestamp)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onDelete(entry),
              ),
              onTap: () => _showDetails(context, entry),
            ),
          ),
        ),
      ],
    );
  }

  String _date(DateTime timestamp) {
    final local = timestamp.toLocal();
    final now = DateTime.now();
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day)
      return 'Hoje, \$time';
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/\${local.year} • \$time';
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Limpar histórico?'),
            content: const Text('Todas as operações recentes serão removidas.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Limpar'),
              ),
            ],
          ),
        ) ??
        false;
    if (confirmed) await onClear();
  }

  void _showDetails(
    BuildContext context,
    TagHistoryEntry entry,
  ) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('\${_label(entry.action)} • \${entry.type}'),
      content: Text(
        'Data: \${_date(entry.timestamp)}\\nCapacidade: \${entry.capacity} bytes\\nGravável: ${entry.writable ? 'sim' : 'não'} ${entry.records.isEmpty ? 'Tag sem registros NDEF.' : entry.records.map((item) => '• $item').join('\\n')}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    ),
  );

  static String _label(NfcAction action) => switch (action) {
    NfcAction.read => 'Read',
    NfcAction.edit => 'Edit',
    NfcAction.clean => 'Clean',
  };
  static IconData _icon(NfcAction action) => switch (action) {
    NfcAction.read => Icons.visibility_outlined,
    NfcAction.edit => Icons.edit_outlined,
    NfcAction.clean => Icons.delete_outline,
  };
}
