import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 0)
class JournalEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String caption;

  @HiveField(2)
  final String imagePath;

  @HiveField(3)
  final DateTime createdAt;

  JournalEntry({
    required this.id,
    required this.caption,
    required this.imagePath,
    required this.createdAt,
  });
}
