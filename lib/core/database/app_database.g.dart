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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ScenariosTable scenarios = $ScenariosTable(this);
  late final $PlayedScenariosTable playedScenarios = $PlayedScenariosTable(
    this,
  );
  late final $UserStatsRowsTable userStatsRows = $UserStatsRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    scenarios,
    playedScenarios,
    userStatsRows,
  ];
}

typedef $$ScenariosTableCreateCompanionBuilder =
    ScenariosCompanion Function({
      Value<int> id,
      required String contentHash,
      required String payloadJson,
      Value<DateTime> createdAt,
    });
typedef $$ScenariosTableUpdateCompanionBuilder =
    ScenariosCompanion Function({
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
                  e.readTable(table),
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
                  e.readTable(table),
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
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scenarioId,
                                referencedTable:
                                    $$PlayedScenariosTableReferences
                                        ._scenarioIdTable(db),
                                referencedColumn:
                                    $$PlayedScenariosTableReferences
                                        ._scenarioIdTable(db)
                                        .id,
                              )
                              as T;
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ScenariosTableTableManager get scenarios =>
      $$ScenariosTableTableManager(_db, _db.scenarios);
  $$PlayedScenariosTableTableManager get playedScenarios =>
      $$PlayedScenariosTableTableManager(_db, _db.playedScenarios);
  $$UserStatsRowsTableTableManager get userStatsRows =>
      $$UserStatsRowsTableTableManager(_db, _db.userStatsRows);
}
