// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ScenariosTable extends Scenarios
    with TableInfo<$ScenariosTable, Scenario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScenariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gemini'),
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _generatedAtMsMeta = const VerificationMeta(
    'generatedAtMs',
  );
  @override
  late final GeneratedColumn<int> generatedAtMs = GeneratedColumn<int>(
    'generated_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUpdatedAtMsMeta = const VerificationMeta(
    'lastUpdatedAtMs',
  );
  @override
  late final GeneratedColumn<int> lastUpdatedAtMs = GeneratedColumn<int>(
    'last_updated_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timesServedMeta = const VerificationMeta(
    'timesServed',
  );
  @override
  late final GeneratedColumn<int> timesServed = GeneratedColumn<int>(
    'times_served',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastServedAtMsMeta = const VerificationMeta(
    'lastServedAtMs',
  );
  @override
  late final GeneratedColumn<int> lastServedAtMs = GeneratedColumn<int>(
    'last_served_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadVersionMeta = const VerificationMeta(
    'payloadVersion',
  );
  @override
  late final GeneratedColumn<int> payloadVersion = GeneratedColumn<int>(
    'payload_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentHash,
    payloadJson,
    createdAt,
    source,
    modelId,
    generatedAtMs,
    lastUpdatedAtMs,
    timesServed,
    lastServedAtMs,
    payloadVersion,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scenarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Scenario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    }
    if (data.containsKey('generated_at_ms')) {
      context.handle(
        _generatedAtMsMeta,
        generatedAtMs.isAcceptableOrUnknown(
          data['generated_at_ms']!,
          _generatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('last_updated_at_ms')) {
      context.handle(
        _lastUpdatedAtMsMeta,
        lastUpdatedAtMs.isAcceptableOrUnknown(
          data['last_updated_at_ms']!,
          _lastUpdatedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('times_served')) {
      context.handle(
        _timesServedMeta,
        timesServed.isAcceptableOrUnknown(
          data['times_served']!,
          _timesServedMeta,
        ),
      );
    }
    if (data.containsKey('last_served_at_ms')) {
      context.handle(
        _lastServedAtMsMeta,
        lastServedAtMs.isAcceptableOrUnknown(
          data['last_served_at_ms']!,
          _lastServedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('payload_version')) {
      context.handle(
        _payloadVersionMeta,
        payloadVersion.isAcceptableOrUnknown(
          data['payload_version']!,
          _payloadVersionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Scenario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Scenario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      generatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generated_at_ms'],
      ),
      lastUpdatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_updated_at_ms'],
      ),
      timesServed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_served'],
      )!,
      lastServedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_served_at_ms'],
      ),
      payloadVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_version'],
      )!,
    );
  }

  @override
  $ScenariosTable createAlias(String alias) {
    return $ScenariosTable(attachedDatabase, alias);
  }
}

class Scenario extends DataClass implements Insertable<Scenario> {
  final int id;
  final String contentHash;
  final String payloadJson;
  final DateTime createdAt;

  /// `gemini` or `offline`.
  final String source;
  final String modelId;

  /// UTC epoch ms; null for rows written before schema v3.
  final int? generatedAtMs;
  final int? lastUpdatedAtMs;
  final int timesServed;
  final int? lastServedAtMs;
  final int payloadVersion;
  const Scenario({
    required this.id,
    required this.contentHash,
    required this.payloadJson,
    required this.createdAt,
    required this.source,
    required this.modelId,
    this.generatedAtMs,
    this.lastUpdatedAtMs,
    required this.timesServed,
    this.lastServedAtMs,
    required this.payloadVersion,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content_hash'] = Variable<String>(contentHash);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['source'] = Variable<String>(source);
    map['model_id'] = Variable<String>(modelId);
    if (!nullToAbsent || generatedAtMs != null) {
      map['generated_at_ms'] = Variable<int>(generatedAtMs);
    }
    if (!nullToAbsent || lastUpdatedAtMs != null) {
      map['last_updated_at_ms'] = Variable<int>(lastUpdatedAtMs);
    }
    map['times_served'] = Variable<int>(timesServed);
    if (!nullToAbsent || lastServedAtMs != null) {
      map['last_served_at_ms'] = Variable<int>(lastServedAtMs);
    }
    map['payload_version'] = Variable<int>(payloadVersion);
    return map;
  }

  ScenariosCompanion toCompanion(bool nullToAbsent) {
    return ScenariosCompanion(
      id: Value(id),
      contentHash: Value(contentHash),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      source: Value(source),
      modelId: Value(modelId),
      generatedAtMs: generatedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(generatedAtMs),
      lastUpdatedAtMs: lastUpdatedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdatedAtMs),
      timesServed: Value(timesServed),
      lastServedAtMs: lastServedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastServedAtMs),
      payloadVersion: Value(payloadVersion),
    );
  }

  factory Scenario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Scenario(
      id: serializer.fromJson<int>(json['id']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      source: serializer.fromJson<String>(json['source']),
      modelId: serializer.fromJson<String>(json['modelId']),
      generatedAtMs: serializer.fromJson<int?>(json['generatedAtMs']),
      lastUpdatedAtMs: serializer.fromJson<int?>(json['lastUpdatedAtMs']),
      timesServed: serializer.fromJson<int>(json['timesServed']),
      lastServedAtMs: serializer.fromJson<int?>(json['lastServedAtMs']),
      payloadVersion: serializer.fromJson<int>(json['payloadVersion']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'contentHash': serializer.toJson<String>(contentHash),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'source': serializer.toJson<String>(source),
      'modelId': serializer.toJson<String>(modelId),
      'generatedAtMs': serializer.toJson<int?>(generatedAtMs),
      'lastUpdatedAtMs': serializer.toJson<int?>(lastUpdatedAtMs),
      'timesServed': serializer.toJson<int>(timesServed),
      'lastServedAtMs': serializer.toJson<int?>(lastServedAtMs),
      'payloadVersion': serializer.toJson<int>(payloadVersion),
    };
  }

  Scenario copyWith({
    int? id,
    String? contentHash,
    String? payloadJson,
    DateTime? createdAt,
    String? source,
    String? modelId,
    Value<int?> generatedAtMs = const Value.absent(),
    Value<int?> lastUpdatedAtMs = const Value.absent(),
    int? timesServed,
    Value<int?> lastServedAtMs = const Value.absent(),
    int? payloadVersion,
  }) => Scenario(
    id: id ?? this.id,
    contentHash: contentHash ?? this.contentHash,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
    source: source ?? this.source,
    modelId: modelId ?? this.modelId,
    generatedAtMs: generatedAtMs.present
        ? generatedAtMs.value
        : this.generatedAtMs,
    lastUpdatedAtMs: lastUpdatedAtMs.present
        ? lastUpdatedAtMs.value
        : this.lastUpdatedAtMs,
    timesServed: timesServed ?? this.timesServed,
    lastServedAtMs: lastServedAtMs.present
        ? lastServedAtMs.value
        : this.lastServedAtMs,
    payloadVersion: payloadVersion ?? this.payloadVersion,
  );
  Scenario copyWithCompanion(ScenariosCompanion data) {
    return Scenario(
      id: data.id.present ? data.id.value : this.id,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      source: data.source.present ? data.source.value : this.source,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      generatedAtMs: data.generatedAtMs.present
          ? data.generatedAtMs.value
          : this.generatedAtMs,
      lastUpdatedAtMs: data.lastUpdatedAtMs.present
          ? data.lastUpdatedAtMs.value
          : this.lastUpdatedAtMs,
      timesServed: data.timesServed.present
          ? data.timesServed.value
          : this.timesServed,
      lastServedAtMs: data.lastServedAtMs.present
          ? data.lastServedAtMs.value
          : this.lastServedAtMs,
      payloadVersion: data.payloadVersion.present
          ? data.payloadVersion.value
          : this.payloadVersion,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Scenario(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('source: $source, ')
          ..write('modelId: $modelId, ')
          ..write('generatedAtMs: $generatedAtMs, ')
          ..write('lastUpdatedAtMs: $lastUpdatedAtMs, ')
          ..write('timesServed: $timesServed, ')
          ..write('lastServedAtMs: $lastServedAtMs, ')
          ..write('payloadVersion: $payloadVersion')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contentHash,
    payloadJson,
    createdAt,
    source,
    modelId,
    generatedAtMs,
    lastUpdatedAtMs,
    timesServed,
    lastServedAtMs,
    payloadVersion,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Scenario &&
          other.id == this.id &&
          other.contentHash == this.contentHash &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.source == this.source &&
          other.modelId == this.modelId &&
          other.generatedAtMs == this.generatedAtMs &&
          other.lastUpdatedAtMs == this.lastUpdatedAtMs &&
          other.timesServed == this.timesServed &&
          other.lastServedAtMs == this.lastServedAtMs &&
          other.payloadVersion == this.payloadVersion);
}

class ScenariosCompanion extends UpdateCompanion<Scenario> {
  final Value<int> id;
  final Value<String> contentHash;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<String> source;
  final Value<String> modelId;
  final Value<int?> generatedAtMs;
  final Value<int?> lastUpdatedAtMs;
  final Value<int> timesServed;
  final Value<int?> lastServedAtMs;
  final Value<int> payloadVersion;
  const ScenariosCompanion({
    this.id = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.source = const Value.absent(),
    this.modelId = const Value.absent(),
    this.generatedAtMs = const Value.absent(),
    this.lastUpdatedAtMs = const Value.absent(),
    this.timesServed = const Value.absent(),
    this.lastServedAtMs = const Value.absent(),
    this.payloadVersion = const Value.absent(),
  });
  ScenariosCompanion.insert({
    this.id = const Value.absent(),
    required String contentHash,
    required String payloadJson,
    this.createdAt = const Value.absent(),
    this.source = const Value.absent(),
    this.modelId = const Value.absent(),
    this.generatedAtMs = const Value.absent(),
    this.lastUpdatedAtMs = const Value.absent(),
    this.timesServed = const Value.absent(),
    this.lastServedAtMs = const Value.absent(),
    this.payloadVersion = const Value.absent(),
  }) : contentHash = Value(contentHash),
       payloadJson = Value(payloadJson);
  static Insertable<Scenario> custom({
    Expression<int>? id,
    Expression<String>? contentHash,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<String>? source,
    Expression<String>? modelId,
    Expression<int>? generatedAtMs,
    Expression<int>? lastUpdatedAtMs,
    Expression<int>? timesServed,
    Expression<int>? lastServedAtMs,
    Expression<int>? payloadVersion,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentHash != null) 'content_hash': contentHash,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (source != null) 'source': source,
      if (modelId != null) 'model_id': modelId,
      if (generatedAtMs != null) 'generated_at_ms': generatedAtMs,
      if (lastUpdatedAtMs != null) 'last_updated_at_ms': lastUpdatedAtMs,
      if (timesServed != null) 'times_served': timesServed,
      if (lastServedAtMs != null) 'last_served_at_ms': lastServedAtMs,
      if (payloadVersion != null) 'payload_version': payloadVersion,
    });
  }

  ScenariosCompanion copyWith({
    Value<int>? id,
    Value<String>? contentHash,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
    Value<String>? source,
    Value<String>? modelId,
    Value<int?>? generatedAtMs,
    Value<int?>? lastUpdatedAtMs,
    Value<int>? timesServed,
    Value<int?>? lastServedAtMs,
    Value<int>? payloadVersion,
  }) {
    return ScenariosCompanion(
      id: id ?? this.id,
      contentHash: contentHash ?? this.contentHash,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      source: source ?? this.source,
      modelId: modelId ?? this.modelId,
      generatedAtMs: generatedAtMs ?? this.generatedAtMs,
      lastUpdatedAtMs: lastUpdatedAtMs ?? this.lastUpdatedAtMs,
      timesServed: timesServed ?? this.timesServed,
      lastServedAtMs: lastServedAtMs ?? this.lastServedAtMs,
      payloadVersion: payloadVersion ?? this.payloadVersion,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (generatedAtMs.present) {
      map['generated_at_ms'] = Variable<int>(generatedAtMs.value);
    }
    if (lastUpdatedAtMs.present) {
      map['last_updated_at_ms'] = Variable<int>(lastUpdatedAtMs.value);
    }
    if (timesServed.present) {
      map['times_served'] = Variable<int>(timesServed.value);
    }
    if (lastServedAtMs.present) {
      map['last_served_at_ms'] = Variable<int>(lastServedAtMs.value);
    }
    if (payloadVersion.present) {
      map['payload_version'] = Variable<int>(payloadVersion.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenariosCompanion(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('source: $source, ')
          ..write('modelId: $modelId, ')
          ..write('generatedAtMs: $generatedAtMs, ')
          ..write('lastUpdatedAtMs: $lastUpdatedAtMs, ')
          ..write('timesServed: $timesServed, ')
          ..write('lastServedAtMs: $lastServedAtMs, ')
          ..write('payloadVersion: $payloadVersion')
          ..write(')'))
        .toString();
  }
}

class $PlayedScenariosTable extends PlayedScenarios
    with TableInfo<$PlayedScenariosTable, PlayedScenario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayedScenariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scenarioIdMeta = const VerificationMeta(
    'scenarioId',
  );
  @override
  late final GeneratedColumn<int> scenarioId = GeneratedColumn<int>(
    'scenario_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scenarios (id)',
    ),
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _wasCorrectMeta = const VerificationMeta(
    'wasCorrect',
  );
  @override
  late final GeneratedColumn<bool> wasCorrect = GeneratedColumn<bool>(
    'was_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_correct" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _evDeltaBbMeta = const VerificationMeta(
    'evDeltaBb',
  );
  @override
  late final GeneratedColumn<double> evDeltaBb = GeneratedColumn<double>(
    'ev_delta_bb',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
    'street',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _archetypeMeta = const VerificationMeta(
    'archetype',
  );
  @override
  late final GeneratedColumn<String> archetype = GeneratedColumn<String>(
    'archetype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    scenarioId,
    playedAt,
    wasCorrect,
    evDeltaBb,
    street,
    archetype,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'played_scenarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayedScenario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('scenario_id')) {
      context.handle(
        _scenarioIdMeta,
        scenarioId.isAcceptableOrUnknown(data['scenario_id']!, _scenarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scenarioIdMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    }
    if (data.containsKey('was_correct')) {
      context.handle(
        _wasCorrectMeta,
        wasCorrect.isAcceptableOrUnknown(data['was_correct']!, _wasCorrectMeta),
      );
    }
    if (data.containsKey('ev_delta_bb')) {
      context.handle(
        _evDeltaBbMeta,
        evDeltaBb.isAcceptableOrUnknown(data['ev_delta_bb']!, _evDeltaBbMeta),
      );
    }
    if (data.containsKey('street')) {
      context.handle(
        _streetMeta,
        street.isAcceptableOrUnknown(data['street']!, _streetMeta),
      );
    }
    if (data.containsKey('archetype')) {
      context.handle(
        _archetypeMeta,
        archetype.isAcceptableOrUnknown(data['archetype']!, _archetypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userId, scenarioId},
  ];
  @override
  PlayedScenario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayedScenario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      scenarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scenario_id'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
      wasCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_correct'],
      )!,
      evDeltaBb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ev_delta_bb'],
      )!,
      street: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street'],
      )!,
      archetype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archetype'],
      )!,
    );
  }

  @override
  $PlayedScenariosTable createAlias(String alias) {
    return $PlayedScenariosTable(attachedDatabase, alias);
  }
}

class PlayedScenario extends DataClass implements Insertable<PlayedScenario> {
  final int id;
  final String userId;
  final int scenarioId;
  final DateTime playedAt;
  final bool wasCorrect;
  final double evDeltaBb;
  final String street;
  final String archetype;
  const PlayedScenario({
    required this.id,
    required this.userId,
    required this.scenarioId,
    required this.playedAt,
    required this.wasCorrect,
    required this.evDeltaBb,
    required this.street,
    required this.archetype,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['scenario_id'] = Variable<int>(scenarioId);
    map['played_at'] = Variable<DateTime>(playedAt);
    map['was_correct'] = Variable<bool>(wasCorrect);
    map['ev_delta_bb'] = Variable<double>(evDeltaBb);
    map['street'] = Variable<String>(street);
    map['archetype'] = Variable<String>(archetype);
    return map;
  }

  PlayedScenariosCompanion toCompanion(bool nullToAbsent) {
    return PlayedScenariosCompanion(
      id: Value(id),
      userId: Value(userId),
      scenarioId: Value(scenarioId),
      playedAt: Value(playedAt),
      wasCorrect: Value(wasCorrect),
      evDeltaBb: Value(evDeltaBb),
      street: Value(street),
      archetype: Value(archetype),
    );
  }

  factory PlayedScenario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayedScenario(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      scenarioId: serializer.fromJson<int>(json['scenarioId']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
      wasCorrect: serializer.fromJson<bool>(json['wasCorrect']),
      evDeltaBb: serializer.fromJson<double>(json['evDeltaBb']),
      street: serializer.fromJson<String>(json['street']),
      archetype: serializer.fromJson<String>(json['archetype']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'scenarioId': serializer.toJson<int>(scenarioId),
      'playedAt': serializer.toJson<DateTime>(playedAt),
      'wasCorrect': serializer.toJson<bool>(wasCorrect),
      'evDeltaBb': serializer.toJson<double>(evDeltaBb),
      'street': serializer.toJson<String>(street),
      'archetype': serializer.toJson<String>(archetype),
    };
  }

  PlayedScenario copyWith({
    int? id,
    String? userId,
    int? scenarioId,
    DateTime? playedAt,
    bool? wasCorrect,
    double? evDeltaBb,
    String? street,
    String? archetype,
  }) => PlayedScenario(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    scenarioId: scenarioId ?? this.scenarioId,
    playedAt: playedAt ?? this.playedAt,
    wasCorrect: wasCorrect ?? this.wasCorrect,
    evDeltaBb: evDeltaBb ?? this.evDeltaBb,
    street: street ?? this.street,
    archetype: archetype ?? this.archetype,
  );
  PlayedScenario copyWithCompanion(PlayedScenariosCompanion data) {
    return PlayedScenario(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      scenarioId: data.scenarioId.present
          ? data.scenarioId.value
          : this.scenarioId,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      wasCorrect: data.wasCorrect.present
          ? data.wasCorrect.value
          : this.wasCorrect,
      evDeltaBb: data.evDeltaBb.present ? data.evDeltaBb.value : this.evDeltaBb,
      street: data.street.present ? data.street.value : this.street,
      archetype: data.archetype.present ? data.archetype.value : this.archetype,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayedScenario(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('playedAt: $playedAt, ')
          ..write('wasCorrect: $wasCorrect, ')
          ..write('evDeltaBb: $evDeltaBb, ')
          ..write('street: $street, ')
          ..write('archetype: $archetype')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    scenarioId,
    playedAt,
    wasCorrect,
    evDeltaBb,
    street,
    archetype,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayedScenario &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.scenarioId == this.scenarioId &&
          other.playedAt == this.playedAt &&
          other.wasCorrect == this.wasCorrect &&
          other.evDeltaBb == this.evDeltaBb &&
          other.street == this.street &&
          other.archetype == this.archetype);
}

class PlayedScenariosCompanion extends UpdateCompanion<PlayedScenario> {
  final Value<int> id;
  final Value<String> userId;
  final Value<int> scenarioId;
  final Value<DateTime> playedAt;
  final Value<bool> wasCorrect;
  final Value<double> evDeltaBb;
  final Value<String> street;
  final Value<String> archetype;
  const PlayedScenariosCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.scenarioId = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.wasCorrect = const Value.absent(),
    this.evDeltaBb = const Value.absent(),
    this.street = const Value.absent(),
    this.archetype = const Value.absent(),
  });
  PlayedScenariosCompanion.insert({
    this.id = const Value.absent(),
    required String userId,
    required int scenarioId,
    this.playedAt = const Value.absent(),
    this.wasCorrect = const Value.absent(),
    this.evDeltaBb = const Value.absent(),
    this.street = const Value.absent(),
    this.archetype = const Value.absent(),
  }) : userId = Value(userId),
       scenarioId = Value(scenarioId);
  static Insertable<PlayedScenario> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<int>? scenarioId,
    Expression<DateTime>? playedAt,
    Expression<bool>? wasCorrect,
    Expression<double>? evDeltaBb,
    Expression<String>? street,
    Expression<String>? archetype,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (scenarioId != null) 'scenario_id': scenarioId,
      if (playedAt != null) 'played_at': playedAt,
      if (wasCorrect != null) 'was_correct': wasCorrect,
      if (evDeltaBb != null) 'ev_delta_bb': evDeltaBb,
      if (street != null) 'street': street,
      if (archetype != null) 'archetype': archetype,
    });
  }

  PlayedScenariosCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<int>? scenarioId,
    Value<DateTime>? playedAt,
    Value<bool>? wasCorrect,
    Value<double>? evDeltaBb,
    Value<String>? street,
    Value<String>? archetype,
  }) {
    return PlayedScenariosCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      scenarioId: scenarioId ?? this.scenarioId,
      playedAt: playedAt ?? this.playedAt,
      wasCorrect: wasCorrect ?? this.wasCorrect,
      evDeltaBb: evDeltaBb ?? this.evDeltaBb,
      street: street ?? this.street,
      archetype: archetype ?? this.archetype,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (scenarioId.present) {
      map['scenario_id'] = Variable<int>(scenarioId.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (wasCorrect.present) {
      map['was_correct'] = Variable<bool>(wasCorrect.value);
    }
    if (evDeltaBb.present) {
      map['ev_delta_bb'] = Variable<double>(evDeltaBb.value);
    }
    if (street.present) {
      map['street'] = Variable<String>(street.value);
    }
    if (archetype.present) {
      map['archetype'] = Variable<String>(archetype.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayedScenariosCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('playedAt: $playedAt, ')
          ..write('wasCorrect: $wasCorrect, ')
          ..write('evDeltaBb: $evDeltaBb, ')
          ..write('street: $street, ')
          ..write('archetype: $archetype')
          ..write(')'))
        .toString();
  }
}

class $UserStatsRowsTable extends UserStatsRows
    with TableInfo<$UserStatsRowsTable, UserStatsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStatsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalSpotsMeta = const VerificationMeta(
    'totalSpots',
  );
  @override
  late final GeneratedColumn<int> totalSpots = GeneratedColumn<int>(
    'total_spots',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctSpotsMeta = const VerificationMeta(
    'correctSpots',
  );
  @override
  late final GeneratedColumn<int> correctSpots = GeneratedColumn<int>(
    'correct_spots',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _netEvBbMeta = const VerificationMeta(
    'netEvBb',
  );
  @override
  late final GeneratedColumn<double> netEvBb = GeneratedColumn<double>(
    'net_ev_bb',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archetypeJsonMeta = const VerificationMeta(
    'archetypeJson',
  );
  @override
  late final GeneratedColumn<String> archetypeJson = GeneratedColumn<String>(
    'archetype_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _streetJsonMeta = const VerificationMeta(
    'streetJson',
  );
  @override
  late final GeneratedColumn<String> streetJson = GeneratedColumn<String>(
    'street_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _recentEvJsonMeta = const VerificationMeta(
    'recentEvJson',
  );
  @override
  late final GeneratedColumn<String> recentEvJson = GeneratedColumn<String>(
    'recent_ev_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    userId,
    totalSpots,
    correctSpots,
    netEvBb,
    archetypeJson,
    streetJson,
    recentEvJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_stats_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserStatsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('total_spots')) {
      context.handle(
        _totalSpotsMeta,
        totalSpots.isAcceptableOrUnknown(data['total_spots']!, _totalSpotsMeta),
      );
    }
    if (data.containsKey('correct_spots')) {
      context.handle(
        _correctSpotsMeta,
        correctSpots.isAcceptableOrUnknown(
          data['correct_spots']!,
          _correctSpotsMeta,
        ),
      );
    }
    if (data.containsKey('net_ev_bb')) {
      context.handle(
        _netEvBbMeta,
        netEvBb.isAcceptableOrUnknown(data['net_ev_bb']!, _netEvBbMeta),
      );
    }
    if (data.containsKey('archetype_json')) {
      context.handle(
        _archetypeJsonMeta,
        archetypeJson.isAcceptableOrUnknown(
          data['archetype_json']!,
          _archetypeJsonMeta,
        ),
      );
    }
    if (data.containsKey('street_json')) {
      context.handle(
        _streetJsonMeta,
        streetJson.isAcceptableOrUnknown(data['street_json']!, _streetJsonMeta),
      );
    }
    if (data.containsKey('recent_ev_json')) {
      context.handle(
        _recentEvJsonMeta,
        recentEvJson.isAcceptableOrUnknown(
          data['recent_ev_json']!,
          _recentEvJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  UserStatsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStatsRow(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      totalSpots: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_spots'],
      )!,
      correctSpots: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_spots'],
      )!,
      netEvBb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_ev_bb'],
      )!,
      archetypeJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archetype_json'],
      )!,
      streetJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street_json'],
      )!,
      recentEvJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recent_ev_json'],
      )!,
    );
  }

  @override
  $UserStatsRowsTable createAlias(String alias) {
    return $UserStatsRowsTable(attachedDatabase, alias);
  }
}

class UserStatsRow extends DataClass implements Insertable<UserStatsRow> {
  final String userId;
  final int totalSpots;
  final int correctSpots;
  final double netEvBb;
  final String archetypeJson;
  final String streetJson;
  final String recentEvJson;
  const UserStatsRow({
    required this.userId,
    required this.totalSpots,
    required this.correctSpots,
    required this.netEvBb,
    required this.archetypeJson,
    required this.streetJson,
    required this.recentEvJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['total_spots'] = Variable<int>(totalSpots);
    map['correct_spots'] = Variable<int>(correctSpots);
    map['net_ev_bb'] = Variable<double>(netEvBb);
    map['archetype_json'] = Variable<String>(archetypeJson);
    map['street_json'] = Variable<String>(streetJson);
    map['recent_ev_json'] = Variable<String>(recentEvJson);
    return map;
  }

  UserStatsRowsCompanion toCompanion(bool nullToAbsent) {
    return UserStatsRowsCompanion(
      userId: Value(userId),
      totalSpots: Value(totalSpots),
      correctSpots: Value(correctSpots),
      netEvBb: Value(netEvBb),
      archetypeJson: Value(archetypeJson),
      streetJson: Value(streetJson),
      recentEvJson: Value(recentEvJson),
    );
  }

  factory UserStatsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStatsRow(
      userId: serializer.fromJson<String>(json['userId']),
      totalSpots: serializer.fromJson<int>(json['totalSpots']),
      correctSpots: serializer.fromJson<int>(json['correctSpots']),
      netEvBb: serializer.fromJson<double>(json['netEvBb']),
      archetypeJson: serializer.fromJson<String>(json['archetypeJson']),
      streetJson: serializer.fromJson<String>(json['streetJson']),
      recentEvJson: serializer.fromJson<String>(json['recentEvJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'totalSpots': serializer.toJson<int>(totalSpots),
      'correctSpots': serializer.toJson<int>(correctSpots),
      'netEvBb': serializer.toJson<double>(netEvBb),
      'archetypeJson': serializer.toJson<String>(archetypeJson),
      'streetJson': serializer.toJson<String>(streetJson),
      'recentEvJson': serializer.toJson<String>(recentEvJson),
    };
  }

  UserStatsRow copyWith({
    String? userId,
    int? totalSpots,
    int? correctSpots,
    double? netEvBb,
    String? archetypeJson,
    String? streetJson,
    String? recentEvJson,
  }) => UserStatsRow(
    userId: userId ?? this.userId,
    totalSpots: totalSpots ?? this.totalSpots,
    correctSpots: correctSpots ?? this.correctSpots,
    netEvBb: netEvBb ?? this.netEvBb,
    archetypeJson: archetypeJson ?? this.archetypeJson,
    streetJson: streetJson ?? this.streetJson,
    recentEvJson: recentEvJson ?? this.recentEvJson,
  );
  UserStatsRow copyWithCompanion(UserStatsRowsCompanion data) {
    return UserStatsRow(
      userId: data.userId.present ? data.userId.value : this.userId,
      totalSpots: data.totalSpots.present
          ? data.totalSpots.value
          : this.totalSpots,
      correctSpots: data.correctSpots.present
          ? data.correctSpots.value
          : this.correctSpots,
      netEvBb: data.netEvBb.present ? data.netEvBb.value : this.netEvBb,
      archetypeJson: data.archetypeJson.present
          ? data.archetypeJson.value
          : this.archetypeJson,
      streetJson: data.streetJson.present
          ? data.streetJson.value
          : this.streetJson,
      recentEvJson: data.recentEvJson.present
          ? data.recentEvJson.value
          : this.recentEvJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsRow(')
          ..write('userId: $userId, ')
          ..write('totalSpots: $totalSpots, ')
          ..write('correctSpots: $correctSpots, ')
          ..write('netEvBb: $netEvBb, ')
          ..write('archetypeJson: $archetypeJson, ')
          ..write('streetJson: $streetJson, ')
          ..write('recentEvJson: $recentEvJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    totalSpots,
    correctSpots,
    netEvBb,
    archetypeJson,
    streetJson,
    recentEvJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStatsRow &&
          other.userId == this.userId &&
          other.totalSpots == this.totalSpots &&
          other.correctSpots == this.correctSpots &&
          other.netEvBb == this.netEvBb &&
          other.archetypeJson == this.archetypeJson &&
          other.streetJson == this.streetJson &&
          other.recentEvJson == this.recentEvJson);
}

class UserStatsRowsCompanion extends UpdateCompanion<UserStatsRow> {
  final Value<String> userId;
  final Value<int> totalSpots;
  final Value<int> correctSpots;
  final Value<double> netEvBb;
  final Value<String> archetypeJson;
  final Value<String> streetJson;
  final Value<String> recentEvJson;
  final Value<int> rowid;
  const UserStatsRowsCompanion({
    this.userId = const Value.absent(),
    this.totalSpots = const Value.absent(),
    this.correctSpots = const Value.absent(),
    this.netEvBb = const Value.absent(),
    this.archetypeJson = const Value.absent(),
    this.streetJson = const Value.absent(),
    this.recentEvJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserStatsRowsCompanion.insert({
    required String userId,
    this.totalSpots = const Value.absent(),
    this.correctSpots = const Value.absent(),
    this.netEvBb = const Value.absent(),
    this.archetypeJson = const Value.absent(),
    this.streetJson = const Value.absent(),
    this.recentEvJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : userId = Value(userId);
  static Insertable<UserStatsRow> custom({
    Expression<String>? userId,
    Expression<int>? totalSpots,
    Expression<int>? correctSpots,
    Expression<double>? netEvBb,
    Expression<String>? archetypeJson,
    Expression<String>? streetJson,
    Expression<String>? recentEvJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (totalSpots != null) 'total_spots': totalSpots,
      if (correctSpots != null) 'correct_spots': correctSpots,
      if (netEvBb != null) 'net_ev_bb': netEvBb,
      if (archetypeJson != null) 'archetype_json': archetypeJson,
      if (streetJson != null) 'street_json': streetJson,
      if (recentEvJson != null) 'recent_ev_json': recentEvJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserStatsRowsCompanion copyWith({
    Value<String>? userId,
    Value<int>? totalSpots,
    Value<int>? correctSpots,
    Value<double>? netEvBb,
    Value<String>? archetypeJson,
    Value<String>? streetJson,
    Value<String>? recentEvJson,
    Value<int>? rowid,
  }) {
    return UserStatsRowsCompanion(
      userId: userId ?? this.userId,
      totalSpots: totalSpots ?? this.totalSpots,
      correctSpots: correctSpots ?? this.correctSpots,
      netEvBb: netEvBb ?? this.netEvBb,
      archetypeJson: archetypeJson ?? this.archetypeJson,
      streetJson: streetJson ?? this.streetJson,
      recentEvJson: recentEvJson ?? this.recentEvJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (totalSpots.present) {
      map['total_spots'] = Variable<int>(totalSpots.value);
    }
    if (correctSpots.present) {
      map['correct_spots'] = Variable<int>(correctSpots.value);
    }
    if (netEvBb.present) {
      map['net_ev_bb'] = Variable<double>(netEvBb.value);
    }
    if (archetypeJson.present) {
      map['archetype_json'] = Variable<String>(archetypeJson.value);
    }
    if (streetJson.present) {
      map['street_json'] = Variable<String>(streetJson.value);
    }
    if (recentEvJson.present) {
      map['recent_ev_json'] = Variable<String>(recentEvJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsRowsCompanion(')
          ..write('userId: $userId, ')
          ..write('totalSpots: $totalSpots, ')
          ..write('correctSpots: $correctSpots, ')
          ..write('netEvBb: $netEvBb, ')
          ..write('archetypeJson: $archetypeJson, ')
          ..write('streetJson: $streetJson, ')
          ..write('recentEvJson: $recentEvJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MistakesTable extends Mistakes with TableInfo<$MistakesTable, Mistake> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MistakesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handIdMeta = const VerificationMeta('handId');
  @override
  late final GeneratedColumn<String> handId = GeneratedColumn<String>(
    'hand_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decisionIdMeta = const VerificationMeta(
    'decisionId',
  );
  @override
  late final GeneratedColumn<String> decisionId = GeneratedColumn<String>(
    'decision_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
    'street',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villainArchetypeMeta = const VerificationMeta(
    'villainArchetype',
  );
  @override
  late final GeneratedColumn<String> villainArchetype = GeneratedColumn<String>(
    'villain_archetype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heroActionMeta = const VerificationMeta(
    'heroAction',
  );
  @override
  late final GeneratedColumn<String> heroAction = GeneratedColumn<String>(
    'hero_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heroAmountMeta = const VerificationMeta(
    'heroAmount',
  );
  @override
  late final GeneratedColumn<double> heroAmount = GeneratedColumn<double>(
    'hero_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestActionMeta = const VerificationMeta(
    'bestAction',
  );
  @override
  late final GeneratedColumn<String> bestAction = GeneratedColumn<String>(
    'best_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestSizingBbMeta = const VerificationMeta(
    'bestSizingBb',
  );
  @override
  late final GeneratedColumn<double> bestSizingBb = GeneratedColumn<double>(
    'best_sizing_bb',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _evDeltaBbMeta = const VerificationMeta(
    'evDeltaBb',
  );
  @override
  late final GeneratedColumn<double> evDeltaBb = GeneratedColumn<double>(
    'ev_delta_bb',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _evDeltaDollarsMeta = const VerificationMeta(
    'evDeltaDollars',
  );
  @override
  late final GeneratedColumn<double> evDeltaDollars = GeneratedColumn<double>(
    'ev_delta_dollars',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mistakeKeyMeta = const VerificationMeta(
    'mistakeKey',
  );
  @override
  late final GeneratedColumn<String> mistakeKey = GeneratedColumn<String>(
    'mistake_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextKeyMeta = const VerificationMeta(
    'contextKey',
  );
  @override
  late final GeneratedColumn<String> contextKey = GeneratedColumn<String>(
    'context_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryTagMeta = const VerificationMeta(
    'primaryTag',
  );
  @override
  late final GeneratedColumn<String> primaryTag = GeneratedColumn<String>(
    'primary_tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coarseTagsJsonMeta = const VerificationMeta(
    'coarseTagsJson',
  );
  @override
  late final GeneratedColumn<String> coarseTagsJson = GeneratedColumn<String>(
    'coarse_tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _adviceTextMeta = const VerificationMeta(
    'adviceText',
  );
  @override
  late final GeneratedColumn<String> adviceText = GeneratedColumn<String>(
    'advice_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    sessionId,
    handId,
    decisionId,
    createdAt,
    street,
    villainArchetype,
    heroAction,
    heroAmount,
    bestAction,
    bestSizingBb,
    evDeltaBb,
    evDeltaDollars,
    mistakeKey,
    contextKey,
    primaryTag,
    coarseTagsJson,
    adviceText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mistakes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mistake> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('hand_id')) {
      context.handle(
        _handIdMeta,
        handId.isAcceptableOrUnknown(data['hand_id']!, _handIdMeta),
      );
    } else if (isInserting) {
      context.missing(_handIdMeta);
    }
    if (data.containsKey('decision_id')) {
      context.handle(
        _decisionIdMeta,
        decisionId.isAcceptableOrUnknown(data['decision_id']!, _decisionIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('street')) {
      context.handle(
        _streetMeta,
        street.isAcceptableOrUnknown(data['street']!, _streetMeta),
      );
    } else if (isInserting) {
      context.missing(_streetMeta);
    }
    if (data.containsKey('villain_archetype')) {
      context.handle(
        _villainArchetypeMeta,
        villainArchetype.isAcceptableOrUnknown(
          data['villain_archetype']!,
          _villainArchetypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_villainArchetypeMeta);
    }
    if (data.containsKey('hero_action')) {
      context.handle(
        _heroActionMeta,
        heroAction.isAcceptableOrUnknown(data['hero_action']!, _heroActionMeta),
      );
    } else if (isInserting) {
      context.missing(_heroActionMeta);
    }
    if (data.containsKey('hero_amount')) {
      context.handle(
        _heroAmountMeta,
        heroAmount.isAcceptableOrUnknown(data['hero_amount']!, _heroAmountMeta),
      );
    }
    if (data.containsKey('best_action')) {
      context.handle(
        _bestActionMeta,
        bestAction.isAcceptableOrUnknown(data['best_action']!, _bestActionMeta),
      );
    } else if (isInserting) {
      context.missing(_bestActionMeta);
    }
    if (data.containsKey('best_sizing_bb')) {
      context.handle(
        _bestSizingBbMeta,
        bestSizingBb.isAcceptableOrUnknown(
          data['best_sizing_bb']!,
          _bestSizingBbMeta,
        ),
      );
    }
    if (data.containsKey('ev_delta_bb')) {
      context.handle(
        _evDeltaBbMeta,
        evDeltaBb.isAcceptableOrUnknown(data['ev_delta_bb']!, _evDeltaBbMeta),
      );
    }
    if (data.containsKey('ev_delta_dollars')) {
      context.handle(
        _evDeltaDollarsMeta,
        evDeltaDollars.isAcceptableOrUnknown(
          data['ev_delta_dollars']!,
          _evDeltaDollarsMeta,
        ),
      );
    }
    if (data.containsKey('mistake_key')) {
      context.handle(
        _mistakeKeyMeta,
        mistakeKey.isAcceptableOrUnknown(data['mistake_key']!, _mistakeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_mistakeKeyMeta);
    }
    if (data.containsKey('context_key')) {
      context.handle(
        _contextKeyMeta,
        contextKey.isAcceptableOrUnknown(data['context_key']!, _contextKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_contextKeyMeta);
    }
    if (data.containsKey('primary_tag')) {
      context.handle(
        _primaryTagMeta,
        primaryTag.isAcceptableOrUnknown(data['primary_tag']!, _primaryTagMeta),
      );
    } else if (isInserting) {
      context.missing(_primaryTagMeta);
    }
    if (data.containsKey('coarse_tags_json')) {
      context.handle(
        _coarseTagsJsonMeta,
        coarseTagsJson.isAcceptableOrUnknown(
          data['coarse_tags_json']!,
          _coarseTagsJsonMeta,
        ),
      );
    }
    if (data.containsKey('advice_text')) {
      context.handle(
        _adviceTextMeta,
        adviceText.isAcceptableOrUnknown(data['advice_text']!, _adviceTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mistake map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mistake(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      handId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hand_id'],
      )!,
      decisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      street: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street'],
      )!,
      villainArchetype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}villain_archetype'],
      )!,
      heroAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_action'],
      )!,
      heroAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hero_amount'],
      )!,
      bestAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}best_action'],
      )!,
      bestSizingBb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}best_sizing_bb'],
      )!,
      evDeltaBb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ev_delta_bb'],
      )!,
      evDeltaDollars: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ev_delta_dollars'],
      )!,
      mistakeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mistake_key'],
      )!,
      contextKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_key'],
      )!,
      primaryTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_tag'],
      )!,
      coarseTagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coarse_tags_json'],
      )!,
      adviceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}advice_text'],
      )!,
    );
  }

  @override
  $MistakesTable createAlias(String alias) {
    return $MistakesTable(attachedDatabase, alias);
  }
}

class Mistake extends DataClass implements Insertable<Mistake> {
  final int id;
  final String userId;
  final String sessionId;
  final String handId;
  final String? decisionId;
  final DateTime createdAt;
  final String street;
  final String villainArchetype;
  final String heroAction;
  final double heroAmount;
  final String bestAction;
  final double bestSizingBb;
  final double evDeltaBb;
  final double evDeltaDollars;

  /// Fine-grained key, e.g. `river:nit:raise->call`.
  final String mistakeKey;

  /// Spot without the hero action, e.g. `river:nit:call`.
  final String contextKey;

  /// Most specific coarse tag id.
  final String primaryTag;

  /// JSON list of every coarse tag id.
  final String coarseTagsJson;

  /// Advice shown to the user (updated once the AI line arrives).
  final String adviceText;
  const Mistake({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.handId,
    this.decisionId,
    required this.createdAt,
    required this.street,
    required this.villainArchetype,
    required this.heroAction,
    required this.heroAmount,
    required this.bestAction,
    required this.bestSizingBb,
    required this.evDeltaBb,
    required this.evDeltaDollars,
    required this.mistakeKey,
    required this.contextKey,
    required this.primaryTag,
    required this.coarseTagsJson,
    required this.adviceText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['session_id'] = Variable<String>(sessionId);
    map['hand_id'] = Variable<String>(handId);
    if (!nullToAbsent || decisionId != null) {
      map['decision_id'] = Variable<String>(decisionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['street'] = Variable<String>(street);
    map['villain_archetype'] = Variable<String>(villainArchetype);
    map['hero_action'] = Variable<String>(heroAction);
    map['hero_amount'] = Variable<double>(heroAmount);
    map['best_action'] = Variable<String>(bestAction);
    map['best_sizing_bb'] = Variable<double>(bestSizingBb);
    map['ev_delta_bb'] = Variable<double>(evDeltaBb);
    map['ev_delta_dollars'] = Variable<double>(evDeltaDollars);
    map['mistake_key'] = Variable<String>(mistakeKey);
    map['context_key'] = Variable<String>(contextKey);
    map['primary_tag'] = Variable<String>(primaryTag);
    map['coarse_tags_json'] = Variable<String>(coarseTagsJson);
    map['advice_text'] = Variable<String>(adviceText);
    return map;
  }

  MistakesCompanion toCompanion(bool nullToAbsent) {
    return MistakesCompanion(
      id: Value(id),
      userId: Value(userId),
      sessionId: Value(sessionId),
      handId: Value(handId),
      decisionId: decisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionId),
      createdAt: Value(createdAt),
      street: Value(street),
      villainArchetype: Value(villainArchetype),
      heroAction: Value(heroAction),
      heroAmount: Value(heroAmount),
      bestAction: Value(bestAction),
      bestSizingBb: Value(bestSizingBb),
      evDeltaBb: Value(evDeltaBb),
      evDeltaDollars: Value(evDeltaDollars),
      mistakeKey: Value(mistakeKey),
      contextKey: Value(contextKey),
      primaryTag: Value(primaryTag),
      coarseTagsJson: Value(coarseTagsJson),
      adviceText: Value(adviceText),
    );
  }

  factory Mistake.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mistake(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      handId: serializer.fromJson<String>(json['handId']),
      decisionId: serializer.fromJson<String?>(json['decisionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      street: serializer.fromJson<String>(json['street']),
      villainArchetype: serializer.fromJson<String>(json['villainArchetype']),
      heroAction: serializer.fromJson<String>(json['heroAction']),
      heroAmount: serializer.fromJson<double>(json['heroAmount']),
      bestAction: serializer.fromJson<String>(json['bestAction']),
      bestSizingBb: serializer.fromJson<double>(json['bestSizingBb']),
      evDeltaBb: serializer.fromJson<double>(json['evDeltaBb']),
      evDeltaDollars: serializer.fromJson<double>(json['evDeltaDollars']),
      mistakeKey: serializer.fromJson<String>(json['mistakeKey']),
      contextKey: serializer.fromJson<String>(json['contextKey']),
      primaryTag: serializer.fromJson<String>(json['primaryTag']),
      coarseTagsJson: serializer.fromJson<String>(json['coarseTagsJson']),
      adviceText: serializer.fromJson<String>(json['adviceText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'sessionId': serializer.toJson<String>(sessionId),
      'handId': serializer.toJson<String>(handId),
      'decisionId': serializer.toJson<String?>(decisionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'street': serializer.toJson<String>(street),
      'villainArchetype': serializer.toJson<String>(villainArchetype),
      'heroAction': serializer.toJson<String>(heroAction),
      'heroAmount': serializer.toJson<double>(heroAmount),
      'bestAction': serializer.toJson<String>(bestAction),
      'bestSizingBb': serializer.toJson<double>(bestSizingBb),
      'evDeltaBb': serializer.toJson<double>(evDeltaBb),
      'evDeltaDollars': serializer.toJson<double>(evDeltaDollars),
      'mistakeKey': serializer.toJson<String>(mistakeKey),
      'contextKey': serializer.toJson<String>(contextKey),
      'primaryTag': serializer.toJson<String>(primaryTag),
      'coarseTagsJson': serializer.toJson<String>(coarseTagsJson),
      'adviceText': serializer.toJson<String>(adviceText),
    };
  }

  Mistake copyWith({
    int? id,
    String? userId,
    String? sessionId,
    String? handId,
    Value<String?> decisionId = const Value.absent(),
    DateTime? createdAt,
    String? street,
    String? villainArchetype,
    String? heroAction,
    double? heroAmount,
    String? bestAction,
    double? bestSizingBb,
    double? evDeltaBb,
    double? evDeltaDollars,
    String? mistakeKey,
    String? contextKey,
    String? primaryTag,
    String? coarseTagsJson,
    String? adviceText,
  }) => Mistake(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    sessionId: sessionId ?? this.sessionId,
    handId: handId ?? this.handId,
    decisionId: decisionId.present ? decisionId.value : this.decisionId,
    createdAt: createdAt ?? this.createdAt,
    street: street ?? this.street,
    villainArchetype: villainArchetype ?? this.villainArchetype,
    heroAction: heroAction ?? this.heroAction,
    heroAmount: heroAmount ?? this.heroAmount,
    bestAction: bestAction ?? this.bestAction,
    bestSizingBb: bestSizingBb ?? this.bestSizingBb,
    evDeltaBb: evDeltaBb ?? this.evDeltaBb,
    evDeltaDollars: evDeltaDollars ?? this.evDeltaDollars,
    mistakeKey: mistakeKey ?? this.mistakeKey,
    contextKey: contextKey ?? this.contextKey,
    primaryTag: primaryTag ?? this.primaryTag,
    coarseTagsJson: coarseTagsJson ?? this.coarseTagsJson,
    adviceText: adviceText ?? this.adviceText,
  );
  Mistake copyWithCompanion(MistakesCompanion data) {
    return Mistake(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      handId: data.handId.present ? data.handId.value : this.handId,
      decisionId: data.decisionId.present
          ? data.decisionId.value
          : this.decisionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      street: data.street.present ? data.street.value : this.street,
      villainArchetype: data.villainArchetype.present
          ? data.villainArchetype.value
          : this.villainArchetype,
      heroAction: data.heroAction.present
          ? data.heroAction.value
          : this.heroAction,
      heroAmount: data.heroAmount.present
          ? data.heroAmount.value
          : this.heroAmount,
      bestAction: data.bestAction.present
          ? data.bestAction.value
          : this.bestAction,
      bestSizingBb: data.bestSizingBb.present
          ? data.bestSizingBb.value
          : this.bestSizingBb,
      evDeltaBb: data.evDeltaBb.present ? data.evDeltaBb.value : this.evDeltaBb,
      evDeltaDollars: data.evDeltaDollars.present
          ? data.evDeltaDollars.value
          : this.evDeltaDollars,
      mistakeKey: data.mistakeKey.present
          ? data.mistakeKey.value
          : this.mistakeKey,
      contextKey: data.contextKey.present
          ? data.contextKey.value
          : this.contextKey,
      primaryTag: data.primaryTag.present
          ? data.primaryTag.value
          : this.primaryTag,
      coarseTagsJson: data.coarseTagsJson.present
          ? data.coarseTagsJson.value
          : this.coarseTagsJson,
      adviceText: data.adviceText.present
          ? data.adviceText.value
          : this.adviceText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mistake(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionId: $sessionId, ')
          ..write('handId: $handId, ')
          ..write('decisionId: $decisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('street: $street, ')
          ..write('villainArchetype: $villainArchetype, ')
          ..write('heroAction: $heroAction, ')
          ..write('heroAmount: $heroAmount, ')
          ..write('bestAction: $bestAction, ')
          ..write('bestSizingBb: $bestSizingBb, ')
          ..write('evDeltaBb: $evDeltaBb, ')
          ..write('evDeltaDollars: $evDeltaDollars, ')
          ..write('mistakeKey: $mistakeKey, ')
          ..write('contextKey: $contextKey, ')
          ..write('primaryTag: $primaryTag, ')
          ..write('coarseTagsJson: $coarseTagsJson, ')
          ..write('adviceText: $adviceText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    sessionId,
    handId,
    decisionId,
    createdAt,
    street,
    villainArchetype,
    heroAction,
    heroAmount,
    bestAction,
    bestSizingBb,
    evDeltaBb,
    evDeltaDollars,
    mistakeKey,
    contextKey,
    primaryTag,
    coarseTagsJson,
    adviceText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mistake &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.sessionId == this.sessionId &&
          other.handId == this.handId &&
          other.decisionId == this.decisionId &&
          other.createdAt == this.createdAt &&
          other.street == this.street &&
          other.villainArchetype == this.villainArchetype &&
          other.heroAction == this.heroAction &&
          other.heroAmount == this.heroAmount &&
          other.bestAction == this.bestAction &&
          other.bestSizingBb == this.bestSizingBb &&
          other.evDeltaBb == this.evDeltaBb &&
          other.evDeltaDollars == this.evDeltaDollars &&
          other.mistakeKey == this.mistakeKey &&
          other.contextKey == this.contextKey &&
          other.primaryTag == this.primaryTag &&
          other.coarseTagsJson == this.coarseTagsJson &&
          other.adviceText == this.adviceText);
}

class MistakesCompanion extends UpdateCompanion<Mistake> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> sessionId;
  final Value<String> handId;
  final Value<String?> decisionId;
  final Value<DateTime> createdAt;
  final Value<String> street;
  final Value<String> villainArchetype;
  final Value<String> heroAction;
  final Value<double> heroAmount;
  final Value<String> bestAction;
  final Value<double> bestSizingBb;
  final Value<double> evDeltaBb;
  final Value<double> evDeltaDollars;
  final Value<String> mistakeKey;
  final Value<String> contextKey;
  final Value<String> primaryTag;
  final Value<String> coarseTagsJson;
  final Value<String> adviceText;
  const MistakesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.handId = const Value.absent(),
    this.decisionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.street = const Value.absent(),
    this.villainArchetype = const Value.absent(),
    this.heroAction = const Value.absent(),
    this.heroAmount = const Value.absent(),
    this.bestAction = const Value.absent(),
    this.bestSizingBb = const Value.absent(),
    this.evDeltaBb = const Value.absent(),
    this.evDeltaDollars = const Value.absent(),
    this.mistakeKey = const Value.absent(),
    this.contextKey = const Value.absent(),
    this.primaryTag = const Value.absent(),
    this.coarseTagsJson = const Value.absent(),
    this.adviceText = const Value.absent(),
  });
  MistakesCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required String sessionId,
    required String handId,
    this.decisionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String street,
    required String villainArchetype,
    required String heroAction,
    this.heroAmount = const Value.absent(),
    required String bestAction,
    this.bestSizingBb = const Value.absent(),
    this.evDeltaBb = const Value.absent(),
    this.evDeltaDollars = const Value.absent(),
    required String mistakeKey,
    required String contextKey,
    required String primaryTag,
    this.coarseTagsJson = const Value.absent(),
    this.adviceText = const Value.absent(),
  }) : sessionId = Value(sessionId),
       handId = Value(handId),
       street = Value(street),
       villainArchetype = Value(villainArchetype),
       heroAction = Value(heroAction),
       bestAction = Value(bestAction),
       mistakeKey = Value(mistakeKey),
       contextKey = Value(contextKey),
       primaryTag = Value(primaryTag);
  static Insertable<Mistake> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? sessionId,
    Expression<String>? handId,
    Expression<String>? decisionId,
    Expression<DateTime>? createdAt,
    Expression<String>? street,
    Expression<String>? villainArchetype,
    Expression<String>? heroAction,
    Expression<double>? heroAmount,
    Expression<String>? bestAction,
    Expression<double>? bestSizingBb,
    Expression<double>? evDeltaBb,
    Expression<double>? evDeltaDollars,
    Expression<String>? mistakeKey,
    Expression<String>? contextKey,
    Expression<String>? primaryTag,
    Expression<String>? coarseTagsJson,
    Expression<String>? adviceText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
      if (handId != null) 'hand_id': handId,
      if (decisionId != null) 'decision_id': decisionId,
      if (createdAt != null) 'created_at': createdAt,
      if (street != null) 'street': street,
      if (villainArchetype != null) 'villain_archetype': villainArchetype,
      if (heroAction != null) 'hero_action': heroAction,
      if (heroAmount != null) 'hero_amount': heroAmount,
      if (bestAction != null) 'best_action': bestAction,
      if (bestSizingBb != null) 'best_sizing_bb': bestSizingBb,
      if (evDeltaBb != null) 'ev_delta_bb': evDeltaBb,
      if (evDeltaDollars != null) 'ev_delta_dollars': evDeltaDollars,
      if (mistakeKey != null) 'mistake_key': mistakeKey,
      if (contextKey != null) 'context_key': contextKey,
      if (primaryTag != null) 'primary_tag': primaryTag,
      if (coarseTagsJson != null) 'coarse_tags_json': coarseTagsJson,
      if (adviceText != null) 'advice_text': adviceText,
    });
  }

  MistakesCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? sessionId,
    Value<String>? handId,
    Value<String?>? decisionId,
    Value<DateTime>? createdAt,
    Value<String>? street,
    Value<String>? villainArchetype,
    Value<String>? heroAction,
    Value<double>? heroAmount,
    Value<String>? bestAction,
    Value<double>? bestSizingBb,
    Value<double>? evDeltaBb,
    Value<double>? evDeltaDollars,
    Value<String>? mistakeKey,
    Value<String>? contextKey,
    Value<String>? primaryTag,
    Value<String>? coarseTagsJson,
    Value<String>? adviceText,
  }) {
    return MistakesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      handId: handId ?? this.handId,
      decisionId: decisionId ?? this.decisionId,
      createdAt: createdAt ?? this.createdAt,
      street: street ?? this.street,
      villainArchetype: villainArchetype ?? this.villainArchetype,
      heroAction: heroAction ?? this.heroAction,
      heroAmount: heroAmount ?? this.heroAmount,
      bestAction: bestAction ?? this.bestAction,
      bestSizingBb: bestSizingBb ?? this.bestSizingBb,
      evDeltaBb: evDeltaBb ?? this.evDeltaBb,
      evDeltaDollars: evDeltaDollars ?? this.evDeltaDollars,
      mistakeKey: mistakeKey ?? this.mistakeKey,
      contextKey: contextKey ?? this.contextKey,
      primaryTag: primaryTag ?? this.primaryTag,
      coarseTagsJson: coarseTagsJson ?? this.coarseTagsJson,
      adviceText: adviceText ?? this.adviceText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (handId.present) {
      map['hand_id'] = Variable<String>(handId.value);
    }
    if (decisionId.present) {
      map['decision_id'] = Variable<String>(decisionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (street.present) {
      map['street'] = Variable<String>(street.value);
    }
    if (villainArchetype.present) {
      map['villain_archetype'] = Variable<String>(villainArchetype.value);
    }
    if (heroAction.present) {
      map['hero_action'] = Variable<String>(heroAction.value);
    }
    if (heroAmount.present) {
      map['hero_amount'] = Variable<double>(heroAmount.value);
    }
    if (bestAction.present) {
      map['best_action'] = Variable<String>(bestAction.value);
    }
    if (bestSizingBb.present) {
      map['best_sizing_bb'] = Variable<double>(bestSizingBb.value);
    }
    if (evDeltaBb.present) {
      map['ev_delta_bb'] = Variable<double>(evDeltaBb.value);
    }
    if (evDeltaDollars.present) {
      map['ev_delta_dollars'] = Variable<double>(evDeltaDollars.value);
    }
    if (mistakeKey.present) {
      map['mistake_key'] = Variable<String>(mistakeKey.value);
    }
    if (contextKey.present) {
      map['context_key'] = Variable<String>(contextKey.value);
    }
    if (primaryTag.present) {
      map['primary_tag'] = Variable<String>(primaryTag.value);
    }
    if (coarseTagsJson.present) {
      map['coarse_tags_json'] = Variable<String>(coarseTagsJson.value);
    }
    if (adviceText.present) {
      map['advice_text'] = Variable<String>(adviceText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MistakesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionId: $sessionId, ')
          ..write('handId: $handId, ')
          ..write('decisionId: $decisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('street: $street, ')
          ..write('villainArchetype: $villainArchetype, ')
          ..write('heroAction: $heroAction, ')
          ..write('heroAmount: $heroAmount, ')
          ..write('bestAction: $bestAction, ')
          ..write('bestSizingBb: $bestSizingBb, ')
          ..write('evDeltaBb: $evDeltaBb, ')
          ..write('evDeltaDollars: $evDeltaDollars, ')
          ..write('mistakeKey: $mistakeKey, ')
          ..write('contextKey: $contextKey, ')
          ..write('primaryTag: $primaryTag, ')
          ..write('coarseTagsJson: $coarseTagsJson, ')
          ..write('adviceText: $adviceText')
          ..write(')'))
        .toString();
  }
}

class $ImprovementEventsTable extends ImprovementEvents
    with TableInfo<$ImprovementEventsTable, ImprovementEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImprovementEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handIdMeta = const VerificationMeta('handId');
  @override
  late final GeneratedColumn<String> handId = GeneratedColumn<String>(
    'hand_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decisionIdMeta = const VerificationMeta(
    'decisionId',
  );
  @override
  late final GeneratedColumn<String> decisionId = GeneratedColumn<String>(
    'decision_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _mistakeKeyMeta = const VerificationMeta(
    'mistakeKey',
  );
  @override
  late final GeneratedColumn<String> mistakeKey = GeneratedColumn<String>(
    'mistake_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryTagMeta = const VerificationMeta(
    'primaryTag',
  );
  @override
  late final GeneratedColumn<String> primaryTag = GeneratedColumn<String>(
    'primary_tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
    'street',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _villainArchetypeMeta = const VerificationMeta(
    'villainArchetype',
  );
  @override
  late final GeneratedColumn<String> villainArchetype = GeneratedColumn<String>(
    'villain_archetype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heroActionMeta = const VerificationMeta(
    'heroAction',
  );
  @override
  late final GeneratedColumn<String> heroAction = GeneratedColumn<String>(
    'hero_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streakMeta = const VerificationMeta('streak');
  @override
  late final GeneratedColumn<int> streak = GeneratedColumn<int>(
    'streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    sessionId,
    handId,
    decisionId,
    createdAt,
    mistakeKey,
    primaryTag,
    street,
    villainArchetype,
    heroAction,
    streak,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'improvement_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImprovementEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('hand_id')) {
      context.handle(
        _handIdMeta,
        handId.isAcceptableOrUnknown(data['hand_id']!, _handIdMeta),
      );
    } else if (isInserting) {
      context.missing(_handIdMeta);
    }
    if (data.containsKey('decision_id')) {
      context.handle(
        _decisionIdMeta,
        decisionId.isAcceptableOrUnknown(data['decision_id']!, _decisionIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('mistake_key')) {
      context.handle(
        _mistakeKeyMeta,
        mistakeKey.isAcceptableOrUnknown(data['mistake_key']!, _mistakeKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_mistakeKeyMeta);
    }
    if (data.containsKey('primary_tag')) {
      context.handle(
        _primaryTagMeta,
        primaryTag.isAcceptableOrUnknown(data['primary_tag']!, _primaryTagMeta),
      );
    } else if (isInserting) {
      context.missing(_primaryTagMeta);
    }
    if (data.containsKey('street')) {
      context.handle(
        _streetMeta,
        street.isAcceptableOrUnknown(data['street']!, _streetMeta),
      );
    } else if (isInserting) {
      context.missing(_streetMeta);
    }
    if (data.containsKey('villain_archetype')) {
      context.handle(
        _villainArchetypeMeta,
        villainArchetype.isAcceptableOrUnknown(
          data['villain_archetype']!,
          _villainArchetypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_villainArchetypeMeta);
    }
    if (data.containsKey('hero_action')) {
      context.handle(
        _heroActionMeta,
        heroAction.isAcceptableOrUnknown(data['hero_action']!, _heroActionMeta),
      );
    } else if (isInserting) {
      context.missing(_heroActionMeta);
    }
    if (data.containsKey('streak')) {
      context.handle(
        _streakMeta,
        streak.isAcceptableOrUnknown(data['streak']!, _streakMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImprovementEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImprovementEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      handId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hand_id'],
      )!,
      decisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      mistakeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mistake_key'],
      )!,
      primaryTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_tag'],
      )!,
      street: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street'],
      )!,
      villainArchetype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}villain_archetype'],
      )!,
      heroAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_action'],
      )!,
      streak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak'],
      )!,
    );
  }

  @override
  $ImprovementEventsTable createAlias(String alias) {
    return $ImprovementEventsTable(attachedDatabase, alias);
  }
}

class ImprovementEvent extends DataClass
    implements Insertable<ImprovementEvent> {
  final int id;
  final String userId;
  final String sessionId;
  final String handId;
  final String? decisionId;
  final DateTime createdAt;

  /// The mistake key credited with this fix.
  final String mistakeKey;
  final String primaryTag;
  final String street;
  final String villainArchetype;
  final String heroAction;

  /// Consecutive fixes on this key since its last mistake, including this one.
  final int streak;
  const ImprovementEvent({
    required this.id,
    required this.userId,
    required this.sessionId,
    required this.handId,
    this.decisionId,
    required this.createdAt,
    required this.mistakeKey,
    required this.primaryTag,
    required this.street,
    required this.villainArchetype,
    required this.heroAction,
    required this.streak,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<String>(userId);
    map['session_id'] = Variable<String>(sessionId);
    map['hand_id'] = Variable<String>(handId);
    if (!nullToAbsent || decisionId != null) {
      map['decision_id'] = Variable<String>(decisionId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['mistake_key'] = Variable<String>(mistakeKey);
    map['primary_tag'] = Variable<String>(primaryTag);
    map['street'] = Variable<String>(street);
    map['villain_archetype'] = Variable<String>(villainArchetype);
    map['hero_action'] = Variable<String>(heroAction);
    map['streak'] = Variable<int>(streak);
    return map;
  }

  ImprovementEventsCompanion toCompanion(bool nullToAbsent) {
    return ImprovementEventsCompanion(
      id: Value(id),
      userId: Value(userId),
      sessionId: Value(sessionId),
      handId: Value(handId),
      decisionId: decisionId == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionId),
      createdAt: Value(createdAt),
      mistakeKey: Value(mistakeKey),
      primaryTag: Value(primaryTag),
      street: Value(street),
      villainArchetype: Value(villainArchetype),
      heroAction: Value(heroAction),
      streak: Value(streak),
    );
  }

  factory ImprovementEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImprovementEvent(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      handId: serializer.fromJson<String>(json['handId']),
      decisionId: serializer.fromJson<String?>(json['decisionId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      mistakeKey: serializer.fromJson<String>(json['mistakeKey']),
      primaryTag: serializer.fromJson<String>(json['primaryTag']),
      street: serializer.fromJson<String>(json['street']),
      villainArchetype: serializer.fromJson<String>(json['villainArchetype']),
      heroAction: serializer.fromJson<String>(json['heroAction']),
      streak: serializer.fromJson<int>(json['streak']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<String>(userId),
      'sessionId': serializer.toJson<String>(sessionId),
      'handId': serializer.toJson<String>(handId),
      'decisionId': serializer.toJson<String?>(decisionId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'mistakeKey': serializer.toJson<String>(mistakeKey),
      'primaryTag': serializer.toJson<String>(primaryTag),
      'street': serializer.toJson<String>(street),
      'villainArchetype': serializer.toJson<String>(villainArchetype),
      'heroAction': serializer.toJson<String>(heroAction),
      'streak': serializer.toJson<int>(streak),
    };
  }

  ImprovementEvent copyWith({
    int? id,
    String? userId,
    String? sessionId,
    String? handId,
    Value<String?> decisionId = const Value.absent(),
    DateTime? createdAt,
    String? mistakeKey,
    String? primaryTag,
    String? street,
    String? villainArchetype,
    String? heroAction,
    int? streak,
  }) => ImprovementEvent(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    sessionId: sessionId ?? this.sessionId,
    handId: handId ?? this.handId,
    decisionId: decisionId.present ? decisionId.value : this.decisionId,
    createdAt: createdAt ?? this.createdAt,
    mistakeKey: mistakeKey ?? this.mistakeKey,
    primaryTag: primaryTag ?? this.primaryTag,
    street: street ?? this.street,
    villainArchetype: villainArchetype ?? this.villainArchetype,
    heroAction: heroAction ?? this.heroAction,
    streak: streak ?? this.streak,
  );
  ImprovementEvent copyWithCompanion(ImprovementEventsCompanion data) {
    return ImprovementEvent(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      handId: data.handId.present ? data.handId.value : this.handId,
      decisionId: data.decisionId.present
          ? data.decisionId.value
          : this.decisionId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      mistakeKey: data.mistakeKey.present
          ? data.mistakeKey.value
          : this.mistakeKey,
      primaryTag: data.primaryTag.present
          ? data.primaryTag.value
          : this.primaryTag,
      street: data.street.present ? data.street.value : this.street,
      villainArchetype: data.villainArchetype.present
          ? data.villainArchetype.value
          : this.villainArchetype,
      heroAction: data.heroAction.present
          ? data.heroAction.value
          : this.heroAction,
      streak: data.streak.present ? data.streak.value : this.streak,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImprovementEvent(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionId: $sessionId, ')
          ..write('handId: $handId, ')
          ..write('decisionId: $decisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('mistakeKey: $mistakeKey, ')
          ..write('primaryTag: $primaryTag, ')
          ..write('street: $street, ')
          ..write('villainArchetype: $villainArchetype, ')
          ..write('heroAction: $heroAction, ')
          ..write('streak: $streak')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    sessionId,
    handId,
    decisionId,
    createdAt,
    mistakeKey,
    primaryTag,
    street,
    villainArchetype,
    heroAction,
    streak,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImprovementEvent &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.sessionId == this.sessionId &&
          other.handId == this.handId &&
          other.decisionId == this.decisionId &&
          other.createdAt == this.createdAt &&
          other.mistakeKey == this.mistakeKey &&
          other.primaryTag == this.primaryTag &&
          other.street == this.street &&
          other.villainArchetype == this.villainArchetype &&
          other.heroAction == this.heroAction &&
          other.streak == this.streak);
}

class ImprovementEventsCompanion extends UpdateCompanion<ImprovementEvent> {
  final Value<int> id;
  final Value<String> userId;
  final Value<String> sessionId;
  final Value<String> handId;
  final Value<String?> decisionId;
  final Value<DateTime> createdAt;
  final Value<String> mistakeKey;
  final Value<String> primaryTag;
  final Value<String> street;
  final Value<String> villainArchetype;
  final Value<String> heroAction;
  final Value<int> streak;
  const ImprovementEventsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.handId = const Value.absent(),
    this.decisionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.mistakeKey = const Value.absent(),
    this.primaryTag = const Value.absent(),
    this.street = const Value.absent(),
    this.villainArchetype = const Value.absent(),
    this.heroAction = const Value.absent(),
    this.streak = const Value.absent(),
  });
  ImprovementEventsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    required String sessionId,
    required String handId,
    this.decisionId = const Value.absent(),
    this.createdAt = const Value.absent(),
    required String mistakeKey,
    required String primaryTag,
    required String street,
    required String villainArchetype,
    required String heroAction,
    this.streak = const Value.absent(),
  }) : sessionId = Value(sessionId),
       handId = Value(handId),
       mistakeKey = Value(mistakeKey),
       primaryTag = Value(primaryTag),
       street = Value(street),
       villainArchetype = Value(villainArchetype),
       heroAction = Value(heroAction);
  static Insertable<ImprovementEvent> custom({
    Expression<int>? id,
    Expression<String>? userId,
    Expression<String>? sessionId,
    Expression<String>? handId,
    Expression<String>? decisionId,
    Expression<DateTime>? createdAt,
    Expression<String>? mistakeKey,
    Expression<String>? primaryTag,
    Expression<String>? street,
    Expression<String>? villainArchetype,
    Expression<String>? heroAction,
    Expression<int>? streak,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (sessionId != null) 'session_id': sessionId,
      if (handId != null) 'hand_id': handId,
      if (decisionId != null) 'decision_id': decisionId,
      if (createdAt != null) 'created_at': createdAt,
      if (mistakeKey != null) 'mistake_key': mistakeKey,
      if (primaryTag != null) 'primary_tag': primaryTag,
      if (street != null) 'street': street,
      if (villainArchetype != null) 'villain_archetype': villainArchetype,
      if (heroAction != null) 'hero_action': heroAction,
      if (streak != null) 'streak': streak,
    });
  }

  ImprovementEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? userId,
    Value<String>? sessionId,
    Value<String>? handId,
    Value<String?>? decisionId,
    Value<DateTime>? createdAt,
    Value<String>? mistakeKey,
    Value<String>? primaryTag,
    Value<String>? street,
    Value<String>? villainArchetype,
    Value<String>? heroAction,
    Value<int>? streak,
  }) {
    return ImprovementEventsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      handId: handId ?? this.handId,
      decisionId: decisionId ?? this.decisionId,
      createdAt: createdAt ?? this.createdAt,
      mistakeKey: mistakeKey ?? this.mistakeKey,
      primaryTag: primaryTag ?? this.primaryTag,
      street: street ?? this.street,
      villainArchetype: villainArchetype ?? this.villainArchetype,
      heroAction: heroAction ?? this.heroAction,
      streak: streak ?? this.streak,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (handId.present) {
      map['hand_id'] = Variable<String>(handId.value);
    }
    if (decisionId.present) {
      map['decision_id'] = Variable<String>(decisionId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (mistakeKey.present) {
      map['mistake_key'] = Variable<String>(mistakeKey.value);
    }
    if (primaryTag.present) {
      map['primary_tag'] = Variable<String>(primaryTag.value);
    }
    if (street.present) {
      map['street'] = Variable<String>(street.value);
    }
    if (villainArchetype.present) {
      map['villain_archetype'] = Variable<String>(villainArchetype.value);
    }
    if (heroAction.present) {
      map['hero_action'] = Variable<String>(heroAction.value);
    }
    if (streak.present) {
      map['streak'] = Variable<int>(streak.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImprovementEventsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionId: $sessionId, ')
          ..write('handId: $handId, ')
          ..write('decisionId: $decisionId, ')
          ..write('createdAt: $createdAt, ')
          ..write('mistakeKey: $mistakeKey, ')
          ..write('primaryTag: $primaryTag, ')
          ..write('street: $street, ')
          ..write('villainArchetype: $villainArchetype, ')
          ..write('heroAction: $heroAction, ')
          ..write('streak: $streak')
          ..write(')'))
        .toString();
  }
}

class $AppSessionsTable extends AppSessions
    with TableInfo<$AppSessionsTable, AppSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionUuidMeta = const VerificationMeta(
    'sessionUuid',
  );
  @override
  late final GeneratedColumn<String> sessionUuid = GeneratedColumn<String>(
    'session_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _startedAtMsMeta = const VerificationMeta(
    'startedAtMs',
  );
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
    'started_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMsMeta = const VerificationMeta(
    'lastSeenAtMs',
  );
  @override
  late final GeneratedColumn<int> lastSeenAtMs = GeneratedColumn<int>(
    'last_seen_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMsMeta = const VerificationMeta(
    'endedAtMs',
  );
  @override
  late final GeneratedColumn<int> endedAtMs = GeneratedColumn<int>(
    'ended_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _buildNumberMeta = const VerificationMeta(
    'buildNumber',
  );
  @override
  late final GeneratedColumn<String> buildNumber = GeneratedColumn<String>(
    'build_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _osVersionMeta = const VerificationMeta(
    'osVersion',
  );
  @override
  late final GeneratedColumn<String> osVersion = GeneratedColumn<String>(
    'os_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isDebugBuildMeta = const VerificationMeta(
    'isDebugBuild',
  );
  @override
  late final GeneratedColumn<bool> isDebugBuild = GeneratedColumn<bool>(
    'is_debug_build',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_debug_build" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionUuid,
    startedAtMs,
    lastSeenAtMs,
    endedAtMs,
    appVersion,
    buildNumber,
    platform,
    osVersion,
    isDebugBuild,
    schemaVersion,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_uuid')) {
      context.handle(
        _sessionUuidMeta,
        sessionUuid.isAcceptableOrUnknown(
          data['session_uuid']!,
          _sessionUuidMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionUuidMeta);
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
        _startedAtMsMeta,
        startedAtMs.isAcceptableOrUnknown(
          data['started_at_ms']!,
          _startedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('last_seen_at_ms')) {
      context.handle(
        _lastSeenAtMsMeta,
        lastSeenAtMs.isAcceptableOrUnknown(
          data['last_seen_at_ms']!,
          _lastSeenAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMsMeta);
    }
    if (data.containsKey('ended_at_ms')) {
      context.handle(
        _endedAtMsMeta,
        endedAtMs.isAcceptableOrUnknown(data['ended_at_ms']!, _endedAtMsMeta),
      );
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    }
    if (data.containsKey('build_number')) {
      context.handle(
        _buildNumberMeta,
        buildNumber.isAcceptableOrUnknown(
          data['build_number']!,
          _buildNumberMeta,
        ),
      );
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('os_version')) {
      context.handle(
        _osVersionMeta,
        osVersion.isAcceptableOrUnknown(data['os_version']!, _osVersionMeta),
      );
    }
    if (data.containsKey('is_debug_build')) {
      context.handle(
        _isDebugBuildMeta,
        isDebugBuild.isAcceptableOrUnknown(
          data['is_debug_build']!,
          _isDebugBuildMeta,
        ),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_uuid'],
      )!,
      startedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_ms'],
      )!,
      lastSeenAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen_at_ms'],
      )!,
      endedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at_ms'],
      ),
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      )!,
      buildNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}build_number'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      osVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}os_version'],
      )!,
      isDebugBuild: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_debug_build'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $AppSessionsTable createAlias(String alias) {
    return $AppSessionsTable(attachedDatabase, alias);
  }
}

class AppSession extends DataClass implements Insertable<AppSession> {
  final int id;

  /// Random id that stays stable for the lifetime of the process.
  final String sessionUuid;
  final int startedAtMs;

  /// Last lifecycle heartbeat (resume / pause / detach). Mobile OSes kill
  /// processes without notice, so this is the best "shutdown" estimate.
  final int lastSeenAtMs;

  /// Set when the app reported `detached` / `paused`; null while alive.
  final int? endedAtMs;
  final String appVersion;
  final String buildNumber;

  /// `ios`, `android`, `web`, `macos`, …
  final String platform;
  final String osVersion;
  final bool isDebugBuild;

  /// Schema version that was live when the session started.
  final int schemaVersion;
  final int createdAtMs;
  final int updatedAtMs;
  const AppSession({
    required this.id,
    required this.sessionUuid,
    required this.startedAtMs,
    required this.lastSeenAtMs,
    this.endedAtMs,
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    required this.osVersion,
    required this.isDebugBuild,
    required this.schemaVersion,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_uuid'] = Variable<String>(sessionUuid);
    map['started_at_ms'] = Variable<int>(startedAtMs);
    map['last_seen_at_ms'] = Variable<int>(lastSeenAtMs);
    if (!nullToAbsent || endedAtMs != null) {
      map['ended_at_ms'] = Variable<int>(endedAtMs);
    }
    map['app_version'] = Variable<String>(appVersion);
    map['build_number'] = Variable<String>(buildNumber);
    map['platform'] = Variable<String>(platform);
    map['os_version'] = Variable<String>(osVersion);
    map['is_debug_build'] = Variable<bool>(isDebugBuild);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  AppSessionsCompanion toCompanion(bool nullToAbsent) {
    return AppSessionsCompanion(
      id: Value(id),
      sessionUuid: Value(sessionUuid),
      startedAtMs: Value(startedAtMs),
      lastSeenAtMs: Value(lastSeenAtMs),
      endedAtMs: endedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAtMs),
      appVersion: Value(appVersion),
      buildNumber: Value(buildNumber),
      platform: Value(platform),
      osVersion: Value(osVersion),
      isDebugBuild: Value(isDebugBuild),
      schemaVersion: Value(schemaVersion),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory AppSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSession(
      id: serializer.fromJson<int>(json['id']),
      sessionUuid: serializer.fromJson<String>(json['sessionUuid']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      lastSeenAtMs: serializer.fromJson<int>(json['lastSeenAtMs']),
      endedAtMs: serializer.fromJson<int?>(json['endedAtMs']),
      appVersion: serializer.fromJson<String>(json['appVersion']),
      buildNumber: serializer.fromJson<String>(json['buildNumber']),
      platform: serializer.fromJson<String>(json['platform']),
      osVersion: serializer.fromJson<String>(json['osVersion']),
      isDebugBuild: serializer.fromJson<bool>(json['isDebugBuild']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionUuid': serializer.toJson<String>(sessionUuid),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'lastSeenAtMs': serializer.toJson<int>(lastSeenAtMs),
      'endedAtMs': serializer.toJson<int?>(endedAtMs),
      'appVersion': serializer.toJson<String>(appVersion),
      'buildNumber': serializer.toJson<String>(buildNumber),
      'platform': serializer.toJson<String>(platform),
      'osVersion': serializer.toJson<String>(osVersion),
      'isDebugBuild': serializer.toJson<bool>(isDebugBuild),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  AppSession copyWith({
    int? id,
    String? sessionUuid,
    int? startedAtMs,
    int? lastSeenAtMs,
    Value<int?> endedAtMs = const Value.absent(),
    String? appVersion,
    String? buildNumber,
    String? platform,
    String? osVersion,
    bool? isDebugBuild,
    int? schemaVersion,
    int? createdAtMs,
    int? updatedAtMs,
  }) => AppSession(
    id: id ?? this.id,
    sessionUuid: sessionUuid ?? this.sessionUuid,
    startedAtMs: startedAtMs ?? this.startedAtMs,
    lastSeenAtMs: lastSeenAtMs ?? this.lastSeenAtMs,
    endedAtMs: endedAtMs.present ? endedAtMs.value : this.endedAtMs,
    appVersion: appVersion ?? this.appVersion,
    buildNumber: buildNumber ?? this.buildNumber,
    platform: platform ?? this.platform,
    osVersion: osVersion ?? this.osVersion,
    isDebugBuild: isDebugBuild ?? this.isDebugBuild,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  AppSession copyWithCompanion(AppSessionsCompanion data) {
    return AppSession(
      id: data.id.present ? data.id.value : this.id,
      sessionUuid: data.sessionUuid.present
          ? data.sessionUuid.value
          : this.sessionUuid,
      startedAtMs: data.startedAtMs.present
          ? data.startedAtMs.value
          : this.startedAtMs,
      lastSeenAtMs: data.lastSeenAtMs.present
          ? data.lastSeenAtMs.value
          : this.lastSeenAtMs,
      endedAtMs: data.endedAtMs.present ? data.endedAtMs.value : this.endedAtMs,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      buildNumber: data.buildNumber.present
          ? data.buildNumber.value
          : this.buildNumber,
      platform: data.platform.present ? data.platform.value : this.platform,
      osVersion: data.osVersion.present ? data.osVersion.value : this.osVersion,
      isDebugBuild: data.isDebugBuild.present
          ? data.isDebugBuild.value
          : this.isDebugBuild,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSession(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('lastSeenAtMs: $lastSeenAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('appVersion: $appVersion, ')
          ..write('buildNumber: $buildNumber, ')
          ..write('platform: $platform, ')
          ..write('osVersion: $osVersion, ')
          ..write('isDebugBuild: $isDebugBuild, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionUuid,
    startedAtMs,
    lastSeenAtMs,
    endedAtMs,
    appVersion,
    buildNumber,
    platform,
    osVersion,
    isDebugBuild,
    schemaVersion,
    createdAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSession &&
          other.id == this.id &&
          other.sessionUuid == this.sessionUuid &&
          other.startedAtMs == this.startedAtMs &&
          other.lastSeenAtMs == this.lastSeenAtMs &&
          other.endedAtMs == this.endedAtMs &&
          other.appVersion == this.appVersion &&
          other.buildNumber == this.buildNumber &&
          other.platform == this.platform &&
          other.osVersion == this.osVersion &&
          other.isDebugBuild == this.isDebugBuild &&
          other.schemaVersion == this.schemaVersion &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class AppSessionsCompanion extends UpdateCompanion<AppSession> {
  final Value<int> id;
  final Value<String> sessionUuid;
  final Value<int> startedAtMs;
  final Value<int> lastSeenAtMs;
  final Value<int?> endedAtMs;
  final Value<String> appVersion;
  final Value<String> buildNumber;
  final Value<String> platform;
  final Value<String> osVersion;
  final Value<bool> isDebugBuild;
  final Value<int> schemaVersion;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  const AppSessionsCompanion({
    this.id = const Value.absent(),
    this.sessionUuid = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.lastSeenAtMs = const Value.absent(),
    this.endedAtMs = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.buildNumber = const Value.absent(),
    this.platform = const Value.absent(),
    this.osVersion = const Value.absent(),
    this.isDebugBuild = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
  });
  AppSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionUuid,
    required int startedAtMs,
    required int lastSeenAtMs,
    this.endedAtMs = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.buildNumber = const Value.absent(),
    this.platform = const Value.absent(),
    this.osVersion = const Value.absent(),
    this.isDebugBuild = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
  }) : sessionUuid = Value(sessionUuid),
       startedAtMs = Value(startedAtMs),
       lastSeenAtMs = Value(lastSeenAtMs),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<AppSession> custom({
    Expression<int>? id,
    Expression<String>? sessionUuid,
    Expression<int>? startedAtMs,
    Expression<int>? lastSeenAtMs,
    Expression<int>? endedAtMs,
    Expression<String>? appVersion,
    Expression<String>? buildNumber,
    Expression<String>? platform,
    Expression<String>? osVersion,
    Expression<bool>? isDebugBuild,
    Expression<int>? schemaVersion,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionUuid != null) 'session_uuid': sessionUuid,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (lastSeenAtMs != null) 'last_seen_at_ms': lastSeenAtMs,
      if (endedAtMs != null) 'ended_at_ms': endedAtMs,
      if (appVersion != null) 'app_version': appVersion,
      if (buildNumber != null) 'build_number': buildNumber,
      if (platform != null) 'platform': platform,
      if (osVersion != null) 'os_version': osVersion,
      if (isDebugBuild != null) 'is_debug_build': isDebugBuild,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
    });
  }

  AppSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionUuid,
    Value<int>? startedAtMs,
    Value<int>? lastSeenAtMs,
    Value<int?>? endedAtMs,
    Value<String>? appVersion,
    Value<String>? buildNumber,
    Value<String>? platform,
    Value<String>? osVersion,
    Value<bool>? isDebugBuild,
    Value<int>? schemaVersion,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
  }) {
    return AppSessionsCompanion(
      id: id ?? this.id,
      sessionUuid: sessionUuid ?? this.sessionUuid,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      lastSeenAtMs: lastSeenAtMs ?? this.lastSeenAtMs,
      endedAtMs: endedAtMs ?? this.endedAtMs,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      platform: platform ?? this.platform,
      osVersion: osVersion ?? this.osVersion,
      isDebugBuild: isDebugBuild ?? this.isDebugBuild,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionUuid.present) {
      map['session_uuid'] = Variable<String>(sessionUuid.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (lastSeenAtMs.present) {
      map['last_seen_at_ms'] = Variable<int>(lastSeenAtMs.value);
    }
    if (endedAtMs.present) {
      map['ended_at_ms'] = Variable<int>(endedAtMs.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (buildNumber.present) {
      map['build_number'] = Variable<String>(buildNumber.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (osVersion.present) {
      map['os_version'] = Variable<String>(osVersion.value);
    }
    if (isDebugBuild.present) {
      map['is_debug_build'] = Variable<bool>(isDebugBuild.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSessionsCompanion(')
          ..write('id: $id, ')
          ..write('sessionUuid: $sessionUuid, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('lastSeenAtMs: $lastSeenAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('appVersion: $appVersion, ')
          ..write('buildNumber: $buildNumber, ')
          ..write('platform: $platform, ')
          ..write('osVersion: $osVersion, ')
          ..write('isDebugBuild: $isDebugBuild, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }
}

class $AiRequestsTable extends AiRequests
    with TableInfo<$AiRequestsTable, AiRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _handIdMeta = const VerificationMeta('handId');
  @override
  late final GeneratedColumn<int> handId = GeneratedColumn<int>(
    'hand_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestKindMeta = const VerificationMeta(
    'requestKind',
  );
  @override
  late final GeneratedColumn<String> requestKind = GeneratedColumn<String>(
    'request_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systemInstructionHashMeta =
      const VerificationMeta('systemInstructionHash');
  @override
  late final GeneratedColumn<String> systemInstructionHash =
      GeneratedColumn<String>(
        'system_instruction_hash',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  static const VerificationMeta _promptHashMeta = const VerificationMeta(
    'promptHash',
  );
  @override
  late final GeneratedColumn<String> promptHash = GeneratedColumn<String>(
    'prompt_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptTextMeta = const VerificationMeta(
    'promptText',
  );
  @override
  late final GeneratedColumn<String> promptText = GeneratedColumn<String>(
    'prompt_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptFullMeta = const VerificationMeta(
    'promptFull',
  );
  @override
  late final GeneratedColumn<Uint8List> promptFull = GeneratedColumn<Uint8List>(
    'prompt_full',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _requestedAtMsMeta = const VerificationMeta(
    'requestedAtMs',
  );
  @override
  late final GeneratedColumn<int> requestedAtMs = GeneratedColumn<int>(
    'requested_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respondedAtMsMeta = const VerificationMeta(
    'respondedAtMs',
  );
  @override
  late final GeneratedColumn<int> respondedAtMs = GeneratedColumn<int>(
    'responded_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latencyMsMeta = const VerificationMeta(
    'latencyMs',
  );
  @override
  late final GeneratedColumn<int> latencyMs = GeneratedColumn<int>(
    'latency_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _httpStatusMeta = const VerificationMeta(
    'httpStatus',
  );
  @override
  late final GeneratedColumn<int> httpStatus = GeneratedColumn<int>(
    'http_status',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promptTokensMeta = const VerificationMeta(
    'promptTokens',
  );
  @override
  late final GeneratedColumn<int> promptTokens = GeneratedColumn<int>(
    'prompt_tokens',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responseTokensMeta = const VerificationMeta(
    'responseTokens',
  );
  @override
  late final GeneratedColumn<int> responseTokens = GeneratedColumn<int>(
    'response_tokens',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalTokensMeta = const VerificationMeta(
    'totalTokens',
  );
  @override
  late final GeneratedColumn<int> totalTokens = GeneratedColumn<int>(
    'total_tokens',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responseTextMeta = const VerificationMeta(
    'responseText',
  );
  @override
  late final GeneratedColumn<String> responseText = GeneratedColumn<String>(
    'response_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _responseBytesMeta = const VerificationMeta(
    'responseBytes',
  );
  @override
  late final GeneratedColumn<int> responseBytes = GeneratedColumn<int>(
    'response_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _fromCacheMeta = const VerificationMeta(
    'fromCache',
  );
  @override
  late final GeneratedColumn<bool> fromCache = GeneratedColumn<bool>(
    'from_cache',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("from_cache" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    handId,
    requestKind,
    modelId,
    systemInstructionHash,
    promptHash,
    promptText,
    promptFull,
    requestedAtMs,
    respondedAtMs,
    latencyMs,
    httpStatus,
    success,
    errorMessage,
    promptTokens,
    responseTokens,
    totalTokens,
    responseText,
    responseBytes,
    attempt,
    fromCache,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('hand_id')) {
      context.handle(
        _handIdMeta,
        handId.isAcceptableOrUnknown(data['hand_id']!, _handIdMeta),
      );
    }
    if (data.containsKey('request_kind')) {
      context.handle(
        _requestKindMeta,
        requestKind.isAcceptableOrUnknown(
          data['request_kind']!,
          _requestKindMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestKindMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('system_instruction_hash')) {
      context.handle(
        _systemInstructionHashMeta,
        systemInstructionHash.isAcceptableOrUnknown(
          data['system_instruction_hash']!,
          _systemInstructionHashMeta,
        ),
      );
    }
    if (data.containsKey('prompt_hash')) {
      context.handle(
        _promptHashMeta,
        promptHash.isAcceptableOrUnknown(data['prompt_hash']!, _promptHashMeta),
      );
    } else if (isInserting) {
      context.missing(_promptHashMeta);
    }
    if (data.containsKey('prompt_text')) {
      context.handle(
        _promptTextMeta,
        promptText.isAcceptableOrUnknown(data['prompt_text']!, _promptTextMeta),
      );
    } else if (isInserting) {
      context.missing(_promptTextMeta);
    }
    if (data.containsKey('prompt_full')) {
      context.handle(
        _promptFullMeta,
        promptFull.isAcceptableOrUnknown(data['prompt_full']!, _promptFullMeta),
      );
    }
    if (data.containsKey('requested_at_ms')) {
      context.handle(
        _requestedAtMsMeta,
        requestedAtMs.isAcceptableOrUnknown(
          data['requested_at_ms']!,
          _requestedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_requestedAtMsMeta);
    }
    if (data.containsKey('responded_at_ms')) {
      context.handle(
        _respondedAtMsMeta,
        respondedAtMs.isAcceptableOrUnknown(
          data['responded_at_ms']!,
          _respondedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('latency_ms')) {
      context.handle(
        _latencyMsMeta,
        latencyMs.isAcceptableOrUnknown(data['latency_ms']!, _latencyMsMeta),
      );
    }
    if (data.containsKey('http_status')) {
      context.handle(
        _httpStatusMeta,
        httpStatus.isAcceptableOrUnknown(data['http_status']!, _httpStatusMeta),
      );
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('prompt_tokens')) {
      context.handle(
        _promptTokensMeta,
        promptTokens.isAcceptableOrUnknown(
          data['prompt_tokens']!,
          _promptTokensMeta,
        ),
      );
    }
    if (data.containsKey('response_tokens')) {
      context.handle(
        _responseTokensMeta,
        responseTokens.isAcceptableOrUnknown(
          data['response_tokens']!,
          _responseTokensMeta,
        ),
      );
    }
    if (data.containsKey('total_tokens')) {
      context.handle(
        _totalTokensMeta,
        totalTokens.isAcceptableOrUnknown(
          data['total_tokens']!,
          _totalTokensMeta,
        ),
      );
    }
    if (data.containsKey('response_text')) {
      context.handle(
        _responseTextMeta,
        responseText.isAcceptableOrUnknown(
          data['response_text']!,
          _responseTextMeta,
        ),
      );
    }
    if (data.containsKey('response_bytes')) {
      context.handle(
        _responseBytesMeta,
        responseBytes.isAcceptableOrUnknown(
          data['response_bytes']!,
          _responseBytesMeta,
        ),
      );
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    if (data.containsKey('from_cache')) {
      context.handle(
        _fromCacheMeta,
        fromCache.isAcceptableOrUnknown(data['from_cache']!, _fromCacheMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      handId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hand_id'],
      ),
      requestKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}request_kind'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      systemInstructionHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}system_instruction_hash'],
      )!,
      promptHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_hash'],
      )!,
      promptText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_text'],
      )!,
      promptFull: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}prompt_full'],
      ),
      requestedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_at_ms'],
      )!,
      respondedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}responded_at_ms'],
      ),
      latencyMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}latency_ms'],
      ),
      httpStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}http_status'],
      ),
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      promptTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}prompt_tokens'],
      ),
      responseTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_tokens'],
      ),
      totalTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_tokens'],
      ),
      responseText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}response_text'],
      ),
      responseBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_bytes'],
      ),
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      fromCache: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}from_cache'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $AiRequestsTable createAlias(String alias) {
    return $AiRequestsTable(attachedDatabase, alias);
  }
}

class AiRequest extends DataClass implements Insertable<AiRequest> {
  final int id;
  final int? sessionId;
  final int? handId;

  /// `scenario`, `coach`, `tts`, `image`.
  final String requestKind;
  final String modelId;

  /// SHA-256 of the system instruction (empty when none was sent).
  final String systemInstructionHash;

  /// SHA-256 of the user prompt as sent.
  final String promptHash;

  /// Prompt text, truncated to `RetentionPolicy.maxInlineTextChars`.
  final String promptText;

  /// Full prompt bytes (UTF-8) only when [promptText] had to be truncated.
  final Uint8List? promptFull;
  final int requestedAtMs;
  final int? respondedAtMs;
  final int? latencyMs;
  final int? httpStatus;
  final bool success;

  /// Redacted error / exception message.
  final String? errorMessage;
  final int? promptTokens;
  final int? responseTokens;
  final int? totalTokens;

  /// Text response (truncated). For audio/image responses this holds the MIME
  /// type and byte length instead of the payload.
  final String? responseText;

  /// Size of a binary response (audio / image) in bytes.
  final int? responseBytes;

  /// 1-based attempt counter (retries increment it).
  final int attempt;
  final bool fromCache;
  final int createdAtMs;
  const AiRequest({
    required this.id,
    this.sessionId,
    this.handId,
    required this.requestKind,
    required this.modelId,
    required this.systemInstructionHash,
    required this.promptHash,
    required this.promptText,
    this.promptFull,
    required this.requestedAtMs,
    this.respondedAtMs,
    this.latencyMs,
    this.httpStatus,
    required this.success,
    this.errorMessage,
    this.promptTokens,
    this.responseTokens,
    this.totalTokens,
    this.responseText,
    this.responseBytes,
    required this.attempt,
    required this.fromCache,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    if (!nullToAbsent || handId != null) {
      map['hand_id'] = Variable<int>(handId);
    }
    map['request_kind'] = Variable<String>(requestKind);
    map['model_id'] = Variable<String>(modelId);
    map['system_instruction_hash'] = Variable<String>(systemInstructionHash);
    map['prompt_hash'] = Variable<String>(promptHash);
    map['prompt_text'] = Variable<String>(promptText);
    if (!nullToAbsent || promptFull != null) {
      map['prompt_full'] = Variable<Uint8List>(promptFull);
    }
    map['requested_at_ms'] = Variable<int>(requestedAtMs);
    if (!nullToAbsent || respondedAtMs != null) {
      map['responded_at_ms'] = Variable<int>(respondedAtMs);
    }
    if (!nullToAbsent || latencyMs != null) {
      map['latency_ms'] = Variable<int>(latencyMs);
    }
    if (!nullToAbsent || httpStatus != null) {
      map['http_status'] = Variable<int>(httpStatus);
    }
    map['success'] = Variable<bool>(success);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    if (!nullToAbsent || promptTokens != null) {
      map['prompt_tokens'] = Variable<int>(promptTokens);
    }
    if (!nullToAbsent || responseTokens != null) {
      map['response_tokens'] = Variable<int>(responseTokens);
    }
    if (!nullToAbsent || totalTokens != null) {
      map['total_tokens'] = Variable<int>(totalTokens);
    }
    if (!nullToAbsent || responseText != null) {
      map['response_text'] = Variable<String>(responseText);
    }
    if (!nullToAbsent || responseBytes != null) {
      map['response_bytes'] = Variable<int>(responseBytes);
    }
    map['attempt'] = Variable<int>(attempt);
    map['from_cache'] = Variable<bool>(fromCache);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  AiRequestsCompanion toCompanion(bool nullToAbsent) {
    return AiRequestsCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      handId: handId == null && nullToAbsent
          ? const Value.absent()
          : Value(handId),
      requestKind: Value(requestKind),
      modelId: Value(modelId),
      systemInstructionHash: Value(systemInstructionHash),
      promptHash: Value(promptHash),
      promptText: Value(promptText),
      promptFull: promptFull == null && nullToAbsent
          ? const Value.absent()
          : Value(promptFull),
      requestedAtMs: Value(requestedAtMs),
      respondedAtMs: respondedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(respondedAtMs),
      latencyMs: latencyMs == null && nullToAbsent
          ? const Value.absent()
          : Value(latencyMs),
      httpStatus: httpStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(httpStatus),
      success: Value(success),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      promptTokens: promptTokens == null && nullToAbsent
          ? const Value.absent()
          : Value(promptTokens),
      responseTokens: responseTokens == null && nullToAbsent
          ? const Value.absent()
          : Value(responseTokens),
      totalTokens: totalTokens == null && nullToAbsent
          ? const Value.absent()
          : Value(totalTokens),
      responseText: responseText == null && nullToAbsent
          ? const Value.absent()
          : Value(responseText),
      responseBytes: responseBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(responseBytes),
      attempt: Value(attempt),
      fromCache: Value(fromCache),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory AiRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiRequest(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      handId: serializer.fromJson<int?>(json['handId']),
      requestKind: serializer.fromJson<String>(json['requestKind']),
      modelId: serializer.fromJson<String>(json['modelId']),
      systemInstructionHash: serializer.fromJson<String>(
        json['systemInstructionHash'],
      ),
      promptHash: serializer.fromJson<String>(json['promptHash']),
      promptText: serializer.fromJson<String>(json['promptText']),
      promptFull: serializer.fromJson<Uint8List?>(json['promptFull']),
      requestedAtMs: serializer.fromJson<int>(json['requestedAtMs']),
      respondedAtMs: serializer.fromJson<int?>(json['respondedAtMs']),
      latencyMs: serializer.fromJson<int?>(json['latencyMs']),
      httpStatus: serializer.fromJson<int?>(json['httpStatus']),
      success: serializer.fromJson<bool>(json['success']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      promptTokens: serializer.fromJson<int?>(json['promptTokens']),
      responseTokens: serializer.fromJson<int?>(json['responseTokens']),
      totalTokens: serializer.fromJson<int?>(json['totalTokens']),
      responseText: serializer.fromJson<String?>(json['responseText']),
      responseBytes: serializer.fromJson<int?>(json['responseBytes']),
      attempt: serializer.fromJson<int>(json['attempt']),
      fromCache: serializer.fromJson<bool>(json['fromCache']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'handId': serializer.toJson<int?>(handId),
      'requestKind': serializer.toJson<String>(requestKind),
      'modelId': serializer.toJson<String>(modelId),
      'systemInstructionHash': serializer.toJson<String>(systemInstructionHash),
      'promptHash': serializer.toJson<String>(promptHash),
      'promptText': serializer.toJson<String>(promptText),
      'promptFull': serializer.toJson<Uint8List?>(promptFull),
      'requestedAtMs': serializer.toJson<int>(requestedAtMs),
      'respondedAtMs': serializer.toJson<int?>(respondedAtMs),
      'latencyMs': serializer.toJson<int?>(latencyMs),
      'httpStatus': serializer.toJson<int?>(httpStatus),
      'success': serializer.toJson<bool>(success),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'promptTokens': serializer.toJson<int?>(promptTokens),
      'responseTokens': serializer.toJson<int?>(responseTokens),
      'totalTokens': serializer.toJson<int?>(totalTokens),
      'responseText': serializer.toJson<String?>(responseText),
      'responseBytes': serializer.toJson<int?>(responseBytes),
      'attempt': serializer.toJson<int>(attempt),
      'fromCache': serializer.toJson<bool>(fromCache),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  AiRequest copyWith({
    int? id,
    Value<int?> sessionId = const Value.absent(),
    Value<int?> handId = const Value.absent(),
    String? requestKind,
    String? modelId,
    String? systemInstructionHash,
    String? promptHash,
    String? promptText,
    Value<Uint8List?> promptFull = const Value.absent(),
    int? requestedAtMs,
    Value<int?> respondedAtMs = const Value.absent(),
    Value<int?> latencyMs = const Value.absent(),
    Value<int?> httpStatus = const Value.absent(),
    bool? success,
    Value<String?> errorMessage = const Value.absent(),
    Value<int?> promptTokens = const Value.absent(),
    Value<int?> responseTokens = const Value.absent(),
    Value<int?> totalTokens = const Value.absent(),
    Value<String?> responseText = const Value.absent(),
    Value<int?> responseBytes = const Value.absent(),
    int? attempt,
    bool? fromCache,
    int? createdAtMs,
  }) => AiRequest(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    handId: handId.present ? handId.value : this.handId,
    requestKind: requestKind ?? this.requestKind,
    modelId: modelId ?? this.modelId,
    systemInstructionHash: systemInstructionHash ?? this.systemInstructionHash,
    promptHash: promptHash ?? this.promptHash,
    promptText: promptText ?? this.promptText,
    promptFull: promptFull.present ? promptFull.value : this.promptFull,
    requestedAtMs: requestedAtMs ?? this.requestedAtMs,
    respondedAtMs: respondedAtMs.present
        ? respondedAtMs.value
        : this.respondedAtMs,
    latencyMs: latencyMs.present ? latencyMs.value : this.latencyMs,
    httpStatus: httpStatus.present ? httpStatus.value : this.httpStatus,
    success: success ?? this.success,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    promptTokens: promptTokens.present ? promptTokens.value : this.promptTokens,
    responseTokens: responseTokens.present
        ? responseTokens.value
        : this.responseTokens,
    totalTokens: totalTokens.present ? totalTokens.value : this.totalTokens,
    responseText: responseText.present ? responseText.value : this.responseText,
    responseBytes: responseBytes.present
        ? responseBytes.value
        : this.responseBytes,
    attempt: attempt ?? this.attempt,
    fromCache: fromCache ?? this.fromCache,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  AiRequest copyWithCompanion(AiRequestsCompanion data) {
    return AiRequest(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      handId: data.handId.present ? data.handId.value : this.handId,
      requestKind: data.requestKind.present
          ? data.requestKind.value
          : this.requestKind,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      systemInstructionHash: data.systemInstructionHash.present
          ? data.systemInstructionHash.value
          : this.systemInstructionHash,
      promptHash: data.promptHash.present
          ? data.promptHash.value
          : this.promptHash,
      promptText: data.promptText.present
          ? data.promptText.value
          : this.promptText,
      promptFull: data.promptFull.present
          ? data.promptFull.value
          : this.promptFull,
      requestedAtMs: data.requestedAtMs.present
          ? data.requestedAtMs.value
          : this.requestedAtMs,
      respondedAtMs: data.respondedAtMs.present
          ? data.respondedAtMs.value
          : this.respondedAtMs,
      latencyMs: data.latencyMs.present ? data.latencyMs.value : this.latencyMs,
      httpStatus: data.httpStatus.present
          ? data.httpStatus.value
          : this.httpStatus,
      success: data.success.present ? data.success.value : this.success,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      promptTokens: data.promptTokens.present
          ? data.promptTokens.value
          : this.promptTokens,
      responseTokens: data.responseTokens.present
          ? data.responseTokens.value
          : this.responseTokens,
      totalTokens: data.totalTokens.present
          ? data.totalTokens.value
          : this.totalTokens,
      responseText: data.responseText.present
          ? data.responseText.value
          : this.responseText,
      responseBytes: data.responseBytes.present
          ? data.responseBytes.value
          : this.responseBytes,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      fromCache: data.fromCache.present ? data.fromCache.value : this.fromCache,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiRequest(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('handId: $handId, ')
          ..write('requestKind: $requestKind, ')
          ..write('modelId: $modelId, ')
          ..write('systemInstructionHash: $systemInstructionHash, ')
          ..write('promptHash: $promptHash, ')
          ..write('promptText: $promptText, ')
          ..write('promptFull: $promptFull, ')
          ..write('requestedAtMs: $requestedAtMs, ')
          ..write('respondedAtMs: $respondedAtMs, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('httpStatus: $httpStatus, ')
          ..write('success: $success, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('responseTokens: $responseTokens, ')
          ..write('totalTokens: $totalTokens, ')
          ..write('responseText: $responseText, ')
          ..write('responseBytes: $responseBytes, ')
          ..write('attempt: $attempt, ')
          ..write('fromCache: $fromCache, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sessionId,
    handId,
    requestKind,
    modelId,
    systemInstructionHash,
    promptHash,
    promptText,
    $driftBlobEquality.hash(promptFull),
    requestedAtMs,
    respondedAtMs,
    latencyMs,
    httpStatus,
    success,
    errorMessage,
    promptTokens,
    responseTokens,
    totalTokens,
    responseText,
    responseBytes,
    attempt,
    fromCache,
    createdAtMs,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiRequest &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.handId == this.handId &&
          other.requestKind == this.requestKind &&
          other.modelId == this.modelId &&
          other.systemInstructionHash == this.systemInstructionHash &&
          other.promptHash == this.promptHash &&
          other.promptText == this.promptText &&
          $driftBlobEquality.equals(other.promptFull, this.promptFull) &&
          other.requestedAtMs == this.requestedAtMs &&
          other.respondedAtMs == this.respondedAtMs &&
          other.latencyMs == this.latencyMs &&
          other.httpStatus == this.httpStatus &&
          other.success == this.success &&
          other.errorMessage == this.errorMessage &&
          other.promptTokens == this.promptTokens &&
          other.responseTokens == this.responseTokens &&
          other.totalTokens == this.totalTokens &&
          other.responseText == this.responseText &&
          other.responseBytes == this.responseBytes &&
          other.attempt == this.attempt &&
          other.fromCache == this.fromCache &&
          other.createdAtMs == this.createdAtMs);
}

class AiRequestsCompanion extends UpdateCompanion<AiRequest> {
  final Value<int> id;
  final Value<int?> sessionId;
  final Value<int?> handId;
  final Value<String> requestKind;
  final Value<String> modelId;
  final Value<String> systemInstructionHash;
  final Value<String> promptHash;
  final Value<String> promptText;
  final Value<Uint8List?> promptFull;
  final Value<int> requestedAtMs;
  final Value<int?> respondedAtMs;
  final Value<int?> latencyMs;
  final Value<int?> httpStatus;
  final Value<bool> success;
  final Value<String?> errorMessage;
  final Value<int?> promptTokens;
  final Value<int?> responseTokens;
  final Value<int?> totalTokens;
  final Value<String?> responseText;
  final Value<int?> responseBytes;
  final Value<int> attempt;
  final Value<bool> fromCache;
  final Value<int> createdAtMs;
  const AiRequestsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.handId = const Value.absent(),
    this.requestKind = const Value.absent(),
    this.modelId = const Value.absent(),
    this.systemInstructionHash = const Value.absent(),
    this.promptHash = const Value.absent(),
    this.promptText = const Value.absent(),
    this.promptFull = const Value.absent(),
    this.requestedAtMs = const Value.absent(),
    this.respondedAtMs = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.httpStatus = const Value.absent(),
    this.success = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.promptTokens = const Value.absent(),
    this.responseTokens = const Value.absent(),
    this.totalTokens = const Value.absent(),
    this.responseText = const Value.absent(),
    this.responseBytes = const Value.absent(),
    this.attempt = const Value.absent(),
    this.fromCache = const Value.absent(),
    this.createdAtMs = const Value.absent(),
  });
  AiRequestsCompanion.insert({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.handId = const Value.absent(),
    required String requestKind,
    required String modelId,
    this.systemInstructionHash = const Value.absent(),
    required String promptHash,
    required String promptText,
    this.promptFull = const Value.absent(),
    required int requestedAtMs,
    this.respondedAtMs = const Value.absent(),
    this.latencyMs = const Value.absent(),
    this.httpStatus = const Value.absent(),
    required bool success,
    this.errorMessage = const Value.absent(),
    this.promptTokens = const Value.absent(),
    this.responseTokens = const Value.absent(),
    this.totalTokens = const Value.absent(),
    this.responseText = const Value.absent(),
    this.responseBytes = const Value.absent(),
    this.attempt = const Value.absent(),
    this.fromCache = const Value.absent(),
    required int createdAtMs,
  }) : requestKind = Value(requestKind),
       modelId = Value(modelId),
       promptHash = Value(promptHash),
       promptText = Value(promptText),
       requestedAtMs = Value(requestedAtMs),
       success = Value(success),
       createdAtMs = Value(createdAtMs);
  static Insertable<AiRequest> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? handId,
    Expression<String>? requestKind,
    Expression<String>? modelId,
    Expression<String>? systemInstructionHash,
    Expression<String>? promptHash,
    Expression<String>? promptText,
    Expression<Uint8List>? promptFull,
    Expression<int>? requestedAtMs,
    Expression<int>? respondedAtMs,
    Expression<int>? latencyMs,
    Expression<int>? httpStatus,
    Expression<bool>? success,
    Expression<String>? errorMessage,
    Expression<int>? promptTokens,
    Expression<int>? responseTokens,
    Expression<int>? totalTokens,
    Expression<String>? responseText,
    Expression<int>? responseBytes,
    Expression<int>? attempt,
    Expression<bool>? fromCache,
    Expression<int>? createdAtMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (handId != null) 'hand_id': handId,
      if (requestKind != null) 'request_kind': requestKind,
      if (modelId != null) 'model_id': modelId,
      if (systemInstructionHash != null)
        'system_instruction_hash': systemInstructionHash,
      if (promptHash != null) 'prompt_hash': promptHash,
      if (promptText != null) 'prompt_text': promptText,
      if (promptFull != null) 'prompt_full': promptFull,
      if (requestedAtMs != null) 'requested_at_ms': requestedAtMs,
      if (respondedAtMs != null) 'responded_at_ms': respondedAtMs,
      if (latencyMs != null) 'latency_ms': latencyMs,
      if (httpStatus != null) 'http_status': httpStatus,
      if (success != null) 'success': success,
      if (errorMessage != null) 'error_message': errorMessage,
      if (promptTokens != null) 'prompt_tokens': promptTokens,
      if (responseTokens != null) 'response_tokens': responseTokens,
      if (totalTokens != null) 'total_tokens': totalTokens,
      if (responseText != null) 'response_text': responseText,
      if (responseBytes != null) 'response_bytes': responseBytes,
      if (attempt != null) 'attempt': attempt,
      if (fromCache != null) 'from_cache': fromCache,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
    });
  }

  AiRequestsCompanion copyWith({
    Value<int>? id,
    Value<int?>? sessionId,
    Value<int?>? handId,
    Value<String>? requestKind,
    Value<String>? modelId,
    Value<String>? systemInstructionHash,
    Value<String>? promptHash,
    Value<String>? promptText,
    Value<Uint8List?>? promptFull,
    Value<int>? requestedAtMs,
    Value<int?>? respondedAtMs,
    Value<int?>? latencyMs,
    Value<int?>? httpStatus,
    Value<bool>? success,
    Value<String?>? errorMessage,
    Value<int?>? promptTokens,
    Value<int?>? responseTokens,
    Value<int?>? totalTokens,
    Value<String?>? responseText,
    Value<int?>? responseBytes,
    Value<int>? attempt,
    Value<bool>? fromCache,
    Value<int>? createdAtMs,
  }) {
    return AiRequestsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      handId: handId ?? this.handId,
      requestKind: requestKind ?? this.requestKind,
      modelId: modelId ?? this.modelId,
      systemInstructionHash:
          systemInstructionHash ?? this.systemInstructionHash,
      promptHash: promptHash ?? this.promptHash,
      promptText: promptText ?? this.promptText,
      promptFull: promptFull ?? this.promptFull,
      requestedAtMs: requestedAtMs ?? this.requestedAtMs,
      respondedAtMs: respondedAtMs ?? this.respondedAtMs,
      latencyMs: latencyMs ?? this.latencyMs,
      httpStatus: httpStatus ?? this.httpStatus,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
      promptTokens: promptTokens ?? this.promptTokens,
      responseTokens: responseTokens ?? this.responseTokens,
      totalTokens: totalTokens ?? this.totalTokens,
      responseText: responseText ?? this.responseText,
      responseBytes: responseBytes ?? this.responseBytes,
      attempt: attempt ?? this.attempt,
      fromCache: fromCache ?? this.fromCache,
      createdAtMs: createdAtMs ?? this.createdAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (handId.present) {
      map['hand_id'] = Variable<int>(handId.value);
    }
    if (requestKind.present) {
      map['request_kind'] = Variable<String>(requestKind.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (systemInstructionHash.present) {
      map['system_instruction_hash'] = Variable<String>(
        systemInstructionHash.value,
      );
    }
    if (promptHash.present) {
      map['prompt_hash'] = Variable<String>(promptHash.value);
    }
    if (promptText.present) {
      map['prompt_text'] = Variable<String>(promptText.value);
    }
    if (promptFull.present) {
      map['prompt_full'] = Variable<Uint8List>(promptFull.value);
    }
    if (requestedAtMs.present) {
      map['requested_at_ms'] = Variable<int>(requestedAtMs.value);
    }
    if (respondedAtMs.present) {
      map['responded_at_ms'] = Variable<int>(respondedAtMs.value);
    }
    if (latencyMs.present) {
      map['latency_ms'] = Variable<int>(latencyMs.value);
    }
    if (httpStatus.present) {
      map['http_status'] = Variable<int>(httpStatus.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (promptTokens.present) {
      map['prompt_tokens'] = Variable<int>(promptTokens.value);
    }
    if (responseTokens.present) {
      map['response_tokens'] = Variable<int>(responseTokens.value);
    }
    if (totalTokens.present) {
      map['total_tokens'] = Variable<int>(totalTokens.value);
    }
    if (responseText.present) {
      map['response_text'] = Variable<String>(responseText.value);
    }
    if (responseBytes.present) {
      map['response_bytes'] = Variable<int>(responseBytes.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (fromCache.present) {
      map['from_cache'] = Variable<bool>(fromCache.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiRequestsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('handId: $handId, ')
          ..write('requestKind: $requestKind, ')
          ..write('modelId: $modelId, ')
          ..write('systemInstructionHash: $systemInstructionHash, ')
          ..write('promptHash: $promptHash, ')
          ..write('promptText: $promptText, ')
          ..write('promptFull: $promptFull, ')
          ..write('requestedAtMs: $requestedAtMs, ')
          ..write('respondedAtMs: $respondedAtMs, ')
          ..write('latencyMs: $latencyMs, ')
          ..write('httpStatus: $httpStatus, ')
          ..write('success: $success, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('promptTokens: $promptTokens, ')
          ..write('responseTokens: $responseTokens, ')
          ..write('totalTokens: $totalTokens, ')
          ..write('responseText: $responseText, ')
          ..write('responseBytes: $responseBytes, ')
          ..write('attempt: $attempt, ')
          ..write('fromCache: $fromCache, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }
}

class $VoiceClipsTable extends VoiceClips
    with TableInfo<$VoiceClipsTable, VoiceClip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceClipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _spokenTextMeta = const VerificationMeta(
    'spokenText',
  );
  @override
  late final GeneratedColumn<String> spokenText = GeneratedColumn<String>(
    'spoken_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voiceMeta = const VerificationMeta('voice');
  @override
  late final GeneratedColumn<String> voice = GeneratedColumn<String>(
    'voice',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('audio/wav'),
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioBlobMeta = const VerificationMeta(
    'audioBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> audioBlob = GeneratedColumn<Uint8List>(
    'audio_blob',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMsMeta = const VerificationMeta(
    'lastAccessedAtMs',
  );
  @override
  late final GeneratedColumn<int> lastAccessedAtMs = GeneratedColumn<int>(
    'last_accessed_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hitCountMeta = const VerificationMeta(
    'hitCount',
  );
  @override
  late final GeneratedColumn<int> hitCount = GeneratedColumn<int>(
    'hit_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _expiresAtMsMeta = const VerificationMeta(
    'expiresAtMs',
  );
  @override
  late final GeneratedColumn<int> expiresAtMs = GeneratedColumn<int>(
    'expires_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evictedAtMsMeta = const VerificationMeta(
    'evictedAtMs',
  );
  @override
  late final GeneratedColumn<int> evictedAtMs = GeneratedColumn<int>(
    'evicted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _evictionReasonMeta = const VerificationMeta(
    'evictionReason',
  );
  @override
  late final GeneratedColumn<String> evictionReason = GeneratedColumn<String>(
    'eviction_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cacheKey,
    spokenText,
    voice,
    modelId,
    mimeType,
    byteSize,
    filePath,
    audioBlob,
    createdAtMs,
    lastAccessedAtMs,
    hitCount,
    expiresAtMs,
    evictedAtMs,
    evictionReason,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_clips';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoiceClip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('spoken_text')) {
      context.handle(
        _spokenTextMeta,
        spokenText.isAcceptableOrUnknown(data['spoken_text']!, _spokenTextMeta),
      );
    } else if (isInserting) {
      context.missing(_spokenTextMeta);
    }
    if (data.containsKey('voice')) {
      context.handle(
        _voiceMeta,
        voice.isAcceptableOrUnknown(data['voice']!, _voiceMeta),
      );
    } else if (isInserting) {
      context.missing(_voiceMeta);
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_byteSizeMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('audio_blob')) {
      context.handle(
        _audioBlobMeta,
        audioBlob.isAcceptableOrUnknown(data['audio_blob']!, _audioBlobMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('last_accessed_at_ms')) {
      context.handle(
        _lastAccessedAtMsMeta,
        lastAccessedAtMs.isAcceptableOrUnknown(
          data['last_accessed_at_ms']!,
          _lastAccessedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMsMeta);
    }
    if (data.containsKey('hit_count')) {
      context.handle(
        _hitCountMeta,
        hitCount.isAcceptableOrUnknown(data['hit_count']!, _hitCountMeta),
      );
    }
    if (data.containsKey('expires_at_ms')) {
      context.handle(
        _expiresAtMsMeta,
        expiresAtMs.isAcceptableOrUnknown(
          data['expires_at_ms']!,
          _expiresAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMsMeta);
    }
    if (data.containsKey('evicted_at_ms')) {
      context.handle(
        _evictedAtMsMeta,
        evictedAtMs.isAcceptableOrUnknown(
          data['evicted_at_ms']!,
          _evictedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('eviction_reason')) {
      context.handle(
        _evictionReasonMeta,
        evictionReason.isAcceptableOrUnknown(
          data['eviction_reason']!,
          _evictionReasonMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoiceClip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceClip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      spokenText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spoken_text'],
      )!,
      voice: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      audioBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}audio_blob'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      lastAccessedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_accessed_at_ms'],
      )!,
      hitCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hit_count'],
      )!,
      expiresAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expires_at_ms'],
      )!,
      evictedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}evicted_at_ms'],
      ),
      evictionReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}eviction_reason'],
      ),
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $VoiceClipsTable createAlias(String alias) {
    return $VoiceClipsTable(attachedDatabase, alias);
  }
}

class VoiceClip extends DataClass implements Insertable<VoiceClip> {
  final int id;

  /// `VoiceCache.keyFor(text, voice, model)`.
  final String cacheKey;
  final String spokenText;
  final String voice;
  final String modelId;
  final String mimeType;
  final int byteSize;
  final String? filePath;
  final Uint8List? audioBlob;
  final int createdAtMs;
  final int lastAccessedAtMs;
  final int hitCount;
  final int expiresAtMs;
  final int? evictedAtMs;

  /// `ttl`, `lru`, `clear`, `missing`.
  final String? evictionReason;
  final int updatedAtMs;
  const VoiceClip({
    required this.id,
    required this.cacheKey,
    required this.spokenText,
    required this.voice,
    required this.modelId,
    required this.mimeType,
    required this.byteSize,
    this.filePath,
    this.audioBlob,
    required this.createdAtMs,
    required this.lastAccessedAtMs,
    required this.hitCount,
    required this.expiresAtMs,
    this.evictedAtMs,
    this.evictionReason,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cache_key'] = Variable<String>(cacheKey);
    map['spoken_text'] = Variable<String>(spokenText);
    map['voice'] = Variable<String>(voice);
    map['model_id'] = Variable<String>(modelId);
    map['mime_type'] = Variable<String>(mimeType);
    map['byte_size'] = Variable<int>(byteSize);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || audioBlob != null) {
      map['audio_blob'] = Variable<Uint8List>(audioBlob);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['last_accessed_at_ms'] = Variable<int>(lastAccessedAtMs);
    map['hit_count'] = Variable<int>(hitCount);
    map['expires_at_ms'] = Variable<int>(expiresAtMs);
    if (!nullToAbsent || evictedAtMs != null) {
      map['evicted_at_ms'] = Variable<int>(evictedAtMs);
    }
    if (!nullToAbsent || evictionReason != null) {
      map['eviction_reason'] = Variable<String>(evictionReason);
    }
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  VoiceClipsCompanion toCompanion(bool nullToAbsent) {
    return VoiceClipsCompanion(
      id: Value(id),
      cacheKey: Value(cacheKey),
      spokenText: Value(spokenText),
      voice: Value(voice),
      modelId: Value(modelId),
      mimeType: Value(mimeType),
      byteSize: Value(byteSize),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      audioBlob: audioBlob == null && nullToAbsent
          ? const Value.absent()
          : Value(audioBlob),
      createdAtMs: Value(createdAtMs),
      lastAccessedAtMs: Value(lastAccessedAtMs),
      hitCount: Value(hitCount),
      expiresAtMs: Value(expiresAtMs),
      evictedAtMs: evictedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(evictedAtMs),
      evictionReason: evictionReason == null && nullToAbsent
          ? const Value.absent()
          : Value(evictionReason),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory VoiceClip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceClip(
      id: serializer.fromJson<int>(json['id']),
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      spokenText: serializer.fromJson<String>(json['spokenText']),
      voice: serializer.fromJson<String>(json['voice']),
      modelId: serializer.fromJson<String>(json['modelId']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      byteSize: serializer.fromJson<int>(json['byteSize']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      audioBlob: serializer.fromJson<Uint8List?>(json['audioBlob']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      lastAccessedAtMs: serializer.fromJson<int>(json['lastAccessedAtMs']),
      hitCount: serializer.fromJson<int>(json['hitCount']),
      expiresAtMs: serializer.fromJson<int>(json['expiresAtMs']),
      evictedAtMs: serializer.fromJson<int?>(json['evictedAtMs']),
      evictionReason: serializer.fromJson<String?>(json['evictionReason']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cacheKey': serializer.toJson<String>(cacheKey),
      'spokenText': serializer.toJson<String>(spokenText),
      'voice': serializer.toJson<String>(voice),
      'modelId': serializer.toJson<String>(modelId),
      'mimeType': serializer.toJson<String>(mimeType),
      'byteSize': serializer.toJson<int>(byteSize),
      'filePath': serializer.toJson<String?>(filePath),
      'audioBlob': serializer.toJson<Uint8List?>(audioBlob),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'lastAccessedAtMs': serializer.toJson<int>(lastAccessedAtMs),
      'hitCount': serializer.toJson<int>(hitCount),
      'expiresAtMs': serializer.toJson<int>(expiresAtMs),
      'evictedAtMs': serializer.toJson<int?>(evictedAtMs),
      'evictionReason': serializer.toJson<String?>(evictionReason),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  VoiceClip copyWith({
    int? id,
    String? cacheKey,
    String? spokenText,
    String? voice,
    String? modelId,
    String? mimeType,
    int? byteSize,
    Value<String?> filePath = const Value.absent(),
    Value<Uint8List?> audioBlob = const Value.absent(),
    int? createdAtMs,
    int? lastAccessedAtMs,
    int? hitCount,
    int? expiresAtMs,
    Value<int?> evictedAtMs = const Value.absent(),
    Value<String?> evictionReason = const Value.absent(),
    int? updatedAtMs,
  }) => VoiceClip(
    id: id ?? this.id,
    cacheKey: cacheKey ?? this.cacheKey,
    spokenText: spokenText ?? this.spokenText,
    voice: voice ?? this.voice,
    modelId: modelId ?? this.modelId,
    mimeType: mimeType ?? this.mimeType,
    byteSize: byteSize ?? this.byteSize,
    filePath: filePath.present ? filePath.value : this.filePath,
    audioBlob: audioBlob.present ? audioBlob.value : this.audioBlob,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    lastAccessedAtMs: lastAccessedAtMs ?? this.lastAccessedAtMs,
    hitCount: hitCount ?? this.hitCount,
    expiresAtMs: expiresAtMs ?? this.expiresAtMs,
    evictedAtMs: evictedAtMs.present ? evictedAtMs.value : this.evictedAtMs,
    evictionReason: evictionReason.present
        ? evictionReason.value
        : this.evictionReason,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  VoiceClip copyWithCompanion(VoiceClipsCompanion data) {
    return VoiceClip(
      id: data.id.present ? data.id.value : this.id,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      spokenText: data.spokenText.present
          ? data.spokenText.value
          : this.spokenText,
      voice: data.voice.present ? data.voice.value : this.voice,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      audioBlob: data.audioBlob.present ? data.audioBlob.value : this.audioBlob,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      lastAccessedAtMs: data.lastAccessedAtMs.present
          ? data.lastAccessedAtMs.value
          : this.lastAccessedAtMs,
      hitCount: data.hitCount.present ? data.hitCount.value : this.hitCount,
      expiresAtMs: data.expiresAtMs.present
          ? data.expiresAtMs.value
          : this.expiresAtMs,
      evictedAtMs: data.evictedAtMs.present
          ? data.evictedAtMs.value
          : this.evictedAtMs,
      evictionReason: data.evictionReason.present
          ? data.evictionReason.value
          : this.evictionReason,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoiceClip(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('spokenText: $spokenText, ')
          ..write('voice: $voice, ')
          ..write('modelId: $modelId, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('filePath: $filePath, ')
          ..write('audioBlob: $audioBlob, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('lastAccessedAtMs: $lastAccessedAtMs, ')
          ..write('hitCount: $hitCount, ')
          ..write('expiresAtMs: $expiresAtMs, ')
          ..write('evictedAtMs: $evictedAtMs, ')
          ..write('evictionReason: $evictionReason, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    cacheKey,
    spokenText,
    voice,
    modelId,
    mimeType,
    byteSize,
    filePath,
    $driftBlobEquality.hash(audioBlob),
    createdAtMs,
    lastAccessedAtMs,
    hitCount,
    expiresAtMs,
    evictedAtMs,
    evictionReason,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceClip &&
          other.id == this.id &&
          other.cacheKey == this.cacheKey &&
          other.spokenText == this.spokenText &&
          other.voice == this.voice &&
          other.modelId == this.modelId &&
          other.mimeType == this.mimeType &&
          other.byteSize == this.byteSize &&
          other.filePath == this.filePath &&
          $driftBlobEquality.equals(other.audioBlob, this.audioBlob) &&
          other.createdAtMs == this.createdAtMs &&
          other.lastAccessedAtMs == this.lastAccessedAtMs &&
          other.hitCount == this.hitCount &&
          other.expiresAtMs == this.expiresAtMs &&
          other.evictedAtMs == this.evictedAtMs &&
          other.evictionReason == this.evictionReason &&
          other.updatedAtMs == this.updatedAtMs);
}

class VoiceClipsCompanion extends UpdateCompanion<VoiceClip> {
  final Value<int> id;
  final Value<String> cacheKey;
  final Value<String> spokenText;
  final Value<String> voice;
  final Value<String> modelId;
  final Value<String> mimeType;
  final Value<int> byteSize;
  final Value<String?> filePath;
  final Value<Uint8List?> audioBlob;
  final Value<int> createdAtMs;
  final Value<int> lastAccessedAtMs;
  final Value<int> hitCount;
  final Value<int> expiresAtMs;
  final Value<int?> evictedAtMs;
  final Value<String?> evictionReason;
  final Value<int> updatedAtMs;
  const VoiceClipsCompanion({
    this.id = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.spokenText = const Value.absent(),
    this.voice = const Value.absent(),
    this.modelId = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.filePath = const Value.absent(),
    this.audioBlob = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.lastAccessedAtMs = const Value.absent(),
    this.hitCount = const Value.absent(),
    this.expiresAtMs = const Value.absent(),
    this.evictedAtMs = const Value.absent(),
    this.evictionReason = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
  });
  VoiceClipsCompanion.insert({
    this.id = const Value.absent(),
    required String cacheKey,
    required String spokenText,
    required String voice,
    required String modelId,
    this.mimeType = const Value.absent(),
    required int byteSize,
    this.filePath = const Value.absent(),
    this.audioBlob = const Value.absent(),
    required int createdAtMs,
    required int lastAccessedAtMs,
    this.hitCount = const Value.absent(),
    required int expiresAtMs,
    this.evictedAtMs = const Value.absent(),
    this.evictionReason = const Value.absent(),
    required int updatedAtMs,
  }) : cacheKey = Value(cacheKey),
       spokenText = Value(spokenText),
       voice = Value(voice),
       modelId = Value(modelId),
       byteSize = Value(byteSize),
       createdAtMs = Value(createdAtMs),
       lastAccessedAtMs = Value(lastAccessedAtMs),
       expiresAtMs = Value(expiresAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<VoiceClip> custom({
    Expression<int>? id,
    Expression<String>? cacheKey,
    Expression<String>? spokenText,
    Expression<String>? voice,
    Expression<String>? modelId,
    Expression<String>? mimeType,
    Expression<int>? byteSize,
    Expression<String>? filePath,
    Expression<Uint8List>? audioBlob,
    Expression<int>? createdAtMs,
    Expression<int>? lastAccessedAtMs,
    Expression<int>? hitCount,
    Expression<int>? expiresAtMs,
    Expression<int>? evictedAtMs,
    Expression<String>? evictionReason,
    Expression<int>? updatedAtMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cacheKey != null) 'cache_key': cacheKey,
      if (spokenText != null) 'spoken_text': spokenText,
      if (voice != null) 'voice': voice,
      if (modelId != null) 'model_id': modelId,
      if (mimeType != null) 'mime_type': mimeType,
      if (byteSize != null) 'byte_size': byteSize,
      if (filePath != null) 'file_path': filePath,
      if (audioBlob != null) 'audio_blob': audioBlob,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (lastAccessedAtMs != null) 'last_accessed_at_ms': lastAccessedAtMs,
      if (hitCount != null) 'hit_count': hitCount,
      if (expiresAtMs != null) 'expires_at_ms': expiresAtMs,
      if (evictedAtMs != null) 'evicted_at_ms': evictedAtMs,
      if (evictionReason != null) 'eviction_reason': evictionReason,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
    });
  }

  VoiceClipsCompanion copyWith({
    Value<int>? id,
    Value<String>? cacheKey,
    Value<String>? spokenText,
    Value<String>? voice,
    Value<String>? modelId,
    Value<String>? mimeType,
    Value<int>? byteSize,
    Value<String?>? filePath,
    Value<Uint8List?>? audioBlob,
    Value<int>? createdAtMs,
    Value<int>? lastAccessedAtMs,
    Value<int>? hitCount,
    Value<int>? expiresAtMs,
    Value<int?>? evictedAtMs,
    Value<String?>? evictionReason,
    Value<int>? updatedAtMs,
  }) {
    return VoiceClipsCompanion(
      id: id ?? this.id,
      cacheKey: cacheKey ?? this.cacheKey,
      spokenText: spokenText ?? this.spokenText,
      voice: voice ?? this.voice,
      modelId: modelId ?? this.modelId,
      mimeType: mimeType ?? this.mimeType,
      byteSize: byteSize ?? this.byteSize,
      filePath: filePath ?? this.filePath,
      audioBlob: audioBlob ?? this.audioBlob,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      lastAccessedAtMs: lastAccessedAtMs ?? this.lastAccessedAtMs,
      hitCount: hitCount ?? this.hitCount,
      expiresAtMs: expiresAtMs ?? this.expiresAtMs,
      evictedAtMs: evictedAtMs ?? this.evictedAtMs,
      evictionReason: evictionReason ?? this.evictionReason,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (spokenText.present) {
      map['spoken_text'] = Variable<String>(spokenText.value);
    }
    if (voice.present) {
      map['voice'] = Variable<String>(voice.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (audioBlob.present) {
      map['audio_blob'] = Variable<Uint8List>(audioBlob.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (lastAccessedAtMs.present) {
      map['last_accessed_at_ms'] = Variable<int>(lastAccessedAtMs.value);
    }
    if (hitCount.present) {
      map['hit_count'] = Variable<int>(hitCount.value);
    }
    if (expiresAtMs.present) {
      map['expires_at_ms'] = Variable<int>(expiresAtMs.value);
    }
    if (evictedAtMs.present) {
      map['evicted_at_ms'] = Variable<int>(evictedAtMs.value);
    }
    if (evictionReason.present) {
      map['eviction_reason'] = Variable<String>(evictionReason.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VoiceClipsCompanion(')
          ..write('id: $id, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('spokenText: $spokenText, ')
          ..write('voice: $voice, ')
          ..write('modelId: $modelId, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteSize: $byteSize, ')
          ..write('filePath: $filePath, ')
          ..write('audioBlob: $audioBlob, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('lastAccessedAtMs: $lastAccessedAtMs, ')
          ..write('hitCount: $hitCount, ')
          ..write('expiresAtMs: $expiresAtMs, ')
          ..write('evictedAtMs: $evictedAtMs, ')
          ..write('evictionReason: $evictionReason, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }
}

class $HandsTable extends Hands with TableInfo<$HandsTable, Hand> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HandsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _handNumberMeta = const VerificationMeta(
    'handNumber',
  );
  @override
  late final GeneratedColumn<int> handNumber = GeneratedColumn<int>(
    'hand_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMsMeta = const VerificationMeta(
    'startedAtMs',
  );
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
    'started_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMsMeta = const VerificationMeta(
    'endedAtMs',
  );
  @override
  late final GeneratedColumn<int> endedAtMs = GeneratedColumn<int>(
    'ended_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settingsJsonMeta = const VerificationMeta(
    'settingsJson',
  );
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
    'settings_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seatCountMeta = const VerificationMeta(
    'seatCount',
  );
  @override
  late final GeneratedColumn<int> seatCount = GeneratedColumn<int>(
    'seat_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _smallBlindMeta = const VerificationMeta(
    'smallBlind',
  );
  @override
  late final GeneratedColumn<double> smallBlind = GeneratedColumn<double>(
    'small_blind',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bigBlindMeta = const VerificationMeta(
    'bigBlind',
  );
  @override
  late final GeneratedColumn<double> bigBlind = GeneratedColumn<double>(
    'big_blind',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stackDepthBbMeta = const VerificationMeta(
    'stackDepthBb',
  );
  @override
  late final GeneratedColumn<int> stackDepthBb = GeneratedColumn<int>(
    'stack_depth_bb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dealerSeatMeta = const VerificationMeta(
    'dealerSeat',
  );
  @override
  late final GeneratedColumn<int> dealerSeat = GeneratedColumn<int>(
    'dealer_seat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sbSeatMeta = const VerificationMeta('sbSeat');
  @override
  late final GeneratedColumn<int> sbSeat = GeneratedColumn<int>(
    'sb_seat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bbSeatMeta = const VerificationMeta('bbSeat');
  @override
  late final GeneratedColumn<int> bbSeat = GeneratedColumn<int>(
    'bb_seat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heroSeatMeta = const VerificationMeta(
    'heroSeat',
  );
  @override
  late final GeneratedColumn<int> heroSeat = GeneratedColumn<int>(
    'hero_seat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lineupJsonMeta = const VerificationMeta(
    'lineupJson',
  );
  @override
  late final GeneratedColumn<String> lineupJson = GeneratedColumn<String>(
    'lineup_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heroCardsMeta = const VerificationMeta(
    'heroCards',
  );
  @override
  late final GeneratedColumn<String> heroCards = GeneratedColumn<String>(
    'hero_cards',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _boardFlopMeta = const VerificationMeta(
    'boardFlop',
  );
  @override
  late final GeneratedColumn<String> boardFlop = GeneratedColumn<String>(
    'board_flop',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _boardTurnMeta = const VerificationMeta(
    'boardTurn',
  );
  @override
  late final GeneratedColumn<String> boardTurn = GeneratedColumn<String>(
    'board_turn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _boardRiverMeta = const VerificationMeta(
    'boardRiver',
  );
  @override
  late final GeneratedColumn<String> boardRiver = GeneratedColumn<String>(
    'board_river',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _finalStreetMeta = const VerificationMeta(
    'finalStreet',
  );
  @override
  late final GeneratedColumn<String> finalStreet = GeneratedColumn<String>(
    'final_street',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wentToShowdownMeta = const VerificationMeta(
    'wentToShowdown',
  );
  @override
  late final GeneratedColumn<bool> wentToShowdown = GeneratedColumn<bool>(
    'went_to_showdown',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("went_to_showdown" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _resultMessageMeta = const VerificationMeta(
    'resultMessage',
  );
  @override
  late final GeneratedColumn<String> resultMessage = GeneratedColumn<String>(
    'result_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _winnerSeatsJsonMeta = const VerificationMeta(
    'winnerSeatsJson',
  );
  @override
  late final GeneratedColumn<String> winnerSeatsJson = GeneratedColumn<String>(
    'winner_seats_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _finalPotMeta = const VerificationMeta(
    'finalPot',
  );
  @override
  late final GeneratedColumn<double> finalPot = GeneratedColumn<double>(
    'final_pot',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _heroNetDollarsMeta = const VerificationMeta(
    'heroNetDollars',
  );
  @override
  late final GeneratedColumn<double> heroNetDollars = GeneratedColumn<double>(
    'hero_net_dollars',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _heroNetBbMeta = const VerificationMeta(
    'heroNetBb',
  );
  @override
  late final GeneratedColumn<double> heroNetBb = GeneratedColumn<double>(
    'hero_net_bb',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _heroEvDeltaDollarsMeta =
      const VerificationMeta('heroEvDeltaDollars');
  @override
  late final GeneratedColumn<double> heroEvDeltaDollars =
      GeneratedColumn<double>(
        'hero_ev_delta_dollars',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _heroEvDeltaBbMeta = const VerificationMeta(
    'heroEvDeltaBb',
  );
  @override
  late final GeneratedColumn<double> heroEvDeltaBb = GeneratedColumn<double>(
    'hero_ev_delta_bb',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rebuyEventsJsonMeta = const VerificationMeta(
    'rebuyEventsJson',
  );
  @override
  late final GeneratedColumn<String> rebuyEventsJson = GeneratedColumn<String>(
    'rebuy_events_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _payloadVersionMeta = const VerificationMeta(
    'payloadVersion',
  );
  @override
  late final GeneratedColumn<int> payloadVersion = GeneratedColumn<int>(
    'payload_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    handNumber,
    startedAtMs,
    endedAtMs,
    settingsJson,
    seatCount,
    smallBlind,
    bigBlind,
    stackDepthBb,
    dealerSeat,
    sbSeat,
    bbSeat,
    heroSeat,
    lineupJson,
    heroCards,
    boardFlop,
    boardTurn,
    boardRiver,
    finalStreet,
    wentToShowdown,
    resultMessage,
    winnerSeatsJson,
    finalPot,
    heroNetDollars,
    heroNetBb,
    heroEvDeltaDollars,
    heroEvDeltaBb,
    rebuyEventsJson,
    payloadVersion,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hands';
  @override
  VerificationContext validateIntegrity(
    Insertable<Hand> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('hand_number')) {
      context.handle(
        _handNumberMeta,
        handNumber.isAcceptableOrUnknown(data['hand_number']!, _handNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_handNumberMeta);
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
        _startedAtMsMeta,
        startedAtMs.isAcceptableOrUnknown(
          data['started_at_ms']!,
          _startedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('ended_at_ms')) {
      context.handle(
        _endedAtMsMeta,
        endedAtMs.isAcceptableOrUnknown(data['ended_at_ms']!, _endedAtMsMeta),
      );
    }
    if (data.containsKey('settings_json')) {
      context.handle(
        _settingsJsonMeta,
        settingsJson.isAcceptableOrUnknown(
          data['settings_json']!,
          _settingsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingsJsonMeta);
    }
    if (data.containsKey('seat_count')) {
      context.handle(
        _seatCountMeta,
        seatCount.isAcceptableOrUnknown(data['seat_count']!, _seatCountMeta),
      );
    } else if (isInserting) {
      context.missing(_seatCountMeta);
    }
    if (data.containsKey('small_blind')) {
      context.handle(
        _smallBlindMeta,
        smallBlind.isAcceptableOrUnknown(data['small_blind']!, _smallBlindMeta),
      );
    } else if (isInserting) {
      context.missing(_smallBlindMeta);
    }
    if (data.containsKey('big_blind')) {
      context.handle(
        _bigBlindMeta,
        bigBlind.isAcceptableOrUnknown(data['big_blind']!, _bigBlindMeta),
      );
    } else if (isInserting) {
      context.missing(_bigBlindMeta);
    }
    if (data.containsKey('stack_depth_bb')) {
      context.handle(
        _stackDepthBbMeta,
        stackDepthBb.isAcceptableOrUnknown(
          data['stack_depth_bb']!,
          _stackDepthBbMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stackDepthBbMeta);
    }
    if (data.containsKey('dealer_seat')) {
      context.handle(
        _dealerSeatMeta,
        dealerSeat.isAcceptableOrUnknown(data['dealer_seat']!, _dealerSeatMeta),
      );
    } else if (isInserting) {
      context.missing(_dealerSeatMeta);
    }
    if (data.containsKey('sb_seat')) {
      context.handle(
        _sbSeatMeta,
        sbSeat.isAcceptableOrUnknown(data['sb_seat']!, _sbSeatMeta),
      );
    } else if (isInserting) {
      context.missing(_sbSeatMeta);
    }
    if (data.containsKey('bb_seat')) {
      context.handle(
        _bbSeatMeta,
        bbSeat.isAcceptableOrUnknown(data['bb_seat']!, _bbSeatMeta),
      );
    } else if (isInserting) {
      context.missing(_bbSeatMeta);
    }
    if (data.containsKey('hero_seat')) {
      context.handle(
        _heroSeatMeta,
        heroSeat.isAcceptableOrUnknown(data['hero_seat']!, _heroSeatMeta),
      );
    } else if (isInserting) {
      context.missing(_heroSeatMeta);
    }
    if (data.containsKey('lineup_json')) {
      context.handle(
        _lineupJsonMeta,
        lineupJson.isAcceptableOrUnknown(data['lineup_json']!, _lineupJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_lineupJsonMeta);
    }
    if (data.containsKey('hero_cards')) {
      context.handle(
        _heroCardsMeta,
        heroCards.isAcceptableOrUnknown(data['hero_cards']!, _heroCardsMeta),
      );
    }
    if (data.containsKey('board_flop')) {
      context.handle(
        _boardFlopMeta,
        boardFlop.isAcceptableOrUnknown(data['board_flop']!, _boardFlopMeta),
      );
    }
    if (data.containsKey('board_turn')) {
      context.handle(
        _boardTurnMeta,
        boardTurn.isAcceptableOrUnknown(data['board_turn']!, _boardTurnMeta),
      );
    }
    if (data.containsKey('board_river')) {
      context.handle(
        _boardRiverMeta,
        boardRiver.isAcceptableOrUnknown(data['board_river']!, _boardRiverMeta),
      );
    }
    if (data.containsKey('final_street')) {
      context.handle(
        _finalStreetMeta,
        finalStreet.isAcceptableOrUnknown(
          data['final_street']!,
          _finalStreetMeta,
        ),
      );
    }
    if (data.containsKey('went_to_showdown')) {
      context.handle(
        _wentToShowdownMeta,
        wentToShowdown.isAcceptableOrUnknown(
          data['went_to_showdown']!,
          _wentToShowdownMeta,
        ),
      );
    }
    if (data.containsKey('result_message')) {
      context.handle(
        _resultMessageMeta,
        resultMessage.isAcceptableOrUnknown(
          data['result_message']!,
          _resultMessageMeta,
        ),
      );
    }
    if (data.containsKey('winner_seats_json')) {
      context.handle(
        _winnerSeatsJsonMeta,
        winnerSeatsJson.isAcceptableOrUnknown(
          data['winner_seats_json']!,
          _winnerSeatsJsonMeta,
        ),
      );
    }
    if (data.containsKey('final_pot')) {
      context.handle(
        _finalPotMeta,
        finalPot.isAcceptableOrUnknown(data['final_pot']!, _finalPotMeta),
      );
    }
    if (data.containsKey('hero_net_dollars')) {
      context.handle(
        _heroNetDollarsMeta,
        heroNetDollars.isAcceptableOrUnknown(
          data['hero_net_dollars']!,
          _heroNetDollarsMeta,
        ),
      );
    }
    if (data.containsKey('hero_net_bb')) {
      context.handle(
        _heroNetBbMeta,
        heroNetBb.isAcceptableOrUnknown(data['hero_net_bb']!, _heroNetBbMeta),
      );
    }
    if (data.containsKey('hero_ev_delta_dollars')) {
      context.handle(
        _heroEvDeltaDollarsMeta,
        heroEvDeltaDollars.isAcceptableOrUnknown(
          data['hero_ev_delta_dollars']!,
          _heroEvDeltaDollarsMeta,
        ),
      );
    }
    if (data.containsKey('hero_ev_delta_bb')) {
      context.handle(
        _heroEvDeltaBbMeta,
        heroEvDeltaBb.isAcceptableOrUnknown(
          data['hero_ev_delta_bb']!,
          _heroEvDeltaBbMeta,
        ),
      );
    }
    if (data.containsKey('rebuy_events_json')) {
      context.handle(
        _rebuyEventsJsonMeta,
        rebuyEventsJson.isAcceptableOrUnknown(
          data['rebuy_events_json']!,
          _rebuyEventsJsonMeta,
        ),
      );
    }
    if (data.containsKey('payload_version')) {
      context.handle(
        _payloadVersionMeta,
        payloadVersion.isAcceptableOrUnknown(
          data['payload_version']!,
          _payloadVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Hand map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Hand(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      handNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hand_number'],
      )!,
      startedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_ms'],
      )!,
      endedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at_ms'],
      ),
      settingsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_json'],
      )!,
      seatCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seat_count'],
      )!,
      smallBlind: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}small_blind'],
      )!,
      bigBlind: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}big_blind'],
      )!,
      stackDepthBb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stack_depth_bb'],
      )!,
      dealerSeat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dealer_seat'],
      )!,
      sbSeat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sb_seat'],
      )!,
      bbSeat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bb_seat'],
      )!,
      heroSeat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hero_seat'],
      )!,
      lineupJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lineup_json'],
      )!,
      heroCards: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_cards'],
      )!,
      boardFlop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_flop'],
      )!,
      boardTurn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_turn'],
      )!,
      boardRiver: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board_river'],
      )!,
      finalStreet: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}final_street'],
      ),
      wentToShowdown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}went_to_showdown'],
      )!,
      resultMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_message'],
      ),
      winnerSeatsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winner_seats_json'],
      )!,
      finalPot: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}final_pot'],
      )!,
      heroNetDollars: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hero_net_dollars'],
      )!,
      heroNetBb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hero_net_bb'],
      )!,
      heroEvDeltaDollars: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hero_ev_delta_dollars'],
      )!,
      heroEvDeltaBb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hero_ev_delta_bb'],
      )!,
      rebuyEventsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rebuy_events_json'],
      )!,
      payloadVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payload_version'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $HandsTable createAlias(String alias) {
    return $HandsTable(attachedDatabase, alias);
  }
}

class Hand extends DataClass implements Insertable<Hand> {
  final int id;
  final int? sessionId;

  /// Engine hand counter within the table session.
  final int handNumber;
  final int startedAtMs;
  final int? endedAtMs;

  /// `GameSettingsModel.toPrefsMap()` at deal time.
  final String settingsJson;
  final int seatCount;
  final double smallBlind;
  final double bigBlind;
  final int stackDepthBb;
  final int dealerSeat;
  final int sbSeat;
  final int bbSeat;
  final int heroSeat;

  /// Per seat: id, name, archetype, starting stack.
  final String lineupJson;

  /// Hero hole cards as space-separated codes (`As Kd`).
  final String heroCards;
  final String boardFlop;
  final String boardTurn;
  final String boardRiver;

  /// Street the hand ended on (`PREFLOP` … `SHOWDOWN`).
  final String? finalStreet;
  final bool wentToShowdown;
  final String? resultMessage;

  /// Seats that were awarded chips.
  final String winnerSeatsJson;
  final double finalPot;

  /// Hero stack change over the hand, in dollars and big blinds.
  final double heroNetDollars;
  final double heroNetBb;

  /// Sum of coach EV deltas for the hand.
  final double heroEvDeltaDollars;
  final double heroEvDeltaBb;

  /// Auto-rebuy top-ups applied before this deal: seat, from, to.
  final String rebuyEventsJson;

  /// `HandRecorder.payloadVersion`, so readers can evolve the JSON columns.
  final int payloadVersion;
  final int createdAtMs;
  final int updatedAtMs;
  const Hand({
    required this.id,
    this.sessionId,
    required this.handNumber,
    required this.startedAtMs,
    this.endedAtMs,
    required this.settingsJson,
    required this.seatCount,
    required this.smallBlind,
    required this.bigBlind,
    required this.stackDepthBb,
    required this.dealerSeat,
    required this.sbSeat,
    required this.bbSeat,
    required this.heroSeat,
    required this.lineupJson,
    required this.heroCards,
    required this.boardFlop,
    required this.boardTurn,
    required this.boardRiver,
    this.finalStreet,
    required this.wentToShowdown,
    this.resultMessage,
    required this.winnerSeatsJson,
    required this.finalPot,
    required this.heroNetDollars,
    required this.heroNetBb,
    required this.heroEvDeltaDollars,
    required this.heroEvDeltaBb,
    required this.rebuyEventsJson,
    required this.payloadVersion,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['hand_number'] = Variable<int>(handNumber);
    map['started_at_ms'] = Variable<int>(startedAtMs);
    if (!nullToAbsent || endedAtMs != null) {
      map['ended_at_ms'] = Variable<int>(endedAtMs);
    }
    map['settings_json'] = Variable<String>(settingsJson);
    map['seat_count'] = Variable<int>(seatCount);
    map['small_blind'] = Variable<double>(smallBlind);
    map['big_blind'] = Variable<double>(bigBlind);
    map['stack_depth_bb'] = Variable<int>(stackDepthBb);
    map['dealer_seat'] = Variable<int>(dealerSeat);
    map['sb_seat'] = Variable<int>(sbSeat);
    map['bb_seat'] = Variable<int>(bbSeat);
    map['hero_seat'] = Variable<int>(heroSeat);
    map['lineup_json'] = Variable<String>(lineupJson);
    map['hero_cards'] = Variable<String>(heroCards);
    map['board_flop'] = Variable<String>(boardFlop);
    map['board_turn'] = Variable<String>(boardTurn);
    map['board_river'] = Variable<String>(boardRiver);
    if (!nullToAbsent || finalStreet != null) {
      map['final_street'] = Variable<String>(finalStreet);
    }
    map['went_to_showdown'] = Variable<bool>(wentToShowdown);
    if (!nullToAbsent || resultMessage != null) {
      map['result_message'] = Variable<String>(resultMessage);
    }
    map['winner_seats_json'] = Variable<String>(winnerSeatsJson);
    map['final_pot'] = Variable<double>(finalPot);
    map['hero_net_dollars'] = Variable<double>(heroNetDollars);
    map['hero_net_bb'] = Variable<double>(heroNetBb);
    map['hero_ev_delta_dollars'] = Variable<double>(heroEvDeltaDollars);
    map['hero_ev_delta_bb'] = Variable<double>(heroEvDeltaBb);
    map['rebuy_events_json'] = Variable<String>(rebuyEventsJson);
    map['payload_version'] = Variable<int>(payloadVersion);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  HandsCompanion toCompanion(bool nullToAbsent) {
    return HandsCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      handNumber: Value(handNumber),
      startedAtMs: Value(startedAtMs),
      endedAtMs: endedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAtMs),
      settingsJson: Value(settingsJson),
      seatCount: Value(seatCount),
      smallBlind: Value(smallBlind),
      bigBlind: Value(bigBlind),
      stackDepthBb: Value(stackDepthBb),
      dealerSeat: Value(dealerSeat),
      sbSeat: Value(sbSeat),
      bbSeat: Value(bbSeat),
      heroSeat: Value(heroSeat),
      lineupJson: Value(lineupJson),
      heroCards: Value(heroCards),
      boardFlop: Value(boardFlop),
      boardTurn: Value(boardTurn),
      boardRiver: Value(boardRiver),
      finalStreet: finalStreet == null && nullToAbsent
          ? const Value.absent()
          : Value(finalStreet),
      wentToShowdown: Value(wentToShowdown),
      resultMessage: resultMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(resultMessage),
      winnerSeatsJson: Value(winnerSeatsJson),
      finalPot: Value(finalPot),
      heroNetDollars: Value(heroNetDollars),
      heroNetBb: Value(heroNetBb),
      heroEvDeltaDollars: Value(heroEvDeltaDollars),
      heroEvDeltaBb: Value(heroEvDeltaBb),
      rebuyEventsJson: Value(rebuyEventsJson),
      payloadVersion: Value(payloadVersion),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory Hand.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Hand(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      handNumber: serializer.fromJson<int>(json['handNumber']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      endedAtMs: serializer.fromJson<int?>(json['endedAtMs']),
      settingsJson: serializer.fromJson<String>(json['settingsJson']),
      seatCount: serializer.fromJson<int>(json['seatCount']),
      smallBlind: serializer.fromJson<double>(json['smallBlind']),
      bigBlind: serializer.fromJson<double>(json['bigBlind']),
      stackDepthBb: serializer.fromJson<int>(json['stackDepthBb']),
      dealerSeat: serializer.fromJson<int>(json['dealerSeat']),
      sbSeat: serializer.fromJson<int>(json['sbSeat']),
      bbSeat: serializer.fromJson<int>(json['bbSeat']),
      heroSeat: serializer.fromJson<int>(json['heroSeat']),
      lineupJson: serializer.fromJson<String>(json['lineupJson']),
      heroCards: serializer.fromJson<String>(json['heroCards']),
      boardFlop: serializer.fromJson<String>(json['boardFlop']),
      boardTurn: serializer.fromJson<String>(json['boardTurn']),
      boardRiver: serializer.fromJson<String>(json['boardRiver']),
      finalStreet: serializer.fromJson<String?>(json['finalStreet']),
      wentToShowdown: serializer.fromJson<bool>(json['wentToShowdown']),
      resultMessage: serializer.fromJson<String?>(json['resultMessage']),
      winnerSeatsJson: serializer.fromJson<String>(json['winnerSeatsJson']),
      finalPot: serializer.fromJson<double>(json['finalPot']),
      heroNetDollars: serializer.fromJson<double>(json['heroNetDollars']),
      heroNetBb: serializer.fromJson<double>(json['heroNetBb']),
      heroEvDeltaDollars: serializer.fromJson<double>(
        json['heroEvDeltaDollars'],
      ),
      heroEvDeltaBb: serializer.fromJson<double>(json['heroEvDeltaBb']),
      rebuyEventsJson: serializer.fromJson<String>(json['rebuyEventsJson']),
      payloadVersion: serializer.fromJson<int>(json['payloadVersion']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'handNumber': serializer.toJson<int>(handNumber),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'endedAtMs': serializer.toJson<int?>(endedAtMs),
      'settingsJson': serializer.toJson<String>(settingsJson),
      'seatCount': serializer.toJson<int>(seatCount),
      'smallBlind': serializer.toJson<double>(smallBlind),
      'bigBlind': serializer.toJson<double>(bigBlind),
      'stackDepthBb': serializer.toJson<int>(stackDepthBb),
      'dealerSeat': serializer.toJson<int>(dealerSeat),
      'sbSeat': serializer.toJson<int>(sbSeat),
      'bbSeat': serializer.toJson<int>(bbSeat),
      'heroSeat': serializer.toJson<int>(heroSeat),
      'lineupJson': serializer.toJson<String>(lineupJson),
      'heroCards': serializer.toJson<String>(heroCards),
      'boardFlop': serializer.toJson<String>(boardFlop),
      'boardTurn': serializer.toJson<String>(boardTurn),
      'boardRiver': serializer.toJson<String>(boardRiver),
      'finalStreet': serializer.toJson<String?>(finalStreet),
      'wentToShowdown': serializer.toJson<bool>(wentToShowdown),
      'resultMessage': serializer.toJson<String?>(resultMessage),
      'winnerSeatsJson': serializer.toJson<String>(winnerSeatsJson),
      'finalPot': serializer.toJson<double>(finalPot),
      'heroNetDollars': serializer.toJson<double>(heroNetDollars),
      'heroNetBb': serializer.toJson<double>(heroNetBb),
      'heroEvDeltaDollars': serializer.toJson<double>(heroEvDeltaDollars),
      'heroEvDeltaBb': serializer.toJson<double>(heroEvDeltaBb),
      'rebuyEventsJson': serializer.toJson<String>(rebuyEventsJson),
      'payloadVersion': serializer.toJson<int>(payloadVersion),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  Hand copyWith({
    int? id,
    Value<int?> sessionId = const Value.absent(),
    int? handNumber,
    int? startedAtMs,
    Value<int?> endedAtMs = const Value.absent(),
    String? settingsJson,
    int? seatCount,
    double? smallBlind,
    double? bigBlind,
    int? stackDepthBb,
    int? dealerSeat,
    int? sbSeat,
    int? bbSeat,
    int? heroSeat,
    String? lineupJson,
    String? heroCards,
    String? boardFlop,
    String? boardTurn,
    String? boardRiver,
    Value<String?> finalStreet = const Value.absent(),
    bool? wentToShowdown,
    Value<String?> resultMessage = const Value.absent(),
    String? winnerSeatsJson,
    double? finalPot,
    double? heroNetDollars,
    double? heroNetBb,
    double? heroEvDeltaDollars,
    double? heroEvDeltaBb,
    String? rebuyEventsJson,
    int? payloadVersion,
    int? createdAtMs,
    int? updatedAtMs,
  }) => Hand(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    handNumber: handNumber ?? this.handNumber,
    startedAtMs: startedAtMs ?? this.startedAtMs,
    endedAtMs: endedAtMs.present ? endedAtMs.value : this.endedAtMs,
    settingsJson: settingsJson ?? this.settingsJson,
    seatCount: seatCount ?? this.seatCount,
    smallBlind: smallBlind ?? this.smallBlind,
    bigBlind: bigBlind ?? this.bigBlind,
    stackDepthBb: stackDepthBb ?? this.stackDepthBb,
    dealerSeat: dealerSeat ?? this.dealerSeat,
    sbSeat: sbSeat ?? this.sbSeat,
    bbSeat: bbSeat ?? this.bbSeat,
    heroSeat: heroSeat ?? this.heroSeat,
    lineupJson: lineupJson ?? this.lineupJson,
    heroCards: heroCards ?? this.heroCards,
    boardFlop: boardFlop ?? this.boardFlop,
    boardTurn: boardTurn ?? this.boardTurn,
    boardRiver: boardRiver ?? this.boardRiver,
    finalStreet: finalStreet.present ? finalStreet.value : this.finalStreet,
    wentToShowdown: wentToShowdown ?? this.wentToShowdown,
    resultMessage: resultMessage.present
        ? resultMessage.value
        : this.resultMessage,
    winnerSeatsJson: winnerSeatsJson ?? this.winnerSeatsJson,
    finalPot: finalPot ?? this.finalPot,
    heroNetDollars: heroNetDollars ?? this.heroNetDollars,
    heroNetBb: heroNetBb ?? this.heroNetBb,
    heroEvDeltaDollars: heroEvDeltaDollars ?? this.heroEvDeltaDollars,
    heroEvDeltaBb: heroEvDeltaBb ?? this.heroEvDeltaBb,
    rebuyEventsJson: rebuyEventsJson ?? this.rebuyEventsJson,
    payloadVersion: payloadVersion ?? this.payloadVersion,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  Hand copyWithCompanion(HandsCompanion data) {
    return Hand(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      handNumber: data.handNumber.present
          ? data.handNumber.value
          : this.handNumber,
      startedAtMs: data.startedAtMs.present
          ? data.startedAtMs.value
          : this.startedAtMs,
      endedAtMs: data.endedAtMs.present ? data.endedAtMs.value : this.endedAtMs,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
      seatCount: data.seatCount.present ? data.seatCount.value : this.seatCount,
      smallBlind: data.smallBlind.present
          ? data.smallBlind.value
          : this.smallBlind,
      bigBlind: data.bigBlind.present ? data.bigBlind.value : this.bigBlind,
      stackDepthBb: data.stackDepthBb.present
          ? data.stackDepthBb.value
          : this.stackDepthBb,
      dealerSeat: data.dealerSeat.present
          ? data.dealerSeat.value
          : this.dealerSeat,
      sbSeat: data.sbSeat.present ? data.sbSeat.value : this.sbSeat,
      bbSeat: data.bbSeat.present ? data.bbSeat.value : this.bbSeat,
      heroSeat: data.heroSeat.present ? data.heroSeat.value : this.heroSeat,
      lineupJson: data.lineupJson.present
          ? data.lineupJson.value
          : this.lineupJson,
      heroCards: data.heroCards.present ? data.heroCards.value : this.heroCards,
      boardFlop: data.boardFlop.present ? data.boardFlop.value : this.boardFlop,
      boardTurn: data.boardTurn.present ? data.boardTurn.value : this.boardTurn,
      boardRiver: data.boardRiver.present
          ? data.boardRiver.value
          : this.boardRiver,
      finalStreet: data.finalStreet.present
          ? data.finalStreet.value
          : this.finalStreet,
      wentToShowdown: data.wentToShowdown.present
          ? data.wentToShowdown.value
          : this.wentToShowdown,
      resultMessage: data.resultMessage.present
          ? data.resultMessage.value
          : this.resultMessage,
      winnerSeatsJson: data.winnerSeatsJson.present
          ? data.winnerSeatsJson.value
          : this.winnerSeatsJson,
      finalPot: data.finalPot.present ? data.finalPot.value : this.finalPot,
      heroNetDollars: data.heroNetDollars.present
          ? data.heroNetDollars.value
          : this.heroNetDollars,
      heroNetBb: data.heroNetBb.present ? data.heroNetBb.value : this.heroNetBb,
      heroEvDeltaDollars: data.heroEvDeltaDollars.present
          ? data.heroEvDeltaDollars.value
          : this.heroEvDeltaDollars,
      heroEvDeltaBb: data.heroEvDeltaBb.present
          ? data.heroEvDeltaBb.value
          : this.heroEvDeltaBb,
      rebuyEventsJson: data.rebuyEventsJson.present
          ? data.rebuyEventsJson.value
          : this.rebuyEventsJson,
      payloadVersion: data.payloadVersion.present
          ? data.payloadVersion.value
          : this.payloadVersion,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Hand(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('handNumber: $handNumber, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('seatCount: $seatCount, ')
          ..write('smallBlind: $smallBlind, ')
          ..write('bigBlind: $bigBlind, ')
          ..write('stackDepthBb: $stackDepthBb, ')
          ..write('dealerSeat: $dealerSeat, ')
          ..write('sbSeat: $sbSeat, ')
          ..write('bbSeat: $bbSeat, ')
          ..write('heroSeat: $heroSeat, ')
          ..write('lineupJson: $lineupJson, ')
          ..write('heroCards: $heroCards, ')
          ..write('boardFlop: $boardFlop, ')
          ..write('boardTurn: $boardTurn, ')
          ..write('boardRiver: $boardRiver, ')
          ..write('finalStreet: $finalStreet, ')
          ..write('wentToShowdown: $wentToShowdown, ')
          ..write('resultMessage: $resultMessage, ')
          ..write('winnerSeatsJson: $winnerSeatsJson, ')
          ..write('finalPot: $finalPot, ')
          ..write('heroNetDollars: $heroNetDollars, ')
          ..write('heroNetBb: $heroNetBb, ')
          ..write('heroEvDeltaDollars: $heroEvDeltaDollars, ')
          ..write('heroEvDeltaBb: $heroEvDeltaBb, ')
          ..write('rebuyEventsJson: $rebuyEventsJson, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    sessionId,
    handNumber,
    startedAtMs,
    endedAtMs,
    settingsJson,
    seatCount,
    smallBlind,
    bigBlind,
    stackDepthBb,
    dealerSeat,
    sbSeat,
    bbSeat,
    heroSeat,
    lineupJson,
    heroCards,
    boardFlop,
    boardTurn,
    boardRiver,
    finalStreet,
    wentToShowdown,
    resultMessage,
    winnerSeatsJson,
    finalPot,
    heroNetDollars,
    heroNetBb,
    heroEvDeltaDollars,
    heroEvDeltaBb,
    rebuyEventsJson,
    payloadVersion,
    createdAtMs,
    updatedAtMs,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Hand &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.handNumber == this.handNumber &&
          other.startedAtMs == this.startedAtMs &&
          other.endedAtMs == this.endedAtMs &&
          other.settingsJson == this.settingsJson &&
          other.seatCount == this.seatCount &&
          other.smallBlind == this.smallBlind &&
          other.bigBlind == this.bigBlind &&
          other.stackDepthBb == this.stackDepthBb &&
          other.dealerSeat == this.dealerSeat &&
          other.sbSeat == this.sbSeat &&
          other.bbSeat == this.bbSeat &&
          other.heroSeat == this.heroSeat &&
          other.lineupJson == this.lineupJson &&
          other.heroCards == this.heroCards &&
          other.boardFlop == this.boardFlop &&
          other.boardTurn == this.boardTurn &&
          other.boardRiver == this.boardRiver &&
          other.finalStreet == this.finalStreet &&
          other.wentToShowdown == this.wentToShowdown &&
          other.resultMessage == this.resultMessage &&
          other.winnerSeatsJson == this.winnerSeatsJson &&
          other.finalPot == this.finalPot &&
          other.heroNetDollars == this.heroNetDollars &&
          other.heroNetBb == this.heroNetBb &&
          other.heroEvDeltaDollars == this.heroEvDeltaDollars &&
          other.heroEvDeltaBb == this.heroEvDeltaBb &&
          other.rebuyEventsJson == this.rebuyEventsJson &&
          other.payloadVersion == this.payloadVersion &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class HandsCompanion extends UpdateCompanion<Hand> {
  final Value<int> id;
  final Value<int?> sessionId;
  final Value<int> handNumber;
  final Value<int> startedAtMs;
  final Value<int?> endedAtMs;
  final Value<String> settingsJson;
  final Value<int> seatCount;
  final Value<double> smallBlind;
  final Value<double> bigBlind;
  final Value<int> stackDepthBb;
  final Value<int> dealerSeat;
  final Value<int> sbSeat;
  final Value<int> bbSeat;
  final Value<int> heroSeat;
  final Value<String> lineupJson;
  final Value<String> heroCards;
  final Value<String> boardFlop;
  final Value<String> boardTurn;
  final Value<String> boardRiver;
  final Value<String?> finalStreet;
  final Value<bool> wentToShowdown;
  final Value<String?> resultMessage;
  final Value<String> winnerSeatsJson;
  final Value<double> finalPot;
  final Value<double> heroNetDollars;
  final Value<double> heroNetBb;
  final Value<double> heroEvDeltaDollars;
  final Value<double> heroEvDeltaBb;
  final Value<String> rebuyEventsJson;
  final Value<int> payloadVersion;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  const HandsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.handNumber = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.endedAtMs = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.seatCount = const Value.absent(),
    this.smallBlind = const Value.absent(),
    this.bigBlind = const Value.absent(),
    this.stackDepthBb = const Value.absent(),
    this.dealerSeat = const Value.absent(),
    this.sbSeat = const Value.absent(),
    this.bbSeat = const Value.absent(),
    this.heroSeat = const Value.absent(),
    this.lineupJson = const Value.absent(),
    this.heroCards = const Value.absent(),
    this.boardFlop = const Value.absent(),
    this.boardTurn = const Value.absent(),
    this.boardRiver = const Value.absent(),
    this.finalStreet = const Value.absent(),
    this.wentToShowdown = const Value.absent(),
    this.resultMessage = const Value.absent(),
    this.winnerSeatsJson = const Value.absent(),
    this.finalPot = const Value.absent(),
    this.heroNetDollars = const Value.absent(),
    this.heroNetBb = const Value.absent(),
    this.heroEvDeltaDollars = const Value.absent(),
    this.heroEvDeltaBb = const Value.absent(),
    this.rebuyEventsJson = const Value.absent(),
    this.payloadVersion = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
  });
  HandsCompanion.insert({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    required int handNumber,
    required int startedAtMs,
    this.endedAtMs = const Value.absent(),
    required String settingsJson,
    required int seatCount,
    required double smallBlind,
    required double bigBlind,
    required int stackDepthBb,
    required int dealerSeat,
    required int sbSeat,
    required int bbSeat,
    required int heroSeat,
    required String lineupJson,
    this.heroCards = const Value.absent(),
    this.boardFlop = const Value.absent(),
    this.boardTurn = const Value.absent(),
    this.boardRiver = const Value.absent(),
    this.finalStreet = const Value.absent(),
    this.wentToShowdown = const Value.absent(),
    this.resultMessage = const Value.absent(),
    this.winnerSeatsJson = const Value.absent(),
    this.finalPot = const Value.absent(),
    this.heroNetDollars = const Value.absent(),
    this.heroNetBb = const Value.absent(),
    this.heroEvDeltaDollars = const Value.absent(),
    this.heroEvDeltaBb = const Value.absent(),
    this.rebuyEventsJson = const Value.absent(),
    this.payloadVersion = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
  }) : handNumber = Value(handNumber),
       startedAtMs = Value(startedAtMs),
       settingsJson = Value(settingsJson),
       seatCount = Value(seatCount),
       smallBlind = Value(smallBlind),
       bigBlind = Value(bigBlind),
       stackDepthBb = Value(stackDepthBb),
       dealerSeat = Value(dealerSeat),
       sbSeat = Value(sbSeat),
       bbSeat = Value(bbSeat),
       heroSeat = Value(heroSeat),
       lineupJson = Value(lineupJson),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<Hand> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? handNumber,
    Expression<int>? startedAtMs,
    Expression<int>? endedAtMs,
    Expression<String>? settingsJson,
    Expression<int>? seatCount,
    Expression<double>? smallBlind,
    Expression<double>? bigBlind,
    Expression<int>? stackDepthBb,
    Expression<int>? dealerSeat,
    Expression<int>? sbSeat,
    Expression<int>? bbSeat,
    Expression<int>? heroSeat,
    Expression<String>? lineupJson,
    Expression<String>? heroCards,
    Expression<String>? boardFlop,
    Expression<String>? boardTurn,
    Expression<String>? boardRiver,
    Expression<String>? finalStreet,
    Expression<bool>? wentToShowdown,
    Expression<String>? resultMessage,
    Expression<String>? winnerSeatsJson,
    Expression<double>? finalPot,
    Expression<double>? heroNetDollars,
    Expression<double>? heroNetBb,
    Expression<double>? heroEvDeltaDollars,
    Expression<double>? heroEvDeltaBb,
    Expression<String>? rebuyEventsJson,
    Expression<int>? payloadVersion,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (handNumber != null) 'hand_number': handNumber,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (endedAtMs != null) 'ended_at_ms': endedAtMs,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (seatCount != null) 'seat_count': seatCount,
      if (smallBlind != null) 'small_blind': smallBlind,
      if (bigBlind != null) 'big_blind': bigBlind,
      if (stackDepthBb != null) 'stack_depth_bb': stackDepthBb,
      if (dealerSeat != null) 'dealer_seat': dealerSeat,
      if (sbSeat != null) 'sb_seat': sbSeat,
      if (bbSeat != null) 'bb_seat': bbSeat,
      if (heroSeat != null) 'hero_seat': heroSeat,
      if (lineupJson != null) 'lineup_json': lineupJson,
      if (heroCards != null) 'hero_cards': heroCards,
      if (boardFlop != null) 'board_flop': boardFlop,
      if (boardTurn != null) 'board_turn': boardTurn,
      if (boardRiver != null) 'board_river': boardRiver,
      if (finalStreet != null) 'final_street': finalStreet,
      if (wentToShowdown != null) 'went_to_showdown': wentToShowdown,
      if (resultMessage != null) 'result_message': resultMessage,
      if (winnerSeatsJson != null) 'winner_seats_json': winnerSeatsJson,
      if (finalPot != null) 'final_pot': finalPot,
      if (heroNetDollars != null) 'hero_net_dollars': heroNetDollars,
      if (heroNetBb != null) 'hero_net_bb': heroNetBb,
      if (heroEvDeltaDollars != null)
        'hero_ev_delta_dollars': heroEvDeltaDollars,
      if (heroEvDeltaBb != null) 'hero_ev_delta_bb': heroEvDeltaBb,
      if (rebuyEventsJson != null) 'rebuy_events_json': rebuyEventsJson,
      if (payloadVersion != null) 'payload_version': payloadVersion,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
    });
  }

  HandsCompanion copyWith({
    Value<int>? id,
    Value<int?>? sessionId,
    Value<int>? handNumber,
    Value<int>? startedAtMs,
    Value<int?>? endedAtMs,
    Value<String>? settingsJson,
    Value<int>? seatCount,
    Value<double>? smallBlind,
    Value<double>? bigBlind,
    Value<int>? stackDepthBb,
    Value<int>? dealerSeat,
    Value<int>? sbSeat,
    Value<int>? bbSeat,
    Value<int>? heroSeat,
    Value<String>? lineupJson,
    Value<String>? heroCards,
    Value<String>? boardFlop,
    Value<String>? boardTurn,
    Value<String>? boardRiver,
    Value<String?>? finalStreet,
    Value<bool>? wentToShowdown,
    Value<String?>? resultMessage,
    Value<String>? winnerSeatsJson,
    Value<double>? finalPot,
    Value<double>? heroNetDollars,
    Value<double>? heroNetBb,
    Value<double>? heroEvDeltaDollars,
    Value<double>? heroEvDeltaBb,
    Value<String>? rebuyEventsJson,
    Value<int>? payloadVersion,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
  }) {
    return HandsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      handNumber: handNumber ?? this.handNumber,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      endedAtMs: endedAtMs ?? this.endedAtMs,
      settingsJson: settingsJson ?? this.settingsJson,
      seatCount: seatCount ?? this.seatCount,
      smallBlind: smallBlind ?? this.smallBlind,
      bigBlind: bigBlind ?? this.bigBlind,
      stackDepthBb: stackDepthBb ?? this.stackDepthBb,
      dealerSeat: dealerSeat ?? this.dealerSeat,
      sbSeat: sbSeat ?? this.sbSeat,
      bbSeat: bbSeat ?? this.bbSeat,
      heroSeat: heroSeat ?? this.heroSeat,
      lineupJson: lineupJson ?? this.lineupJson,
      heroCards: heroCards ?? this.heroCards,
      boardFlop: boardFlop ?? this.boardFlop,
      boardTurn: boardTurn ?? this.boardTurn,
      boardRiver: boardRiver ?? this.boardRiver,
      finalStreet: finalStreet ?? this.finalStreet,
      wentToShowdown: wentToShowdown ?? this.wentToShowdown,
      resultMessage: resultMessage ?? this.resultMessage,
      winnerSeatsJson: winnerSeatsJson ?? this.winnerSeatsJson,
      finalPot: finalPot ?? this.finalPot,
      heroNetDollars: heroNetDollars ?? this.heroNetDollars,
      heroNetBb: heroNetBb ?? this.heroNetBb,
      heroEvDeltaDollars: heroEvDeltaDollars ?? this.heroEvDeltaDollars,
      heroEvDeltaBb: heroEvDeltaBb ?? this.heroEvDeltaBb,
      rebuyEventsJson: rebuyEventsJson ?? this.rebuyEventsJson,
      payloadVersion: payloadVersion ?? this.payloadVersion,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (handNumber.present) {
      map['hand_number'] = Variable<int>(handNumber.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (endedAtMs.present) {
      map['ended_at_ms'] = Variable<int>(endedAtMs.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (seatCount.present) {
      map['seat_count'] = Variable<int>(seatCount.value);
    }
    if (smallBlind.present) {
      map['small_blind'] = Variable<double>(smallBlind.value);
    }
    if (bigBlind.present) {
      map['big_blind'] = Variable<double>(bigBlind.value);
    }
    if (stackDepthBb.present) {
      map['stack_depth_bb'] = Variable<int>(stackDepthBb.value);
    }
    if (dealerSeat.present) {
      map['dealer_seat'] = Variable<int>(dealerSeat.value);
    }
    if (sbSeat.present) {
      map['sb_seat'] = Variable<int>(sbSeat.value);
    }
    if (bbSeat.present) {
      map['bb_seat'] = Variable<int>(bbSeat.value);
    }
    if (heroSeat.present) {
      map['hero_seat'] = Variable<int>(heroSeat.value);
    }
    if (lineupJson.present) {
      map['lineup_json'] = Variable<String>(lineupJson.value);
    }
    if (heroCards.present) {
      map['hero_cards'] = Variable<String>(heroCards.value);
    }
    if (boardFlop.present) {
      map['board_flop'] = Variable<String>(boardFlop.value);
    }
    if (boardTurn.present) {
      map['board_turn'] = Variable<String>(boardTurn.value);
    }
    if (boardRiver.present) {
      map['board_river'] = Variable<String>(boardRiver.value);
    }
    if (finalStreet.present) {
      map['final_street'] = Variable<String>(finalStreet.value);
    }
    if (wentToShowdown.present) {
      map['went_to_showdown'] = Variable<bool>(wentToShowdown.value);
    }
    if (resultMessage.present) {
      map['result_message'] = Variable<String>(resultMessage.value);
    }
    if (winnerSeatsJson.present) {
      map['winner_seats_json'] = Variable<String>(winnerSeatsJson.value);
    }
    if (finalPot.present) {
      map['final_pot'] = Variable<double>(finalPot.value);
    }
    if (heroNetDollars.present) {
      map['hero_net_dollars'] = Variable<double>(heroNetDollars.value);
    }
    if (heroNetBb.present) {
      map['hero_net_bb'] = Variable<double>(heroNetBb.value);
    }
    if (heroEvDeltaDollars.present) {
      map['hero_ev_delta_dollars'] = Variable<double>(heroEvDeltaDollars.value);
    }
    if (heroEvDeltaBb.present) {
      map['hero_ev_delta_bb'] = Variable<double>(heroEvDeltaBb.value);
    }
    if (rebuyEventsJson.present) {
      map['rebuy_events_json'] = Variable<String>(rebuyEventsJson.value);
    }
    if (payloadVersion.present) {
      map['payload_version'] = Variable<int>(payloadVersion.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HandsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('handNumber: $handNumber, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('endedAtMs: $endedAtMs, ')
          ..write('settingsJson: $settingsJson, ')
          ..write('seatCount: $seatCount, ')
          ..write('smallBlind: $smallBlind, ')
          ..write('bigBlind: $bigBlind, ')
          ..write('stackDepthBb: $stackDepthBb, ')
          ..write('dealerSeat: $dealerSeat, ')
          ..write('sbSeat: $sbSeat, ')
          ..write('bbSeat: $bbSeat, ')
          ..write('heroSeat: $heroSeat, ')
          ..write('lineupJson: $lineupJson, ')
          ..write('heroCards: $heroCards, ')
          ..write('boardFlop: $boardFlop, ')
          ..write('boardTurn: $boardTurn, ')
          ..write('boardRiver: $boardRiver, ')
          ..write('finalStreet: $finalStreet, ')
          ..write('wentToShowdown: $wentToShowdown, ')
          ..write('resultMessage: $resultMessage, ')
          ..write('winnerSeatsJson: $winnerSeatsJson, ')
          ..write('finalPot: $finalPot, ')
          ..write('heroNetDollars: $heroNetDollars, ')
          ..write('heroNetBb: $heroNetBb, ')
          ..write('heroEvDeltaDollars: $heroEvDeltaDollars, ')
          ..write('heroEvDeltaBb: $heroEvDeltaBb, ')
          ..write('rebuyEventsJson: $rebuyEventsJson, ')
          ..write('payloadVersion: $payloadVersion, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }
}

class $HandActionsTable extends HandActions
    with TableInfo<$HandActionsTable, HandAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HandActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _handIdMeta = const VerificationMeta('handId');
  @override
  late final GeneratedColumn<int> handId = GeneratedColumn<int>(
    'hand_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seatMeta = const VerificationMeta('seat');
  @override
  late final GeneratedColumn<int> seat = GeneratedColumn<int>(
    'seat',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerNameMeta = const VerificationMeta(
    'playerName',
  );
  @override
  late final GeneratedColumn<String> playerName = GeneratedColumn<String>(
    'player_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archetypeMeta = const VerificationMeta(
    'archetype',
  );
  @override
  late final GeneratedColumn<String> archetype = GeneratedColumn<String>(
    'archetype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isHeroMeta = const VerificationMeta('isHero');
  @override
  late final GeneratedColumn<bool> isHero = GeneratedColumn<bool>(
    'is_hero',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hero" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
    'street',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _potBeforeMeta = const VerificationMeta(
    'potBefore',
  );
  @override
  late final GeneratedColumn<double> potBefore = GeneratedColumn<double>(
    'pot_before',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _potAfterMeta = const VerificationMeta(
    'potAfter',
  );
  @override
  late final GeneratedColumn<double> potAfter = GeneratedColumn<double>(
    'pot_after',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stackAfterMeta = const VerificationMeta(
    'stackAfter',
  );
  @override
  late final GeneratedColumn<double> stackAfter = GeneratedColumn<double>(
    'stack_after',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _atMsMeta = const VerificationMeta('atMs');
  @override
  late final GeneratedColumn<int> atMs = GeneratedColumn<int>(
    'at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    handId,
    sequence,
    seat,
    playerName,
    archetype,
    isHero,
    street,
    actionType,
    amount,
    potBefore,
    potAfter,
    stackAfter,
    atMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hand_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<HandAction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hand_id')) {
      context.handle(
        _handIdMeta,
        handId.isAcceptableOrUnknown(data['hand_id']!, _handIdMeta),
      );
    } else if (isInserting) {
      context.missing(_handIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('seat')) {
      context.handle(
        _seatMeta,
        seat.isAcceptableOrUnknown(data['seat']!, _seatMeta),
      );
    } else if (isInserting) {
      context.missing(_seatMeta);
    }
    if (data.containsKey('player_name')) {
      context.handle(
        _playerNameMeta,
        playerName.isAcceptableOrUnknown(data['player_name']!, _playerNameMeta),
      );
    } else if (isInserting) {
      context.missing(_playerNameMeta);
    }
    if (data.containsKey('archetype')) {
      context.handle(
        _archetypeMeta,
        archetype.isAcceptableOrUnknown(data['archetype']!, _archetypeMeta),
      );
    } else if (isInserting) {
      context.missing(_archetypeMeta);
    }
    if (data.containsKey('is_hero')) {
      context.handle(
        _isHeroMeta,
        isHero.isAcceptableOrUnknown(data['is_hero']!, _isHeroMeta),
      );
    }
    if (data.containsKey('street')) {
      context.handle(
        _streetMeta,
        street.isAcceptableOrUnknown(data['street']!, _streetMeta),
      );
    } else if (isInserting) {
      context.missing(_streetMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('pot_before')) {
      context.handle(
        _potBeforeMeta,
        potBefore.isAcceptableOrUnknown(data['pot_before']!, _potBeforeMeta),
      );
    }
    if (data.containsKey('pot_after')) {
      context.handle(
        _potAfterMeta,
        potAfter.isAcceptableOrUnknown(data['pot_after']!, _potAfterMeta),
      );
    }
    if (data.containsKey('stack_after')) {
      context.handle(
        _stackAfterMeta,
        stackAfter.isAcceptableOrUnknown(data['stack_after']!, _stackAfterMeta),
      );
    }
    if (data.containsKey('at_ms')) {
      context.handle(
        _atMsMeta,
        atMs.isAcceptableOrUnknown(data['at_ms']!, _atMsMeta),
      );
    } else if (isInserting) {
      context.missing(_atMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HandAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HandAction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      handId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hand_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      seat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seat'],
      )!,
      playerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_name'],
      )!,
      archetype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archetype'],
      )!,
      isHero: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hero'],
      )!,
      street: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      potBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pot_before'],
      )!,
      potAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}pot_after'],
      )!,
      stackAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stack_after'],
      )!,
      atMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}at_ms'],
      )!,
    );
  }

  @override
  $HandActionsTable createAlias(String alias) {
    return $HandActionsTable(attachedDatabase, alias);
  }
}

class HandAction extends DataClass implements Insertable<HandAction> {
  final int id;
  final int handId;
  final int sequence;
  final int seat;
  final String playerName;
  final String archetype;
  final bool isHero;
  final String street;

  /// `BLIND`, `FOLD`, `CHECK`, `CALL`, `BET`, `RAISE`, `ALL-IN`.
  final String actionType;
  final double amount;
  final double potBefore;
  final double potAfter;
  final double stackAfter;
  final int atMs;
  const HandAction({
    required this.id,
    required this.handId,
    required this.sequence,
    required this.seat,
    required this.playerName,
    required this.archetype,
    required this.isHero,
    required this.street,
    required this.actionType,
    required this.amount,
    required this.potBefore,
    required this.potAfter,
    required this.stackAfter,
    required this.atMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['hand_id'] = Variable<int>(handId);
    map['sequence'] = Variable<int>(sequence);
    map['seat'] = Variable<int>(seat);
    map['player_name'] = Variable<String>(playerName);
    map['archetype'] = Variable<String>(archetype);
    map['is_hero'] = Variable<bool>(isHero);
    map['street'] = Variable<String>(street);
    map['action_type'] = Variable<String>(actionType);
    map['amount'] = Variable<double>(amount);
    map['pot_before'] = Variable<double>(potBefore);
    map['pot_after'] = Variable<double>(potAfter);
    map['stack_after'] = Variable<double>(stackAfter);
    map['at_ms'] = Variable<int>(atMs);
    return map;
  }

  HandActionsCompanion toCompanion(bool nullToAbsent) {
    return HandActionsCompanion(
      id: Value(id),
      handId: Value(handId),
      sequence: Value(sequence),
      seat: Value(seat),
      playerName: Value(playerName),
      archetype: Value(archetype),
      isHero: Value(isHero),
      street: Value(street),
      actionType: Value(actionType),
      amount: Value(amount),
      potBefore: Value(potBefore),
      potAfter: Value(potAfter),
      stackAfter: Value(stackAfter),
      atMs: Value(atMs),
    );
  }

  factory HandAction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HandAction(
      id: serializer.fromJson<int>(json['id']),
      handId: serializer.fromJson<int>(json['handId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      seat: serializer.fromJson<int>(json['seat']),
      playerName: serializer.fromJson<String>(json['playerName']),
      archetype: serializer.fromJson<String>(json['archetype']),
      isHero: serializer.fromJson<bool>(json['isHero']),
      street: serializer.fromJson<String>(json['street']),
      actionType: serializer.fromJson<String>(json['actionType']),
      amount: serializer.fromJson<double>(json['amount']),
      potBefore: serializer.fromJson<double>(json['potBefore']),
      potAfter: serializer.fromJson<double>(json['potAfter']),
      stackAfter: serializer.fromJson<double>(json['stackAfter']),
      atMs: serializer.fromJson<int>(json['atMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'handId': serializer.toJson<int>(handId),
      'sequence': serializer.toJson<int>(sequence),
      'seat': serializer.toJson<int>(seat),
      'playerName': serializer.toJson<String>(playerName),
      'archetype': serializer.toJson<String>(archetype),
      'isHero': serializer.toJson<bool>(isHero),
      'street': serializer.toJson<String>(street),
      'actionType': serializer.toJson<String>(actionType),
      'amount': serializer.toJson<double>(amount),
      'potBefore': serializer.toJson<double>(potBefore),
      'potAfter': serializer.toJson<double>(potAfter),
      'stackAfter': serializer.toJson<double>(stackAfter),
      'atMs': serializer.toJson<int>(atMs),
    };
  }

  HandAction copyWith({
    int? id,
    int? handId,
    int? sequence,
    int? seat,
    String? playerName,
    String? archetype,
    bool? isHero,
    String? street,
    String? actionType,
    double? amount,
    double? potBefore,
    double? potAfter,
    double? stackAfter,
    int? atMs,
  }) => HandAction(
    id: id ?? this.id,
    handId: handId ?? this.handId,
    sequence: sequence ?? this.sequence,
    seat: seat ?? this.seat,
    playerName: playerName ?? this.playerName,
    archetype: archetype ?? this.archetype,
    isHero: isHero ?? this.isHero,
    street: street ?? this.street,
    actionType: actionType ?? this.actionType,
    amount: amount ?? this.amount,
    potBefore: potBefore ?? this.potBefore,
    potAfter: potAfter ?? this.potAfter,
    stackAfter: stackAfter ?? this.stackAfter,
    atMs: atMs ?? this.atMs,
  );
  HandAction copyWithCompanion(HandActionsCompanion data) {
    return HandAction(
      id: data.id.present ? data.id.value : this.id,
      handId: data.handId.present ? data.handId.value : this.handId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      seat: data.seat.present ? data.seat.value : this.seat,
      playerName: data.playerName.present
          ? data.playerName.value
          : this.playerName,
      archetype: data.archetype.present ? data.archetype.value : this.archetype,
      isHero: data.isHero.present ? data.isHero.value : this.isHero,
      street: data.street.present ? data.street.value : this.street,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      amount: data.amount.present ? data.amount.value : this.amount,
      potBefore: data.potBefore.present ? data.potBefore.value : this.potBefore,
      potAfter: data.potAfter.present ? data.potAfter.value : this.potAfter,
      stackAfter: data.stackAfter.present
          ? data.stackAfter.value
          : this.stackAfter,
      atMs: data.atMs.present ? data.atMs.value : this.atMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HandAction(')
          ..write('id: $id, ')
          ..write('handId: $handId, ')
          ..write('sequence: $sequence, ')
          ..write('seat: $seat, ')
          ..write('playerName: $playerName, ')
          ..write('archetype: $archetype, ')
          ..write('isHero: $isHero, ')
          ..write('street: $street, ')
          ..write('actionType: $actionType, ')
          ..write('amount: $amount, ')
          ..write('potBefore: $potBefore, ')
          ..write('potAfter: $potAfter, ')
          ..write('stackAfter: $stackAfter, ')
          ..write('atMs: $atMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    handId,
    sequence,
    seat,
    playerName,
    archetype,
    isHero,
    street,
    actionType,
    amount,
    potBefore,
    potAfter,
    stackAfter,
    atMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HandAction &&
          other.id == this.id &&
          other.handId == this.handId &&
          other.sequence == this.sequence &&
          other.seat == this.seat &&
          other.playerName == this.playerName &&
          other.archetype == this.archetype &&
          other.isHero == this.isHero &&
          other.street == this.street &&
          other.actionType == this.actionType &&
          other.amount == this.amount &&
          other.potBefore == this.potBefore &&
          other.potAfter == this.potAfter &&
          other.stackAfter == this.stackAfter &&
          other.atMs == this.atMs);
}

class HandActionsCompanion extends UpdateCompanion<HandAction> {
  final Value<int> id;
  final Value<int> handId;
  final Value<int> sequence;
  final Value<int> seat;
  final Value<String> playerName;
  final Value<String> archetype;
  final Value<bool> isHero;
  final Value<String> street;
  final Value<String> actionType;
  final Value<double> amount;
  final Value<double> potBefore;
  final Value<double> potAfter;
  final Value<double> stackAfter;
  final Value<int> atMs;
  const HandActionsCompanion({
    this.id = const Value.absent(),
    this.handId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.seat = const Value.absent(),
    this.playerName = const Value.absent(),
    this.archetype = const Value.absent(),
    this.isHero = const Value.absent(),
    this.street = const Value.absent(),
    this.actionType = const Value.absent(),
    this.amount = const Value.absent(),
    this.potBefore = const Value.absent(),
    this.potAfter = const Value.absent(),
    this.stackAfter = const Value.absent(),
    this.atMs = const Value.absent(),
  });
  HandActionsCompanion.insert({
    this.id = const Value.absent(),
    required int handId,
    required int sequence,
    required int seat,
    required String playerName,
    required String archetype,
    this.isHero = const Value.absent(),
    required String street,
    required String actionType,
    this.amount = const Value.absent(),
    this.potBefore = const Value.absent(),
    this.potAfter = const Value.absent(),
    this.stackAfter = const Value.absent(),
    required int atMs,
  }) : handId = Value(handId),
       sequence = Value(sequence),
       seat = Value(seat),
       playerName = Value(playerName),
       archetype = Value(archetype),
       street = Value(street),
       actionType = Value(actionType),
       atMs = Value(atMs);
  static Insertable<HandAction> custom({
    Expression<int>? id,
    Expression<int>? handId,
    Expression<int>? sequence,
    Expression<int>? seat,
    Expression<String>? playerName,
    Expression<String>? archetype,
    Expression<bool>? isHero,
    Expression<String>? street,
    Expression<String>? actionType,
    Expression<double>? amount,
    Expression<double>? potBefore,
    Expression<double>? potAfter,
    Expression<double>? stackAfter,
    Expression<int>? atMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (handId != null) 'hand_id': handId,
      if (sequence != null) 'sequence': sequence,
      if (seat != null) 'seat': seat,
      if (playerName != null) 'player_name': playerName,
      if (archetype != null) 'archetype': archetype,
      if (isHero != null) 'is_hero': isHero,
      if (street != null) 'street': street,
      if (actionType != null) 'action_type': actionType,
      if (amount != null) 'amount': amount,
      if (potBefore != null) 'pot_before': potBefore,
      if (potAfter != null) 'pot_after': potAfter,
      if (stackAfter != null) 'stack_after': stackAfter,
      if (atMs != null) 'at_ms': atMs,
    });
  }

  HandActionsCompanion copyWith({
    Value<int>? id,
    Value<int>? handId,
    Value<int>? sequence,
    Value<int>? seat,
    Value<String>? playerName,
    Value<String>? archetype,
    Value<bool>? isHero,
    Value<String>? street,
    Value<String>? actionType,
    Value<double>? amount,
    Value<double>? potBefore,
    Value<double>? potAfter,
    Value<double>? stackAfter,
    Value<int>? atMs,
  }) {
    return HandActionsCompanion(
      id: id ?? this.id,
      handId: handId ?? this.handId,
      sequence: sequence ?? this.sequence,
      seat: seat ?? this.seat,
      playerName: playerName ?? this.playerName,
      archetype: archetype ?? this.archetype,
      isHero: isHero ?? this.isHero,
      street: street ?? this.street,
      actionType: actionType ?? this.actionType,
      amount: amount ?? this.amount,
      potBefore: potBefore ?? this.potBefore,
      potAfter: potAfter ?? this.potAfter,
      stackAfter: stackAfter ?? this.stackAfter,
      atMs: atMs ?? this.atMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (handId.present) {
      map['hand_id'] = Variable<int>(handId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (seat.present) {
      map['seat'] = Variable<int>(seat.value);
    }
    if (playerName.present) {
      map['player_name'] = Variable<String>(playerName.value);
    }
    if (archetype.present) {
      map['archetype'] = Variable<String>(archetype.value);
    }
    if (isHero.present) {
      map['is_hero'] = Variable<bool>(isHero.value);
    }
    if (street.present) {
      map['street'] = Variable<String>(street.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (potBefore.present) {
      map['pot_before'] = Variable<double>(potBefore.value);
    }
    if (potAfter.present) {
      map['pot_after'] = Variable<double>(potAfter.value);
    }
    if (stackAfter.present) {
      map['stack_after'] = Variable<double>(stackAfter.value);
    }
    if (atMs.present) {
      map['at_ms'] = Variable<int>(atMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HandActionsCompanion(')
          ..write('id: $id, ')
          ..write('handId: $handId, ')
          ..write('sequence: $sequence, ')
          ..write('seat: $seat, ')
          ..write('playerName: $playerName, ')
          ..write('archetype: $archetype, ')
          ..write('isHero: $isHero, ')
          ..write('street: $street, ')
          ..write('actionType: $actionType, ')
          ..write('amount: $amount, ')
          ..write('potBefore: $potBefore, ')
          ..write('potAfter: $potAfter, ')
          ..write('stackAfter: $stackAfter, ')
          ..write('atMs: $atMs')
          ..write(')'))
        .toString();
  }
}

class $CoachDecisionsTable extends CoachDecisions
    with TableInfo<$CoachDecisionsTable, CoachDecision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoachDecisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _handIdMeta = const VerificationMeta('handId');
  @override
  late final GeneratedColumn<int> handId = GeneratedColumn<int>(
    'hand_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _streetMeta = const VerificationMeta('street');
  @override
  late final GeneratedColumn<String> street = GeneratedColumn<String>(
    'street',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heroActionMeta = const VerificationMeta(
    'heroAction',
  );
  @override
  late final GeneratedColumn<String> heroAction = GeneratedColumn<String>(
    'hero_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heroAmountMeta = const VerificationMeta(
    'heroAmount',
  );
  @override
  late final GeneratedColumn<double> heroAmount = GeneratedColumn<double>(
    'hero_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bestActionMeta = const VerificationMeta(
    'bestAction',
  );
  @override
  late final GeneratedColumn<String> bestAction = GeneratedColumn<String>(
    'best_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bestSizingBbMeta = const VerificationMeta(
    'bestSizingBb',
  );
  @override
  late final GeneratedColumn<double> bestSizingBb = GeneratedColumn<double>(
    'best_sizing_bb',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _verdictMeta = const VerificationMeta(
    'verdict',
  );
  @override
  late final GeneratedColumn<String> verdict = GeneratedColumn<String>(
    'verdict',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mismatchMeta = const VerificationMeta(
    'mismatch',
  );
  @override
  late final GeneratedColumn<String> mismatch = GeneratedColumn<String>(
    'mismatch',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('none'),
  );
  static const VerificationMeta _evDeltaBbMeta = const VerificationMeta(
    'evDeltaBb',
  );
  @override
  late final GeneratedColumn<double> evDeltaBb = GeneratedColumn<double>(
    'ev_delta_bb',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _evDeltaDollarsMeta = const VerificationMeta(
    'evDeltaDollars',
  );
  @override
  late final GeneratedColumn<double> evDeltaDollars = GeneratedColumn<double>(
    'ev_delta_dollars',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _villainNameMeta = const VerificationMeta(
    'villainName',
  );
  @override
  late final GeneratedColumn<String> villainName = GeneratedColumn<String>(
    'villain_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _villainArchetypeMeta = const VerificationMeta(
    'villainArchetype',
  );
  @override
  late final GeneratedColumn<String> villainArchetype = GeneratedColumn<String>(
    'villain_archetype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _adviceTextMeta = const VerificationMeta(
    'adviceText',
  );
  @override
  late final GeneratedColumn<String> adviceText = GeneratedColumn<String>(
    'advice_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adviceSourceMeta = const VerificationMeta(
    'adviceSource',
  );
  @override
  late final GeneratedColumn<String> adviceSource = GeneratedColumn<String>(
    'advice_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('offline'),
  );
  static const VerificationMeta _aiRequestIdMeta = const VerificationMeta(
    'aiRequestId',
  );
  @override
  late final GeneratedColumn<int> aiRequestId = GeneratedColumn<int>(
    'ai_request_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voicePlayedMeta = const VerificationMeta(
    'voicePlayed',
  );
  @override
  late final GeneratedColumn<bool> voicePlayed = GeneratedColumn<bool>(
    'voice_played',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("voice_played" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _voiceFromCacheMeta = const VerificationMeta(
    'voiceFromCache',
  );
  @override
  late final GeneratedColumn<bool> voiceFromCache = GeneratedColumn<bool>(
    'voice_from_cache',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("voice_from_cache" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _voiceUsedDeviceMeta = const VerificationMeta(
    'voiceUsedDevice',
  );
  @override
  late final GeneratedColumn<bool> voiceUsedDevice = GeneratedColumn<bool>(
    'voice_used_device',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("voice_used_device" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _gradedAtMsMeta = const VerificationMeta(
    'gradedAtMs',
  );
  @override
  late final GeneratedColumn<int> gradedAtMs = GeneratedColumn<int>(
    'graded_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _narratedAtMsMeta = const VerificationMeta(
    'narratedAtMs',
  );
  @override
  late final GeneratedColumn<int> narratedAtMs = GeneratedColumn<int>(
    'narrated_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    handId,
    sessionId,
    street,
    heroAction,
    heroAmount,
    bestAction,
    bestSizingBb,
    verdict,
    mismatch,
    evDeltaBb,
    evDeltaDollars,
    villainName,
    villainArchetype,
    adviceText,
    adviceSource,
    aiRequestId,
    voicePlayed,
    voiceFromCache,
    voiceUsedDevice,
    gradedAtMs,
    narratedAtMs,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'coach_decisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoachDecision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('hand_id')) {
      context.handle(
        _handIdMeta,
        handId.isAcceptableOrUnknown(data['hand_id']!, _handIdMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('street')) {
      context.handle(
        _streetMeta,
        street.isAcceptableOrUnknown(data['street']!, _streetMeta),
      );
    } else if (isInserting) {
      context.missing(_streetMeta);
    }
    if (data.containsKey('hero_action')) {
      context.handle(
        _heroActionMeta,
        heroAction.isAcceptableOrUnknown(data['hero_action']!, _heroActionMeta),
      );
    } else if (isInserting) {
      context.missing(_heroActionMeta);
    }
    if (data.containsKey('hero_amount')) {
      context.handle(
        _heroAmountMeta,
        heroAmount.isAcceptableOrUnknown(data['hero_amount']!, _heroAmountMeta),
      );
    }
    if (data.containsKey('best_action')) {
      context.handle(
        _bestActionMeta,
        bestAction.isAcceptableOrUnknown(data['best_action']!, _bestActionMeta),
      );
    }
    if (data.containsKey('best_sizing_bb')) {
      context.handle(
        _bestSizingBbMeta,
        bestSizingBb.isAcceptableOrUnknown(
          data['best_sizing_bb']!,
          _bestSizingBbMeta,
        ),
      );
    }
    if (data.containsKey('verdict')) {
      context.handle(
        _verdictMeta,
        verdict.isAcceptableOrUnknown(data['verdict']!, _verdictMeta),
      );
    } else if (isInserting) {
      context.missing(_verdictMeta);
    }
    if (data.containsKey('mismatch')) {
      context.handle(
        _mismatchMeta,
        mismatch.isAcceptableOrUnknown(data['mismatch']!, _mismatchMeta),
      );
    }
    if (data.containsKey('ev_delta_bb')) {
      context.handle(
        _evDeltaBbMeta,
        evDeltaBb.isAcceptableOrUnknown(data['ev_delta_bb']!, _evDeltaBbMeta),
      );
    }
    if (data.containsKey('ev_delta_dollars')) {
      context.handle(
        _evDeltaDollarsMeta,
        evDeltaDollars.isAcceptableOrUnknown(
          data['ev_delta_dollars']!,
          _evDeltaDollarsMeta,
        ),
      );
    }
    if (data.containsKey('villain_name')) {
      context.handle(
        _villainNameMeta,
        villainName.isAcceptableOrUnknown(
          data['villain_name']!,
          _villainNameMeta,
        ),
      );
    }
    if (data.containsKey('villain_archetype')) {
      context.handle(
        _villainArchetypeMeta,
        villainArchetype.isAcceptableOrUnknown(
          data['villain_archetype']!,
          _villainArchetypeMeta,
        ),
      );
    }
    if (data.containsKey('advice_text')) {
      context.handle(
        _adviceTextMeta,
        adviceText.isAcceptableOrUnknown(data['advice_text']!, _adviceTextMeta),
      );
    } else if (isInserting) {
      context.missing(_adviceTextMeta);
    }
    if (data.containsKey('advice_source')) {
      context.handle(
        _adviceSourceMeta,
        adviceSource.isAcceptableOrUnknown(
          data['advice_source']!,
          _adviceSourceMeta,
        ),
      );
    }
    if (data.containsKey('ai_request_id')) {
      context.handle(
        _aiRequestIdMeta,
        aiRequestId.isAcceptableOrUnknown(
          data['ai_request_id']!,
          _aiRequestIdMeta,
        ),
      );
    }
    if (data.containsKey('voice_played')) {
      context.handle(
        _voicePlayedMeta,
        voicePlayed.isAcceptableOrUnknown(
          data['voice_played']!,
          _voicePlayedMeta,
        ),
      );
    }
    if (data.containsKey('voice_from_cache')) {
      context.handle(
        _voiceFromCacheMeta,
        voiceFromCache.isAcceptableOrUnknown(
          data['voice_from_cache']!,
          _voiceFromCacheMeta,
        ),
      );
    }
    if (data.containsKey('voice_used_device')) {
      context.handle(
        _voiceUsedDeviceMeta,
        voiceUsedDevice.isAcceptableOrUnknown(
          data['voice_used_device']!,
          _voiceUsedDeviceMeta,
        ),
      );
    }
    if (data.containsKey('graded_at_ms')) {
      context.handle(
        _gradedAtMsMeta,
        gradedAtMs.isAcceptableOrUnknown(
          data['graded_at_ms']!,
          _gradedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_gradedAtMsMeta);
    }
    if (data.containsKey('narrated_at_ms')) {
      context.handle(
        _narratedAtMsMeta,
        narratedAtMs.isAcceptableOrUnknown(
          data['narrated_at_ms']!,
          _narratedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoachDecision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoachDecision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      handId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hand_id'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      street: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}street'],
      )!,
      heroAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_action'],
      )!,
      heroAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hero_amount'],
      )!,
      bestAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}best_action'],
      ),
      bestSizingBb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}best_sizing_bb'],
      )!,
      verdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict'],
      )!,
      mismatch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mismatch'],
      )!,
      evDeltaBb: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ev_delta_bb'],
      )!,
      evDeltaDollars: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ev_delta_dollars'],
      )!,
      villainName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}villain_name'],
      )!,
      villainArchetype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}villain_archetype'],
      )!,
      adviceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}advice_text'],
      )!,
      adviceSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}advice_source'],
      )!,
      aiRequestId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ai_request_id'],
      ),
      voicePlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voice_played'],
      )!,
      voiceFromCache: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voice_from_cache'],
      )!,
      voiceUsedDevice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voice_used_device'],
      )!,
      gradedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}graded_at_ms'],
      )!,
      narratedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}narrated_at_ms'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $CoachDecisionsTable createAlias(String alias) {
    return $CoachDecisionsTable(attachedDatabase, alias);
  }
}

class CoachDecision extends DataClass implements Insertable<CoachDecision> {
  final int id;
  final int? handId;
  final int? sessionId;
  final String street;
  final String heroAction;
  final double heroAmount;
  final String? bestAction;
  final double bestSizingBb;

  /// `correct`, `incorrect`, `none`.
  final String verdict;

  /// `CoachMismatch.name`.
  final String mismatch;
  final double evDeltaBb;
  final double evDeltaDollars;
  final String villainName;
  final String villainArchetype;

  /// Final advice shown to the player.
  final String adviceText;

  /// `gemini` or `offline`.
  final String adviceSource;

  /// Linked `ai_requests.id` for the coach text call, when one was made.
  final int? aiRequestId;
  final bool voicePlayed;
  final bool voiceFromCache;
  final bool voiceUsedDevice;
  final int gradedAtMs;
  final int? narratedAtMs;
  final int createdAtMs;
  final int updatedAtMs;
  const CoachDecision({
    required this.id,
    this.handId,
    this.sessionId,
    required this.street,
    required this.heroAction,
    required this.heroAmount,
    this.bestAction,
    required this.bestSizingBb,
    required this.verdict,
    required this.mismatch,
    required this.evDeltaBb,
    required this.evDeltaDollars,
    required this.villainName,
    required this.villainArchetype,
    required this.adviceText,
    required this.adviceSource,
    this.aiRequestId,
    required this.voicePlayed,
    required this.voiceFromCache,
    required this.voiceUsedDevice,
    required this.gradedAtMs,
    this.narratedAtMs,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || handId != null) {
      map['hand_id'] = Variable<int>(handId);
    }
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['street'] = Variable<String>(street);
    map['hero_action'] = Variable<String>(heroAction);
    map['hero_amount'] = Variable<double>(heroAmount);
    if (!nullToAbsent || bestAction != null) {
      map['best_action'] = Variable<String>(bestAction);
    }
    map['best_sizing_bb'] = Variable<double>(bestSizingBb);
    map['verdict'] = Variable<String>(verdict);
    map['mismatch'] = Variable<String>(mismatch);
    map['ev_delta_bb'] = Variable<double>(evDeltaBb);
    map['ev_delta_dollars'] = Variable<double>(evDeltaDollars);
    map['villain_name'] = Variable<String>(villainName);
    map['villain_archetype'] = Variable<String>(villainArchetype);
    map['advice_text'] = Variable<String>(adviceText);
    map['advice_source'] = Variable<String>(adviceSource);
    if (!nullToAbsent || aiRequestId != null) {
      map['ai_request_id'] = Variable<int>(aiRequestId);
    }
    map['voice_played'] = Variable<bool>(voicePlayed);
    map['voice_from_cache'] = Variable<bool>(voiceFromCache);
    map['voice_used_device'] = Variable<bool>(voiceUsedDevice);
    map['graded_at_ms'] = Variable<int>(gradedAtMs);
    if (!nullToAbsent || narratedAtMs != null) {
      map['narrated_at_ms'] = Variable<int>(narratedAtMs);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  CoachDecisionsCompanion toCompanion(bool nullToAbsent) {
    return CoachDecisionsCompanion(
      id: Value(id),
      handId: handId == null && nullToAbsent
          ? const Value.absent()
          : Value(handId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      street: Value(street),
      heroAction: Value(heroAction),
      heroAmount: Value(heroAmount),
      bestAction: bestAction == null && nullToAbsent
          ? const Value.absent()
          : Value(bestAction),
      bestSizingBb: Value(bestSizingBb),
      verdict: Value(verdict),
      mismatch: Value(mismatch),
      evDeltaBb: Value(evDeltaBb),
      evDeltaDollars: Value(evDeltaDollars),
      villainName: Value(villainName),
      villainArchetype: Value(villainArchetype),
      adviceText: Value(adviceText),
      adviceSource: Value(adviceSource),
      aiRequestId: aiRequestId == null && nullToAbsent
          ? const Value.absent()
          : Value(aiRequestId),
      voicePlayed: Value(voicePlayed),
      voiceFromCache: Value(voiceFromCache),
      voiceUsedDevice: Value(voiceUsedDevice),
      gradedAtMs: Value(gradedAtMs),
      narratedAtMs: narratedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(narratedAtMs),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory CoachDecision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoachDecision(
      id: serializer.fromJson<int>(json['id']),
      handId: serializer.fromJson<int?>(json['handId']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      street: serializer.fromJson<String>(json['street']),
      heroAction: serializer.fromJson<String>(json['heroAction']),
      heroAmount: serializer.fromJson<double>(json['heroAmount']),
      bestAction: serializer.fromJson<String?>(json['bestAction']),
      bestSizingBb: serializer.fromJson<double>(json['bestSizingBb']),
      verdict: serializer.fromJson<String>(json['verdict']),
      mismatch: serializer.fromJson<String>(json['mismatch']),
      evDeltaBb: serializer.fromJson<double>(json['evDeltaBb']),
      evDeltaDollars: serializer.fromJson<double>(json['evDeltaDollars']),
      villainName: serializer.fromJson<String>(json['villainName']),
      villainArchetype: serializer.fromJson<String>(json['villainArchetype']),
      adviceText: serializer.fromJson<String>(json['adviceText']),
      adviceSource: serializer.fromJson<String>(json['adviceSource']),
      aiRequestId: serializer.fromJson<int?>(json['aiRequestId']),
      voicePlayed: serializer.fromJson<bool>(json['voicePlayed']),
      voiceFromCache: serializer.fromJson<bool>(json['voiceFromCache']),
      voiceUsedDevice: serializer.fromJson<bool>(json['voiceUsedDevice']),
      gradedAtMs: serializer.fromJson<int>(json['gradedAtMs']),
      narratedAtMs: serializer.fromJson<int?>(json['narratedAtMs']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'handId': serializer.toJson<int?>(handId),
      'sessionId': serializer.toJson<int?>(sessionId),
      'street': serializer.toJson<String>(street),
      'heroAction': serializer.toJson<String>(heroAction),
      'heroAmount': serializer.toJson<double>(heroAmount),
      'bestAction': serializer.toJson<String?>(bestAction),
      'bestSizingBb': serializer.toJson<double>(bestSizingBb),
      'verdict': serializer.toJson<String>(verdict),
      'mismatch': serializer.toJson<String>(mismatch),
      'evDeltaBb': serializer.toJson<double>(evDeltaBb),
      'evDeltaDollars': serializer.toJson<double>(evDeltaDollars),
      'villainName': serializer.toJson<String>(villainName),
      'villainArchetype': serializer.toJson<String>(villainArchetype),
      'adviceText': serializer.toJson<String>(adviceText),
      'adviceSource': serializer.toJson<String>(adviceSource),
      'aiRequestId': serializer.toJson<int?>(aiRequestId),
      'voicePlayed': serializer.toJson<bool>(voicePlayed),
      'voiceFromCache': serializer.toJson<bool>(voiceFromCache),
      'voiceUsedDevice': serializer.toJson<bool>(voiceUsedDevice),
      'gradedAtMs': serializer.toJson<int>(gradedAtMs),
      'narratedAtMs': serializer.toJson<int?>(narratedAtMs),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  CoachDecision copyWith({
    int? id,
    Value<int?> handId = const Value.absent(),
    Value<int?> sessionId = const Value.absent(),
    String? street,
    String? heroAction,
    double? heroAmount,
    Value<String?> bestAction = const Value.absent(),
    double? bestSizingBb,
    String? verdict,
    String? mismatch,
    double? evDeltaBb,
    double? evDeltaDollars,
    String? villainName,
    String? villainArchetype,
    String? adviceText,
    String? adviceSource,
    Value<int?> aiRequestId = const Value.absent(),
    bool? voicePlayed,
    bool? voiceFromCache,
    bool? voiceUsedDevice,
    int? gradedAtMs,
    Value<int?> narratedAtMs = const Value.absent(),
    int? createdAtMs,
    int? updatedAtMs,
  }) => CoachDecision(
    id: id ?? this.id,
    handId: handId.present ? handId.value : this.handId,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    street: street ?? this.street,
    heroAction: heroAction ?? this.heroAction,
    heroAmount: heroAmount ?? this.heroAmount,
    bestAction: bestAction.present ? bestAction.value : this.bestAction,
    bestSizingBb: bestSizingBb ?? this.bestSizingBb,
    verdict: verdict ?? this.verdict,
    mismatch: mismatch ?? this.mismatch,
    evDeltaBb: evDeltaBb ?? this.evDeltaBb,
    evDeltaDollars: evDeltaDollars ?? this.evDeltaDollars,
    villainName: villainName ?? this.villainName,
    villainArchetype: villainArchetype ?? this.villainArchetype,
    adviceText: adviceText ?? this.adviceText,
    adviceSource: adviceSource ?? this.adviceSource,
    aiRequestId: aiRequestId.present ? aiRequestId.value : this.aiRequestId,
    voicePlayed: voicePlayed ?? this.voicePlayed,
    voiceFromCache: voiceFromCache ?? this.voiceFromCache,
    voiceUsedDevice: voiceUsedDevice ?? this.voiceUsedDevice,
    gradedAtMs: gradedAtMs ?? this.gradedAtMs,
    narratedAtMs: narratedAtMs.present ? narratedAtMs.value : this.narratedAtMs,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  CoachDecision copyWithCompanion(CoachDecisionsCompanion data) {
    return CoachDecision(
      id: data.id.present ? data.id.value : this.id,
      handId: data.handId.present ? data.handId.value : this.handId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      street: data.street.present ? data.street.value : this.street,
      heroAction: data.heroAction.present
          ? data.heroAction.value
          : this.heroAction,
      heroAmount: data.heroAmount.present
          ? data.heroAmount.value
          : this.heroAmount,
      bestAction: data.bestAction.present
          ? data.bestAction.value
          : this.bestAction,
      bestSizingBb: data.bestSizingBb.present
          ? data.bestSizingBb.value
          : this.bestSizingBb,
      verdict: data.verdict.present ? data.verdict.value : this.verdict,
      mismatch: data.mismatch.present ? data.mismatch.value : this.mismatch,
      evDeltaBb: data.evDeltaBb.present ? data.evDeltaBb.value : this.evDeltaBb,
      evDeltaDollars: data.evDeltaDollars.present
          ? data.evDeltaDollars.value
          : this.evDeltaDollars,
      villainName: data.villainName.present
          ? data.villainName.value
          : this.villainName,
      villainArchetype: data.villainArchetype.present
          ? data.villainArchetype.value
          : this.villainArchetype,
      adviceText: data.adviceText.present
          ? data.adviceText.value
          : this.adviceText,
      adviceSource: data.adviceSource.present
          ? data.adviceSource.value
          : this.adviceSource,
      aiRequestId: data.aiRequestId.present
          ? data.aiRequestId.value
          : this.aiRequestId,
      voicePlayed: data.voicePlayed.present
          ? data.voicePlayed.value
          : this.voicePlayed,
      voiceFromCache: data.voiceFromCache.present
          ? data.voiceFromCache.value
          : this.voiceFromCache,
      voiceUsedDevice: data.voiceUsedDevice.present
          ? data.voiceUsedDevice.value
          : this.voiceUsedDevice,
      gradedAtMs: data.gradedAtMs.present
          ? data.gradedAtMs.value
          : this.gradedAtMs,
      narratedAtMs: data.narratedAtMs.present
          ? data.narratedAtMs.value
          : this.narratedAtMs,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoachDecision(')
          ..write('id: $id, ')
          ..write('handId: $handId, ')
          ..write('sessionId: $sessionId, ')
          ..write('street: $street, ')
          ..write('heroAction: $heroAction, ')
          ..write('heroAmount: $heroAmount, ')
          ..write('bestAction: $bestAction, ')
          ..write('bestSizingBb: $bestSizingBb, ')
          ..write('verdict: $verdict, ')
          ..write('mismatch: $mismatch, ')
          ..write('evDeltaBb: $evDeltaBb, ')
          ..write('evDeltaDollars: $evDeltaDollars, ')
          ..write('villainName: $villainName, ')
          ..write('villainArchetype: $villainArchetype, ')
          ..write('adviceText: $adviceText, ')
          ..write('adviceSource: $adviceSource, ')
          ..write('aiRequestId: $aiRequestId, ')
          ..write('voicePlayed: $voicePlayed, ')
          ..write('voiceFromCache: $voiceFromCache, ')
          ..write('voiceUsedDevice: $voiceUsedDevice, ')
          ..write('gradedAtMs: $gradedAtMs, ')
          ..write('narratedAtMs: $narratedAtMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    handId,
    sessionId,
    street,
    heroAction,
    heroAmount,
    bestAction,
    bestSizingBb,
    verdict,
    mismatch,
    evDeltaBb,
    evDeltaDollars,
    villainName,
    villainArchetype,
    adviceText,
    adviceSource,
    aiRequestId,
    voicePlayed,
    voiceFromCache,
    voiceUsedDevice,
    gradedAtMs,
    narratedAtMs,
    createdAtMs,
    updatedAtMs,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoachDecision &&
          other.id == this.id &&
          other.handId == this.handId &&
          other.sessionId == this.sessionId &&
          other.street == this.street &&
          other.heroAction == this.heroAction &&
          other.heroAmount == this.heroAmount &&
          other.bestAction == this.bestAction &&
          other.bestSizingBb == this.bestSizingBb &&
          other.verdict == this.verdict &&
          other.mismatch == this.mismatch &&
          other.evDeltaBb == this.evDeltaBb &&
          other.evDeltaDollars == this.evDeltaDollars &&
          other.villainName == this.villainName &&
          other.villainArchetype == this.villainArchetype &&
          other.adviceText == this.adviceText &&
          other.adviceSource == this.adviceSource &&
          other.aiRequestId == this.aiRequestId &&
          other.voicePlayed == this.voicePlayed &&
          other.voiceFromCache == this.voiceFromCache &&
          other.voiceUsedDevice == this.voiceUsedDevice &&
          other.gradedAtMs == this.gradedAtMs &&
          other.narratedAtMs == this.narratedAtMs &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class CoachDecisionsCompanion extends UpdateCompanion<CoachDecision> {
  final Value<int> id;
  final Value<int?> handId;
  final Value<int?> sessionId;
  final Value<String> street;
  final Value<String> heroAction;
  final Value<double> heroAmount;
  final Value<String?> bestAction;
  final Value<double> bestSizingBb;
  final Value<String> verdict;
  final Value<String> mismatch;
  final Value<double> evDeltaBb;
  final Value<double> evDeltaDollars;
  final Value<String> villainName;
  final Value<String> villainArchetype;
  final Value<String> adviceText;
  final Value<String> adviceSource;
  final Value<int?> aiRequestId;
  final Value<bool> voicePlayed;
  final Value<bool> voiceFromCache;
  final Value<bool> voiceUsedDevice;
  final Value<int> gradedAtMs;
  final Value<int?> narratedAtMs;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  const CoachDecisionsCompanion({
    this.id = const Value.absent(),
    this.handId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.street = const Value.absent(),
    this.heroAction = const Value.absent(),
    this.heroAmount = const Value.absent(),
    this.bestAction = const Value.absent(),
    this.bestSizingBb = const Value.absent(),
    this.verdict = const Value.absent(),
    this.mismatch = const Value.absent(),
    this.evDeltaBb = const Value.absent(),
    this.evDeltaDollars = const Value.absent(),
    this.villainName = const Value.absent(),
    this.villainArchetype = const Value.absent(),
    this.adviceText = const Value.absent(),
    this.adviceSource = const Value.absent(),
    this.aiRequestId = const Value.absent(),
    this.voicePlayed = const Value.absent(),
    this.voiceFromCache = const Value.absent(),
    this.voiceUsedDevice = const Value.absent(),
    this.gradedAtMs = const Value.absent(),
    this.narratedAtMs = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
  });
  CoachDecisionsCompanion.insert({
    this.id = const Value.absent(),
    this.handId = const Value.absent(),
    this.sessionId = const Value.absent(),
    required String street,
    required String heroAction,
    this.heroAmount = const Value.absent(),
    this.bestAction = const Value.absent(),
    this.bestSizingBb = const Value.absent(),
    required String verdict,
    this.mismatch = const Value.absent(),
    this.evDeltaBb = const Value.absent(),
    this.evDeltaDollars = const Value.absent(),
    this.villainName = const Value.absent(),
    this.villainArchetype = const Value.absent(),
    required String adviceText,
    this.adviceSource = const Value.absent(),
    this.aiRequestId = const Value.absent(),
    this.voicePlayed = const Value.absent(),
    this.voiceFromCache = const Value.absent(),
    this.voiceUsedDevice = const Value.absent(),
    required int gradedAtMs,
    this.narratedAtMs = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
  }) : street = Value(street),
       heroAction = Value(heroAction),
       verdict = Value(verdict),
       adviceText = Value(adviceText),
       gradedAtMs = Value(gradedAtMs),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<CoachDecision> custom({
    Expression<int>? id,
    Expression<int>? handId,
    Expression<int>? sessionId,
    Expression<String>? street,
    Expression<String>? heroAction,
    Expression<double>? heroAmount,
    Expression<String>? bestAction,
    Expression<double>? bestSizingBb,
    Expression<String>? verdict,
    Expression<String>? mismatch,
    Expression<double>? evDeltaBb,
    Expression<double>? evDeltaDollars,
    Expression<String>? villainName,
    Expression<String>? villainArchetype,
    Expression<String>? adviceText,
    Expression<String>? adviceSource,
    Expression<int>? aiRequestId,
    Expression<bool>? voicePlayed,
    Expression<bool>? voiceFromCache,
    Expression<bool>? voiceUsedDevice,
    Expression<int>? gradedAtMs,
    Expression<int>? narratedAtMs,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (handId != null) 'hand_id': handId,
      if (sessionId != null) 'session_id': sessionId,
      if (street != null) 'street': street,
      if (heroAction != null) 'hero_action': heroAction,
      if (heroAmount != null) 'hero_amount': heroAmount,
      if (bestAction != null) 'best_action': bestAction,
      if (bestSizingBb != null) 'best_sizing_bb': bestSizingBb,
      if (verdict != null) 'verdict': verdict,
      if (mismatch != null) 'mismatch': mismatch,
      if (evDeltaBb != null) 'ev_delta_bb': evDeltaBb,
      if (evDeltaDollars != null) 'ev_delta_dollars': evDeltaDollars,
      if (villainName != null) 'villain_name': villainName,
      if (villainArchetype != null) 'villain_archetype': villainArchetype,
      if (adviceText != null) 'advice_text': adviceText,
      if (adviceSource != null) 'advice_source': adviceSource,
      if (aiRequestId != null) 'ai_request_id': aiRequestId,
      if (voicePlayed != null) 'voice_played': voicePlayed,
      if (voiceFromCache != null) 'voice_from_cache': voiceFromCache,
      if (voiceUsedDevice != null) 'voice_used_device': voiceUsedDevice,
      if (gradedAtMs != null) 'graded_at_ms': gradedAtMs,
      if (narratedAtMs != null) 'narrated_at_ms': narratedAtMs,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
    });
  }

  CoachDecisionsCompanion copyWith({
    Value<int>? id,
    Value<int?>? handId,
    Value<int?>? sessionId,
    Value<String>? street,
    Value<String>? heroAction,
    Value<double>? heroAmount,
    Value<String?>? bestAction,
    Value<double>? bestSizingBb,
    Value<String>? verdict,
    Value<String>? mismatch,
    Value<double>? evDeltaBb,
    Value<double>? evDeltaDollars,
    Value<String>? villainName,
    Value<String>? villainArchetype,
    Value<String>? adviceText,
    Value<String>? adviceSource,
    Value<int?>? aiRequestId,
    Value<bool>? voicePlayed,
    Value<bool>? voiceFromCache,
    Value<bool>? voiceUsedDevice,
    Value<int>? gradedAtMs,
    Value<int?>? narratedAtMs,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
  }) {
    return CoachDecisionsCompanion(
      id: id ?? this.id,
      handId: handId ?? this.handId,
      sessionId: sessionId ?? this.sessionId,
      street: street ?? this.street,
      heroAction: heroAction ?? this.heroAction,
      heroAmount: heroAmount ?? this.heroAmount,
      bestAction: bestAction ?? this.bestAction,
      bestSizingBb: bestSizingBb ?? this.bestSizingBb,
      verdict: verdict ?? this.verdict,
      mismatch: mismatch ?? this.mismatch,
      evDeltaBb: evDeltaBb ?? this.evDeltaBb,
      evDeltaDollars: evDeltaDollars ?? this.evDeltaDollars,
      villainName: villainName ?? this.villainName,
      villainArchetype: villainArchetype ?? this.villainArchetype,
      adviceText: adviceText ?? this.adviceText,
      adviceSource: adviceSource ?? this.adviceSource,
      aiRequestId: aiRequestId ?? this.aiRequestId,
      voicePlayed: voicePlayed ?? this.voicePlayed,
      voiceFromCache: voiceFromCache ?? this.voiceFromCache,
      voiceUsedDevice: voiceUsedDevice ?? this.voiceUsedDevice,
      gradedAtMs: gradedAtMs ?? this.gradedAtMs,
      narratedAtMs: narratedAtMs ?? this.narratedAtMs,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (handId.present) {
      map['hand_id'] = Variable<int>(handId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (street.present) {
      map['street'] = Variable<String>(street.value);
    }
    if (heroAction.present) {
      map['hero_action'] = Variable<String>(heroAction.value);
    }
    if (heroAmount.present) {
      map['hero_amount'] = Variable<double>(heroAmount.value);
    }
    if (bestAction.present) {
      map['best_action'] = Variable<String>(bestAction.value);
    }
    if (bestSizingBb.present) {
      map['best_sizing_bb'] = Variable<double>(bestSizingBb.value);
    }
    if (verdict.present) {
      map['verdict'] = Variable<String>(verdict.value);
    }
    if (mismatch.present) {
      map['mismatch'] = Variable<String>(mismatch.value);
    }
    if (evDeltaBb.present) {
      map['ev_delta_bb'] = Variable<double>(evDeltaBb.value);
    }
    if (evDeltaDollars.present) {
      map['ev_delta_dollars'] = Variable<double>(evDeltaDollars.value);
    }
    if (villainName.present) {
      map['villain_name'] = Variable<String>(villainName.value);
    }
    if (villainArchetype.present) {
      map['villain_archetype'] = Variable<String>(villainArchetype.value);
    }
    if (adviceText.present) {
      map['advice_text'] = Variable<String>(adviceText.value);
    }
    if (adviceSource.present) {
      map['advice_source'] = Variable<String>(adviceSource.value);
    }
    if (aiRequestId.present) {
      map['ai_request_id'] = Variable<int>(aiRequestId.value);
    }
    if (voicePlayed.present) {
      map['voice_played'] = Variable<bool>(voicePlayed.value);
    }
    if (voiceFromCache.present) {
      map['voice_from_cache'] = Variable<bool>(voiceFromCache.value);
    }
    if (voiceUsedDevice.present) {
      map['voice_used_device'] = Variable<bool>(voiceUsedDevice.value);
    }
    if (gradedAtMs.present) {
      map['graded_at_ms'] = Variable<int>(gradedAtMs.value);
    }
    if (narratedAtMs.present) {
      map['narrated_at_ms'] = Variable<int>(narratedAtMs.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoachDecisionsCompanion(')
          ..write('id: $id, ')
          ..write('handId: $handId, ')
          ..write('sessionId: $sessionId, ')
          ..write('street: $street, ')
          ..write('heroAction: $heroAction, ')
          ..write('heroAmount: $heroAmount, ')
          ..write('bestAction: $bestAction, ')
          ..write('bestSizingBb: $bestSizingBb, ')
          ..write('verdict: $verdict, ')
          ..write('mismatch: $mismatch, ')
          ..write('evDeltaBb: $evDeltaBb, ')
          ..write('evDeltaDollars: $evDeltaDollars, ')
          ..write('villainName: $villainName, ')
          ..write('villainArchetype: $villainArchetype, ')
          ..write('adviceText: $adviceText, ')
          ..write('adviceSource: $adviceSource, ')
          ..write('aiRequestId: $aiRequestId, ')
          ..write('voicePlayed: $voicePlayed, ')
          ..write('voiceFromCache: $voiceFromCache, ')
          ..write('voiceUsedDevice: $voiceUsedDevice, ')
          ..write('gradedAtMs: $gradedAtMs, ')
          ..write('narratedAtMs: $narratedAtMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }
}

class $SettingsChangesTable extends SettingsChanges
    with TableInfo<$SettingsChangesTable, SettingsChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changedAtMsMeta = const VerificationMeta(
    'changedAtMs',
  );
  @override
  late final GeneratedColumn<int> changedAtMs = GeneratedColumn<int>(
    'changed_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    settingKey,
    oldValue,
    newValue,
    changedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('changed_at_ms')) {
      context.handle(
        _changedAtMsMeta,
        changedAtMs.isAcceptableOrUnknown(
          data['changed_at_ms']!,
          _changedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_changedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SettingsChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      changedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}changed_at_ms'],
      )!,
    );
  }

  @override
  $SettingsChangesTable createAlias(String alias) {
    return $SettingsChangesTable(attachedDatabase, alias);
  }
}

class SettingsChange extends DataClass implements Insertable<SettingsChange> {
  final int id;
  final int? sessionId;
  final String settingKey;
  final String? oldValue;
  final String? newValue;
  final int changedAtMs;
  const SettingsChange({
    required this.id,
    this.sessionId,
    required this.settingKey,
    this.oldValue,
    this.newValue,
    required this.changedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    map['setting_key'] = Variable<String>(settingKey);
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    map['changed_at_ms'] = Variable<int>(changedAtMs);
    return map;
  }

  SettingsChangesCompanion toCompanion(bool nullToAbsent) {
    return SettingsChangesCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      settingKey: Value(settingKey),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      changedAtMs: Value(changedAtMs),
    );
  }

  factory SettingsChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsChange(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      settingKey: serializer.fromJson<String>(json['settingKey']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      changedAtMs: serializer.fromJson<int>(json['changedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'settingKey': serializer.toJson<String>(settingKey),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'changedAtMs': serializer.toJson<int>(changedAtMs),
    };
  }

  SettingsChange copyWith({
    int? id,
    Value<int?> sessionId = const Value.absent(),
    String? settingKey,
    Value<String?> oldValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    int? changedAtMs,
  }) => SettingsChange(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    settingKey: settingKey ?? this.settingKey,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    changedAtMs: changedAtMs ?? this.changedAtMs,
  );
  SettingsChange copyWithCompanion(SettingsChangesCompanion data) {
    return SettingsChange(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      changedAtMs: data.changedAtMs.present
          ? data.changedAtMs.value
          : this.changedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsChange(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('settingKey: $settingKey, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('changedAtMs: $changedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sessionId, settingKey, oldValue, newValue, changedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsChange &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.settingKey == this.settingKey &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.changedAtMs == this.changedAtMs);
}

class SettingsChangesCompanion extends UpdateCompanion<SettingsChange> {
  final Value<int> id;
  final Value<int?> sessionId;
  final Value<String> settingKey;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<int> changedAtMs;
  const SettingsChangesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.settingKey = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.changedAtMs = const Value.absent(),
  });
  SettingsChangesCompanion.insert({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    required String settingKey,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    required int changedAtMs,
  }) : settingKey = Value(settingKey),
       changedAtMs = Value(changedAtMs);
  static Insertable<SettingsChange> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<String>? settingKey,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<int>? changedAtMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (settingKey != null) 'setting_key': settingKey,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (changedAtMs != null) 'changed_at_ms': changedAtMs,
    });
  }

  SettingsChangesCompanion copyWith({
    Value<int>? id,
    Value<int?>? sessionId,
    Value<String>? settingKey,
    Value<String?>? oldValue,
    Value<String?>? newValue,
    Value<int>? changedAtMs,
  }) {
    return SettingsChangesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      settingKey: settingKey ?? this.settingKey,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      changedAtMs: changedAtMs ?? this.changedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (changedAtMs.present) {
      map['changed_at_ms'] = Variable<int>(changedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsChangesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('settingKey: $settingKey, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('changedAtMs: $changedAtMs')
          ..write(')'))
        .toString();
  }
}

class $DiagnosticEventsTable extends DiagnosticEvents
    with TableInfo<$DiagnosticEventsTable, DiagnosticEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosticEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _handIdMeta = const VerificationMeta('handId');
  @override
  late final GeneratedColumn<int> handId = GeneratedColumn<int>(
    'hand_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('error'),
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stackTraceMeta = const VerificationMeta(
    'stackTrace',
  );
  @override
  late final GeneratedColumn<String> stackTrace = GeneratedColumn<String>(
    'stack_trace',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extraJsonMeta = const VerificationMeta(
    'extraJson',
  );
  @override
  late final GeneratedColumn<String> extraJson = GeneratedColumn<String>(
    'extra_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    handId,
    level,
    context,
    message,
    stackTrace,
    extraJson,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnostic_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiagnosticEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('hand_id')) {
      context.handle(
        _handIdMeta,
        handId.isAcceptableOrUnknown(data['hand_id']!, _handIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    } else if (isInserting) {
      context.missing(_contextMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('stack_trace')) {
      context.handle(
        _stackTraceMeta,
        stackTrace.isAcceptableOrUnknown(data['stack_trace']!, _stackTraceMeta),
      );
    }
    if (data.containsKey('extra_json')) {
      context.handle(
        _extraJsonMeta,
        extraJson.isAcceptableOrUnknown(data['extra_json']!, _extraJsonMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiagnosticEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiagnosticEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      ),
      handId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hand_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      stackTrace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stack_trace'],
      ),
      extraJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra_json'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $DiagnosticEventsTable createAlias(String alias) {
    return $DiagnosticEventsTable(attachedDatabase, alias);
  }
}

class DiagnosticEvent extends DataClass implements Insertable<DiagnosticEvent> {
  final int id;
  final int? sessionId;
  final int? handId;

  /// `error`, `warning`, `info`.
  final String level;

  /// Where it happened, e.g. `GeminiService.coach`, `SoundService.playFile`.
  final String context;
  final String message;

  /// Truncated stack trace.
  final String? stackTrace;

  /// Free-form JSON for extra fields.
  final String? extraJson;
  final int createdAtMs;
  const DiagnosticEvent({
    required this.id,
    this.sessionId,
    this.handId,
    required this.level,
    required this.context,
    required this.message,
    this.stackTrace,
    this.extraJson,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<int>(sessionId);
    }
    if (!nullToAbsent || handId != null) {
      map['hand_id'] = Variable<int>(handId);
    }
    map['level'] = Variable<String>(level);
    map['context'] = Variable<String>(context);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || stackTrace != null) {
      map['stack_trace'] = Variable<String>(stackTrace);
    }
    if (!nullToAbsent || extraJson != null) {
      map['extra_json'] = Variable<String>(extraJson);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  DiagnosticEventsCompanion toCompanion(bool nullToAbsent) {
    return DiagnosticEventsCompanion(
      id: Value(id),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      handId: handId == null && nullToAbsent
          ? const Value.absent()
          : Value(handId),
      level: Value(level),
      context: Value(context),
      message: Value(message),
      stackTrace: stackTrace == null && nullToAbsent
          ? const Value.absent()
          : Value(stackTrace),
      extraJson: extraJson == null && nullToAbsent
          ? const Value.absent()
          : Value(extraJson),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory DiagnosticEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiagnosticEvent(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int?>(json['sessionId']),
      handId: serializer.fromJson<int?>(json['handId']),
      level: serializer.fromJson<String>(json['level']),
      context: serializer.fromJson<String>(json['context']),
      message: serializer.fromJson<String>(json['message']),
      stackTrace: serializer.fromJson<String?>(json['stackTrace']),
      extraJson: serializer.fromJson<String?>(json['extraJson']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int?>(sessionId),
      'handId': serializer.toJson<int?>(handId),
      'level': serializer.toJson<String>(level),
      'context': serializer.toJson<String>(context),
      'message': serializer.toJson<String>(message),
      'stackTrace': serializer.toJson<String?>(stackTrace),
      'extraJson': serializer.toJson<String?>(extraJson),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  DiagnosticEvent copyWith({
    int? id,
    Value<int?> sessionId = const Value.absent(),
    Value<int?> handId = const Value.absent(),
    String? level,
    String? context,
    String? message,
    Value<String?> stackTrace = const Value.absent(),
    Value<String?> extraJson = const Value.absent(),
    int? createdAtMs,
  }) => DiagnosticEvent(
    id: id ?? this.id,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    handId: handId.present ? handId.value : this.handId,
    level: level ?? this.level,
    context: context ?? this.context,
    message: message ?? this.message,
    stackTrace: stackTrace.present ? stackTrace.value : this.stackTrace,
    extraJson: extraJson.present ? extraJson.value : this.extraJson,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  DiagnosticEvent copyWithCompanion(DiagnosticEventsCompanion data) {
    return DiagnosticEvent(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      handId: data.handId.present ? data.handId.value : this.handId,
      level: data.level.present ? data.level.value : this.level,
      context: data.context.present ? data.context.value : this.context,
      message: data.message.present ? data.message.value : this.message,
      stackTrace: data.stackTrace.present
          ? data.stackTrace.value
          : this.stackTrace,
      extraJson: data.extraJson.present ? data.extraJson.value : this.extraJson,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticEvent(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('handId: $handId, ')
          ..write('level: $level, ')
          ..write('context: $context, ')
          ..write('message: $message, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('extraJson: $extraJson, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    handId,
    level,
    context,
    message,
    stackTrace,
    extraJson,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagnosticEvent &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.handId == this.handId &&
          other.level == this.level &&
          other.context == this.context &&
          other.message == this.message &&
          other.stackTrace == this.stackTrace &&
          other.extraJson == this.extraJson &&
          other.createdAtMs == this.createdAtMs);
}

class DiagnosticEventsCompanion extends UpdateCompanion<DiagnosticEvent> {
  final Value<int> id;
  final Value<int?> sessionId;
  final Value<int?> handId;
  final Value<String> level;
  final Value<String> context;
  final Value<String> message;
  final Value<String?> stackTrace;
  final Value<String?> extraJson;
  final Value<int> createdAtMs;
  const DiagnosticEventsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.handId = const Value.absent(),
    this.level = const Value.absent(),
    this.context = const Value.absent(),
    this.message = const Value.absent(),
    this.stackTrace = const Value.absent(),
    this.extraJson = const Value.absent(),
    this.createdAtMs = const Value.absent(),
  });
  DiagnosticEventsCompanion.insert({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.handId = const Value.absent(),
    this.level = const Value.absent(),
    required String context,
    required String message,
    this.stackTrace = const Value.absent(),
    this.extraJson = const Value.absent(),
    required int createdAtMs,
  }) : context = Value(context),
       message = Value(message),
       createdAtMs = Value(createdAtMs);
  static Insertable<DiagnosticEvent> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? handId,
    Expression<String>? level,
    Expression<String>? context,
    Expression<String>? message,
    Expression<String>? stackTrace,
    Expression<String>? extraJson,
    Expression<int>? createdAtMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (handId != null) 'hand_id': handId,
      if (level != null) 'level': level,
      if (context != null) 'context': context,
      if (message != null) 'message': message,
      if (stackTrace != null) 'stack_trace': stackTrace,
      if (extraJson != null) 'extra_json': extraJson,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
    });
  }

  DiagnosticEventsCompanion copyWith({
    Value<int>? id,
    Value<int?>? sessionId,
    Value<int?>? handId,
    Value<String>? level,
    Value<String>? context,
    Value<String>? message,
    Value<String?>? stackTrace,
    Value<String?>? extraJson,
    Value<int>? createdAtMs,
  }) {
    return DiagnosticEventsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      handId: handId ?? this.handId,
      level: level ?? this.level,
      context: context ?? this.context,
      message: message ?? this.message,
      stackTrace: stackTrace ?? this.stackTrace,
      extraJson: extraJson ?? this.extraJson,
      createdAtMs: createdAtMs ?? this.createdAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (handId.present) {
      map['hand_id'] = Variable<int>(handId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (stackTrace.present) {
      map['stack_trace'] = Variable<String>(stackTrace.value);
    }
    if (extraJson.present) {
      map['extra_json'] = Variable<String>(extraJson.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosticEventsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('handId: $handId, ')
          ..write('level: $level, ')
          ..write('context: $context, ')
          ..write('message: $message, ')
          ..write('stackTrace: $stackTrace, ')
          ..write('extraJson: $extraJson, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScenariosTable scenarios = $ScenariosTable(this);
  late final $PlayedScenariosTable playedScenarios = $PlayedScenariosTable(
    this,
  );
  late final $UserStatsRowsTable userStatsRows = $UserStatsRowsTable(this);
  late final $MistakesTable mistakes = $MistakesTable(this);
  late final $ImprovementEventsTable improvementEvents =
      $ImprovementEventsTable(this);
  late final $AppSessionsTable appSessions = $AppSessionsTable(this);
  late final $AiRequestsTable aiRequests = $AiRequestsTable(this);
  late final $VoiceClipsTable voiceClips = $VoiceClipsTable(this);
  late final $HandsTable hands = $HandsTable(this);
  late final $HandActionsTable handActions = $HandActionsTable(this);
  late final $CoachDecisionsTable coachDecisions = $CoachDecisionsTable(this);
  late final $SettingsChangesTable settingsChanges = $SettingsChangesTable(
    this,
  );
  late final $DiagnosticEventsTable diagnosticEvents = $DiagnosticEventsTable(
    this,
  );
  late final Index idxAppSessionsStarted = Index(
    'idx_app_sessions_started',
    'CREATE INDEX idx_app_sessions_started ON app_sessions (started_at_ms)',
  );
  late final Index idxAiRequestsSession = Index(
    'idx_ai_requests_session',
    'CREATE INDEX idx_ai_requests_session ON ai_requests (session_id)',
  );
  late final Index idxAiRequestsCreated = Index(
    'idx_ai_requests_created',
    'CREATE INDEX idx_ai_requests_created ON ai_requests (created_at_ms)',
  );
  late final Index idxAiRequestsModel = Index(
    'idx_ai_requests_model',
    'CREATE INDEX idx_ai_requests_model ON ai_requests (model_id)',
  );
  late final Index idxAiRequestsKind = Index(
    'idx_ai_requests_kind',
    'CREATE INDEX idx_ai_requests_kind ON ai_requests (request_kind)',
  );
  late final Index idxVoiceClipsLastAccess = Index(
    'idx_voice_clips_last_access',
    'CREATE INDEX idx_voice_clips_last_access ON voice_clips (last_accessed_at_ms)',
  );
  late final Index idxVoiceClipsEvicted = Index(
    'idx_voice_clips_evicted',
    'CREATE INDEX idx_voice_clips_evicted ON voice_clips (evicted_at_ms)',
  );
  late final Index idxHandsSession = Index(
    'idx_hands_session',
    'CREATE INDEX idx_hands_session ON hands (session_id)',
  );
  late final Index idxHandsStarted = Index(
    'idx_hands_started',
    'CREATE INDEX idx_hands_started ON hands (started_at_ms)',
  );
  late final Index idxHandActionsHand = Index(
    'idx_hand_actions_hand',
    'CREATE INDEX idx_hand_actions_hand ON hand_actions (hand_id)',
  );
  late final Index idxCoachDecisionsHand = Index(
    'idx_coach_decisions_hand',
    'CREATE INDEX idx_coach_decisions_hand ON coach_decisions (hand_id)',
  );
  late final Index idxCoachDecisionsSession = Index(
    'idx_coach_decisions_session',
    'CREATE INDEX idx_coach_decisions_session ON coach_decisions (session_id)',
  );
  late final Index idxCoachDecisionsCreated = Index(
    'idx_coach_decisions_created',
    'CREATE INDEX idx_coach_decisions_created ON coach_decisions (created_at_ms)',
  );
  late final Index idxSettingsChangesChanged = Index(
    'idx_settings_changes_changed',
    'CREATE INDEX idx_settings_changes_changed ON settings_changes (changed_at_ms)',
  );
  late final Index idxDiagnosticEventsCreated = Index(
    'idx_diagnostic_events_created',
    'CREATE INDEX idx_diagnostic_events_created ON diagnostic_events (created_at_ms)',
  );
  late final Index idxDiagnosticEventsSession = Index(
    'idx_diagnostic_events_session',
    'CREATE INDEX idx_diagnostic_events_session ON diagnostic_events (session_id)',
  );
  late final Index idxDiagnosticEventsContext = Index(
    'idx_diagnostic_events_context',
    'CREATE INDEX idx_diagnostic_events_context ON diagnostic_events (context)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scenarios,
    playedScenarios,
    userStatsRows,
    mistakes,
    improvementEvents,
    appSessions,
    aiRequests,
    voiceClips,
    hands,
    handActions,
    coachDecisions,
    settingsChanges,
    diagnosticEvents,
    idxAppSessionsStarted,
    idxAiRequestsSession,
    idxAiRequestsCreated,
    idxAiRequestsModel,
    idxAiRequestsKind,
    idxVoiceClipsLastAccess,
    idxVoiceClipsEvicted,
    idxHandsSession,
    idxHandsStarted,
    idxHandActionsHand,
    idxCoachDecisionsHand,
    idxCoachDecisionsSession,
    idxCoachDecisionsCreated,
    idxSettingsChangesChanged,
    idxDiagnosticEventsCreated,
    idxDiagnosticEventsSession,
    idxDiagnosticEventsContext,
  ];
}

typedef $$ScenariosTableCreateCompanionBuilder = ScenariosCompanion Function({
  Value<int> id,
  required String contentHash,
  required String payloadJson,
  Value<DateTime> createdAt,
  Value<String> source,
  Value<String> modelId,
  Value<int?> generatedAtMs,
  Value<int?> lastUpdatedAtMs,
  Value<int> timesServed,
  Value<int?> lastServedAtMs,
  Value<int> payloadVersion,
});
typedef $$ScenariosTableUpdateCompanionBuilder = ScenariosCompanion Function({
  Value<int> id,
  Value<String> contentHash,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<String> source,
  Value<String> modelId,
  Value<int?> generatedAtMs,
  Value<int?> lastUpdatedAtMs,
  Value<int> timesServed,
  Value<int?> lastServedAtMs,
  Value<int> payloadVersion,
});

final class $$ScenariosTableReferences
    extends BaseReferences<_$AppDatabase, $ScenariosTable, Scenario> {
  $$ScenariosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlayedScenariosTable, List<PlayedScenario>>
  _playedScenariosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.playedScenarios,
    aliasName: 'scenarios__id__played_scenarios__scenario_id',
  );

  $$PlayedScenariosTableProcessedTableManager get playedScenariosRefs {
    final manager = $$PlayedScenariosTableTableManager(
      $_db,
      $_db.playedScenarios,
    ).filter((f) => f.scenarioId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _playedScenariosRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScenariosTableFilterComposer
    extends Composer<_$AppDatabase, $ScenariosTable> {
  $$ScenariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get generatedAtMs => $composableBuilder(
    column: $table.generatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastUpdatedAtMs => $composableBuilder(
    column: $table.lastUpdatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesServed => $composableBuilder(
    column: $table.timesServed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastServedAtMs => $composableBuilder(
    column: $table.lastServedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playedScenariosRefs(
    Expression<bool> Function($$PlayedScenariosTableFilterComposer f) f,
  ) {
    final $$PlayedScenariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playedScenarios,
      getReferencedColumn: (t) => t.scenarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayedScenariosTableFilterComposer(
            $db: $db,
            $table: $db.playedScenarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScenariosTableOrderingComposer
    extends Composer<_$AppDatabase, $ScenariosTable> {
  $$ScenariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get generatedAtMs => $composableBuilder(
    column: $table.generatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastUpdatedAtMs => $composableBuilder(
    column: $table.lastUpdatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesServed => $composableBuilder(
    column: $table.timesServed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastServedAtMs => $composableBuilder(
    column: $table.lastServedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScenariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScenariosTable> {
  $$ScenariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<int> get generatedAtMs => $composableBuilder(
    column: $table.generatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastUpdatedAtMs => $composableBuilder(
    column: $table.lastUpdatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timesServed => $composableBuilder(
    column: $table.timesServed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastServedAtMs => $composableBuilder(
    column: $table.lastServedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => column,
  );

  Expression<T> playedScenariosRefs<T extends Object>(
    Expression<T> Function($$PlayedScenariosTableAnnotationComposer a) f,
  ) {
    final $$PlayedScenariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playedScenarios,
      getReferencedColumn: (t) => t.scenarioId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlayedScenariosTableAnnotationComposer(
            $db: $db,
            $table: $db.playedScenarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ScenariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScenariosTable,
          Scenario,
          $$ScenariosTableFilterComposer,
          $$ScenariosTableOrderingComposer,
          $$ScenariosTableAnnotationComposer,
          $$ScenariosTableCreateCompanionBuilder,
          $$ScenariosTableUpdateCompanionBuilder,
          (Scenario, $$ScenariosTableReferences),
          Scenario,
          PrefetchHooks Function({bool playedScenariosRefs})
        > {
  $$ScenariosTableTableManager(_$AppDatabase db, $ScenariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScenariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScenariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScenariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<int?> generatedAtMs = const Value.absent(),
                Value<int?> lastUpdatedAtMs = const Value.absent(),
                Value<int> timesServed = const Value.absent(),
                Value<int?> lastServedAtMs = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
              }) => ScenariosCompanion(
                id: id,
                contentHash: contentHash,
                payloadJson: payloadJson,
                createdAt: createdAt,
                source: source,
                modelId: modelId,
                generatedAtMs: generatedAtMs,
                lastUpdatedAtMs: lastUpdatedAtMs,
                timesServed: timesServed,
                lastServedAtMs: lastServedAtMs,
                payloadVersion: payloadVersion,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contentHash,
                required String payloadJson,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<int?> generatedAtMs = const Value.absent(),
                Value<int?> lastUpdatedAtMs = const Value.absent(),
                Value<int> timesServed = const Value.absent(),
                Value<int?> lastServedAtMs = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
              }) => ScenariosCompanion.insert(
                id: id,
                contentHash: contentHash,
                payloadJson: payloadJson,
                createdAt: createdAt,
                source: source,
                modelId: modelId,
                generatedAtMs: generatedAtMs,
                lastUpdatedAtMs: lastUpdatedAtMs,
                timesServed: timesServed,
                lastServedAtMs: lastServedAtMs,
                payloadVersion: payloadVersion,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScenariosTable, Scenario>(table),
                  $$ScenariosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playedScenariosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playedScenariosRefs) db.playedScenarios,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playedScenariosRefs)
                    await $_getPrefetchedData<
                      Scenario,
                      $ScenariosTable,
                      PlayedScenario
                    >(
                      currentTable: table,
                      referencedTable: $$ScenariosTableReferences
                          ._playedScenariosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ScenariosTableReferences(
                            db,
                            table,
                            p0,
                          ).playedScenariosRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.scenarioId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ScenariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScenariosTable,
      Scenario,
      $$ScenariosTableFilterComposer,
      $$ScenariosTableOrderingComposer,
      $$ScenariosTableAnnotationComposer,
      $$ScenariosTableCreateCompanionBuilder,
      $$ScenariosTableUpdateCompanionBuilder,
      (Scenario, $$ScenariosTableReferences),
      Scenario,
      PrefetchHooks Function({bool playedScenariosRefs})
    >;
typedef $$PlayedScenariosTableCreateCompanionBuilder =
    PlayedScenariosCompanion Function({
      Value<int> id,
      required String userId,
      required int scenarioId,
      Value<DateTime> playedAt,
      Value<bool> wasCorrect,
      Value<double> evDeltaBb,
      Value<String> street,
      Value<String> archetype,
    });
typedef $$PlayedScenariosTableUpdateCompanionBuilder =
    PlayedScenariosCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<int> scenarioId,
      Value<DateTime> playedAt,
      Value<bool> wasCorrect,
      Value<double> evDeltaBb,
      Value<String> street,
      Value<String> archetype,
    });

final class $$PlayedScenariosTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlayedScenariosTable, PlayedScenario> {
  $$PlayedScenariosTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScenariosTable _scenarioIdTable(_$AppDatabase db) =>
      db.scenarios.createAlias('played_scenarios__scenario_id__scenarios__id');

  $$ScenariosTableProcessedTableManager get scenarioId {
    final $_column = $_itemColumn<int>('scenario_id')!;

    final manager = $$ScenariosTableTableManager(
      $_db,
      $_db.scenarios,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scenarioIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlayedScenariosTableFilterComposer
    extends Composer<_$AppDatabase, $PlayedScenariosTable> {
  $$PlayedScenariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasCorrect => $composableBuilder(
    column: $table.wasCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get evDeltaBb => $composableBuilder(
    column: $table.evDeltaBb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnFilters(column),
  );

  $$ScenariosTableFilterComposer get scenarioId {
    final $$ScenariosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scenarioId,
      referencedTable: $db.scenarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenariosTableFilterComposer(
            $db: $db,
            $table: $db.scenarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayedScenariosTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayedScenariosTable> {
  $$PlayedScenariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasCorrect => $composableBuilder(
    column: $table.wasCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get evDeltaBb => $composableBuilder(
    column: $table.evDeltaBb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScenariosTableOrderingComposer get scenarioId {
    final $$ScenariosTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scenarioId,
      referencedTable: $db.scenarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenariosTableOrderingComposer(
            $db: $db,
            $table: $db.scenarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayedScenariosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayedScenariosTable> {
  $$PlayedScenariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<bool> get wasCorrect => $composableBuilder(
    column: $table.wasCorrect,
    builder: (column) => column,
  );

  GeneratedColumn<double> get evDeltaBb =>
      $composableBuilder(column: $table.evDeltaBb, builder: (column) => column);

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get archetype =>
      $composableBuilder(column: $table.archetype, builder: (column) => column);

  $$ScenariosTableAnnotationComposer get scenarioId {
    final $$ScenariosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scenarioId,
      referencedTable: $db.scenarios,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScenariosTableAnnotationComposer(
            $db: $db,
            $table: $db.scenarios,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlayedScenariosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayedScenariosTable,
          PlayedScenario,
          $$PlayedScenariosTableFilterComposer,
          $$PlayedScenariosTableOrderingComposer,
          $$PlayedScenariosTableAnnotationComposer,
          $$PlayedScenariosTableCreateCompanionBuilder,
          $$PlayedScenariosTableUpdateCompanionBuilder,
          (PlayedScenario, $$PlayedScenariosTableReferences),
          PlayedScenario,
          PrefetchHooks Function({bool scenarioId})
        > {
  $$PlayedScenariosTableTableManager(
    _$AppDatabase db,
    $PlayedScenariosTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayedScenariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayedScenariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayedScenariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> scenarioId = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<bool> wasCorrect = const Value.absent(),
                Value<double> evDeltaBb = const Value.absent(),
                Value<String> street = const Value.absent(),
                Value<String> archetype = const Value.absent(),
              }) => PlayedScenariosCompanion(
                id: id,
                userId: userId,
                scenarioId: scenarioId,
                playedAt: playedAt,
                wasCorrect: wasCorrect,
                evDeltaBb: evDeltaBb,
                street: street,
                archetype: archetype,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String userId,
                required int scenarioId,
                Value<DateTime> playedAt = const Value.absent(),
                Value<bool> wasCorrect = const Value.absent(),
                Value<double> evDeltaBb = const Value.absent(),
                Value<String> street = const Value.absent(),
                Value<String> archetype = const Value.absent(),
              }) => PlayedScenariosCompanion.insert(
                id: id,
                userId: userId,
                scenarioId: scenarioId,
                playedAt: playedAt,
                wasCorrect: wasCorrect,
                evDeltaBb: evDeltaBb,
                street: street,
                archetype: archetype,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayedScenariosTable, PlayedScenario>(table),
                  $$PlayedScenariosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({scenarioId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (scenarioId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.scenarioId,
                        referencedTable: $$PlayedScenariosTableReferences
                            ._scenarioIdTable(db),
                        referencedColumn: $$PlayedScenariosTableReferences
                            ._scenarioIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlayedScenariosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayedScenariosTable,
      PlayedScenario,
      $$PlayedScenariosTableFilterComposer,
      $$PlayedScenariosTableOrderingComposer,
      $$PlayedScenariosTableAnnotationComposer,
      $$PlayedScenariosTableCreateCompanionBuilder,
      $$PlayedScenariosTableUpdateCompanionBuilder,
      (PlayedScenario, $$PlayedScenariosTableReferences),
      PlayedScenario,
      PrefetchHooks Function({bool scenarioId})
    >;
typedef $$UserStatsRowsTableCreateCompanionBuilder =
    UserStatsRowsCompanion Function({
      required String userId,
      Value<int> totalSpots,
      Value<int> correctSpots,
      Value<double> netEvBb,
      Value<String> archetypeJson,
      Value<String> streetJson,
      Value<String> recentEvJson,
      Value<int> rowid,
    });
typedef $$UserStatsRowsTableUpdateCompanionBuilder =
    UserStatsRowsCompanion Function({
      Value<String> userId,
      Value<int> totalSpots,
      Value<int> correctSpots,
      Value<double> netEvBb,
      Value<String> archetypeJson,
      Value<String> streetJson,
      Value<String> recentEvJson,
      Value<int> rowid,
    });

class $$UserStatsRowsTableFilterComposer
    extends Composer<_$AppDatabase, $UserStatsRowsTable> {
  $$UserStatsRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSpots => $composableBuilder(
    column: $table.totalSpots,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctSpots => $composableBuilder(
    column: $table.correctSpots,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netEvBb => $composableBuilder(
    column: $table.netEvBb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archetypeJson => $composableBuilder(
    column: $table.archetypeJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streetJson => $composableBuilder(
    column: $table.streetJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recentEvJson => $composableBuilder(
    column: $table.recentEvJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserStatsRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserStatsRowsTable> {
  $$UserStatsRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSpots => $composableBuilder(
    column: $table.totalSpots,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctSpots => $composableBuilder(
    column: $table.correctSpots,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netEvBb => $composableBuilder(
    column: $table.netEvBb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archetypeJson => $composableBuilder(
    column: $table.archetypeJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streetJson => $composableBuilder(
    column: $table.streetJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recentEvJson => $composableBuilder(
    column: $table.recentEvJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserStatsRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserStatsRowsTable> {
  $$UserStatsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get totalSpots => $composableBuilder(
    column: $table.totalSpots,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctSpots => $composableBuilder(
    column: $table.correctSpots,
    builder: (column) => column,
  );

  GeneratedColumn<double> get netEvBb =>
      $composableBuilder(column: $table.netEvBb, builder: (column) => column);

  GeneratedColumn<String> get archetypeJson => $composableBuilder(
    column: $table.archetypeJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get streetJson => $composableBuilder(
    column: $table.streetJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recentEvJson => $composableBuilder(
    column: $table.recentEvJson,
    builder: (column) => column,
  );
}

class $$UserStatsRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserStatsRowsTable,
          UserStatsRow,
          $$UserStatsRowsTableFilterComposer,
          $$UserStatsRowsTableOrderingComposer,
          $$UserStatsRowsTableAnnotationComposer,
          $$UserStatsRowsTableCreateCompanionBuilder,
          $$UserStatsRowsTableUpdateCompanionBuilder,
          (
            UserStatsRow,
            BaseReferences<_$AppDatabase, $UserStatsRowsTable, UserStatsRow>,
          ),
          UserStatsRow,
          PrefetchHooks Function()
        > {
  $$UserStatsRowsTableTableManager(_$AppDatabase db, $UserStatsRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserStatsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserStatsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserStatsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<int> totalSpots = const Value.absent(),
                Value<int> correctSpots = const Value.absent(),
                Value<double> netEvBb = const Value.absent(),
                Value<String> archetypeJson = const Value.absent(),
                Value<String> streetJson = const Value.absent(),
                Value<String> recentEvJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserStatsRowsCompanion(
                userId: userId,
                totalSpots: totalSpots,
                correctSpots: correctSpots,
                netEvBb: netEvBb,
                archetypeJson: archetypeJson,
                streetJson: streetJson,
                recentEvJson: recentEvJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<int> totalSpots = const Value.absent(),
                Value<int> correctSpots = const Value.absent(),
                Value<double> netEvBb = const Value.absent(),
                Value<String> archetypeJson = const Value.absent(),
                Value<String> streetJson = const Value.absent(),
                Value<String> recentEvJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserStatsRowsCompanion.insert(
                userId: userId,
                totalSpots: totalSpots,
                correctSpots: correctSpots,
                netEvBb: netEvBb,
                archetypeJson: archetypeJson,
                streetJson: streetJson,
                recentEvJson: recentEvJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserStatsRowsTable, UserStatsRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserStatsRowsTable,
                    UserStatsRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserStatsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserStatsRowsTable,
      UserStatsRow,
      $$UserStatsRowsTableFilterComposer,
      $$UserStatsRowsTableOrderingComposer,
      $$UserStatsRowsTableAnnotationComposer,
      $$UserStatsRowsTableCreateCompanionBuilder,
      $$UserStatsRowsTableUpdateCompanionBuilder,
      (
        UserStatsRow,
        BaseReferences<_$AppDatabase, $UserStatsRowsTable, UserStatsRow>,
      ),
      UserStatsRow,
      PrefetchHooks Function()
    >;
typedef $$MistakesTableCreateCompanionBuilder = MistakesCompanion Function({
  Value<int> id,
  Value<String> userId,
  required String sessionId,
  required String handId,
  Value<String?> decisionId,
  Value<DateTime> createdAt,
  required String street,
  required String villainArchetype,
  required String heroAction,
  Value<double> heroAmount,
  required String bestAction,
  Value<double> bestSizingBb,
  Value<double> evDeltaBb,
  Value<double> evDeltaDollars,
  required String mistakeKey,
  required String contextKey,
  required String primaryTag,
  Value<String> coarseTagsJson,
  Value<String> adviceText,
});
typedef $$MistakesTableUpdateCompanionBuilder = MistakesCompanion Function({
  Value<int> id,
  Value<String> userId,
  Value<String> sessionId,
  Value<String> handId,
  Value<String?> decisionId,
  Value<DateTime> createdAt,
  Value<String> street,
  Value<String> villainArchetype,
  Value<String> heroAction,
  Value<double> heroAmount,
  Value<String> bestAction,
  Value<double> bestSizingBb,
  Value<double> evDeltaBb,
  Value<double> evDeltaDollars,
  Value<String> mistakeKey,
  Value<String> contextKey,
  Value<String> primaryTag,
  Value<String> coarseTagsJson,
  Value<String> adviceText,
});

class $$MistakesTableFilterComposer
    extends Composer<_$AppDatabase, $MistakesTable> {
  $$MistakesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villainArchetype => $composableBuilder(
    column: $table.villainArchetype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroAction => $composableBuilder(
    column: $table.heroAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heroAmount => $composableBuilder(
    column: $table.heroAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bestAction => $composableBuilder(
    column: $table.bestAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bestSizingBb => $composableBuilder(
    column: $table.bestSizingBb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get evDeltaBb => $composableBuilder(
    column: $table.evDeltaBb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get evDeltaDollars => $composableBuilder(
    column: $table.evDeltaDollars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mistakeKey => $composableBuilder(
    column: $table.mistakeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryTag => $composableBuilder(
    column: $table.primaryTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coarseTagsJson => $composableBuilder(
    column: $table.coarseTagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adviceText => $composableBuilder(
    column: $table.adviceText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MistakesTableOrderingComposer
    extends Composer<_$AppDatabase, $MistakesTable> {
  $$MistakesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villainArchetype => $composableBuilder(
    column: $table.villainArchetype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroAction => $composableBuilder(
    column: $table.heroAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heroAmount => $composableBuilder(
    column: $table.heroAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bestAction => $composableBuilder(
    column: $table.bestAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bestSizingBb => $composableBuilder(
    column: $table.bestSizingBb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get evDeltaBb => $composableBuilder(
    column: $table.evDeltaBb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get evDeltaDollars => $composableBuilder(
    column: $table.evDeltaDollars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mistakeKey => $composableBuilder(
    column: $table.mistakeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryTag => $composableBuilder(
    column: $table.primaryTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coarseTagsJson => $composableBuilder(
    column: $table.coarseTagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adviceText => $composableBuilder(
    column: $table.adviceText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MistakesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MistakesTable> {
  $$MistakesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get handId =>
      $composableBuilder(column: $table.handId, builder: (column) => column);

  GeneratedColumn<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get villainArchetype => $composableBuilder(
    column: $table.villainArchetype,
    builder: (column) => column,
  );

  GeneratedColumn<String> get heroAction => $composableBuilder(
    column: $table.heroAction,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heroAmount => $composableBuilder(
    column: $table.heroAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bestAction => $composableBuilder(
    column: $table.bestAction,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bestSizingBb => $composableBuilder(
    column: $table.bestSizingBb,
    builder: (column) => column,
  );

  GeneratedColumn<double> get evDeltaBb =>
      $composableBuilder(column: $table.evDeltaBb, builder: (column) => column);

  GeneratedColumn<double> get evDeltaDollars => $composableBuilder(
    column: $table.evDeltaDollars,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mistakeKey => $composableBuilder(
    column: $table.mistakeKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextKey => $composableBuilder(
    column: $table.contextKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryTag => $composableBuilder(
    column: $table.primaryTag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coarseTagsJson => $composableBuilder(
    column: $table.coarseTagsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adviceText => $composableBuilder(
    column: $table.adviceText,
    builder: (column) => column,
  );
}

class $$MistakesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MistakesTable,
          Mistake,
          $$MistakesTableFilterComposer,
          $$MistakesTableOrderingComposer,
          $$MistakesTableAnnotationComposer,
          $$MistakesTableCreateCompanionBuilder,
          $$MistakesTableUpdateCompanionBuilder,
          (Mistake, BaseReferences<_$AppDatabase, $MistakesTable, Mistake>),
          Mistake,
          PrefetchHooks Function()
        > {
  $$MistakesTableTableManager(_$AppDatabase db, $MistakesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MistakesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MistakesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MistakesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> handId = const Value.absent(),
                Value<String?> decisionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> street = const Value.absent(),
                Value<String> villainArchetype = const Value.absent(),
                Value<String> heroAction = const Value.absent(),
                Value<double> heroAmount = const Value.absent(),
                Value<String> bestAction = const Value.absent(),
                Value<double> bestSizingBb = const Value.absent(),
                Value<double> evDeltaBb = const Value.absent(),
                Value<double> evDeltaDollars = const Value.absent(),
                Value<String> mistakeKey = const Value.absent(),
                Value<String> contextKey = const Value.absent(),
                Value<String> primaryTag = const Value.absent(),
                Value<String> coarseTagsJson = const Value.absent(),
                Value<String> adviceText = const Value.absent(),
              }) => MistakesCompanion(
                id: id,
                userId: userId,
                sessionId: sessionId,
                handId: handId,
                decisionId: decisionId,
                createdAt: createdAt,
                street: street,
                villainArchetype: villainArchetype,
                heroAction: heroAction,
                heroAmount: heroAmount,
                bestAction: bestAction,
                bestSizingBb: bestSizingBb,
                evDeltaBb: evDeltaBb,
                evDeltaDollars: evDeltaDollars,
                mistakeKey: mistakeKey,
                contextKey: contextKey,
                primaryTag: primaryTag,
                coarseTagsJson: coarseTagsJson,
                adviceText: adviceText,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                required String sessionId,
                required String handId,
                Value<String?> decisionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String street,
                required String villainArchetype,
                required String heroAction,
                Value<double> heroAmount = const Value.absent(),
                required String bestAction,
                Value<double> bestSizingBb = const Value.absent(),
                Value<double> evDeltaBb = const Value.absent(),
                Value<double> evDeltaDollars = const Value.absent(),
                required String mistakeKey,
                required String contextKey,
                required String primaryTag,
                Value<String> coarseTagsJson = const Value.absent(),
                Value<String> adviceText = const Value.absent(),
              }) => MistakesCompanion.insert(
                id: id,
                userId: userId,
                sessionId: sessionId,
                handId: handId,
                decisionId: decisionId,
                createdAt: createdAt,
                street: street,
                villainArchetype: villainArchetype,
                heroAction: heroAction,
                heroAmount: heroAmount,
                bestAction: bestAction,
                bestSizingBb: bestSizingBb,
                evDeltaBb: evDeltaBb,
                evDeltaDollars: evDeltaDollars,
                mistakeKey: mistakeKey,
                contextKey: contextKey,
                primaryTag: primaryTag,
                coarseTagsJson: coarseTagsJson,
                adviceText: adviceText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MistakesTable, Mistake>(table),
                  BaseReferences<_$AppDatabase, $MistakesTable, Mistake>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MistakesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MistakesTable,
      Mistake,
      $$MistakesTableFilterComposer,
      $$MistakesTableOrderingComposer,
      $$MistakesTableAnnotationComposer,
      $$MistakesTableCreateCompanionBuilder,
      $$MistakesTableUpdateCompanionBuilder,
      (Mistake, BaseReferences<_$AppDatabase, $MistakesTable, Mistake>),
      Mistake,
      PrefetchHooks Function()
    >;
typedef $$ImprovementEventsTableCreateCompanionBuilder =
    ImprovementEventsCompanion Function({
      Value<int> id,
      Value<String> userId,
      required String sessionId,
      required String handId,
      Value<String?> decisionId,
      Value<DateTime> createdAt,
      required String mistakeKey,
      required String primaryTag,
      required String street,
      required String villainArchetype,
      required String heroAction,
      Value<int> streak,
    });
typedef $$ImprovementEventsTableUpdateCompanionBuilder =
    ImprovementEventsCompanion Function({
      Value<int> id,
      Value<String> userId,
      Value<String> sessionId,
      Value<String> handId,
      Value<String?> decisionId,
      Value<DateTime> createdAt,
      Value<String> mistakeKey,
      Value<String> primaryTag,
      Value<String> street,
      Value<String> villainArchetype,
      Value<String> heroAction,
      Value<int> streak,
    });

class $$ImprovementEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ImprovementEventsTable> {
  $$ImprovementEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mistakeKey => $composableBuilder(
    column: $table.mistakeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryTag => $composableBuilder(
    column: $table.primaryTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villainArchetype => $composableBuilder(
    column: $table.villainArchetype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroAction => $composableBuilder(
    column: $table.heroAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ImprovementEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImprovementEventsTable> {
  $$ImprovementEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mistakeKey => $composableBuilder(
    column: $table.mistakeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryTag => $composableBuilder(
    column: $table.primaryTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villainArchetype => $composableBuilder(
    column: $table.villainArchetype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroAction => $composableBuilder(
    column: $table.heroAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streak => $composableBuilder(
    column: $table.streak,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ImprovementEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImprovementEventsTable> {
  $$ImprovementEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get handId =>
      $composableBuilder(column: $table.handId, builder: (column) => column);

  GeneratedColumn<String> get decisionId => $composableBuilder(
    column: $table.decisionId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get mistakeKey => $composableBuilder(
    column: $table.mistakeKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryTag => $composableBuilder(
    column: $table.primaryTag,
    builder: (column) => column,
  );

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get villainArchetype => $composableBuilder(
    column: $table.villainArchetype,
    builder: (column) => column,
  );

  GeneratedColumn<String> get heroAction => $composableBuilder(
    column: $table.heroAction,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streak =>
      $composableBuilder(column: $table.streak, builder: (column) => column);
}

class $$ImprovementEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImprovementEventsTable,
          ImprovementEvent,
          $$ImprovementEventsTableFilterComposer,
          $$ImprovementEventsTableOrderingComposer,
          $$ImprovementEventsTableAnnotationComposer,
          $$ImprovementEventsTableCreateCompanionBuilder,
          $$ImprovementEventsTableUpdateCompanionBuilder,
          (
            ImprovementEvent,
            BaseReferences<
              _$AppDatabase,
              $ImprovementEventsTable,
              ImprovementEvent
            >,
          ),
          ImprovementEvent,
          PrefetchHooks Function()
        > {
  $$ImprovementEventsTableTableManager(
    _$AppDatabase db,
    $ImprovementEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImprovementEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImprovementEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImprovementEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> handId = const Value.absent(),
                Value<String?> decisionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> mistakeKey = const Value.absent(),
                Value<String> primaryTag = const Value.absent(),
                Value<String> street = const Value.absent(),
                Value<String> villainArchetype = const Value.absent(),
                Value<String> heroAction = const Value.absent(),
                Value<int> streak = const Value.absent(),
              }) => ImprovementEventsCompanion(
                id: id,
                userId: userId,
                sessionId: sessionId,
                handId: handId,
                decisionId: decisionId,
                createdAt: createdAt,
                mistakeKey: mistakeKey,
                primaryTag: primaryTag,
                street: street,
                villainArchetype: villainArchetype,
                heroAction: heroAction,
                streak: streak,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                required String sessionId,
                required String handId,
                Value<String?> decisionId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required String mistakeKey,
                required String primaryTag,
                required String street,
                required String villainArchetype,
                required String heroAction,
                Value<int> streak = const Value.absent(),
              }) => ImprovementEventsCompanion.insert(
                id: id,
                userId: userId,
                sessionId: sessionId,
                handId: handId,
                decisionId: decisionId,
                createdAt: createdAt,
                mistakeKey: mistakeKey,
                primaryTag: primaryTag,
                street: street,
                villainArchetype: villainArchetype,
                heroAction: heroAction,
                streak: streak,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ImprovementEventsTable, ImprovementEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ImprovementEventsTable,
                    ImprovementEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ImprovementEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImprovementEventsTable,
      ImprovementEvent,
      $$ImprovementEventsTableFilterComposer,
      $$ImprovementEventsTableOrderingComposer,
      $$ImprovementEventsTableAnnotationComposer,
      $$ImprovementEventsTableCreateCompanionBuilder,
      $$ImprovementEventsTableUpdateCompanionBuilder,
      (
        ImprovementEvent,
        BaseReferences<
          _$AppDatabase,
          $ImprovementEventsTable,
          ImprovementEvent
        >,
      ),
      ImprovementEvent,
      PrefetchHooks Function()
    >;
typedef $$AppSessionsTableCreateCompanionBuilder =
    AppSessionsCompanion Function({
      Value<int> id,
      required String sessionUuid,
      required int startedAtMs,
      required int lastSeenAtMs,
      Value<int?> endedAtMs,
      Value<String> appVersion,
      Value<String> buildNumber,
      Value<String> platform,
      Value<String> osVersion,
      Value<bool> isDebugBuild,
      Value<int> schemaVersion,
      required int createdAtMs,
      required int updatedAtMs,
    });
typedef $$AppSessionsTableUpdateCompanionBuilder =
    AppSessionsCompanion Function({
      Value<int> id,
      Value<String> sessionUuid,
      Value<int> startedAtMs,
      Value<int> lastSeenAtMs,
      Value<int?> endedAtMs,
      Value<String> appVersion,
      Value<String> buildNumber,
      Value<String> platform,
      Value<String> osVersion,
      Value<bool> isDebugBuild,
      Value<int> schemaVersion,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
    });

class $$AppSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSessionsTable> {
  $$AppSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeenAtMs => $composableBuilder(
    column: $table.lastSeenAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buildNumber => $composableBuilder(
    column: $table.buildNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get osVersion => $composableBuilder(
    column: $table.osVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDebugBuild => $composableBuilder(
    column: $table.isDebugBuild,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSessionsTable> {
  $$AppSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeenAtMs => $composableBuilder(
    column: $table.lastSeenAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buildNumber => $composableBuilder(
    column: $table.buildNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get osVersion => $composableBuilder(
    column: $table.osVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDebugBuild => $composableBuilder(
    column: $table.isDebugBuild,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSessionsTable> {
  $$AppSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionUuid => $composableBuilder(
    column: $table.sessionUuid,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSeenAtMs => $composableBuilder(
    column: $table.lastSeenAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAtMs =>
      $composableBuilder(column: $table.endedAtMs, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get buildNumber => $composableBuilder(
    column: $table.buildNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get osVersion =>
      $composableBuilder(column: $table.osVersion, builder: (column) => column);

  GeneratedColumn<bool> get isDebugBuild => $composableBuilder(
    column: $table.isDebugBuild,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$AppSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSessionsTable,
          AppSession,
          $$AppSessionsTableFilterComposer,
          $$AppSessionsTableOrderingComposer,
          $$AppSessionsTableAnnotationComposer,
          $$AppSessionsTableCreateCompanionBuilder,
          $$AppSessionsTableUpdateCompanionBuilder,
          (
            AppSession,
            BaseReferences<_$AppDatabase, $AppSessionsTable, AppSession>,
          ),
          AppSession,
          PrefetchHooks Function()
        > {
  $$AppSessionsTableTableManager(_$AppDatabase db, $AppSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionUuid = const Value.absent(),
                Value<int> startedAtMs = const Value.absent(),
                Value<int> lastSeenAtMs = const Value.absent(),
                Value<int?> endedAtMs = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<String> buildNumber = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> osVersion = const Value.absent(),
                Value<bool> isDebugBuild = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
              }) => AppSessionsCompanion(
                id: id,
                sessionUuid: sessionUuid,
                startedAtMs: startedAtMs,
                lastSeenAtMs: lastSeenAtMs,
                endedAtMs: endedAtMs,
                appVersion: appVersion,
                buildNumber: buildNumber,
                platform: platform,
                osVersion: osVersion,
                isDebugBuild: isDebugBuild,
                schemaVersion: schemaVersion,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionUuid,
                required int startedAtMs,
                required int lastSeenAtMs,
                Value<int?> endedAtMs = const Value.absent(),
                Value<String> appVersion = const Value.absent(),
                Value<String> buildNumber = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> osVersion = const Value.absent(),
                Value<bool> isDebugBuild = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
              }) => AppSessionsCompanion.insert(
                id: id,
                sessionUuid: sessionUuid,
                startedAtMs: startedAtMs,
                lastSeenAtMs: lastSeenAtMs,
                endedAtMs: endedAtMs,
                appVersion: appVersion,
                buildNumber: buildNumber,
                platform: platform,
                osVersion: osVersion,
                isDebugBuild: isDebugBuild,
                schemaVersion: schemaVersion,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSessionsTable, AppSession>(table),
                  BaseReferences<_$AppDatabase, $AppSessionsTable, AppSession>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSessionsTable,
      AppSession,
      $$AppSessionsTableFilterComposer,
      $$AppSessionsTableOrderingComposer,
      $$AppSessionsTableAnnotationComposer,
      $$AppSessionsTableCreateCompanionBuilder,
      $$AppSessionsTableUpdateCompanionBuilder,
      (
        AppSession,
        BaseReferences<_$AppDatabase, $AppSessionsTable, AppSession>,
      ),
      AppSession,
      PrefetchHooks Function()
    >;
typedef $$AiRequestsTableCreateCompanionBuilder = AiRequestsCompanion Function({
  Value<int> id,
  Value<int?> sessionId,
  Value<int?> handId,
  required String requestKind,
  required String modelId,
  Value<String> systemInstructionHash,
  required String promptHash,
  required String promptText,
  Value<Uint8List?> promptFull,
  required int requestedAtMs,
  Value<int?> respondedAtMs,
  Value<int?> latencyMs,
  Value<int?> httpStatus,
  required bool success,
  Value<String?> errorMessage,
  Value<int?> promptTokens,
  Value<int?> responseTokens,
  Value<int?> totalTokens,
  Value<String?> responseText,
  Value<int?> responseBytes,
  Value<int> attempt,
  Value<bool> fromCache,
  required int createdAtMs,
});
typedef $$AiRequestsTableUpdateCompanionBuilder = AiRequestsCompanion Function({
  Value<int> id,
  Value<int?> sessionId,
  Value<int?> handId,
  Value<String> requestKind,
  Value<String> modelId,
  Value<String> systemInstructionHash,
  Value<String> promptHash,
  Value<String> promptText,
  Value<Uint8List?> promptFull,
  Value<int> requestedAtMs,
  Value<int?> respondedAtMs,
  Value<int?> latencyMs,
  Value<int?> httpStatus,
  Value<bool> success,
  Value<String?> errorMessage,
  Value<int?> promptTokens,
  Value<int?> responseTokens,
  Value<int?> totalTokens,
  Value<String?> responseText,
  Value<int?> responseBytes,
  Value<int> attempt,
  Value<bool> fromCache,
  Value<int> createdAtMs,
});

class $$AiRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $AiRequestsTable> {
  $$AiRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestKind => $composableBuilder(
    column: $table.requestKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get systemInstructionHash => $composableBuilder(
    column: $table.systemInstructionHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptHash => $composableBuilder(
    column: $table.promptHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptText => $composableBuilder(
    column: $table.promptText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get promptFull => $composableBuilder(
    column: $table.promptFull,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestedAtMs => $composableBuilder(
    column: $table.requestedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get respondedAtMs => $composableBuilder(
    column: $table.respondedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responseTokens => $composableBuilder(
    column: $table.responseTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalTokens => $composableBuilder(
    column: $table.totalTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responseText => $composableBuilder(
    column: $table.responseText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responseBytes => $composableBuilder(
    column: $table.responseBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fromCache => $composableBuilder(
    column: $table.fromCache,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiRequestsTable> {
  $$AiRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestKind => $composableBuilder(
    column: $table.requestKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get systemInstructionHash => $composableBuilder(
    column: $table.systemInstructionHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptHash => $composableBuilder(
    column: $table.promptHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptText => $composableBuilder(
    column: $table.promptText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get promptFull => $composableBuilder(
    column: $table.promptFull,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestedAtMs => $composableBuilder(
    column: $table.requestedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get respondedAtMs => $composableBuilder(
    column: $table.respondedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get latencyMs => $composableBuilder(
    column: $table.latencyMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseTokens => $composableBuilder(
    column: $table.responseTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalTokens => $composableBuilder(
    column: $table.totalTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responseText => $composableBuilder(
    column: $table.responseText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseBytes => $composableBuilder(
    column: $table.responseBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fromCache => $composableBuilder(
    column: $table.fromCache,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiRequestsTable> {
  $$AiRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get handId =>
      $composableBuilder(column: $table.handId, builder: (column) => column);

  GeneratedColumn<String> get requestKind => $composableBuilder(
    column: $table.requestKind,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get systemInstructionHash => $composableBuilder(
    column: $table.systemInstructionHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get promptHash => $composableBuilder(
    column: $table.promptHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get promptText => $composableBuilder(
    column: $table.promptText,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get promptFull => $composableBuilder(
    column: $table.promptFull,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestedAtMs => $composableBuilder(
    column: $table.requestedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get respondedAtMs => $composableBuilder(
    column: $table.respondedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get latencyMs =>
      $composableBuilder(column: $table.latencyMs, builder: (column) => column);

  GeneratedColumn<int> get httpStatus => $composableBuilder(
    column: $table.httpStatus,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get promptTokens => $composableBuilder(
    column: $table.promptTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get responseTokens => $composableBuilder(
    column: $table.responseTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalTokens => $composableBuilder(
    column: $table.totalTokens,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responseText => $composableBuilder(
    column: $table.responseText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get responseBytes => $composableBuilder(
    column: $table.responseBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<bool> get fromCache =>
      $composableBuilder(column: $table.fromCache, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$AiRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiRequestsTable,
          AiRequest,
          $$AiRequestsTableFilterComposer,
          $$AiRequestsTableOrderingComposer,
          $$AiRequestsTableAnnotationComposer,
          $$AiRequestsTableCreateCompanionBuilder,
          $$AiRequestsTableUpdateCompanionBuilder,
          (
            AiRequest,
            BaseReferences<_$AppDatabase, $AiRequestsTable, AiRequest>,
          ),
          AiRequest,
          PrefetchHooks Function()
        > {
  $$AiRequestsTableTableManager(_$AppDatabase db, $AiRequestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int?> handId = const Value.absent(),
                Value<String> requestKind = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> systemInstructionHash = const Value.absent(),
                Value<String> promptHash = const Value.absent(),
                Value<String> promptText = const Value.absent(),
                Value<Uint8List?> promptFull = const Value.absent(),
                Value<int> requestedAtMs = const Value.absent(),
                Value<int?> respondedAtMs = const Value.absent(),
                Value<int?> latencyMs = const Value.absent(),
                Value<int?> httpStatus = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> promptTokens = const Value.absent(),
                Value<int?> responseTokens = const Value.absent(),
                Value<int?> totalTokens = const Value.absent(),
                Value<String?> responseText = const Value.absent(),
                Value<int?> responseBytes = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<bool> fromCache = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
              }) => AiRequestsCompanion(
                id: id,
                sessionId: sessionId,
                handId: handId,
                requestKind: requestKind,
                modelId: modelId,
                systemInstructionHash: systemInstructionHash,
                promptHash: promptHash,
                promptText: promptText,
                promptFull: promptFull,
                requestedAtMs: requestedAtMs,
                respondedAtMs: respondedAtMs,
                latencyMs: latencyMs,
                httpStatus: httpStatus,
                success: success,
                errorMessage: errorMessage,
                promptTokens: promptTokens,
                responseTokens: responseTokens,
                totalTokens: totalTokens,
                responseText: responseText,
                responseBytes: responseBytes,
                attempt: attempt,
                fromCache: fromCache,
                createdAtMs: createdAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int?> handId = const Value.absent(),
                required String requestKind,
                required String modelId,
                Value<String> systemInstructionHash = const Value.absent(),
                required String promptHash,
                required String promptText,
                Value<Uint8List?> promptFull = const Value.absent(),
                required int requestedAtMs,
                Value<int?> respondedAtMs = const Value.absent(),
                Value<int?> latencyMs = const Value.absent(),
                Value<int?> httpStatus = const Value.absent(),
                required bool success,
                Value<String?> errorMessage = const Value.absent(),
                Value<int?> promptTokens = const Value.absent(),
                Value<int?> responseTokens = const Value.absent(),
                Value<int?> totalTokens = const Value.absent(),
                Value<String?> responseText = const Value.absent(),
                Value<int?> responseBytes = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<bool> fromCache = const Value.absent(),
                required int createdAtMs,
              }) => AiRequestsCompanion.insert(
                id: id,
                sessionId: sessionId,
                handId: handId,
                requestKind: requestKind,
                modelId: modelId,
                systemInstructionHash: systemInstructionHash,
                promptHash: promptHash,
                promptText: promptText,
                promptFull: promptFull,
                requestedAtMs: requestedAtMs,
                respondedAtMs: respondedAtMs,
                latencyMs: latencyMs,
                httpStatus: httpStatus,
                success: success,
                errorMessage: errorMessage,
                promptTokens: promptTokens,
                responseTokens: responseTokens,
                totalTokens: totalTokens,
                responseText: responseText,
                responseBytes: responseBytes,
                attempt: attempt,
                fromCache: fromCache,
                createdAtMs: createdAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AiRequestsTable, AiRequest>(table),
                  BaseReferences<_$AppDatabase, $AiRequestsTable, AiRequest>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiRequestsTable,
      AiRequest,
      $$AiRequestsTableFilterComposer,
      $$AiRequestsTableOrderingComposer,
      $$AiRequestsTableAnnotationComposer,
      $$AiRequestsTableCreateCompanionBuilder,
      $$AiRequestsTableUpdateCompanionBuilder,
      (AiRequest, BaseReferences<_$AppDatabase, $AiRequestsTable, AiRequest>),
      AiRequest,
      PrefetchHooks Function()
    >;
typedef $$VoiceClipsTableCreateCompanionBuilder = VoiceClipsCompanion Function({
  Value<int> id,
  required String cacheKey,
  required String spokenText,
  required String voice,
  required String modelId,
  Value<String> mimeType,
  required int byteSize,
  Value<String?> filePath,
  Value<Uint8List?> audioBlob,
  required int createdAtMs,
  required int lastAccessedAtMs,
  Value<int> hitCount,
  required int expiresAtMs,
  Value<int?> evictedAtMs,
  Value<String?> evictionReason,
  required int updatedAtMs,
});
typedef $$VoiceClipsTableUpdateCompanionBuilder = VoiceClipsCompanion Function({
  Value<int> id,
  Value<String> cacheKey,
  Value<String> spokenText,
  Value<String> voice,
  Value<String> modelId,
  Value<String> mimeType,
  Value<int> byteSize,
  Value<String?> filePath,
  Value<Uint8List?> audioBlob,
  Value<int> createdAtMs,
  Value<int> lastAccessedAtMs,
  Value<int> hitCount,
  Value<int> expiresAtMs,
  Value<int?> evictedAtMs,
  Value<String?> evictionReason,
  Value<int> updatedAtMs,
});

class $$VoiceClipsTableFilterComposer
    extends Composer<_$AppDatabase, $VoiceClipsTable> {
  $$VoiceClipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spokenText => $composableBuilder(
    column: $table.spokenText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voice => $composableBuilder(
    column: $table.voice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get audioBlob => $composableBuilder(
    column: $table.audioBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAccessedAtMs => $composableBuilder(
    column: $table.lastAccessedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hitCount => $composableBuilder(
    column: $table.hitCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expiresAtMs => $composableBuilder(
    column: $table.expiresAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get evictedAtMs => $composableBuilder(
    column: $table.evictedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evictionReason => $composableBuilder(
    column: $table.evictionReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VoiceClipsTableOrderingComposer
    extends Composer<_$AppDatabase, $VoiceClipsTable> {
  $$VoiceClipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spokenText => $composableBuilder(
    column: $table.spokenText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voice => $composableBuilder(
    column: $table.voice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get audioBlob => $composableBuilder(
    column: $table.audioBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAccessedAtMs => $composableBuilder(
    column: $table.lastAccessedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hitCount => $composableBuilder(
    column: $table.hitCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expiresAtMs => $composableBuilder(
    column: $table.expiresAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get evictedAtMs => $composableBuilder(
    column: $table.evictedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evictionReason => $composableBuilder(
    column: $table.evictionReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VoiceClipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoiceClipsTable> {
  $$VoiceClipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get spokenText => $composableBuilder(
    column: $table.spokenText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get voice =>
      $composableBuilder(column: $table.voice, builder: (column) => column);

  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<Uint8List> get audioBlob =>
      $composableBuilder(column: $table.audioBlob, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAccessedAtMs => $composableBuilder(
    column: $table.lastAccessedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hitCount =>
      $composableBuilder(column: $table.hitCount, builder: (column) => column);

  GeneratedColumn<int> get expiresAtMs => $composableBuilder(
    column: $table.expiresAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get evictedAtMs => $composableBuilder(
    column: $table.evictedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evictionReason => $composableBuilder(
    column: $table.evictionReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$VoiceClipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VoiceClipsTable,
          VoiceClip,
          $$VoiceClipsTableFilterComposer,
          $$VoiceClipsTableOrderingComposer,
          $$VoiceClipsTableAnnotationComposer,
          $$VoiceClipsTableCreateCompanionBuilder,
          $$VoiceClipsTableUpdateCompanionBuilder,
          (
            VoiceClip,
            BaseReferences<_$AppDatabase, $VoiceClipsTable, VoiceClip>,
          ),
          VoiceClip,
          PrefetchHooks Function()
        > {
  $$VoiceClipsTableTableManager(_$AppDatabase db, $VoiceClipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoiceClipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VoiceClipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VoiceClipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cacheKey = const Value.absent(),
                Value<String> spokenText = const Value.absent(),
                Value<String> voice = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> byteSize = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<Uint8List?> audioBlob = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> lastAccessedAtMs = const Value.absent(),
                Value<int> hitCount = const Value.absent(),
                Value<int> expiresAtMs = const Value.absent(),
                Value<int?> evictedAtMs = const Value.absent(),
                Value<String?> evictionReason = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
              }) => VoiceClipsCompanion(
                id: id,
                cacheKey: cacheKey,
                spokenText: spokenText,
                voice: voice,
                modelId: modelId,
                mimeType: mimeType,
                byteSize: byteSize,
                filePath: filePath,
                audioBlob: audioBlob,
                createdAtMs: createdAtMs,
                lastAccessedAtMs: lastAccessedAtMs,
                hitCount: hitCount,
                expiresAtMs: expiresAtMs,
                evictedAtMs: evictedAtMs,
                evictionReason: evictionReason,
                updatedAtMs: updatedAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cacheKey,
                required String spokenText,
                required String voice,
                required String modelId,
                Value<String> mimeType = const Value.absent(),
                required int byteSize,
                Value<String?> filePath = const Value.absent(),
                Value<Uint8List?> audioBlob = const Value.absent(),
                required int createdAtMs,
                required int lastAccessedAtMs,
                Value<int> hitCount = const Value.absent(),
                required int expiresAtMs,
                Value<int?> evictedAtMs = const Value.absent(),
                Value<String?> evictionReason = const Value.absent(),
                required int updatedAtMs,
              }) => VoiceClipsCompanion.insert(
                id: id,
                cacheKey: cacheKey,
                spokenText: spokenText,
                voice: voice,
                modelId: modelId,
                mimeType: mimeType,
                byteSize: byteSize,
                filePath: filePath,
                audioBlob: audioBlob,
                createdAtMs: createdAtMs,
                lastAccessedAtMs: lastAccessedAtMs,
                hitCount: hitCount,
                expiresAtMs: expiresAtMs,
                evictedAtMs: evictedAtMs,
                evictionReason: evictionReason,
                updatedAtMs: updatedAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$VoiceClipsTable, VoiceClip>(table),
                  BaseReferences<_$AppDatabase, $VoiceClipsTable, VoiceClip>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VoiceClipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VoiceClipsTable,
      VoiceClip,
      $$VoiceClipsTableFilterComposer,
      $$VoiceClipsTableOrderingComposer,
      $$VoiceClipsTableAnnotationComposer,
      $$VoiceClipsTableCreateCompanionBuilder,
      $$VoiceClipsTableUpdateCompanionBuilder,
      (VoiceClip, BaseReferences<_$AppDatabase, $VoiceClipsTable, VoiceClip>),
      VoiceClip,
      PrefetchHooks Function()
    >;
typedef $$HandsTableCreateCompanionBuilder = HandsCompanion Function({
  Value<int> id,
  Value<int?> sessionId,
  required int handNumber,
  required int startedAtMs,
  Value<int?> endedAtMs,
  required String settingsJson,
  required int seatCount,
  required double smallBlind,
  required double bigBlind,
  required int stackDepthBb,
  required int dealerSeat,
  required int sbSeat,
  required int bbSeat,
  required int heroSeat,
  required String lineupJson,
  Value<String> heroCards,
  Value<String> boardFlop,
  Value<String> boardTurn,
  Value<String> boardRiver,
  Value<String?> finalStreet,
  Value<bool> wentToShowdown,
  Value<String?> resultMessage,
  Value<String> winnerSeatsJson,
  Value<double> finalPot,
  Value<double> heroNetDollars,
  Value<double> heroNetBb,
  Value<double> heroEvDeltaDollars,
  Value<double> heroEvDeltaBb,
  Value<String> rebuyEventsJson,
  Value<int> payloadVersion,
  required int createdAtMs,
  required int updatedAtMs,
});
typedef $$HandsTableUpdateCompanionBuilder = HandsCompanion Function({
  Value<int> id,
  Value<int?> sessionId,
  Value<int> handNumber,
  Value<int> startedAtMs,
  Value<int?> endedAtMs,
  Value<String> settingsJson,
  Value<int> seatCount,
  Value<double> smallBlind,
  Value<double> bigBlind,
  Value<int> stackDepthBb,
  Value<int> dealerSeat,
  Value<int> sbSeat,
  Value<int> bbSeat,
  Value<int> heroSeat,
  Value<String> lineupJson,
  Value<String> heroCards,
  Value<String> boardFlop,
  Value<String> boardTurn,
  Value<String> boardRiver,
  Value<String?> finalStreet,
  Value<bool> wentToShowdown,
  Value<String?> resultMessage,
  Value<String> winnerSeatsJson,
  Value<double> finalPot,
  Value<double> heroNetDollars,
  Value<double> heroNetBb,
  Value<double> heroEvDeltaDollars,
  Value<double> heroEvDeltaBb,
  Value<String> rebuyEventsJson,
  Value<int> payloadVersion,
  Value<int> createdAtMs,
  Value<int> updatedAtMs,
});

class $$HandsTableFilterComposer extends Composer<_$AppDatabase, $HandsTable> {
  $$HandsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get handNumber => $composableBuilder(
    column: $table.handNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seatCount => $composableBuilder(
    column: $table.seatCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get smallBlind => $composableBuilder(
    column: $table.smallBlind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bigBlind => $composableBuilder(
    column: $table.bigBlind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stackDepthBb => $composableBuilder(
    column: $table.stackDepthBb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dealerSeat => $composableBuilder(
    column: $table.dealerSeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sbSeat => $composableBuilder(
    column: $table.sbSeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bbSeat => $composableBuilder(
    column: $table.bbSeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heroSeat => $composableBuilder(
    column: $table.heroSeat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lineupJson => $composableBuilder(
    column: $table.lineupJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroCards => $composableBuilder(
    column: $table.heroCards,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boardFlop => $composableBuilder(
    column: $table.boardFlop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boardTurn => $composableBuilder(
    column: $table.boardTurn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get boardRiver => $composableBuilder(
    column: $table.boardRiver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalStreet => $composableBuilder(
    column: $table.finalStreet,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wentToShowdown => $composableBuilder(
    column: $table.wentToShowdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultMessage => $composableBuilder(
    column: $table.resultMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winnerSeatsJson => $composableBuilder(
    column: $table.winnerSeatsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get finalPot => $composableBuilder(
    column: $table.finalPot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heroNetDollars => $composableBuilder(
    column: $table.heroNetDollars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heroNetBb => $composableBuilder(
    column: $table.heroNetBb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heroEvDeltaDollars => $composableBuilder(
    column: $table.heroEvDeltaDollars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heroEvDeltaBb => $composableBuilder(
    column: $table.heroEvDeltaBb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rebuyEventsJson => $composableBuilder(
    column: $table.rebuyEventsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HandsTableOrderingComposer
    extends Composer<_$AppDatabase, $HandsTable> {
  $$HandsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get handNumber => $composableBuilder(
    column: $table.handNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seatCount => $composableBuilder(
    column: $table.seatCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get smallBlind => $composableBuilder(
    column: $table.smallBlind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bigBlind => $composableBuilder(
    column: $table.bigBlind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stackDepthBb => $composableBuilder(
    column: $table.stackDepthBb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dealerSeat => $composableBuilder(
    column: $table.dealerSeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sbSeat => $composableBuilder(
    column: $table.sbSeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bbSeat => $composableBuilder(
    column: $table.bbSeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heroSeat => $composableBuilder(
    column: $table.heroSeat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lineupJson => $composableBuilder(
    column: $table.lineupJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroCards => $composableBuilder(
    column: $table.heroCards,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boardFlop => $composableBuilder(
    column: $table.boardFlop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boardTurn => $composableBuilder(
    column: $table.boardTurn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get boardRiver => $composableBuilder(
    column: $table.boardRiver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalStreet => $composableBuilder(
    column: $table.finalStreet,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wentToShowdown => $composableBuilder(
    column: $table.wentToShowdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultMessage => $composableBuilder(
    column: $table.resultMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winnerSeatsJson => $composableBuilder(
    column: $table.winnerSeatsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get finalPot => $composableBuilder(
    column: $table.finalPot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heroNetDollars => $composableBuilder(
    column: $table.heroNetDollars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heroNetBb => $composableBuilder(
    column: $table.heroNetBb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heroEvDeltaDollars => $composableBuilder(
    column: $table.heroEvDeltaDollars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heroEvDeltaBb => $composableBuilder(
    column: $table.heroEvDeltaBb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rebuyEventsJson => $composableBuilder(
    column: $table.rebuyEventsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HandsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HandsTable> {
  $$HandsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get handNumber => $composableBuilder(
    column: $table.handNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAtMs =>
      $composableBuilder(column: $table.endedAtMs, builder: (column) => column);

  GeneratedColumn<String> get settingsJson => $composableBuilder(
    column: $table.settingsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seatCount =>
      $composableBuilder(column: $table.seatCount, builder: (column) => column);

  GeneratedColumn<double> get smallBlind => $composableBuilder(
    column: $table.smallBlind,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bigBlind =>
      $composableBuilder(column: $table.bigBlind, builder: (column) => column);

  GeneratedColumn<int> get stackDepthBb => $composableBuilder(
    column: $table.stackDepthBb,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dealerSeat => $composableBuilder(
    column: $table.dealerSeat,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sbSeat =>
      $composableBuilder(column: $table.sbSeat, builder: (column) => column);

  GeneratedColumn<int> get bbSeat =>
      $composableBuilder(column: $table.bbSeat, builder: (column) => column);

  GeneratedColumn<int> get heroSeat =>
      $composableBuilder(column: $table.heroSeat, builder: (column) => column);

  GeneratedColumn<String> get lineupJson => $composableBuilder(
    column: $table.lineupJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get heroCards =>
      $composableBuilder(column: $table.heroCards, builder: (column) => column);

  GeneratedColumn<String> get boardFlop =>
      $composableBuilder(column: $table.boardFlop, builder: (column) => column);

  GeneratedColumn<String> get boardTurn =>
      $composableBuilder(column: $table.boardTurn, builder: (column) => column);

  GeneratedColumn<String> get boardRiver => $composableBuilder(
    column: $table.boardRiver,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finalStreet => $composableBuilder(
    column: $table.finalStreet,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wentToShowdown => $composableBuilder(
    column: $table.wentToShowdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resultMessage => $composableBuilder(
    column: $table.resultMessage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get winnerSeatsJson => $composableBuilder(
    column: $table.winnerSeatsJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get finalPot =>
      $composableBuilder(column: $table.finalPot, builder: (column) => column);

  GeneratedColumn<double> get heroNetDollars => $composableBuilder(
    column: $table.heroNetDollars,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heroNetBb =>
      $composableBuilder(column: $table.heroNetBb, builder: (column) => column);

  GeneratedColumn<double> get heroEvDeltaDollars => $composableBuilder(
    column: $table.heroEvDeltaDollars,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heroEvDeltaBb => $composableBuilder(
    column: $table.heroEvDeltaBb,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rebuyEventsJson => $composableBuilder(
    column: $table.rebuyEventsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get payloadVersion => $composableBuilder(
    column: $table.payloadVersion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$HandsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HandsTable,
          Hand,
          $$HandsTableFilterComposer,
          $$HandsTableOrderingComposer,
          $$HandsTableAnnotationComposer,
          $$HandsTableCreateCompanionBuilder,
          $$HandsTableUpdateCompanionBuilder,
          (Hand, BaseReferences<_$AppDatabase, $HandsTable, Hand>),
          Hand,
          PrefetchHooks Function()
        > {
  $$HandsTableTableManager(_$AppDatabase db, $HandsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HandsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HandsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HandsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int> handNumber = const Value.absent(),
                Value<int> startedAtMs = const Value.absent(),
                Value<int?> endedAtMs = const Value.absent(),
                Value<String> settingsJson = const Value.absent(),
                Value<int> seatCount = const Value.absent(),
                Value<double> smallBlind = const Value.absent(),
                Value<double> bigBlind = const Value.absent(),
                Value<int> stackDepthBb = const Value.absent(),
                Value<int> dealerSeat = const Value.absent(),
                Value<int> sbSeat = const Value.absent(),
                Value<int> bbSeat = const Value.absent(),
                Value<int> heroSeat = const Value.absent(),
                Value<String> lineupJson = const Value.absent(),
                Value<String> heroCards = const Value.absent(),
                Value<String> boardFlop = const Value.absent(),
                Value<String> boardTurn = const Value.absent(),
                Value<String> boardRiver = const Value.absent(),
                Value<String?> finalStreet = const Value.absent(),
                Value<bool> wentToShowdown = const Value.absent(),
                Value<String?> resultMessage = const Value.absent(),
                Value<String> winnerSeatsJson = const Value.absent(),
                Value<double> finalPot = const Value.absent(),
                Value<double> heroNetDollars = const Value.absent(),
                Value<double> heroNetBb = const Value.absent(),
                Value<double> heroEvDeltaDollars = const Value.absent(),
                Value<double> heroEvDeltaBb = const Value.absent(),
                Value<String> rebuyEventsJson = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
              }) => HandsCompanion(
                id: id,
                sessionId: sessionId,
                handNumber: handNumber,
                startedAtMs: startedAtMs,
                endedAtMs: endedAtMs,
                settingsJson: settingsJson,
                seatCount: seatCount,
                smallBlind: smallBlind,
                bigBlind: bigBlind,
                stackDepthBb: stackDepthBb,
                dealerSeat: dealerSeat,
                sbSeat: sbSeat,
                bbSeat: bbSeat,
                heroSeat: heroSeat,
                lineupJson: lineupJson,
                heroCards: heroCards,
                boardFlop: boardFlop,
                boardTurn: boardTurn,
                boardRiver: boardRiver,
                finalStreet: finalStreet,
                wentToShowdown: wentToShowdown,
                resultMessage: resultMessage,
                winnerSeatsJson: winnerSeatsJson,
                finalPot: finalPot,
                heroNetDollars: heroNetDollars,
                heroNetBb: heroNetBb,
                heroEvDeltaDollars: heroEvDeltaDollars,
                heroEvDeltaBb: heroEvDeltaBb,
                rebuyEventsJson: rebuyEventsJson,
                payloadVersion: payloadVersion,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                required int handNumber,
                required int startedAtMs,
                Value<int?> endedAtMs = const Value.absent(),
                required String settingsJson,
                required int seatCount,
                required double smallBlind,
                required double bigBlind,
                required int stackDepthBb,
                required int dealerSeat,
                required int sbSeat,
                required int bbSeat,
                required int heroSeat,
                required String lineupJson,
                Value<String> heroCards = const Value.absent(),
                Value<String> boardFlop = const Value.absent(),
                Value<String> boardTurn = const Value.absent(),
                Value<String> boardRiver = const Value.absent(),
                Value<String?> finalStreet = const Value.absent(),
                Value<bool> wentToShowdown = const Value.absent(),
                Value<String?> resultMessage = const Value.absent(),
                Value<String> winnerSeatsJson = const Value.absent(),
                Value<double> finalPot = const Value.absent(),
                Value<double> heroNetDollars = const Value.absent(),
                Value<double> heroNetBb = const Value.absent(),
                Value<double> heroEvDeltaDollars = const Value.absent(),
                Value<double> heroEvDeltaBb = const Value.absent(),
                Value<String> rebuyEventsJson = const Value.absent(),
                Value<int> payloadVersion = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
              }) => HandsCompanion.insert(
                id: id,
                sessionId: sessionId,
                handNumber: handNumber,
                startedAtMs: startedAtMs,
                endedAtMs: endedAtMs,
                settingsJson: settingsJson,
                seatCount: seatCount,
                smallBlind: smallBlind,
                bigBlind: bigBlind,
                stackDepthBb: stackDepthBb,
                dealerSeat: dealerSeat,
                sbSeat: sbSeat,
                bbSeat: bbSeat,
                heroSeat: heroSeat,
                lineupJson: lineupJson,
                heroCards: heroCards,
                boardFlop: boardFlop,
                boardTurn: boardTurn,
                boardRiver: boardRiver,
                finalStreet: finalStreet,
                wentToShowdown: wentToShowdown,
                resultMessage: resultMessage,
                winnerSeatsJson: winnerSeatsJson,
                finalPot: finalPot,
                heroNetDollars: heroNetDollars,
                heroNetBb: heroNetBb,
                heroEvDeltaDollars: heroEvDeltaDollars,
                heroEvDeltaBb: heroEvDeltaBb,
                rebuyEventsJson: rebuyEventsJson,
                payloadVersion: payloadVersion,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HandsTable, Hand>(table),
                  BaseReferences<_$AppDatabase, $HandsTable, Hand>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HandsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HandsTable,
      Hand,
      $$HandsTableFilterComposer,
      $$HandsTableOrderingComposer,
      $$HandsTableAnnotationComposer,
      $$HandsTableCreateCompanionBuilder,
      $$HandsTableUpdateCompanionBuilder,
      (Hand, BaseReferences<_$AppDatabase, $HandsTable, Hand>),
      Hand,
      PrefetchHooks Function()
    >;
typedef $$HandActionsTableCreateCompanionBuilder =
    HandActionsCompanion Function({
      Value<int> id,
      required int handId,
      required int sequence,
      required int seat,
      required String playerName,
      required String archetype,
      Value<bool> isHero,
      required String street,
      required String actionType,
      Value<double> amount,
      Value<double> potBefore,
      Value<double> potAfter,
      Value<double> stackAfter,
      required int atMs,
    });
typedef $$HandActionsTableUpdateCompanionBuilder =
    HandActionsCompanion Function({
      Value<int> id,
      Value<int> handId,
      Value<int> sequence,
      Value<int> seat,
      Value<String> playerName,
      Value<String> archetype,
      Value<bool> isHero,
      Value<String> street,
      Value<String> actionType,
      Value<double> amount,
      Value<double> potBefore,
      Value<double> potAfter,
      Value<double> stackAfter,
      Value<int> atMs,
    });

class $$HandActionsTableFilterComposer
    extends Composer<_$AppDatabase, $HandActionsTable> {
  $$HandActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seat => $composableBuilder(
    column: $table.seat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHero => $composableBuilder(
    column: $table.isHero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get potBefore => $composableBuilder(
    column: $table.potBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get potAfter => $composableBuilder(
    column: $table.potAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stackAfter => $composableBuilder(
    column: $table.stackAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HandActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $HandActionsTable> {
  $$HandActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seat => $composableBuilder(
    column: $table.seat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHero => $composableBuilder(
    column: $table.isHero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get potBefore => $composableBuilder(
    column: $table.potBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get potAfter => $composableBuilder(
    column: $table.potAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stackAfter => $composableBuilder(
    column: $table.stackAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get atMs => $composableBuilder(
    column: $table.atMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HandActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HandActionsTable> {
  $$HandActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get handId =>
      $composableBuilder(column: $table.handId, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<int> get seat =>
      $composableBuilder(column: $table.seat, builder: (column) => column);

  GeneratedColumn<String> get playerName => $composableBuilder(
    column: $table.playerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get archetype =>
      $composableBuilder(column: $table.archetype, builder: (column) => column);

  GeneratedColumn<bool> get isHero =>
      $composableBuilder(column: $table.isHero, builder: (column) => column);

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get potBefore =>
      $composableBuilder(column: $table.potBefore, builder: (column) => column);

  GeneratedColumn<double> get potAfter =>
      $composableBuilder(column: $table.potAfter, builder: (column) => column);

  GeneratedColumn<double> get stackAfter => $composableBuilder(
    column: $table.stackAfter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get atMs =>
      $composableBuilder(column: $table.atMs, builder: (column) => column);
}

class $$HandActionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HandActionsTable,
          HandAction,
          $$HandActionsTableFilterComposer,
          $$HandActionsTableOrderingComposer,
          $$HandActionsTableAnnotationComposer,
          $$HandActionsTableCreateCompanionBuilder,
          $$HandActionsTableUpdateCompanionBuilder,
          (
            HandAction,
            BaseReferences<_$AppDatabase, $HandActionsTable, HandAction>,
          ),
          HandAction,
          PrefetchHooks Function()
        > {
  $$HandActionsTableTableManager(_$AppDatabase db, $HandActionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HandActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HandActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HandActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> handId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<int> seat = const Value.absent(),
                Value<String> playerName = const Value.absent(),
                Value<String> archetype = const Value.absent(),
                Value<bool> isHero = const Value.absent(),
                Value<String> street = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> potBefore = const Value.absent(),
                Value<double> potAfter = const Value.absent(),
                Value<double> stackAfter = const Value.absent(),
                Value<int> atMs = const Value.absent(),
              }) => HandActionsCompanion(
                id: id,
                handId: handId,
                sequence: sequence,
                seat: seat,
                playerName: playerName,
                archetype: archetype,
                isHero: isHero,
                street: street,
                actionType: actionType,
                amount: amount,
                potBefore: potBefore,
                potAfter: potAfter,
                stackAfter: stackAfter,
                atMs: atMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int handId,
                required int sequence,
                required int seat,
                required String playerName,
                required String archetype,
                Value<bool> isHero = const Value.absent(),
                required String street,
                required String actionType,
                Value<double> amount = const Value.absent(),
                Value<double> potBefore = const Value.absent(),
                Value<double> potAfter = const Value.absent(),
                Value<double> stackAfter = const Value.absent(),
                required int atMs,
              }) => HandActionsCompanion.insert(
                id: id,
                handId: handId,
                sequence: sequence,
                seat: seat,
                playerName: playerName,
                archetype: archetype,
                isHero: isHero,
                street: street,
                actionType: actionType,
                amount: amount,
                potBefore: potBefore,
                potAfter: potAfter,
                stackAfter: stackAfter,
                atMs: atMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HandActionsTable, HandAction>(table),
                  BaseReferences<_$AppDatabase, $HandActionsTable, HandAction>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HandActionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HandActionsTable,
      HandAction,
      $$HandActionsTableFilterComposer,
      $$HandActionsTableOrderingComposer,
      $$HandActionsTableAnnotationComposer,
      $$HandActionsTableCreateCompanionBuilder,
      $$HandActionsTableUpdateCompanionBuilder,
      (
        HandAction,
        BaseReferences<_$AppDatabase, $HandActionsTable, HandAction>,
      ),
      HandAction,
      PrefetchHooks Function()
    >;
typedef $$CoachDecisionsTableCreateCompanionBuilder =
    CoachDecisionsCompanion Function({
      Value<int> id,
      Value<int?> handId,
      Value<int?> sessionId,
      required String street,
      required String heroAction,
      Value<double> heroAmount,
      Value<String?> bestAction,
      Value<double> bestSizingBb,
      required String verdict,
      Value<String> mismatch,
      Value<double> evDeltaBb,
      Value<double> evDeltaDollars,
      Value<String> villainName,
      Value<String> villainArchetype,
      required String adviceText,
      Value<String> adviceSource,
      Value<int?> aiRequestId,
      Value<bool> voicePlayed,
      Value<bool> voiceFromCache,
      Value<bool> voiceUsedDevice,
      required int gradedAtMs,
      Value<int?> narratedAtMs,
      required int createdAtMs,
      required int updatedAtMs,
    });
typedef $$CoachDecisionsTableUpdateCompanionBuilder =
    CoachDecisionsCompanion Function({
      Value<int> id,
      Value<int?> handId,
      Value<int?> sessionId,
      Value<String> street,
      Value<String> heroAction,
      Value<double> heroAmount,
      Value<String?> bestAction,
      Value<double> bestSizingBb,
      Value<String> verdict,
      Value<String> mismatch,
      Value<double> evDeltaBb,
      Value<double> evDeltaDollars,
      Value<String> villainName,
      Value<String> villainArchetype,
      Value<String> adviceText,
      Value<String> adviceSource,
      Value<int?> aiRequestId,
      Value<bool> voicePlayed,
      Value<bool> voiceFromCache,
      Value<bool> voiceUsedDevice,
      Value<int> gradedAtMs,
      Value<int?> narratedAtMs,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
    });

class $$CoachDecisionsTableFilterComposer
    extends Composer<_$AppDatabase, $CoachDecisionsTable> {
  $$CoachDecisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroAction => $composableBuilder(
    column: $table.heroAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heroAmount => $composableBuilder(
    column: $table.heroAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bestAction => $composableBuilder(
    column: $table.bestAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bestSizingBb => $composableBuilder(
    column: $table.bestSizingBb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mismatch => $composableBuilder(
    column: $table.mismatch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get evDeltaBb => $composableBuilder(
    column: $table.evDeltaBb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get evDeltaDollars => $composableBuilder(
    column: $table.evDeltaDollars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villainName => $composableBuilder(
    column: $table.villainName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get villainArchetype => $composableBuilder(
    column: $table.villainArchetype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adviceText => $composableBuilder(
    column: $table.adviceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adviceSource => $composableBuilder(
    column: $table.adviceSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get aiRequestId => $composableBuilder(
    column: $table.aiRequestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voicePlayed => $composableBuilder(
    column: $table.voicePlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voiceFromCache => $composableBuilder(
    column: $table.voiceFromCache,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voiceUsedDevice => $composableBuilder(
    column: $table.voiceUsedDevice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gradedAtMs => $composableBuilder(
    column: $table.gradedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get narratedAtMs => $composableBuilder(
    column: $table.narratedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoachDecisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CoachDecisionsTable> {
  $$CoachDecisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get street => $composableBuilder(
    column: $table.street,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroAction => $composableBuilder(
    column: $table.heroAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heroAmount => $composableBuilder(
    column: $table.heroAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bestAction => $composableBuilder(
    column: $table.bestAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bestSizingBb => $composableBuilder(
    column: $table.bestSizingBb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mismatch => $composableBuilder(
    column: $table.mismatch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get evDeltaBb => $composableBuilder(
    column: $table.evDeltaBb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get evDeltaDollars => $composableBuilder(
    column: $table.evDeltaDollars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villainName => $composableBuilder(
    column: $table.villainName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get villainArchetype => $composableBuilder(
    column: $table.villainArchetype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adviceText => $composableBuilder(
    column: $table.adviceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adviceSource => $composableBuilder(
    column: $table.adviceSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get aiRequestId => $composableBuilder(
    column: $table.aiRequestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voicePlayed => $composableBuilder(
    column: $table.voicePlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voiceFromCache => $composableBuilder(
    column: $table.voiceFromCache,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voiceUsedDevice => $composableBuilder(
    column: $table.voiceUsedDevice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gradedAtMs => $composableBuilder(
    column: $table.gradedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get narratedAtMs => $composableBuilder(
    column: $table.narratedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoachDecisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoachDecisionsTable> {
  $$CoachDecisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get handId =>
      $composableBuilder(column: $table.handId, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get street =>
      $composableBuilder(column: $table.street, builder: (column) => column);

  GeneratedColumn<String> get heroAction => $composableBuilder(
    column: $table.heroAction,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heroAmount => $composableBuilder(
    column: $table.heroAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bestAction => $composableBuilder(
    column: $table.bestAction,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bestSizingBb => $composableBuilder(
    column: $table.bestSizingBb,
    builder: (column) => column,
  );

  GeneratedColumn<String> get verdict =>
      $composableBuilder(column: $table.verdict, builder: (column) => column);

  GeneratedColumn<String> get mismatch =>
      $composableBuilder(column: $table.mismatch, builder: (column) => column);

  GeneratedColumn<double> get evDeltaBb =>
      $composableBuilder(column: $table.evDeltaBb, builder: (column) => column);

  GeneratedColumn<double> get evDeltaDollars => $composableBuilder(
    column: $table.evDeltaDollars,
    builder: (column) => column,
  );

  GeneratedColumn<String> get villainName => $composableBuilder(
    column: $table.villainName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get villainArchetype => $composableBuilder(
    column: $table.villainArchetype,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adviceText => $composableBuilder(
    column: $table.adviceText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adviceSource => $composableBuilder(
    column: $table.adviceSource,
    builder: (column) => column,
  );

  GeneratedColumn<int> get aiRequestId => $composableBuilder(
    column: $table.aiRequestId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get voicePlayed => $composableBuilder(
    column: $table.voicePlayed,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get voiceFromCache => $composableBuilder(
    column: $table.voiceFromCache,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get voiceUsedDevice => $composableBuilder(
    column: $table.voiceUsedDevice,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gradedAtMs => $composableBuilder(
    column: $table.gradedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get narratedAtMs => $composableBuilder(
    column: $table.narratedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$CoachDecisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoachDecisionsTable,
          CoachDecision,
          $$CoachDecisionsTableFilterComposer,
          $$CoachDecisionsTableOrderingComposer,
          $$CoachDecisionsTableAnnotationComposer,
          $$CoachDecisionsTableCreateCompanionBuilder,
          $$CoachDecisionsTableUpdateCompanionBuilder,
          (
            CoachDecision,
            BaseReferences<_$AppDatabase, $CoachDecisionsTable, CoachDecision>,
          ),
          CoachDecision,
          PrefetchHooks Function()
        > {
  $$CoachDecisionsTableTableManager(
    _$AppDatabase db,
    $CoachDecisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoachDecisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoachDecisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoachDecisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> handId = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<String> street = const Value.absent(),
                Value<String> heroAction = const Value.absent(),
                Value<double> heroAmount = const Value.absent(),
                Value<String?> bestAction = const Value.absent(),
                Value<double> bestSizingBb = const Value.absent(),
                Value<String> verdict = const Value.absent(),
                Value<String> mismatch = const Value.absent(),
                Value<double> evDeltaBb = const Value.absent(),
                Value<double> evDeltaDollars = const Value.absent(),
                Value<String> villainName = const Value.absent(),
                Value<String> villainArchetype = const Value.absent(),
                Value<String> adviceText = const Value.absent(),
                Value<String> adviceSource = const Value.absent(),
                Value<int?> aiRequestId = const Value.absent(),
                Value<bool> voicePlayed = const Value.absent(),
                Value<bool> voiceFromCache = const Value.absent(),
                Value<bool> voiceUsedDevice = const Value.absent(),
                Value<int> gradedAtMs = const Value.absent(),
                Value<int?> narratedAtMs = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
              }) => CoachDecisionsCompanion(
                id: id,
                handId: handId,
                sessionId: sessionId,
                street: street,
                heroAction: heroAction,
                heroAmount: heroAmount,
                bestAction: bestAction,
                bestSizingBb: bestSizingBb,
                verdict: verdict,
                mismatch: mismatch,
                evDeltaBb: evDeltaBb,
                evDeltaDollars: evDeltaDollars,
                villainName: villainName,
                villainArchetype: villainArchetype,
                adviceText: adviceText,
                adviceSource: adviceSource,
                aiRequestId: aiRequestId,
                voicePlayed: voicePlayed,
                voiceFromCache: voiceFromCache,
                voiceUsedDevice: voiceUsedDevice,
                gradedAtMs: gradedAtMs,
                narratedAtMs: narratedAtMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> handId = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                required String street,
                required String heroAction,
                Value<double> heroAmount = const Value.absent(),
                Value<String?> bestAction = const Value.absent(),
                Value<double> bestSizingBb = const Value.absent(),
                required String verdict,
                Value<String> mismatch = const Value.absent(),
                Value<double> evDeltaBb = const Value.absent(),
                Value<double> evDeltaDollars = const Value.absent(),
                Value<String> villainName = const Value.absent(),
                Value<String> villainArchetype = const Value.absent(),
                required String adviceText,
                Value<String> adviceSource = const Value.absent(),
                Value<int?> aiRequestId = const Value.absent(),
                Value<bool> voicePlayed = const Value.absent(),
                Value<bool> voiceFromCache = const Value.absent(),
                Value<bool> voiceUsedDevice = const Value.absent(),
                required int gradedAtMs,
                Value<int?> narratedAtMs = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
              }) => CoachDecisionsCompanion.insert(
                id: id,
                handId: handId,
                sessionId: sessionId,
                street: street,
                heroAction: heroAction,
                heroAmount: heroAmount,
                bestAction: bestAction,
                bestSizingBb: bestSizingBb,
                verdict: verdict,
                mismatch: mismatch,
                evDeltaBb: evDeltaBb,
                evDeltaDollars: evDeltaDollars,
                villainName: villainName,
                villainArchetype: villainArchetype,
                adviceText: adviceText,
                adviceSource: adviceSource,
                aiRequestId: aiRequestId,
                voicePlayed: voicePlayed,
                voiceFromCache: voiceFromCache,
                voiceUsedDevice: voiceUsedDevice,
                gradedAtMs: gradedAtMs,
                narratedAtMs: narratedAtMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoachDecisionsTable, CoachDecision>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CoachDecisionsTable,
                    CoachDecision
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoachDecisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoachDecisionsTable,
      CoachDecision,
      $$CoachDecisionsTableFilterComposer,
      $$CoachDecisionsTableOrderingComposer,
      $$CoachDecisionsTableAnnotationComposer,
      $$CoachDecisionsTableCreateCompanionBuilder,
      $$CoachDecisionsTableUpdateCompanionBuilder,
      (
        CoachDecision,
        BaseReferences<_$AppDatabase, $CoachDecisionsTable, CoachDecision>,
      ),
      CoachDecision,
      PrefetchHooks Function()
    >;
typedef $$SettingsChangesTableCreateCompanionBuilder =
    SettingsChangesCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      required String settingKey,
      Value<String?> oldValue,
      Value<String?> newValue,
      required int changedAtMs,
    });
typedef $$SettingsChangesTableUpdateCompanionBuilder =
    SettingsChangesCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<String> settingKey,
      Value<String?> oldValue,
      Value<String?> newValue,
      Value<int> changedAtMs,
    });

class $$SettingsChangesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsChangesTable> {
  $$SettingsChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get changedAtMs => $composableBuilder(
    column: $table.changedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsChangesTable> {
  $$SettingsChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get changedAtMs => $composableBuilder(
    column: $table.changedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsChangesTable> {
  $$SettingsChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<int> get changedAtMs => $composableBuilder(
    column: $table.changedAtMs,
    builder: (column) => column,
  );
}

class $$SettingsChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsChangesTable,
          SettingsChange,
          $$SettingsChangesTableFilterComposer,
          $$SettingsChangesTableOrderingComposer,
          $$SettingsChangesTableAnnotationComposer,
          $$SettingsChangesTableCreateCompanionBuilder,
          $$SettingsChangesTableUpdateCompanionBuilder,
          (
            SettingsChange,
            BaseReferences<
              _$AppDatabase,
              $SettingsChangesTable,
              SettingsChange
            >,
          ),
          SettingsChange,
          PrefetchHooks Function()
        > {
  $$SettingsChangesTableTableManager(
    _$AppDatabase db,
    $SettingsChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<String> settingKey = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<int> changedAtMs = const Value.absent(),
              }) => SettingsChangesCompanion(
                id: id,
                sessionId: sessionId,
                settingKey: settingKey,
                oldValue: oldValue,
                newValue: newValue,
                changedAtMs: changedAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                required String settingKey,
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                required int changedAtMs,
              }) => SettingsChangesCompanion.insert(
                id: id,
                sessionId: sessionId,
                settingKey: settingKey,
                oldValue: oldValue,
                newValue: newValue,
                changedAtMs: changedAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsChangesTable, SettingsChange>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingsChangesTable,
                    SettingsChange
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsChangesTable,
      SettingsChange,
      $$SettingsChangesTableFilterComposer,
      $$SettingsChangesTableOrderingComposer,
      $$SettingsChangesTableAnnotationComposer,
      $$SettingsChangesTableCreateCompanionBuilder,
      $$SettingsChangesTableUpdateCompanionBuilder,
      (
        SettingsChange,
        BaseReferences<_$AppDatabase, $SettingsChangesTable, SettingsChange>,
      ),
      SettingsChange,
      PrefetchHooks Function()
    >;
typedef $$DiagnosticEventsTableCreateCompanionBuilder =
    DiagnosticEventsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<int?> handId,
      Value<String> level,
      required String context,
      required String message,
      Value<String?> stackTrace,
      Value<String?> extraJson,
      required int createdAtMs,
    });
typedef $$DiagnosticEventsTableUpdateCompanionBuilder =
    DiagnosticEventsCompanion Function({
      Value<int> id,
      Value<int?> sessionId,
      Value<int?> handId,
      Value<String> level,
      Value<String> context,
      Value<String> message,
      Value<String?> stackTrace,
      Value<String?> extraJson,
      Value<int> createdAtMs,
    });

class $$DiagnosticEventsTableFilterComposer
    extends Composer<_$AppDatabase, $DiagnosticEventsTable> {
  $$DiagnosticEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiagnosticEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $DiagnosticEventsTable> {
  $$DiagnosticEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get handId => $composableBuilder(
    column: $table.handId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraJson => $composableBuilder(
    column: $table.extraJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiagnosticEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiagnosticEventsTable> {
  $$DiagnosticEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get handId =>
      $composableBuilder(column: $table.handId, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get stackTrace => $composableBuilder(
    column: $table.stackTrace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extraJson =>
      $composableBuilder(column: $table.extraJson, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$DiagnosticEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiagnosticEventsTable,
          DiagnosticEvent,
          $$DiagnosticEventsTableFilterComposer,
          $$DiagnosticEventsTableOrderingComposer,
          $$DiagnosticEventsTableAnnotationComposer,
          $$DiagnosticEventsTableCreateCompanionBuilder,
          $$DiagnosticEventsTableUpdateCompanionBuilder,
          (
            DiagnosticEvent,
            BaseReferences<
              _$AppDatabase,
              $DiagnosticEventsTable,
              DiagnosticEvent
            >,
          ),
          DiagnosticEvent,
          PrefetchHooks Function()
        > {
  $$DiagnosticEventsTableTableManager(
    _$AppDatabase db,
    $DiagnosticEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiagnosticEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiagnosticEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiagnosticEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int?> handId = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> context = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> stackTrace = const Value.absent(),
                Value<String?> extraJson = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
              }) => DiagnosticEventsCompanion(
                id: id,
                sessionId: sessionId,
                handId: handId,
                level: level,
                context: context,
                message: message,
                stackTrace: stackTrace,
                extraJson: extraJson,
                createdAtMs: createdAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> sessionId = const Value.absent(),
                Value<int?> handId = const Value.absent(),
                Value<String> level = const Value.absent(),
                required String context,
                required String message,
                Value<String?> stackTrace = const Value.absent(),
                Value<String?> extraJson = const Value.absent(),
                required int createdAtMs,
              }) => DiagnosticEventsCompanion.insert(
                id: id,
                sessionId: sessionId,
                handId: handId,
                level: level,
                context: context,
                message: message,
                stackTrace: stackTrace,
                extraJson: extraJson,
                createdAtMs: createdAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DiagnosticEventsTable, DiagnosticEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DiagnosticEventsTable,
                    DiagnosticEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiagnosticEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiagnosticEventsTable,
      DiagnosticEvent,
      $$DiagnosticEventsTableFilterComposer,
      $$DiagnosticEventsTableOrderingComposer,
      $$DiagnosticEventsTableAnnotationComposer,
      $$DiagnosticEventsTableCreateCompanionBuilder,
      $$DiagnosticEventsTableUpdateCompanionBuilder,
      (
        DiagnosticEvent,
        BaseReferences<_$AppDatabase, $DiagnosticEventsTable, DiagnosticEvent>,
      ),
      DiagnosticEvent,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScenariosTableTableManager get scenarios =>
      $$ScenariosTableTableManager(_db, _db.scenarios);
  $$PlayedScenariosTableTableManager get playedScenarios =>
      $$PlayedScenariosTableTableManager(_db, _db.playedScenarios);
  $$UserStatsRowsTableTableManager get userStatsRows =>
      $$UserStatsRowsTableTableManager(_db, _db.userStatsRows);
  $$MistakesTableTableManager get mistakes =>
      $$MistakesTableTableManager(_db, _db.mistakes);
  $$ImprovementEventsTableTableManager get improvementEvents =>
      $$ImprovementEventsTableTableManager(_db, _db.improvementEvents);
  $$AppSessionsTableTableManager get appSessions =>
      $$AppSessionsTableTableManager(_db, _db.appSessions);
  $$AiRequestsTableTableManager get aiRequests =>
      $$AiRequestsTableTableManager(_db, _db.aiRequests);
  $$VoiceClipsTableTableManager get voiceClips =>
      $$VoiceClipsTableTableManager(_db, _db.voiceClips);
  $$HandsTableTableManager get hands =>
      $$HandsTableTableManager(_db, _db.hands);
  $$HandActionsTableTableManager get handActions =>
      $$HandActionsTableTableManager(_db, _db.handActions);
  $$CoachDecisionsTableTableManager get coachDecisions =>
      $$CoachDecisionsTableTableManager(_db, _db.coachDecisions);
  $$SettingsChangesTableTableManager get settingsChanges =>
      $$SettingsChangesTableTableManager(_db, _db.settingsChanges);
  $$DiagnosticEventsTableTableManager get diagnosticEvents =>
      $$DiagnosticEventsTableTableManager(_db, _db.diagnosticEvents);
}
