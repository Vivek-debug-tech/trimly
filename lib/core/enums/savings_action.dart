import 'package:hive/hive.dart';

part 'savings_action.g.dart';

@HiveType(typeId: 4)
enum SavingsAction {
  @HiveField(0)
  reviewed,
  @HiveField(1)
  cancelled,
  @HiveField(2)
  kept,
}
