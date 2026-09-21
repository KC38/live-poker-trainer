# Media catalog (v1)

Draft schemas and manifests for learning-platform and shell media. This folder
is content-only scaffolding — the Flutter app does not load these files yet.

## Layout

| Path | Purpose |
| --- | --- |
| `schemas/media.schema.json` | draft-07 schema for media entries |
| `schemas/character.schema.json` | draft-07 schema for cast members |
| `characters.yaml` | Draft cast (coach + supporting aides) |
| `media.source.yaml` | Placeholder / mapped media entries |
| `licenses.yaml` | License stubs |
| `provenance.yaml` | Provenance stubs |

Creative direction lives under `design/creative_bible/v1/`. Casting rules for
lesson roles live under `design/characters/v1/casting_matrix.yaml`.

## ID conventions

- Media: `media.<kind>.<domain>.<name>` — e.g. `media.sfx.table.deal`
- Characters: `character.coach.primary`, `character.player.01` …
- Licenses: `license.<scope>.<name>.vN`
- Provenance: `provenance.<origin>.<name>.vN`
- Usage slots: `usage.<surface>.…` referenced from `usageIds[]`

## How media IDs will map into the app

Until a runtime media resolver ships, treat IDs as stable contracts:

1. **Content references** lesson JSON / YAML by `media.*` ID (not raw asset
   paths). Lessons never embed `assets/…` strings for illustrated media.
2. **Resolver (future)** loads `media.source.yaml` (or a compiled JSON pack),
   picks a variant by locale + theme + reduced-motion preference, and returns
   a Flutter `ImageProvider` / audio asset key.
3. **URI schemes (draft)**
   - `asset://…` → Flutter asset under `assets/` (strip the scheme; path is
     relative to the assets root declared in `pubspec.yaml`)
   - `placeholder://…` → intentional empty / branded fallback until art lands
4. **Existing sounds** map 1:1 today:

   | Media ID | Repo path | Current runtime |
   | --- | --- | --- |
   | `media.music.shell.lounge` | `assets/sounds/lounge_ambient.mp3` | `SoundService` home BGM |
   | `media.sfx.table.deal` | `assets/sounds/deal.wav` | `SfxKind.deal` |
   | `media.sfx.table.chip` | `assets/sounds/chip.wav` | `SfxKind.chip` |
   | `media.sfx.table.knock` | `assets/sounds/knock.wav` | `SfxKind.knock` |
   | `media.sfx.table.fold` | `assets/sounds/fold.wav` | `SfxKind.fold` |
   | `media.sfx.table.win` | `assets/sounds/win.wav` | `SfxKind.win` |

5. **Accessibility** — non-decorative entries require `altMessageId` (and
   optionally `longDescriptionMessageId`) pointing at the message catalog, not
   inline copy in the media file.
6. **Fallbacks** — `fallbackId` chains to another media entry when a variant
   fails integrity or is missing for the active locale.

## Status gate

`draft` → `approved` → `released`. Do not ship `draft` or `retired` entries to
production packs. Approvals[] records creative / accessibility / legal sign-off.
