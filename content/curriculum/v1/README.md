# Curriculum v1 (canonical source)

This directory is the **canonical curriculum source** for the learning platform.

- Edit `catalog.json` (and `schemas/curriculum.schema.json`) here.
- Curated static exercises live under `exercises/` and are referenced by lesson
  `exerciseRefs` (copied into `functions/src/generated/exercises/` for callables).
- Generated Dart/TypeScript catalogs derived from this source **must not be hand-edited**.
- Bump `catalogVersion` when the catalog content changes in a way clients must detect.
