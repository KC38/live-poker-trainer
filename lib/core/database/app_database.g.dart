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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentHash,
    payloadJson,
    createdAt,
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
  const Scenario({
    required this.id,
    required this.contentHash,
    required this.payloadJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['content_hash'] = Variable<String>(contentHash);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScenariosCompanion toCompanion(bool nullToAbsent) {
    return ScenariosCompanion(
      id: Value(id),
      contentHash: Value(contentHash),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
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
    };
  }

  Scenario copyWith({
    int? id,
    String? contentHash,
    String? payloadJson,
    DateTime? createdAt,
  }) => Scenario(
    id: id ?? this.id,
    contentHash: contentHash ?? this.contentHash,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('Scenario(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, contentHash, payloadJson, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Scenario &&
          other.id == this.id &&
          other.contentHash == this.contentHash &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt);
}

class ScenariosCompanion extends UpdateCompanion<Scenario> {
  final Value<int> id;
  final Value<String> contentHash;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  const ScenariosCompanion({
    this.id = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ScenariosCompanion.insert({
    this.id = const Value.absent(),
    required String contentHash,
    required String payloadJson,
    this.createdAt = const Value.absent(),
  }) : contentHash = Value(contentHash),
       payloadJson = Value(payloadJson);
  static Insertable<Scenario> custom({
    Expression<int>? id,
    Expression<String>? contentHash,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentHash != null) 'content_hash': contentHash,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ScenariosCompanion copyWith({
    Value<int>? id,
    Value<String>? contentHash,
    Value<String>? payloadJson,
    Value<DateTime>? createdAt,
  }) {
    return ScenariosCompanion(
      id: id ?? this.id,
      contentHash: contentHash ?? this.contentHash,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScenariosCompanion(')
          ..write('id: $id, ')
          ..write('contentHash: $contentHash, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
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
  ];
}

typedef $$ScenariosTableCreateCompanionBuilder = ScenariosCompanion Function({
  Value<int> id,
  required String contentHash,
  required String payloadJson,
  Value<DateTime> createdAt,
});
typedef $$ScenariosTableUpdateCompanionBuilder = ScenariosCompanion Function({
  Value<int> id,
  Value<String> contentHash,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
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
              }) => ScenariosCompanion(
                id: id,
                contentHash: contentHash,
                payloadJson: payloadJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String contentHash,
                required String payloadJson,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScenariosCompanion.insert(
                id: id,
                contentHash: contentHash,
                payloadJson: payloadJson,
                createdAt: createdAt,
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
}
