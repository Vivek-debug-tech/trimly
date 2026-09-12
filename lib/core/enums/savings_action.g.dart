// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'savings_action.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavingsActionAdapter extends TypeAdapter<SavingsAction> {
  @override
  final int typeId = 4;

  @override
  SavingsAction read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SavingsAction.reviewed;
      case 1:
        return SavingsAction.cancelled;
      case 2:
        return SavingsAction.kept;
      default:
        return SavingsAction.reviewed;
    }
  }

  @override
  void write(BinaryWriter writer, SavingsAction obj) {
    switch (obj) {
      case SavingsAction.reviewed:
        writer.writeByte(0);
        break;
      case SavingsAction.cancelled:
        writer.writeByte(1);
        break;
      case SavingsAction.kept:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavingsActionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
