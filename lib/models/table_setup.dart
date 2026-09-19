/// Canonical table setup DTO sent as `tableSetup` to `fetchSituation`.
///
/// Mirrors `TableSetupInput` in `functions/src/situation_types.ts`.
library;

import 'package:flutter/foundation.dart';
import 'package:live_poker_trainer/models/game_settings_model.dart';
import 'package:live_poker_trainer/models/player_model.dart';
import 'package:live_poker_trainer/models/situation_model.dart';

/// One lineup seat for a custom setup request.
@immutable
class TableSetupLineupSeat {
  /// Creates a lineup seat.
  const TableSetupLineupSeat({
    required this.seat,
    required this.archetype,
    this.name,
  });

  final int seat;
  final String archetype;
  final String? name;

  Map<String, dynamic> toCallableMap() => {
    'seat': seat,
    'archetype': archetype,
    if (name != null && name!.isNotEmpty) 'name': name,
  };
}

/// Setup parameters the server canonicalizes into a situation pool key.
@immutable
class TableSetup {
  /// Creates a table setup.
  const TableSetup({
    required this.mode,
    required this.seatCount,
    required this.smallBlind,
    required this.bigBlind,
    required this.startingStack,
    this.ante = 0,
    this.buttonSeat,
    this.heroSeat,
    this.lineup,
  });

  final SetupMode mode;
  final int seatCount;
  final double smallBlind;
  final double bigBlind;
  final double ante;

  /// Starting stack in chips (not BB).
  final double startingStack;
  final int? buttonSeat;
  final int? heroSeat;
  final List<TableSetupLineupSeat>? lineup;

  /// Builds a setup from local [GameSettingsModel].
  ///
  /// Random pool: mode + seat/blinds/stack only.
  /// Custom: includes ordered lineup with HERO at seat 0 and villains after.
  factory TableSetup.fromGameSettings(
    GameSettingsModel settings, {
    int? buttonSeat,
    int heroSeat = 0,
  }) {
    final startingStack = settings.startingStack;
    if (settings.lineupMode != LineupMode.custom) {
      return TableSetup(
        mode: SetupMode.random,
        seatCount: settings.seatCount,
        smallBlind: settings.smallBlind,
        bigBlind: settings.bigBlind,
        ante: 0,
        startingStack: startingStack,
      );
    }

    final normalized = settings.withNormalizedCustomLineup();
    final lineup = <TableSetupLineupSeat>[
      const TableSetupLineupSeat(seat: 0, archetype: 'HERO', name: 'Hero'),
      for (var i = 0; i < normalized.customArchetypes.length; i++)
        TableSetupLineupSeat(
          seat: i + 1,
          archetype: _wireArchetype(normalized.customArchetypes[i]),
          name: ArchetypeRoster.defaultNames[normalized.customArchetypes[i]],
        ),
    ];

    return TableSetup(
      mode: SetupMode.custom,
      seatCount: normalized.seatCount,
      smallBlind: normalized.smallBlind,
      bigBlind: normalized.bigBlind,
      ante: 0,
      startingStack: startingStack,
      buttonSeat: buttonSeat ?? 0,
      heroSeat: heroSeat,
      lineup: lineup,
    );
  }

  /// Callable payload under `tableSetup`.
  Map<String, dynamic> toCallableMap() {
    final map = <String, dynamic>{
      'mode': mode.wire,
      'seatCount': seatCount,
      'smallBlind': smallBlind,
      'bigBlind': bigBlind,
      'ante': ante,
      'startingStack': startingStack,
    };
    if (mode == SetupMode.custom) {
      map['buttonSeat'] = buttonSeat ?? 0;
      map['heroSeat'] = heroSeat ?? 0;
      map['lineup'] = [
        for (final s in lineup ?? const <TableSetupLineupSeat>[])
          s.toCallableMap(),
      ];
    }
    return map;
  }

  static String _wireArchetype(PlayerArchetype a) {
    return switch (a) {
      PlayerArchetype.callingStation => 'CALLING_STATION',
      PlayerArchetype.hero => 'HERO',
      _ => a.id,
    };
  }
}
