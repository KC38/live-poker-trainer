// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_database.dart';

// ignore_for_file: type=lint
class $HeroProfilesTable extends HeroProfiles
    with TableInfo<$HeroProfilesTable, HeroProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeroProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(HeroIdentity.defaultDisplayName),
  );
  static const VerificationMeta _avatarRefMeta = const VerificationMeta(
    'avatarRef',
  );
  @override
  late final GeneratedColumn<String> avatarRef = GeneratedColumn<String>(
    'avatar_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    userId,
    displayName,
    avatarRef,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hero_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<HeroProfile> instance, {
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
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('avatar_ref')) {
      context.handle(
        _avatarRefMeta,
        avatarRef.isAcceptableOrUnknown(data['avatar_ref']!, _avatarRefMeta),
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
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  HeroProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HeroProfile(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      avatarRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_ref'],
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
  $HeroProfilesTable createAlias(String alias) {
    return $HeroProfilesTable(attachedDatabase, alias);
  }
}

class HeroProfile extends DataClass implements Insertable<HeroProfile> {
  final String userId;

  /// Shown at the hero seat and in the profile header.
  final String displayName;

  /// [AvatarRef.storageValue]: `builtin:<id>`, `file:<path>`, or empty.
  final String avatarRef;
  final int createdAtMs;
  final int updatedAtMs;
  const HeroProfile({
    required this.userId,
    required this.displayName,
    required this.avatarRef,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['display_name'] = Variable<String>(displayName);
    map['avatar_ref'] = Variable<String>(avatarRef);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  HeroProfilesCompanion toCompanion(bool nullToAbsent) {
    return HeroProfilesCompanion(
      userId: Value(userId),
      displayName: Value(displayName),
      avatarRef: Value(avatarRef),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory HeroProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HeroProfile(
      userId: serializer.fromJson<String>(json['userId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      avatarRef: serializer.fromJson<String>(json['avatarRef']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'displayName': serializer.toJson<String>(displayName),
      'avatarRef': serializer.toJson<String>(avatarRef),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  HeroProfile copyWith({
    String? userId,
    String? displayName,
    String? avatarRef,
    int? createdAtMs,
    int? updatedAtMs,
  }) => HeroProfile(
    userId: userId ?? this.userId,
    displayName: displayName ?? this.displayName,
    avatarRef: avatarRef ?? this.avatarRef,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  HeroProfile copyWithCompanion(HeroProfilesCompanion data) {
    return HeroProfile(
      userId: data.userId.present ? data.userId.value : this.userId,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      avatarRef: data.avatarRef.present ? data.avatarRef.value : this.avatarRef,
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
    return (StringBuffer('HeroProfile(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('avatarRef: $avatarRef, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, displayName, avatarRef, createdAtMs, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeroProfile &&
          other.userId == this.userId &&
          other.displayName == this.displayName &&
          other.avatarRef == this.avatarRef &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class HeroProfilesCompanion extends UpdateCompanion<HeroProfile> {
  final Value<String> userId;
  final Value<String> displayName;
  final Value<String> avatarRef;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const HeroProfilesCompanion({
    this.userId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.avatarRef = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HeroProfilesCompanion.insert({
    required String userId,
    this.displayName = const Value.absent(),
    this.avatarRef = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<HeroProfile> custom({
    Expression<String>? userId,
    Expression<String>? displayName,
    Expression<String>? avatarRef,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (displayName != null) 'display_name': displayName,
      if (avatarRef != null) 'avatar_ref': avatarRef,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HeroProfilesCompanion copyWith({
    Value<String>? userId,
    Value<String>? displayName,
    Value<String>? avatarRef,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return HeroProfilesCompanion(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarRef: avatarRef ?? this.avatarRef,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (avatarRef.present) {
      map['avatar_ref'] = Variable<String>(avatarRef.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeroProfilesCompanion(')
          ..write('userId: $userId, ')
          ..write('displayName: $displayName, ')
          ..write('avatarRef: $avatarRef, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileSnapshotsTable extends ProfileSnapshots
    with TableInfo<$ProfileSnapshotsTable, ProfileSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _handsPlayedMeta = const VerificationMeta(
    'handsPlayed',
  );
  @override
  late final GeneratedColumn<int> handsPlayed = GeneratedColumn<int>(
    'hands_played',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _styleIdMeta = const VerificationMeta(
    'styleId',
  );
  @override
  late final GeneratedColumn<String> styleId = GeneratedColumn<String>(
    'style_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('forming'),
  );
  static const VerificationMeta _styleLabelMeta = const VerificationMeta(
    'styleLabel',
  );
  @override
  late final GeneratedColumn<String> styleLabel = GeneratedColumn<String>(
    'style_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _styleConfidenceMeta = const VerificationMeta(
    'styleConfidence',
  );
  @override
  late final GeneratedColumn<String> styleConfidence = GeneratedColumn<String>(
    'style_confidence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('insufficient'),
  );
  static const VerificationMeta _styleExplanationMeta = const VerificationMeta(
    'styleExplanation',
  );
  @override
  late final GeneratedColumn<String> styleExplanation = GeneratedColumn<String>(
    'style_explanation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _metricsJsonMeta = const VerificationMeta(
    'metricsJson',
  );
  @override
  late final GeneratedColumn<String> metricsJson = GeneratedColumn<String>(
    'metrics_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _summaryTextMeta = const VerificationMeta(
    'summaryText',
  );
  @override
  late final GeneratedColumn<String> summaryText = GeneratedColumn<String>(
    'summary_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _summaryLeaksJsonMeta = const VerificationMeta(
    'summaryLeaksJson',
  );
  @override
  late final GeneratedColumn<String> summaryLeaksJson = GeneratedColumn<String>(
    'summary_leaks_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _summaryAdjustmentsJsonMeta =
      const VerificationMeta('summaryAdjustmentsJson');
  @override
  late final GeneratedColumn<String> summaryAdjustmentsJson =
      GeneratedColumn<String>(
        'summary_adjustments_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _summarySourceMeta = const VerificationMeta(
    'summarySource',
  );
  @override
  late final GeneratedColumn<String> summarySource = GeneratedColumn<String>(
    'summary_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _summaryModelIdMeta = const VerificationMeta(
    'summaryModelId',
  );
  @override
  late final GeneratedColumn<String> summaryModelId = GeneratedColumn<String>(
    'summary_model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _summaryHandsPlayedMeta =
      const VerificationMeta('summaryHandsPlayed');
  @override
  late final GeneratedColumn<int> summaryHandsPlayed = GeneratedColumn<int>(
    'summary_hands_played',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _summaryStyleIdMeta = const VerificationMeta(
    'summaryStyleId',
  );
  @override
  late final GeneratedColumn<String> summaryStyleId = GeneratedColumn<String>(
    'summary_style_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _summaryGeneratedAtMsMeta =
      const VerificationMeta('summaryGeneratedAtMs');
  @override
  late final GeneratedColumn<int> summaryGeneratedAtMs = GeneratedColumn<int>(
    'summary_generated_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _computedAtMsMeta = const VerificationMeta(
    'computedAtMs',
  );
  @override
  late final GeneratedColumn<int> computedAtMs = GeneratedColumn<int>(
    'computed_at_ms',
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
    userId,
    handsPlayed,
    styleId,
    styleLabel,
    styleConfidence,
    styleExplanation,
    metricsJson,
    summaryText,
    summaryLeaksJson,
    summaryAdjustmentsJson,
    summarySource,
    summaryModelId,
    summaryHandsPlayed,
    summaryStyleId,
    summaryGeneratedAtMs,
    computedAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileSnapshot> instance, {
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
    if (data.containsKey('hands_played')) {
      context.handle(
        _handsPlayedMeta,
        handsPlayed.isAcceptableOrUnknown(
          data['hands_played']!,
          _handsPlayedMeta,
        ),
      );
    }
    if (data.containsKey('style_id')) {
      context.handle(
        _styleIdMeta,
        styleId.isAcceptableOrUnknown(data['style_id']!, _styleIdMeta),
      );
    }
    if (data.containsKey('style_label')) {
      context.handle(
        _styleLabelMeta,
        styleLabel.isAcceptableOrUnknown(data['style_label']!, _styleLabelMeta),
      );
    }
    if (data.containsKey('style_confidence')) {
      context.handle(
        _styleConfidenceMeta,
        styleConfidence.isAcceptableOrUnknown(
          data['style_confidence']!,
          _styleConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('style_explanation')) {
      context.handle(
        _styleExplanationMeta,
        styleExplanation.isAcceptableOrUnknown(
          data['style_explanation']!,
          _styleExplanationMeta,
        ),
      );
    }
    if (data.containsKey('metrics_json')) {
      context.handle(
        _metricsJsonMeta,
        metricsJson.isAcceptableOrUnknown(
          data['metrics_json']!,
          _metricsJsonMeta,
        ),
      );
    }
    if (data.containsKey('summary_text')) {
      context.handle(
        _summaryTextMeta,
        summaryText.isAcceptableOrUnknown(
          data['summary_text']!,
          _summaryTextMeta,
        ),
      );
    }
    if (data.containsKey('summary_leaks_json')) {
      context.handle(
        _summaryLeaksJsonMeta,
        summaryLeaksJson.isAcceptableOrUnknown(
          data['summary_leaks_json']!,
          _summaryLeaksJsonMeta,
        ),
      );
    }
    if (data.containsKey('summary_adjustments_json')) {
      context.handle(
        _summaryAdjustmentsJsonMeta,
        summaryAdjustmentsJson.isAcceptableOrUnknown(
          data['summary_adjustments_json']!,
          _summaryAdjustmentsJsonMeta,
        ),
      );
    }
    if (data.containsKey('summary_source')) {
      context.handle(
        _summarySourceMeta,
        summarySource.isAcceptableOrUnknown(
          data['summary_source']!,
          _summarySourceMeta,
        ),
      );
    }
    if (data.containsKey('summary_model_id')) {
      context.handle(
        _summaryModelIdMeta,
        summaryModelId.isAcceptableOrUnknown(
          data['summary_model_id']!,
          _summaryModelIdMeta,
        ),
      );
    }
    if (data.containsKey('summary_hands_played')) {
      context.handle(
        _summaryHandsPlayedMeta,
        summaryHandsPlayed.isAcceptableOrUnknown(
          data['summary_hands_played']!,
          _summaryHandsPlayedMeta,
        ),
      );
    }
    if (data.containsKey('summary_style_id')) {
      context.handle(
        _summaryStyleIdMeta,
        summaryStyleId.isAcceptableOrUnknown(
          data['summary_style_id']!,
          _summaryStyleIdMeta,
        ),
      );
    }
    if (data.containsKey('summary_generated_at_ms')) {
      context.handle(
        _summaryGeneratedAtMsMeta,
        summaryGeneratedAtMs.isAcceptableOrUnknown(
          data['summary_generated_at_ms']!,
          _summaryGeneratedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('computed_at_ms')) {
      context.handle(
        _computedAtMsMeta,
        computedAtMs.isAcceptableOrUnknown(
          data['computed_at_ms']!,
          _computedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_computedAtMsMeta);
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
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  ProfileSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileSnapshot(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      handsPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hands_played'],
      )!,
      styleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_id'],
      )!,
      styleLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_label'],
      )!,
      styleConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_confidence'],
      )!,
      styleExplanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}style_explanation'],
      )!,
      metricsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metrics_json'],
      )!,
      summaryText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_text'],
      )!,
      summaryLeaksJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_leaks_json'],
      )!,
      summaryAdjustmentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_adjustments_json'],
      )!,
      summarySource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_source'],
      )!,
      summaryModelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_model_id'],
      )!,
      summaryHandsPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}summary_hands_played'],
      )!,
      summaryStyleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary_style_id'],
      )!,
      summaryGeneratedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}summary_generated_at_ms'],
      ),
      computedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}computed_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $ProfileSnapshotsTable createAlias(String alias) {
    return $ProfileSnapshotsTable(attachedDatabase, alias);
  }
}

class ProfileSnapshot extends DataClass implements Insertable<ProfileSnapshot> {
  final String userId;

  /// Hands behind [metricsJson].
  final int handsPlayed;

  /// `PlayingStyle.name`.
  final String styleId;

  /// Human-readable style label at compute time (`Loose-Passive`).
  final String styleLabel;

  /// `StyleConfidence.name`.
  final String styleConfidence;

  /// Why this style was assigned, in the player's own numbers.
  final String styleExplanation;

  /// `HeroMetrics.toJson()`.
  final String metricsJson;

  /// Style paragraph shown in the AI feedback card.
  final String summaryText;

  /// JSON list of leak lines.
  final String summaryLeaksJson;

  /// JSON list of concrete adjustments.
  final String summaryAdjustmentsJson;

  /// `gemini` or `offline`; empty when no summary has been written.
  final String summarySource;

  /// Model that produced [summaryText] (empty for offline copy).
  final String summaryModelId;

  /// Hands played when the summary was written — the refresh trigger.
  final int summaryHandsPlayed;

  /// `PlayingStyle.name` when the summary was written.
  final String summaryStyleId;
  final int? summaryGeneratedAtMs;
  final int computedAtMs;
  final int updatedAtMs;
  const ProfileSnapshot({
    required this.userId,
    required this.handsPlayed,
    required this.styleId,
    required this.styleLabel,
    required this.styleConfidence,
    required this.styleExplanation,
    required this.metricsJson,
    required this.summaryText,
    required this.summaryLeaksJson,
    required this.summaryAdjustmentsJson,
    required this.summarySource,
    required this.summaryModelId,
    required this.summaryHandsPlayed,
    required this.summaryStyleId,
    this.summaryGeneratedAtMs,
    required this.computedAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['hands_played'] = Variable<int>(handsPlayed);
    map['style_id'] = Variable<String>(styleId);
    map['style_label'] = Variable<String>(styleLabel);
    map['style_confidence'] = Variable<String>(styleConfidence);
    map['style_explanation'] = Variable<String>(styleExplanation);
    map['metrics_json'] = Variable<String>(metricsJson);
    map['summary_text'] = Variable<String>(summaryText);
    map['summary_leaks_json'] = Variable<String>(summaryLeaksJson);
    map['summary_adjustments_json'] = Variable<String>(summaryAdjustmentsJson);
    map['summary_source'] = Variable<String>(summarySource);
    map['summary_model_id'] = Variable<String>(summaryModelId);
    map['summary_hands_played'] = Variable<int>(summaryHandsPlayed);
    map['summary_style_id'] = Variable<String>(summaryStyleId);
    if (!nullToAbsent || summaryGeneratedAtMs != null) {
      map['summary_generated_at_ms'] = Variable<int>(summaryGeneratedAtMs);
    }
    map['computed_at_ms'] = Variable<int>(computedAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  ProfileSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return ProfileSnapshotsCompanion(
      userId: Value(userId),
      handsPlayed: Value(handsPlayed),
      styleId: Value(styleId),
      styleLabel: Value(styleLabel),
      styleConfidence: Value(styleConfidence),
      styleExplanation: Value(styleExplanation),
      metricsJson: Value(metricsJson),
      summaryText: Value(summaryText),
      summaryLeaksJson: Value(summaryLeaksJson),
      summaryAdjustmentsJson: Value(summaryAdjustmentsJson),
      summarySource: Value(summarySource),
      summaryModelId: Value(summaryModelId),
      summaryHandsPlayed: Value(summaryHandsPlayed),
      summaryStyleId: Value(summaryStyleId),
      summaryGeneratedAtMs: summaryGeneratedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(summaryGeneratedAtMs),
      computedAtMs: Value(computedAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory ProfileSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileSnapshot(
      userId: serializer.fromJson<String>(json['userId']),
      handsPlayed: serializer.fromJson<int>(json['handsPlayed']),
      styleId: serializer.fromJson<String>(json['styleId']),
      styleLabel: serializer.fromJson<String>(json['styleLabel']),
      styleConfidence: serializer.fromJson<String>(json['styleConfidence']),
      styleExplanation: serializer.fromJson<String>(json['styleExplanation']),
      metricsJson: serializer.fromJson<String>(json['metricsJson']),
      summaryText: serializer.fromJson<String>(json['summaryText']),
      summaryLeaksJson: serializer.fromJson<String>(json['summaryLeaksJson']),
      summaryAdjustmentsJson: serializer.fromJson<String>(
        json['summaryAdjustmentsJson'],
      ),
      summarySource: serializer.fromJson<String>(json['summarySource']),
      summaryModelId: serializer.fromJson<String>(json['summaryModelId']),
      summaryHandsPlayed: serializer.fromJson<int>(json['summaryHandsPlayed']),
      summaryStyleId: serializer.fromJson<String>(json['summaryStyleId']),
      summaryGeneratedAtMs: serializer.fromJson<int?>(
        json['summaryGeneratedAtMs'],
      ),
      computedAtMs: serializer.fromJson<int>(json['computedAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'handsPlayed': serializer.toJson<int>(handsPlayed),
      'styleId': serializer.toJson<String>(styleId),
      'styleLabel': serializer.toJson<String>(styleLabel),
      'styleConfidence': serializer.toJson<String>(styleConfidence),
      'styleExplanation': serializer.toJson<String>(styleExplanation),
      'metricsJson': serializer.toJson<String>(metricsJson),
      'summaryText': serializer.toJson<String>(summaryText),
      'summaryLeaksJson': serializer.toJson<String>(summaryLeaksJson),
      'summaryAdjustmentsJson': serializer.toJson<String>(
        summaryAdjustmentsJson,
      ),
      'summarySource': serializer.toJson<String>(summarySource),
      'summaryModelId': serializer.toJson<String>(summaryModelId),
      'summaryHandsPlayed': serializer.toJson<int>(summaryHandsPlayed),
      'summaryStyleId': serializer.toJson<String>(summaryStyleId),
      'summaryGeneratedAtMs': serializer.toJson<int?>(summaryGeneratedAtMs),
      'computedAtMs': serializer.toJson<int>(computedAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  ProfileSnapshot copyWith({
    String? userId,
    int? handsPlayed,
    String? styleId,
    String? styleLabel,
    String? styleConfidence,
    String? styleExplanation,
    String? metricsJson,
    String? summaryText,
    String? summaryLeaksJson,
    String? summaryAdjustmentsJson,
    String? summarySource,
    String? summaryModelId,
    int? summaryHandsPlayed,
    String? summaryStyleId,
    Value<int?> summaryGeneratedAtMs = const Value.absent(),
    int? computedAtMs,
    int? updatedAtMs,
  }) => ProfileSnapshot(
    userId: userId ?? this.userId,
    handsPlayed: handsPlayed ?? this.handsPlayed,
    styleId: styleId ?? this.styleId,
    styleLabel: styleLabel ?? this.styleLabel,
    styleConfidence: styleConfidence ?? this.styleConfidence,
    styleExplanation: styleExplanation ?? this.styleExplanation,
    metricsJson: metricsJson ?? this.metricsJson,
    summaryText: summaryText ?? this.summaryText,
    summaryLeaksJson: summaryLeaksJson ?? this.summaryLeaksJson,
    summaryAdjustmentsJson:
        summaryAdjustmentsJson ?? this.summaryAdjustmentsJson,
    summarySource: summarySource ?? this.summarySource,
    summaryModelId: summaryModelId ?? this.summaryModelId,
    summaryHandsPlayed: summaryHandsPlayed ?? this.summaryHandsPlayed,
    summaryStyleId: summaryStyleId ?? this.summaryStyleId,
    summaryGeneratedAtMs: summaryGeneratedAtMs.present
        ? summaryGeneratedAtMs.value
        : this.summaryGeneratedAtMs,
    computedAtMs: computedAtMs ?? this.computedAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  ProfileSnapshot copyWithCompanion(ProfileSnapshotsCompanion data) {
    return ProfileSnapshot(
      userId: data.userId.present ? data.userId.value : this.userId,
      handsPlayed: data.handsPlayed.present
          ? data.handsPlayed.value
          : this.handsPlayed,
      styleId: data.styleId.present ? data.styleId.value : this.styleId,
      styleLabel: data.styleLabel.present
          ? data.styleLabel.value
          : this.styleLabel,
      styleConfidence: data.styleConfidence.present
          ? data.styleConfidence.value
          : this.styleConfidence,
      styleExplanation: data.styleExplanation.present
          ? data.styleExplanation.value
          : this.styleExplanation,
      metricsJson: data.metricsJson.present
          ? data.metricsJson.value
          : this.metricsJson,
      summaryText: data.summaryText.present
          ? data.summaryText.value
          : this.summaryText,
      summaryLeaksJson: data.summaryLeaksJson.present
          ? data.summaryLeaksJson.value
          : this.summaryLeaksJson,
      summaryAdjustmentsJson: data.summaryAdjustmentsJson.present
          ? data.summaryAdjustmentsJson.value
          : this.summaryAdjustmentsJson,
      summarySource: data.summarySource.present
          ? data.summarySource.value
          : this.summarySource,
      summaryModelId: data.summaryModelId.present
          ? data.summaryModelId.value
          : this.summaryModelId,
      summaryHandsPlayed: data.summaryHandsPlayed.present
          ? data.summaryHandsPlayed.value
          : this.summaryHandsPlayed,
      summaryStyleId: data.summaryStyleId.present
          ? data.summaryStyleId.value
          : this.summaryStyleId,
      summaryGeneratedAtMs: data.summaryGeneratedAtMs.present
          ? data.summaryGeneratedAtMs.value
          : this.summaryGeneratedAtMs,
      computedAtMs: data.computedAtMs.present
          ? data.computedAtMs.value
          : this.computedAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileSnapshot(')
          ..write('userId: $userId, ')
          ..write('handsPlayed: $handsPlayed, ')
          ..write('styleId: $styleId, ')
          ..write('styleLabel: $styleLabel, ')
          ..write('styleConfidence: $styleConfidence, ')
          ..write('styleExplanation: $styleExplanation, ')
          ..write('metricsJson: $metricsJson, ')
          ..write('summaryText: $summaryText, ')
          ..write('summaryLeaksJson: $summaryLeaksJson, ')
          ..write('summaryAdjustmentsJson: $summaryAdjustmentsJson, ')
          ..write('summarySource: $summarySource, ')
          ..write('summaryModelId: $summaryModelId, ')
          ..write('summaryHandsPlayed: $summaryHandsPlayed, ')
          ..write('summaryStyleId: $summaryStyleId, ')
          ..write('summaryGeneratedAtMs: $summaryGeneratedAtMs, ')
          ..write('computedAtMs: $computedAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    userId,
    handsPlayed,
    styleId,
    styleLabel,
    styleConfidence,
    styleExplanation,
    metricsJson,
    summaryText,
    summaryLeaksJson,
    summaryAdjustmentsJson,
    summarySource,
    summaryModelId,
    summaryHandsPlayed,
    summaryStyleId,
    summaryGeneratedAtMs,
    computedAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileSnapshot &&
          other.userId == this.userId &&
          other.handsPlayed == this.handsPlayed &&
          other.styleId == this.styleId &&
          other.styleLabel == this.styleLabel &&
          other.styleConfidence == this.styleConfidence &&
          other.styleExplanation == this.styleExplanation &&
          other.metricsJson == this.metricsJson &&
          other.summaryText == this.summaryText &&
          other.summaryLeaksJson == this.summaryLeaksJson &&
          other.summaryAdjustmentsJson == this.summaryAdjustmentsJson &&
          other.summarySource == this.summarySource &&
          other.summaryModelId == this.summaryModelId &&
          other.summaryHandsPlayed == this.summaryHandsPlayed &&
          other.summaryStyleId == this.summaryStyleId &&
          other.summaryGeneratedAtMs == this.summaryGeneratedAtMs &&
          other.computedAtMs == this.computedAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class ProfileSnapshotsCompanion extends UpdateCompanion<ProfileSnapshot> {
  final Value<String> userId;
  final Value<int> handsPlayed;
  final Value<String> styleId;
  final Value<String> styleLabel;
  final Value<String> styleConfidence;
  final Value<String> styleExplanation;
  final Value<String> metricsJson;
  final Value<String> summaryText;
  final Value<String> summaryLeaksJson;
  final Value<String> summaryAdjustmentsJson;
  final Value<String> summarySource;
  final Value<String> summaryModelId;
  final Value<int> summaryHandsPlayed;
  final Value<String> summaryStyleId;
  final Value<int?> summaryGeneratedAtMs;
  final Value<int> computedAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const ProfileSnapshotsCompanion({
    this.userId = const Value.absent(),
    this.handsPlayed = const Value.absent(),
    this.styleId = const Value.absent(),
    this.styleLabel = const Value.absent(),
    this.styleConfidence = const Value.absent(),
    this.styleExplanation = const Value.absent(),
    this.metricsJson = const Value.absent(),
    this.summaryText = const Value.absent(),
    this.summaryLeaksJson = const Value.absent(),
    this.summaryAdjustmentsJson = const Value.absent(),
    this.summarySource = const Value.absent(),
    this.summaryModelId = const Value.absent(),
    this.summaryHandsPlayed = const Value.absent(),
    this.summaryStyleId = const Value.absent(),
    this.summaryGeneratedAtMs = const Value.absent(),
    this.computedAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileSnapshotsCompanion.insert({
    required String userId,
    this.handsPlayed = const Value.absent(),
    this.styleId = const Value.absent(),
    this.styleLabel = const Value.absent(),
    this.styleConfidence = const Value.absent(),
    this.styleExplanation = const Value.absent(),
    this.metricsJson = const Value.absent(),
    this.summaryText = const Value.absent(),
    this.summaryLeaksJson = const Value.absent(),
    this.summaryAdjustmentsJson = const Value.absent(),
    this.summarySource = const Value.absent(),
    this.summaryModelId = const Value.absent(),
    this.summaryHandsPlayed = const Value.absent(),
    this.summaryStyleId = const Value.absent(),
    this.summaryGeneratedAtMs = const Value.absent(),
    required int computedAtMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       computedAtMs = Value(computedAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<ProfileSnapshot> custom({
    Expression<String>? userId,
    Expression<int>? handsPlayed,
    Expression<String>? styleId,
    Expression<String>? styleLabel,
    Expression<String>? styleConfidence,
    Expression<String>? styleExplanation,
    Expression<String>? metricsJson,
    Expression<String>? summaryText,
    Expression<String>? summaryLeaksJson,
    Expression<String>? summaryAdjustmentsJson,
    Expression<String>? summarySource,
    Expression<String>? summaryModelId,
    Expression<int>? summaryHandsPlayed,
    Expression<String>? summaryStyleId,
    Expression<int>? summaryGeneratedAtMs,
    Expression<int>? computedAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (handsPlayed != null) 'hands_played': handsPlayed,
      if (styleId != null) 'style_id': styleId,
      if (styleLabel != null) 'style_label': styleLabel,
      if (styleConfidence != null) 'style_confidence': styleConfidence,
      if (styleExplanation != null) 'style_explanation': styleExplanation,
      if (metricsJson != null) 'metrics_json': metricsJson,
      if (summaryText != null) 'summary_text': summaryText,
      if (summaryLeaksJson != null) 'summary_leaks_json': summaryLeaksJson,
      if (summaryAdjustmentsJson != null)
        'summary_adjustments_json': summaryAdjustmentsJson,
      if (summarySource != null) 'summary_source': summarySource,
      if (summaryModelId != null) 'summary_model_id': summaryModelId,
      if (summaryHandsPlayed != null)
        'summary_hands_played': summaryHandsPlayed,
      if (summaryStyleId != null) 'summary_style_id': summaryStyleId,
      if (summaryGeneratedAtMs != null)
        'summary_generated_at_ms': summaryGeneratedAtMs,
      if (computedAtMs != null) 'computed_at_ms': computedAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileSnapshotsCompanion copyWith({
    Value<String>? userId,
    Value<int>? handsPlayed,
    Value<String>? styleId,
    Value<String>? styleLabel,
    Value<String>? styleConfidence,
    Value<String>? styleExplanation,
    Value<String>? metricsJson,
    Value<String>? summaryText,
    Value<String>? summaryLeaksJson,
    Value<String>? summaryAdjustmentsJson,
    Value<String>? summarySource,
    Value<String>? summaryModelId,
    Value<int>? summaryHandsPlayed,
    Value<String>? summaryStyleId,
    Value<int?>? summaryGeneratedAtMs,
    Value<int>? computedAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return ProfileSnapshotsCompanion(
      userId: userId ?? this.userId,
      handsPlayed: handsPlayed ?? this.handsPlayed,
      styleId: styleId ?? this.styleId,
      styleLabel: styleLabel ?? this.styleLabel,
      styleConfidence: styleConfidence ?? this.styleConfidence,
      styleExplanation: styleExplanation ?? this.styleExplanation,
      metricsJson: metricsJson ?? this.metricsJson,
      summaryText: summaryText ?? this.summaryText,
      summaryLeaksJson: summaryLeaksJson ?? this.summaryLeaksJson,
      summaryAdjustmentsJson:
          summaryAdjustmentsJson ?? this.summaryAdjustmentsJson,
      summarySource: summarySource ?? this.summarySource,
      summaryModelId: summaryModelId ?? this.summaryModelId,
      summaryHandsPlayed: summaryHandsPlayed ?? this.summaryHandsPlayed,
      summaryStyleId: summaryStyleId ?? this.summaryStyleId,
      summaryGeneratedAtMs: summaryGeneratedAtMs ?? this.summaryGeneratedAtMs,
      computedAtMs: computedAtMs ?? this.computedAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (handsPlayed.present) {
      map['hands_played'] = Variable<int>(handsPlayed.value);
    }
    if (styleId.present) {
      map['style_id'] = Variable<String>(styleId.value);
    }
    if (styleLabel.present) {
      map['style_label'] = Variable<String>(styleLabel.value);
    }
    if (styleConfidence.present) {
      map['style_confidence'] = Variable<String>(styleConfidence.value);
    }
    if (styleExplanation.present) {
      map['style_explanation'] = Variable<String>(styleExplanation.value);
    }
    if (metricsJson.present) {
      map['metrics_json'] = Variable<String>(metricsJson.value);
    }
    if (summaryText.present) {
      map['summary_text'] = Variable<String>(summaryText.value);
    }
    if (summaryLeaksJson.present) {
      map['summary_leaks_json'] = Variable<String>(summaryLeaksJson.value);
    }
    if (summaryAdjustmentsJson.present) {
      map['summary_adjustments_json'] = Variable<String>(
        summaryAdjustmentsJson.value,
      );
    }
    if (summarySource.present) {
      map['summary_source'] = Variable<String>(summarySource.value);
    }
    if (summaryModelId.present) {
      map['summary_model_id'] = Variable<String>(summaryModelId.value);
    }
    if (summaryHandsPlayed.present) {
      map['summary_hands_played'] = Variable<int>(summaryHandsPlayed.value);
    }
    if (summaryStyleId.present) {
      map['summary_style_id'] = Variable<String>(summaryStyleId.value);
    }
    if (summaryGeneratedAtMs.present) {
      map['summary_generated_at_ms'] = Variable<int>(
        summaryGeneratedAtMs.value,
      );
    }
    if (computedAtMs.present) {
      map['computed_at_ms'] = Variable<int>(computedAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileSnapshotsCompanion(')
          ..write('userId: $userId, ')
          ..write('handsPlayed: $handsPlayed, ')
          ..write('styleId: $styleId, ')
          ..write('styleLabel: $styleLabel, ')
          ..write('styleConfidence: $styleConfidence, ')
          ..write('styleExplanation: $styleExplanation, ')
          ..write('metricsJson: $metricsJson, ')
          ..write('summaryText: $summaryText, ')
          ..write('summaryLeaksJson: $summaryLeaksJson, ')
          ..write('summaryAdjustmentsJson: $summaryAdjustmentsJson, ')
          ..write('summarySource: $summarySource, ')
          ..write('summaryModelId: $summaryModelId, ')
          ..write('summaryHandsPlayed: $summaryHandsPlayed, ')
          ..write('summaryStyleId: $summaryStyleId, ')
          ..write('summaryGeneratedAtMs: $summaryGeneratedAtMs, ')
          ..write('computedAtMs: $computedAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ProfileDatabase extends GeneratedDatabase {
  _$ProfileDatabase(QueryExecutor e) : super(e);
  $ProfileDatabaseManager get managers => $ProfileDatabaseManager(this);
  late final $HeroProfilesTable heroProfiles = $HeroProfilesTable(this);
  late final $ProfileSnapshotsTable profileSnapshots = $ProfileSnapshotsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    heroProfiles,
    profileSnapshots,
  ];
}

typedef $$HeroProfilesTableCreateCompanionBuilder =
    HeroProfilesCompanion Function({
      required String userId,
      Value<String> displayName,
      Value<String> avatarRef,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$HeroProfilesTableUpdateCompanionBuilder =
    HeroProfilesCompanion Function({
      Value<String> userId,
      Value<String> displayName,
      Value<String> avatarRef,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$HeroProfilesTableFilterComposer
    extends Composer<_$ProfileDatabase, $HeroProfilesTable> {
  $$HeroProfilesTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarRef => $composableBuilder(
    column: $table.avatarRef,
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

class $$HeroProfilesTableOrderingComposer
    extends Composer<_$ProfileDatabase, $HeroProfilesTable> {
  $$HeroProfilesTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarRef => $composableBuilder(
    column: $table.avatarRef,
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

class $$HeroProfilesTableAnnotationComposer
    extends Composer<_$ProfileDatabase, $HeroProfilesTable> {
  $$HeroProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarRef =>
      $composableBuilder(column: $table.avatarRef, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$HeroProfilesTableTableManager
    extends
        RootTableManager<
          _$ProfileDatabase,
          $HeroProfilesTable,
          HeroProfile,
          $$HeroProfilesTableFilterComposer,
          $$HeroProfilesTableOrderingComposer,
          $$HeroProfilesTableAnnotationComposer,
          $$HeroProfilesTableCreateCompanionBuilder,
          $$HeroProfilesTableUpdateCompanionBuilder,
          (
            HeroProfile,
            BaseReferences<_$ProfileDatabase, $HeroProfilesTable, HeroProfile>,
          ),
          HeroProfile,
          PrefetchHooks Function()
        > {
  $$HeroProfilesTableTableManager(
    _$ProfileDatabase db,
    $HeroProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeroProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeroProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeroProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> avatarRef = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HeroProfilesCompanion(
                userId: userId,
                displayName: displayName,
                avatarRef: avatarRef,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<String> displayName = const Value.absent(),
                Value<String> avatarRef = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => HeroProfilesCompanion.insert(
                userId: userId,
                displayName: displayName,
                avatarRef: avatarRef,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HeroProfilesTable, HeroProfile>(table),
                  BaseReferences<
                    _$ProfileDatabase,
                    $HeroProfilesTable,
                    HeroProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HeroProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$ProfileDatabase,
      $HeroProfilesTable,
      HeroProfile,
      $$HeroProfilesTableFilterComposer,
      $$HeroProfilesTableOrderingComposer,
      $$HeroProfilesTableAnnotationComposer,
      $$HeroProfilesTableCreateCompanionBuilder,
      $$HeroProfilesTableUpdateCompanionBuilder,
      (
        HeroProfile,
        BaseReferences<_$ProfileDatabase, $HeroProfilesTable, HeroProfile>,
      ),
      HeroProfile,
      PrefetchHooks Function()
    >;
typedef $$ProfileSnapshotsTableCreateCompanionBuilder =
    ProfileSnapshotsCompanion Function({
      required String userId,
      Value<int> handsPlayed,
      Value<String> styleId,
      Value<String> styleLabel,
      Value<String> styleConfidence,
      Value<String> styleExplanation,
      Value<String> metricsJson,
      Value<String> summaryText,
      Value<String> summaryLeaksJson,
      Value<String> summaryAdjustmentsJson,
      Value<String> summarySource,
      Value<String> summaryModelId,
      Value<int> summaryHandsPlayed,
      Value<String> summaryStyleId,
      Value<int?> summaryGeneratedAtMs,
      required int computedAtMs,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$ProfileSnapshotsTableUpdateCompanionBuilder =
    ProfileSnapshotsCompanion Function({
      Value<String> userId,
      Value<int> handsPlayed,
      Value<String> styleId,
      Value<String> styleLabel,
      Value<String> styleConfidence,
      Value<String> styleExplanation,
      Value<String> metricsJson,
      Value<String> summaryText,
      Value<String> summaryLeaksJson,
      Value<String> summaryAdjustmentsJson,
      Value<String> summarySource,
      Value<String> summaryModelId,
      Value<int> summaryHandsPlayed,
      Value<String> summaryStyleId,
      Value<int?> summaryGeneratedAtMs,
      Value<int> computedAtMs,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$ProfileSnapshotsTableFilterComposer
    extends Composer<_$ProfileDatabase, $ProfileSnapshotsTable> {
  $$ProfileSnapshotsTableFilterComposer({
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

  ColumnFilters<int> get handsPlayed => $composableBuilder(
    column: $table.handsPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleId => $composableBuilder(
    column: $table.styleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleLabel => $composableBuilder(
    column: $table.styleLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleConfidence => $composableBuilder(
    column: $table.styleConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get styleExplanation => $composableBuilder(
    column: $table.styleExplanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryLeaksJson => $composableBuilder(
    column: $table.summaryLeaksJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryAdjustmentsJson => $composableBuilder(
    column: $table.summaryAdjustmentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summarySource => $composableBuilder(
    column: $table.summarySource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryModelId => $composableBuilder(
    column: $table.summaryModelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get summaryHandsPlayed => $composableBuilder(
    column: $table.summaryHandsPlayed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryStyleId => $composableBuilder(
    column: $table.summaryStyleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get summaryGeneratedAtMs => $composableBuilder(
    column: $table.summaryGeneratedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get computedAtMs => $composableBuilder(
    column: $table.computedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileSnapshotsTableOrderingComposer
    extends Composer<_$ProfileDatabase, $ProfileSnapshotsTable> {
  $$ProfileSnapshotsTableOrderingComposer({
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

  ColumnOrderings<int> get handsPlayed => $composableBuilder(
    column: $table.handsPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleId => $composableBuilder(
    column: $table.styleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleLabel => $composableBuilder(
    column: $table.styleLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleConfidence => $composableBuilder(
    column: $table.styleConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get styleExplanation => $composableBuilder(
    column: $table.styleExplanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryLeaksJson => $composableBuilder(
    column: $table.summaryLeaksJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryAdjustmentsJson => $composableBuilder(
    column: $table.summaryAdjustmentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summarySource => $composableBuilder(
    column: $table.summarySource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryModelId => $composableBuilder(
    column: $table.summaryModelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get summaryHandsPlayed => $composableBuilder(
    column: $table.summaryHandsPlayed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryStyleId => $composableBuilder(
    column: $table.summaryStyleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get summaryGeneratedAtMs => $composableBuilder(
    column: $table.summaryGeneratedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get computedAtMs => $composableBuilder(
    column: $table.computedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileSnapshotsTableAnnotationComposer
    extends Composer<_$ProfileDatabase, $ProfileSnapshotsTable> {
  $$ProfileSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get handsPlayed => $composableBuilder(
    column: $table.handsPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get styleId =>
      $composableBuilder(column: $table.styleId, builder: (column) => column);

  GeneratedColumn<String> get styleLabel => $composableBuilder(
    column: $table.styleLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get styleConfidence => $composableBuilder(
    column: $table.styleConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get styleExplanation => $composableBuilder(
    column: $table.styleExplanation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metricsJson => $composableBuilder(
    column: $table.metricsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summaryText => $composableBuilder(
    column: $table.summaryText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summaryLeaksJson => $composableBuilder(
    column: $table.summaryLeaksJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summaryAdjustmentsJson => $composableBuilder(
    column: $table.summaryAdjustmentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summarySource => $composableBuilder(
    column: $table.summarySource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summaryModelId => $composableBuilder(
    column: $table.summaryModelId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get summaryHandsPlayed => $composableBuilder(
    column: $table.summaryHandsPlayed,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summaryStyleId => $composableBuilder(
    column: $table.summaryStyleId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get summaryGeneratedAtMs => $composableBuilder(
    column: $table.summaryGeneratedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get computedAtMs => $composableBuilder(
    column: $table.computedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$ProfileSnapshotsTableTableManager
    extends
        RootTableManager<
          _$ProfileDatabase,
          $ProfileSnapshotsTable,
          ProfileSnapshot,
          $$ProfileSnapshotsTableFilterComposer,
          $$ProfileSnapshotsTableOrderingComposer,
          $$ProfileSnapshotsTableAnnotationComposer,
          $$ProfileSnapshotsTableCreateCompanionBuilder,
          $$ProfileSnapshotsTableUpdateCompanionBuilder,
          (
            ProfileSnapshot,
            BaseReferences<
              _$ProfileDatabase,
              $ProfileSnapshotsTable,
              ProfileSnapshot
            >,
          ),
          ProfileSnapshot,
          PrefetchHooks Function()
        > {
  $$ProfileSnapshotsTableTableManager(
    _$ProfileDatabase db,
    $ProfileSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> userId = const Value.absent(),
                Value<int> handsPlayed = const Value.absent(),
                Value<String> styleId = const Value.absent(),
                Value<String> styleLabel = const Value.absent(),
                Value<String> styleConfidence = const Value.absent(),
                Value<String> styleExplanation = const Value.absent(),
                Value<String> metricsJson = const Value.absent(),
                Value<String> summaryText = const Value.absent(),
                Value<String> summaryLeaksJson = const Value.absent(),
                Value<String> summaryAdjustmentsJson = const Value.absent(),
                Value<String> summarySource = const Value.absent(),
                Value<String> summaryModelId = const Value.absent(),
                Value<int> summaryHandsPlayed = const Value.absent(),
                Value<String> summaryStyleId = const Value.absent(),
                Value<int?> summaryGeneratedAtMs = const Value.absent(),
                Value<int> computedAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileSnapshotsCompanion(
                userId: userId,
                handsPlayed: handsPlayed,
                styleId: styleId,
                styleLabel: styleLabel,
                styleConfidence: styleConfidence,
                styleExplanation: styleExplanation,
                metricsJson: metricsJson,
                summaryText: summaryText,
                summaryLeaksJson: summaryLeaksJson,
                summaryAdjustmentsJson: summaryAdjustmentsJson,
                summarySource: summarySource,
                summaryModelId: summaryModelId,
                summaryHandsPlayed: summaryHandsPlayed,
                summaryStyleId: summaryStyleId,
                summaryGeneratedAtMs: summaryGeneratedAtMs,
                computedAtMs: computedAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String userId,
                Value<int> handsPlayed = const Value.absent(),
                Value<String> styleId = const Value.absent(),
                Value<String> styleLabel = const Value.absent(),
                Value<String> styleConfidence = const Value.absent(),
                Value<String> styleExplanation = const Value.absent(),
                Value<String> metricsJson = const Value.absent(),
                Value<String> summaryText = const Value.absent(),
                Value<String> summaryLeaksJson = const Value.absent(),
                Value<String> summaryAdjustmentsJson = const Value.absent(),
                Value<String> summarySource = const Value.absent(),
                Value<String> summaryModelId = const Value.absent(),
                Value<int> summaryHandsPlayed = const Value.absent(),
                Value<String> summaryStyleId = const Value.absent(),
                Value<int?> summaryGeneratedAtMs = const Value.absent(),
                required int computedAtMs,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => ProfileSnapshotsCompanion.insert(
                userId: userId,
                handsPlayed: handsPlayed,
                styleId: styleId,
                styleLabel: styleLabel,
                styleConfidence: styleConfidence,
                styleExplanation: styleExplanation,
                metricsJson: metricsJson,
                summaryText: summaryText,
                summaryLeaksJson: summaryLeaksJson,
                summaryAdjustmentsJson: summaryAdjustmentsJson,
                summarySource: summarySource,
                summaryModelId: summaryModelId,
                summaryHandsPlayed: summaryHandsPlayed,
                summaryStyleId: summaryStyleId,
                summaryGeneratedAtMs: summaryGeneratedAtMs,
                computedAtMs: computedAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfileSnapshotsTable, ProfileSnapshot>(table),
                  BaseReferences<
                    _$ProfileDatabase,
                    $ProfileSnapshotsTable,
                    ProfileSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$ProfileDatabase,
      $ProfileSnapshotsTable,
      ProfileSnapshot,
      $$ProfileSnapshotsTableFilterComposer,
      $$ProfileSnapshotsTableOrderingComposer,
      $$ProfileSnapshotsTableAnnotationComposer,
      $$ProfileSnapshotsTableCreateCompanionBuilder,
      $$ProfileSnapshotsTableUpdateCompanionBuilder,
      (
        ProfileSnapshot,
        BaseReferences<
          _$ProfileDatabase,
          $ProfileSnapshotsTable,
          ProfileSnapshot
        >,
      ),
      ProfileSnapshot,
      PrefetchHooks Function()
    >;

class $ProfileDatabaseManager {
  final _$ProfileDatabase _db;
  $ProfileDatabaseManager(this._db);
  $$HeroProfilesTableTableManager get heroProfiles =>
      $$HeroProfilesTableTableManager(_db, _db.heroProfiles);
  $$ProfileSnapshotsTableTableManager get profileSnapshots =>
      $$ProfileSnapshotsTableTableManager(_db, _db.profileSnapshots);
}
