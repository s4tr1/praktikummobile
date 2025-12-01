// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BranchModelAdapter extends TypeAdapter<BranchModel> {
  @override
  final int typeId = 3;

  @override
  BranchModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BranchModel(
      id: fields[0] as int,
      name: fields[1] as String,
      address: fields[2] as String,
      latitude: fields[3] as double,
      longitude: fields[4] as double,
      phone: fields[5] as String?,
      email: fields[6] as String?,
      operatingHours: fields[7] as String?,
      description: fields[8] as String?,
      isActive: fields[9] as bool,
      createdAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BranchModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.latitude)
      ..writeByte(4)
      ..write(obj.longitude)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.email)
      ..writeByte(7)
      ..write(obj.operatingHours)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BranchModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
