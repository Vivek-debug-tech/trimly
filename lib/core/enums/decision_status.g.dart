// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'decision_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DecisionStatusAdapter extends TypeAdapter<DecisionStatus> {
  @override
  final int typeId = 2;

  @override
  DecisionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DecisionStatus.keep;
      case 1:
        return DecisionStatus.review;
      case 2:
        return DecisionStatus.cut;
      case 3:
        return DecisionStatus.notEnoughInfo;
      default:
        return DecisionStatus.keep;
    }
  }

  @override
  void write(BinaryWriter writer, DecisionStatus obj) {
    switch (obj) {
      case DecisionStatus.keep:
        writer.writeByte(0);
        break;
      case DecisionStatus.review:
        writer.writeByte(1);
        break;
      case DecisionStatus.cut:
        writer.writeByte(2);
        break;
      case DecisionStatus.notEnoughInfo:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DecisionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
