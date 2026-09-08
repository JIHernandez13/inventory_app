# Changelog

All notable changes to this project are documented here, following
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) conventions. This
file (plus the phase tracking issues under
[#4](https://github.com/JIHernandez13/inventory_app/issues/4)) is the
fastest way to catch a new session up on project state — read it before
starting work.

## [Unreleased]

## [0.2.0] - Phase 1 - 2026-09-08

### Added

- Domain models (`ItemCategory`, base `InventoryItem`, `GroceryAttributes`,
  `DurableGoodAttributes`) with `isExpired`/`isExpiringSoon()`/`isLowStock`
  domain logic
- Local drift database: `Items` base table + `GroceryDetails`/
  `DurableGoodDetails` extension tables, UUID ids + timestamps + soft
  delete for future sync-friendliness
- `ItemRepository`/`DriftItemRepository` hiding drift behind a plain
  interface, wrapping storage failures in `ItemStorageException`
- Riverpod `itemListProvider` (reactive via drift `.watch()`) and
  `ItemsNotifier` for create/update/delete
- Minimal, scheme-agnostic CRUD UI: item list with status icons, add/edit
  form, detail view
- Model/repository/provider/widget tests (21 total)

[PR #10](https://github.com/JIHernandez13/inventory_app/pull/10), closes
[#6](https://github.com/JIHernandez13/inventory_app/issues/6).

## [0.1.0] - Phase 0 - 2026-09-08

### Added

- Flutter project scaffold targeting Android and iOS (Linux desktop enabled
  as a local dev/test convenience only)
- Core dependencies: `flutter_riverpod`, `drift` + `sqlite3_flutter_libs`,
  `path_provider`, `uuid`, `shared_preferences`, `intl`
- CI workflow running `flutter analyze`/`flutter test`/format check
  alongside the existing gitlint check
- `CLAUDE.md` and `README.md` rewritten for the Flutter/Dart architecture

[PR #3](https://github.com/JIHernandez13/inventory_app/pull/3), closes
[#5](https://github.com/JIHernandez13/inventory_app/issues/5).
