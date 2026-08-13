import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/tag_history_entry.dart';

class HistoryService {
  static const _key = 'tag_history';

  Future<List<TagHistoryEntry>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getStringList(_key) ?? [];
    return raw
        .map((item) {
          try {
            return TagHistoryEntry.fromJson(
              jsonDecode(item) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<TagHistoryEntry>()
        .toList();
  }

  Future<void> save(List<TagHistoryEntry> entries) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _key,
      entries.take(50).map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }

  Future<void> add(TagHistoryEntry entry, List<TagHistoryEntry> current) =>
      save([entry, ...current]);

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
