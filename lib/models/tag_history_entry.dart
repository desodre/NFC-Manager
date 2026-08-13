import 'tag_action.dart';

class TagHistoryEntry {
  const TagHistoryEntry({
    required this.id,
    required this.action,
    required this.type,
    required this.capacity,
    required this.writable,
    required this.records,
    required this.timestamp,
  });

  final String id;
  final NfcAction action;
  final String type;
  final int capacity;
  final bool writable;
  final List<String> records;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action.name,
    'type': type,
    'capacity': capacity,
    'writable': writable,
    'records': records,
    'timestamp': timestamp.toIso8601String(),
  };

  factory TagHistoryEntry.fromJson(Map<String, dynamic> json) =>
      TagHistoryEntry(
        id: json['id'] as String,
        action: NfcAction.values.byName(json['action'] as String),
        type: json['type'] as String,
        capacity: json['capacity'] as int,
        writable: json['writable'] as bool,
        records: List<String>.from(json['records'] as List),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
