// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usage_frequency.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UsageFrequencyAdapter extends TypeAdapter<UsageFrequency> {
  @override
  final int typeId = 0;

  @override
  UsageFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UsageFrequency.daily;
      case 1:
        return UsageFrequency.severalPerWeek;
      case 2:
        return UsageFrequency.weekly;
      case 3:
        return UsageFrequency.monthly;
      case 4:
        return UsageFrequency.rarely;
      case 5:
        return UsageFrequency.never;
      default:
        return UsageFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, UsageFrequency obj) {
    switch (obj) {
      case UsageFrequency.daily:
        writer.writeByte(0);
        break;
      case UsageFrequency.severalPerWeek:
        writer.writeByte(1);
        break;
      case UsageFrequency.weekly:
        writer.writeByte(2);
        break;
      case UsageFrequency.monthly:
        writer.writeByte(3);
        break;
      case UsageFrequency.rarely:
        writer.writeByte(4);
        break;
      case UsageFrequency.never:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsageFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
