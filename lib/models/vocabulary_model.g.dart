// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocabulary_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabularyWordAdapter extends TypeAdapter<VocabularyWord> {
  @override
  final int typeId = 4;

  @override
  VocabularyWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabularyWord(
      id: fields[0] as String,
      word: fields[1] as String,
      partOfSpeech: fields[2] as String,
      pronunciation: fields[3] as String,
      definition: fields[4] as String,
      indonesianMeaning: fields[5] as String,
      examples: (fields[6] as List).cast<String>(),
      synonyms: (fields[7] as List).cast<String>(),
      level: fields[8] as String,
      category: fields[9] as String,
      isLearned: fields[10] as bool,
      learnedAt: fields[11] as DateTime?,
      reviewCount: fields[12] as int,
      lastReviewedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, VocabularyWord obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.partOfSpeech)
      ..writeByte(3)
      ..write(obj.pronunciation)
      ..writeByte(4)
      ..write(obj.definition)
      ..writeByte(5)
      ..write(obj.indonesianMeaning)
      ..writeByte(6)
      ..write(obj.examples)
      ..writeByte(7)
      ..write(obj.synonyms)
      ..writeByte(8)
      ..write(obj.level)
      ..writeByte(9)
      ..write(obj.category)
      ..writeByte(10)
      ..write(obj.isLearned)
      ..writeByte(11)
      ..write(obj.learnedAt)
      ..writeByte(12)
      ..write(obj.reviewCount)
      ..writeByte(13)
      ..write(obj.lastReviewedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
