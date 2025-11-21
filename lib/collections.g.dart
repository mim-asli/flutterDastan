// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collections.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSaveSlotCollection on Isar {
  IsarCollection<SaveSlot> get saveSlots => this.collection();
}

const SaveSlotSchema = CollectionSchema(
  name: r'SaveSlot',
  id: -5827442136686301910,
  properties: {
    r'inventoryItems': PropertySchema(
      id: 0,
      name: r'inventoryItems',
      type: IsarType.objectList,
      target: r'InventoryItemDB',
    ),
    r'saveDate': PropertySchema(
      id: 1,
      name: r'saveDate',
      type: IsarType.dateTime,
    ),
    r'stats': PropertySchema(
      id: 2,
      name: r'stats',
      type: IsarType.object,
      target: r'GameStatsDB',
    ),
    r'storyLog': PropertySchema(
      id: 3,
      name: r'storyLog',
      type: IsarType.stringList,
    )
  },
  estimateSize: _saveSlotEstimateSize,
  serialize: _saveSlotSerialize,
  deserialize: _saveSlotDeserialize,
  deserializeProp: _saveSlotDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {
    r'GameStatsDB': GameStatsDBSchema,
    r'InventoryItemDB': InventoryItemDBSchema
  },
  getId: _saveSlotGetId,
  getLinks: _saveSlotGetLinks,
  attach: _saveSlotAttach,
  version: '3.1.0+1',
);

int _saveSlotEstimateSize(
  SaveSlot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.inventoryItems.length * 3;
  {
    final offsets = allOffsets[InventoryItemDB]!;
    for (var i = 0; i < object.inventoryItems.length; i++) {
      final value = object.inventoryItems[i];
      bytesCount +=
          InventoryItemDBSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.stats;
    if (value != null) {
      bytesCount += 3 +
          GameStatsDBSchema.estimateSize(
              value, allOffsets[GameStatsDB]!, allOffsets);
    }
  }
  bytesCount += 3 + object.storyLog.length * 3;
  {
    for (var i = 0; i < object.storyLog.length; i++) {
      final value = object.storyLog[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _saveSlotSerialize(
  SaveSlot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeObjectList<InventoryItemDB>(
    offsets[0],
    allOffsets,
    InventoryItemDBSchema.serialize,
    object.inventoryItems,
  );
  writer.writeDateTime(offsets[1], object.saveDate);
  writer.writeObject<GameStatsDB>(
    offsets[2],
    allOffsets,
    GameStatsDBSchema.serialize,
    object.stats,
  );
  writer.writeStringList(offsets[3], object.storyLog);
}

SaveSlot _saveSlotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SaveSlot(
    inventoryItems: reader.readObjectList<InventoryItemDB>(
          offsets[0],
          InventoryItemDBSchema.deserialize,
          allOffsets,
          InventoryItemDB(),
        ) ??
        [],
    saveDate: reader.readDateTime(offsets[1]),
    stats: reader.readObjectOrNull<GameStatsDB>(
      offsets[2],
      GameStatsDBSchema.deserialize,
      allOffsets,
    ),
    storyLog: reader.readStringList(offsets[3]) ?? [],
  );
  object.id = id;
  return object;
}

P _saveSlotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readObjectList<InventoryItemDB>(
            offset,
            InventoryItemDBSchema.deserialize,
            allOffsets,
            InventoryItemDB(),
          ) ??
          []) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readObjectOrNull<GameStatsDB>(
        offset,
        GameStatsDBSchema.deserialize,
        allOffsets,
      )) as P;
    case 3:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _saveSlotGetId(SaveSlot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _saveSlotGetLinks(SaveSlot object) {
  return [];
}

void _saveSlotAttach(IsarCollection<dynamic> col, Id id, SaveSlot object) {
  object.id = id;
}

extension SaveSlotQueryWhereSort on QueryBuilder<SaveSlot, SaveSlot, QWhere> {
  QueryBuilder<SaveSlot, SaveSlot, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SaveSlotQueryWhere on QueryBuilder<SaveSlot, SaveSlot, QWhereClause> {
  QueryBuilder<SaveSlot, SaveSlot, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SaveSlotQueryFilter
    on QueryBuilder<SaveSlot, SaveSlot, QFilterCondition> {
  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      inventoryItemsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inventoryItems',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      inventoryItemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inventoryItems',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      inventoryItemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inventoryItems',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      inventoryItemsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inventoryItems',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      inventoryItemsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inventoryItems',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      inventoryItemsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'inventoryItems',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> saveDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'saveDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> saveDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'saveDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> saveDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'saveDate',
        value: value,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> saveDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'saveDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> statsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'stats',
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> statsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'stats',
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storyLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'storyLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'storyLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'storyLog',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'storyLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'storyLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'storyLog',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'storyLog',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'storyLog',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'storyLog',
        value: '',
      ));
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> storyLogLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'storyLog',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> storyLogIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'storyLog',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> storyLogIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'storyLog',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'storyLog',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition>
      storyLogLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'storyLog',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> storyLogLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'storyLog',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension SaveSlotQueryObject
    on QueryBuilder<SaveSlot, SaveSlot, QFilterCondition> {
  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> inventoryItemsElement(
      FilterQuery<InventoryItemDB> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'inventoryItems');
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterFilterCondition> stats(
      FilterQuery<GameStatsDB> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'stats');
    });
  }
}

extension SaveSlotQueryLinks
    on QueryBuilder<SaveSlot, SaveSlot, QFilterCondition> {}

extension SaveSlotQuerySortBy on QueryBuilder<SaveSlot, SaveSlot, QSortBy> {
  QueryBuilder<SaveSlot, SaveSlot, QAfterSortBy> sortBySaveDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDate', Sort.asc);
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterSortBy> sortBySaveDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDate', Sort.desc);
    });
  }
}

