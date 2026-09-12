// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'importance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ImportanceAdapter extends TypeAdapter<Importance> {
  @override
  final int typeId = 1;

  @override
  Importance read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Importance.high;
      case 1:
        return Importance.medium;
      case 2:
        return Importance.low;
      default:
        return Importance.high;
    }
  }

  @override
  void write(BinaryWriter writer, Importance obj) {
    switch (obj) {
      case Importance.high:
        writer.writeByte(0);
        break;
      case Importance.medium:
        writer.writeByte(1);
        break;
      case Importance.low:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImportanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
