# 07 — Reusable components

Prefer composing these before writing a new widget. Paths under `lib/`.

## Poker table (shared Live + Course)

| Component | Path | Use when |
| --- | --- | --- |
| `FeltTableView` | `ui/widgets/felt_table_view.dart` | Any hand on felt |
| `TableFeatures` / `TableFeaturesScope` | `ui/widgets/table_features.dart` | Lesson layer gating |
| `PlayerSeatWidget` | `ui/widgets/player_seat_widget.dart` | Seat pods (usually via felt) |
| `TableCard` / `TableCardBack` | `ui/widgets/table_card.dart` | Card faces |
| `MiniCard` | `ui/widgets/mini_card.dart` | Dense trays — same face |
| `CommunityCardsView` | `ui/widgets/community_cards_view.dart` | Board row |
| `GlowHighlight` | `ui/widgets/glow_highlight.dart` | SoftPulse / selection rings |
| `ActionBadge` | `ui/widgets/action_badge.dart` | CHECK / FOLD / etc. on felt |
| `ActionDockWidget` | `ui/widgets/action_dock_widget.dart` | Live / authored hero actions |
| `CoachShelfWidget` | `ui/widgets/coach_shelf_widget.dart` | Live coaching shelf |
| `HeroRailWidget` | `ui/widgets/hero_rail_widget.dart` | Hero rail chrome when needed |
| `TendencyProfileSheet` | `ui/widgets/tendency_profile_sheet.dart` | Villain reads |
| `PokerTableBands` helpers | `ui/widgets/poker_table_bands.dart` | Build lesson `GameState`s |

Deal controllers: `core/deal/felt_deal_controller.dart`,
`felt_action_reveal_controller.dart`, pacing in `card_deal_pace.dart`.

## Lesson frame

| Component | Path | Use when |
| --- | --- | --- |
| `LessonScreenLayout` | `ui/course/widgets/lesson_screen_layout.dart` | Every framed lesson step |
| `LessonTableStage` | `ui/course/widgets/lesson_table_stage.dart` | Stage region |
| `LessonChromeBar` / coach band / tools / dock | same file / siblings | Frame regions |
| `RexCoachLine` | `ui/course/widgets/rex_coach_line.dart` | Coach copy helpers |
| `LessonSoftPulseScope` | `ui/course/widgets/lesson_soft_pulse_scope.dart` | Cue gating |
| `LessonFrameScope` | `ui/course/widgets/lesson_frame_scope.dart` | Frame context |
| `HeartRefillSheet` | `ui/course/widgets/heart_refill_sheet.dart` | Out of hearts |
| `ActivityRegistry` | `ui/course/activity_registry.dart` | Renderer → widget |

Activity widgets live in `ui/course/activities/`. Demo widgets for advanced
concepts live in `ui/course/widgets/*_demo.dart` — reuse before inventing.

## Home / shell / brand

| Component | Path |
| --- | --- |
| `CoursePathView` | `ui/home/course_path_view.dart` |
| `CourseStatusBar` | `ui/home/course_status_bar.dart` |
| `CourseSectionPicker` | `ui/home/course_section_picker.dart` |
| `ShellBottomNav` | `ui/widgets/shell_bottom_nav.dart` |
| `RexMascot` | `ui/widgets/rex_mascot.dart` |
| `BrandLogo` | `ui/widgets/brand_logo.dart` |
| `ProfileAvatar` | `ui/widgets/profile_avatar.dart` |

## Theme / constants

| Module | Path |
| --- | --- |
| `AppTheme` | `ui/theme/app_theme.dart` |
| `AppColors` | `core/constants/colors.dart` |
| Chip display | `core/constants/chip_format.dart` |
| Money / cents | `core/constants/money.dart` |

## Anti-patterns

- New "mini table" for one lesson.
- Second card face art.
- Second coach mascot or letter avatar for Rex.
- Duplicating lesson chrome (title under progress, extra footer).
- Copy-pasting SoftPulse logic instead of `GlowHighlight` /
  `LessonSoftPulseScope`.

When you add a reusable widget that others should prefer, add a row here
and a short library comment pointing at this section.