extension SaveSlotQuerySortThenBy
    on QueryBuilder<SaveSlot, SaveSlot, QSortThenBy> {
  QueryBuilder<SaveSlot, SaveSlot, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterSortBy> thenBySaveDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDate', Sort.asc);
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QAfterSortBy> thenBySaveDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'saveDate', Sort.desc);
    });
  }
}

extension SaveSlotQueryWhereDistinct
    on QueryBuilder<SaveSlot, SaveSlot, QDistinct> {
  QueryBuilder<SaveSlot, SaveSlot, QDistinct> distinctBySaveDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'saveDate');
    });
  }

  QueryBuilder<SaveSlot, SaveSlot, QDistinct> distinctByStoryLog() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'storyLog');
    });
  }
}

extension SaveSlotQueryProperty
    on QueryBuilder<SaveSlot, SaveSlot, QQueryProperty> {
  QueryBuilder<SaveSlot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SaveSlot, List<InventoryItemDB>, QQueryOperations>
      inventoryItemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inventoryItems');
    });
  }

  QueryBuilder<SaveSlot, DateTime, QQueryOperations> saveDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'saveDate');
    });
  }

  QueryBuilder<SaveSlot, GameStatsDB?, QQueryOperations> statsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stats');
    });
  }

  QueryBuilder<SaveSlot, List<String>, QQueryOperations> storyLogProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'storyLog');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const GameStatsDBSchema = Schema(
  name: r'GameStatsDB',
  id: 7803378648279329909,
  properties: {
    r'energy': PropertySchema(
      id: 0,
      name: r'energy',
      type: IsarType.long,
    ),
    r'health': PropertySchema(
      id: 1,
      name: r'health',
      type: IsarType.long,
    ),
    r'hunger': PropertySchema(
      id: 2,
      name: r'hunger',
      type: IsarType.long,
    ),
    r'sanity': PropertySchema(
      id: 3,
      name: r'sanity',
      type: IsarType.long,
    )
  },
  estimateSize: _gameStatsDBEstimateSize,
  serialize: _gameStatsDBSerialize,
  deserialize: _gameStatsDBDeserialize,
  deserializeProp: _gameStatsDBDeserializeProp,
);

int _gameStatsDBEstimateSize(
  GameStatsDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _gameStatsDBSerialize(
  GameStatsDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.energy);
  writer.writeLong(offsets[1], object.health);
  writer.writeLong(offsets[2], object.hunger);
  writer.writeLong(offsets[3], object.sanity);
}

GameStatsDB _gameStatsDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GameStatsDB(
    energy: reader.readLongOrNull(offsets[0]) ?? 100,
    health: reader.readLongOrNull(offsets[1]) ?? 100,
    hunger: reader.readLongOrNull(offsets[2]) ?? 100,
    sanity: reader.readLongOrNull(offsets[3]) ?? 100,
  );
  return object;
}

P _gameStatsDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 100) as P;
    case 1:
      return (reader.readLongOrNull(offset) ?? 100) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 100) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 100) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension GameStatsDBQueryFilter
    on QueryBuilder<GameStatsDB, GameStatsDB, QFilterCondition> {
  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> energyEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'energy',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition>
      energyGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'energy',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> energyLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'energy',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> energyBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'energy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> healthEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'health',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition>
      healthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'health',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> healthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'health',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> healthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'health',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> hungerEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hunger',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition>
      hungerGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hunger',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> hungerLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hunger',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> hungerBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hunger',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> sanityEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sanity',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition>
      sanityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sanity',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> sanityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sanity',
        value: value,
      ));
    });
  }

  QueryBuilder<GameStatsDB, GameStatsDB, QAfterFilterCondition> sanityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sanity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension GameStatsDBQueryObject
    on QueryBuilder<GameStatsDB, GameStatsDB, QFilterCondition> {}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const InventoryItemDBSchema = Schema(
  name: r'InventoryItemDB',
  id: -2897211755137429785,
  properties: {
    r'description': PropertySchema(
      id: 0,
      name: r'description',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _inventoryItemDBEstimateSize,
  serialize: _inventoryItemDBSerialize,
  deserialize: _inventoryItemDBDeserialize,
  deserializeProp: _inventoryItemDBDeserializeProp,
);

int _inventoryItemDBEstimateSize(
  InventoryItemDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _inventoryItemDBSerialize(
  InventoryItemDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.description);
  writer.writeString(offsets[1], object.name);
}

InventoryItemDB _inventoryItemDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = InventoryItemDB(
    description: reader.readStringOrNull(offsets[0]) ?? '',
    name: reader.readStringOrNull(offsets[1]) ?? '',
  );
  return object;
}

P _inventoryItemDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset) ?? '') as P;
    case 1:
      return (reader.readStringOrNull(offset) ?? '') as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension InventoryItemDBQueryFilter
    on QueryBuilder<InventoryItemDB, InventoryItemDB, QFilterCondition> {
  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<InventoryItemDB, InventoryItemDB, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension InventoryItemDBQueryObject
    on QueryBuilder<InventoryItemDB, InventoryItemDB, QFilterCondition> {}
