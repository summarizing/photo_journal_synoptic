import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/journal_entry.dart';

class JournalProvider extends ChangeNotifier {
  late Box<JournalEntry> _box;
  List<JournalEntry> _entries = [];

  List<JournalEntry> get entries => List.unmodifiable(_entries);
  int get totalEntries => _entries.length;

  JournalProvider() {
    _box = Hive.box<JournalEntry>('journal_entries');
    _loadEntries();
  }

  // Reads from Hive and sorts newest first.
  // Called after every write so the UI always reflects the current state.
  void _loadEntries() {
    _entries = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry) async {
    await _box.put(entry.id, entry);
    _loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _box.delete(id);
    _loadEntries();
  }
}
