import 'package:hive/hive.dart';

part 'decision_status.g.dart';

@HiveType(typeId: 2)
enum DecisionStatus {
  @HiveField(0)
  keep,
  @HiveField(1)
  review,
  @HiveField(2)
  cut,
  @HiveField(3)
  notEnoughInfo,
}
