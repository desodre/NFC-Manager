import 'package:flutter/material.dart';

import '../models/tag_action.dart';
import '../viewmodels/home_view_model.dart';
import '../widgets/nfc_waiting_dialog.dart';
import 'manage_screen.dart';
import 'recent_tags_screen.dart';
import 'settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.viewModel, super.key});
  final HomeViewModel viewModel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final input = TextEditingController();
  int selectedIndex = 0;
  bool asUrl = false;

  HomeViewModel get viewModel => widget.viewModel;

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  Future<void> _execute(NfcAction action) async {
    if (action == NfcAction.edit && input.text.trim().isEmpty) {
      viewModel.setError('Digite um texto ou URL para gravar.');
      return;
    }
    final operation = viewModel.execute(action, text: input.text, asUrl: asUrl);
    final dialog = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          NfcWaitingDialog(action: action, onCancel: viewModel.cancel),
    );
    try {
      await operation;
      if (mounted && Navigator.of(context, rootNavigator: true).canPop())
        Navigator.of(context, rootNavigator: true).pop();
      await dialog;
    } catch (_) {
      if (mounted && Navigator.of(context, rootNavigator: true).canPop())
        Navigator.of(context, rootNavigator: true).pop();
      await dialog;
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: viewModel,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: Text(['Gerencie suas tags NFC', 'Tags recentes', 'Configurações'][selectedIndex], style: TextStyle(fontWeight: FontWeight.w700),),
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: [
          ManageScreen(
            running: viewModel.running != null,
            error: viewModel.error,
            lastResult: viewModel.lastResult,
            onRead: () => _execute(NfcAction.read),
            onEdit: () => _showEdit(context),
            onClean: () => _confirmClean(context),
          ),
          RecentTagsScreen(
            entries: viewModel.history,
            loading: viewModel.historyLoading,
            onDelete: viewModel.deleteHistoryEntry,
            onClear: viewModel.clearHistory,
          ),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: viewModel.running == null
            ? (index) => setState(() => selectedIndex = index)
            : null,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.nfc), label: 'Gerenciar'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Recentes'),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Configurações',
          ),
        ],
      ),
    ),
  );

  Future<void> _showEdit(BuildContext context) async {
    input.clear();
    asUrl = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Editar tag',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: input,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: asUrl ? 'URL' : 'Texto',
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SwitchListTile(
                title: const Text('Gravar como URL'),
                value: asUrl,
                onChanged: (value) => setSheetState(() => asUrl = value),
              ),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _execute(NfcAction.edit);
                },
                icon: const Icon(Icons.save),
                label: const Text('Aproximar e gravar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmClean(BuildContext context) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Limpar tag?'),
            content: const Text(
              'Todos os registros NDEF serão apagados. Essa operação não pode ser desfeita.',
            ),
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
    if (confirmed && mounted) _execute(NfcAction.clean);
  }
}
