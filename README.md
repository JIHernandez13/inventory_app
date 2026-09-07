# inventory_app

## Commit message linting

Commit messages are checked with [gitlint](https://jorisroovers.com/gitlint/) (rules in `.gitlint`).

- **Locally**: install gitlint (`pip install gitlint`) and enable the hook once per clone:

  ```sh
  git config core.hooksPath .githooks
  ```

- **CI**: every pull request is linted automatically (see `.github/workflows/gitlint.yml`).
