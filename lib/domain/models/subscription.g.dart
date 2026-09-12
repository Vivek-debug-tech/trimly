// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 10;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      id: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      price: fields[3] as double,
      currency: fields[4] as String,
      billingCycle: fields[5] as BillingCycle,
      nextRenewalDate: fields[6] as DateTime,
      trialEndDate: fields[7] as DateTime?,
      postTrialPrice: fields[8] as double?,
      usageFrequency: fields[9] as UsageFrequency?,
      importance: fields[10] as Importance?,
      impactScore: fields[11] as double?,
      decisionStatus: fields[12] as DecisionStatus,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.currency)
      ..writeByte(5)
      ..write(obj.billingCycle)
      ..writeByte(6)
      ..write(obj.nextRenewalDate)
      ..writeByte(7)
      ..write(obj.trialEndDate)
      ..writeByte(8)
      ..write(obj.postTrialPrice)
      ..writeByte(9)
      ..write(obj.usageFrequency)
      ..writeByte(10)
      ..write(obj.importance)
      ..writeByte(11)
      ..write(obj.impactScore)
      ..writeByte(12)
      ..write(obj.decisionStatus)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
