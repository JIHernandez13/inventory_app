# inventory_app

A Flutter mobile app (Android + iOS) for tracking groceries, home goods,
appliances, and tools, with a fully on-device database (no cloud sync yet)
and a swappable "inventory scheme" UI — the first scheme is a Legend of
Zelda-inspired inventory grid, with more game-inspired schemes planned.

See [`CLAUDE.md`](CLAUDE.md) for architecture, build/test commands, and
coding conventions.

## Getting started

```sh
flutter pub get
flutter run
```

## Commit message linting

Commit messages are checked with [gitlint](https://jorisroovers.com/gitlint/) (rules in `.gitlint`).

- **Locally**: install gitlint (`pip install gitlint`) and enable the hook once per clone:

  ```sh
  git config core.hooksPath .githooks
  ```

- **CI**: every pull request is linted automatically (see `.github/workflows/gitlint.yml`).
