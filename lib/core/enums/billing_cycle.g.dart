// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_cycle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillingCycleAdapter extends TypeAdapter<BillingCycle> {
  @override
  final int typeId = 3;

  @override
  BillingCycle read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BillingCycle.weekly;
      case 1:
        return BillingCycle.monthly;
      case 2:
        return BillingCycle.quarterly;
      case 3:
        return BillingCycle.yearly;
      default:
        return BillingCycle.weekly;
    }
  }

  @override
  void write(BinaryWriter writer, BillingCycle obj) {
    switch (obj) {
      case BillingCycle.weekly:
        writer.writeByte(0);
        break;
      case BillingCycle.monthly:
        writer.writeByte(1);
        break;
      case BillingCycle.quarterly:
        writer.writeByte(2);
        break;
      case BillingCycle.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillingCycleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
