// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSettingsModelCollection on Isar {
  IsarCollection<SettingsModel> get settingsModels => this.collection();
}

const SettingsModelSchema = CollectionSchema(
  name: r'SettingsModel',
  id: 4013777327486952906,
  properties: {
    r'isAutoSaveEnabled': PropertySchema(
      id: 0,
      name: r'isAutoSaveEnabled',
      type: IsarType.bool,
    ),
    r'isMarkdownEnabled': PropertySchema(
      id: 1,
      name: r'isMarkdownEnabled',
      type: IsarType.bool,
    ),
    r'themeMode': PropertySchema(
      id: 2,
      name: r'themeMode',
      type: IsarType.byte,
      enumMap: _SettingsModelthemeModeEnumValueMap,
    )
  },
  estimateSize: _settingsModelEstimateSize,
  serialize: _settingsModelSerialize,
  deserialize: _settingsModelDeserialize,
  deserializeProp: _settingsModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _settingsModelGetId,
  getLinks: _settingsModelGetLinks,
  attach: _settingsModelAttach,
  version: '3.1.0+1',
);

int _settingsModelEstimateSize(
  SettingsModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _settingsModelSerialize(
  SettingsModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isAutoSaveEnabled);
  writer.writeBool(offsets[1], object.isMarkdownEnabled);
  writer.writeByte(offsets[2], object.themeMode.index);
}

SettingsModel _settingsModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SettingsModel();
  object.id = id;
  object.isAutoSaveEnabled = reader.readBool(offsets[0]);
  object.isMarkdownEnabled = reader.readBool(offsets[1]);
  object.themeMode =
      _SettingsModelthemeModeValueEnumMap[reader.readByteOrNull(offsets[2])] ??
          ThemeModeOption.system;
  return object;
}

P _settingsModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (_SettingsModelthemeModeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          ThemeModeOption.system) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SettingsModelthemeModeEnumValueMap = {
  'system': 0,
  'light': 1,
  'dark': 2,
};
const _SettingsModelthemeModeValueEnumMap = {
  0: ThemeModeOption.system,
  1: ThemeModeOption.light,
  2: ThemeModeOption.dark,
};

Id _settingsModelGetId(SettingsModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _settingsModelGetLinks(SettingsModel object) {
  return [];
}

void _settingsModelAttach(
    IsarCollection<dynamic> col, Id id, SettingsModel object) {
  object.id = id;
}

extension SettingsModelQueryWhereSort
    on QueryBuilder<SettingsModel, SettingsModel, QWhere> {
  QueryBuilder<SettingsModel, SettingsModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SettingsModelQueryWhere
    on QueryBuilder<SettingsModel, SettingsModel, QWhereClause> {
  QueryBuilder<SettingsModel, SettingsModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<SettingsModel, SettingsModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterWhereClause> idBetween(
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

extension SettingsModelQueryFilter
    on QueryBuilder<SettingsModel, SettingsModel, QFilterCondition> {
  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      isAutoSaveEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isAutoSaveEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      isMarkdownEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMarkdownEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      themeModeEqualTo(ThemeModeOption value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      themeModeGreaterThan(
    ThemeModeOption value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      themeModeLessThan(
    ThemeModeOption value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themeMode',
        value: value,
      ));
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterFilterCondition>
      themeModeBetween(
    ThemeModeOption lower,
    ThemeModeOption upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themeMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SettingsModelQueryObject
    on QueryBuilder<SettingsModel, SettingsModel, QFilterCondition> {}

extension SettingsModelQueryLinks
    on QueryBuilder<SettingsModel, SettingsModel, QFilterCondition> {}

extension SettingsModelQuerySortBy
    on QueryBuilder<SettingsModel, SettingsModel, QSortBy> {
  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByIsAutoSaveEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoSaveEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByIsAutoSaveEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoSaveEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByIsMarkdownEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMarkdownEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByIsMarkdownEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMarkdownEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy> sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension SettingsModelQuerySortThenBy
    on QueryBuilder<SettingsModel, SettingsModel, QSortThenBy> {
  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByIsAutoSaveEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoSaveEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByIsAutoSaveEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isAutoSaveEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByIsMarkdownEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMarkdownEnabled', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByIsMarkdownEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMarkdownEnabled', Sort.desc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy> thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QAfterSortBy>
      thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }
}

extension SettingsModelQueryWhereDistinct
    on QueryBuilder<SettingsModel, SettingsModel, QDistinct> {
  QueryBuilder<SettingsModel, SettingsModel, QDistinct>
      distinctByIsAutoSaveEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isAutoSaveEnabled');
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QDistinct>
      distinctByIsMarkdownEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMarkdownEnabled');
    });
  }

  QueryBuilder<SettingsModel, SettingsModel, QDistinct> distinctByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode');
    });
  }
}

extension SettingsModelQueryProperty
    on QueryBuilder<SettingsModel, SettingsModel, QQueryProperty> {
  QueryBuilder<SettingsModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SettingsModel, bool, QQueryOperations>
      isAutoSaveEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isAutoSaveEnabled');
    });
  }

  QueryBuilder<SettingsModel, bool, QQueryOperations>
      isMarkdownEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMarkdownEnabled');
    });
  }

  QueryBuilder<SettingsModel, ThemeModeOption, QQueryOperations>
      themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }
}
