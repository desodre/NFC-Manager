import 'package:flutter/foundation.dart';

import '../models/tag_action.dart';
import '../models/tag_history_entry.dart';
import '../models/tag_result.dart';
import '../services/history_service.dart';
import '../services/nfc_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required this.nfcService, required this.historyService});

  final NfcService nfcService;
  final HistoryService historyService;
  NfcAction? running;
  TagResult? lastResult;
  String? error;
  List<TagHistoryEntry> history = [];
  bool historyLoading = true;

  Future<void> initialize() async {
    try {
      history = await historyService.load();
    } finally {
      historyLoading = false;
      notifyListeners();
    }
  }

  Future<TagResult> execute(
    NfcAction action, {
    String? text,
    bool asUrl = false,
  }) async {
    if (action == NfcAction.edit && (text == null || text.trim().isEmpty)) {
      error = 'Digite um texto ou URL para gravar.';
      notifyListeners();
      throw Exception(error);
    }
    running = action;
    error = null;
    notifyListeners();
    try {
      final result = await nfcService.run(
        action,
        text: text?.trim(),
        asUrl: asUrl,
      );
      lastResult = result;
      final entry = TagHistoryEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        action: action,
        type: result.type,
        capacity: result.capacity,
        writable: result.writable,
        records: result.records,
        timestamp: DateTime.now(),
      );
      await historyService.add(entry, history);
      history = [entry, ...history].take(50).toList();
      notifyListeners();
      return result;
    } catch (exception) {
      error = exception.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow;
    } finally {
      running = null;
      notifyListeners();
    }
  }

  void setError(String message) {
    error = message;
    notifyListeners();
  }

  Future<void> cancel() => nfcService.cancel();

  Future<void> deleteHistoryEntry(TagHistoryEntry entry) async {
    history = history.where((item) => item.id != entry.id).toList();
    await historyService.save(history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await historyService.clear();
    history = [];
    notifyListeners();
  }
}
