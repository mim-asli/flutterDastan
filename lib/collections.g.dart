// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collections.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaveSlotAdapter extends TypeAdapter<SaveSlot> {
  @override
  final int typeId = 0;

  @override
  SaveSlot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaveSlot(
      id: fields[0] as int?,
      saveDate: fields[1] as DateTime,
      storyLog: (fields[2] as List).cast<String>(),
      stats: fields[3] as GameStatsDB?,
      inventoryItems: (fields[4] as List).cast<InventoryItemDB>(),
    );
  }

  @override
  void write(BinaryWriter writer, SaveSlot obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.saveDate)
      ..writeByte(2)
      ..write(obj.storyLog)
      ..writeByte(3)
      ..write(obj.stats)
      ..writeByte(4)
      ..write(obj.inventoryItems);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveSlotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GameStatsDBAdapter extends TypeAdapter<GameStatsDB> {
  @override
  final int typeId = 1;

  @override
  GameStatsDB read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameStatsDB(
      health: fields[0] as int,
      sanity: fields[1] as int,
      hunger: fields[2] as int,
      energy: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameStatsDB obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.health)
      ..writeByte(1)
      ..write(obj.sanity)
      ..writeByte(2)
      ..write(obj.hunger)
      ..writeByte(3)
      ..write(obj.energy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStatsDBAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryItemDBAdapter extends TypeAdapter<InventoryItemDB> {
  @override
  final int typeId = 2;

  @override
  InventoryItemDB read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryItemDB(
      name: fields[0] as String,
      description: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItemDB obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItemDBAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
