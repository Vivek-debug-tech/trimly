import 'package:hive/hive.dart';

part 'usage_frequency.g.dart';

@HiveType(typeId: 0)
enum UsageFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  severalPerWeek,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
  @HiveField(4)
  rarely,
  @HiveField(5)
  never,
}
