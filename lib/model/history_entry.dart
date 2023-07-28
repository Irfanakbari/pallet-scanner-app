import 'package:hive/hive.dart';

part "history_entry.g.dart";

@HiveType(typeId: 0)
class HistoryEntry extends HiveObject {
  @HiveField(0)
  String qr;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String status;

  HistoryEntry({required this.qr, required this.date, required this.status});
}
