# CLAUDE.md - AI Assistant Guidelines for inventory_app

## Project Overview

**inventory_app** is a Rust-based inventory management application.

- **Language**: Rust
- **Build System**: Cargo
- **License**: GPL v3
- **Status**: Early development (skeleton project)

## Repository Structure

```
inventory_app/
├── .git/              # Git repository
├── .gitignore         # Rust/Cargo ignore patterns
├── LICENSE            # GPL v3 license
├── README.md          # Project documentation
├── CLAUDE.md          # AI assistant guidelines (this file)
├── Cargo.toml         # (To be created) Package manifest
└── src/               # (To be created) Source code directory
    └── main.rs        # (To be created) Application entry point
```

## Build Commands

Once `Cargo.toml` and source files are created:

```bash
# Build the project (debug mode)
cargo build

# Build for release
cargo build --release

# Run the application
cargo run

# Run tests
cargo test

# Check code without building
cargo check

# Format code
cargo fmt

# Run linter
cargo clippy

# Generate documentation
cargo doc --open
```

## Development Workflow

### Setting Up the Project

1. Create `Cargo.toml` with project metadata:
   ```toml
   [package]
   name = "inventory_app"
   version = "0.1.0"
   edition = "2021"
   authors = ["Jesus Hernandez <jihernandez9513@gmail.com>"]
   license = "GPL-3.0"

   [dependencies]
   # Add dependencies here
   ```

2. Create `src/main.rs` for the application entry point

3. Run `cargo build` to verify setup

### Git Workflow

- Main development branch: `main`
- Feature branches: `feature/<feature-name>`
- Bug fix branches: `bugfix/<issue-description>`
- Commit messages should be descriptive and follow conventional commits

### Before Committing

1. Run `cargo fmt` to format code
2. Run `cargo clippy` to check for lints
3. Run `cargo test` to ensure all tests pass
4. Run `cargo check` to verify compilation

## Rust Coding Conventions

### Code Style

- Follow the [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- Use `rustfmt` for consistent formatting
- Use `clippy` for linting and best practices
- Prefer `snake_case` for functions and variables
- Use `CamelCase` for types and traits
- Use `SCREAMING_SNAKE_CASE` for constants

### Error Handling

- Use `Result<T, E>` for recoverable errors
- Use `Option<T>` for optional values
- Avoid `unwrap()` in production code; prefer `?` operator or explicit handling
- Create custom error types when appropriate using `thiserror` or similar

### Documentation

- Add doc comments (`///`) to all public items
- Include examples in documentation where helpful
- Use `//!` for module-level documentation

### Testing

- Place unit tests in the same file with `#[cfg(test)]` module
- Place integration tests in `tests/` directory
- Use descriptive test names: `test_<function>_<scenario>_<expected_behavior>`
- Aim for good test coverage of business logic

## Project Architecture (Suggested)

For an inventory application, consider this structure:

```
src/
├── main.rs           # Entry point, CLI handling
├── lib.rs            # Library root (if building as library)
├── models/           # Data structures
│   ├── mod.rs
│   ├── item.rs       # Inventory item model
│   └── category.rs   # Category model
├── storage/          # Data persistence
│   ├── mod.rs
│   └── database.rs   # Database operations
├── commands/         # CLI commands or API handlers
│   ├── mod.rs
│   ├── add.rs
│   ├── remove.rs
│   ├── list.rs
│   └── update.rs
└── utils/            # Utility functions
    └── mod.rs
```

## Common Dependencies (Suggestions)

```toml
[dependencies]
# CLI argument parsing
clap = { version = "4", features = ["derive"] }

# Serialization
serde = { version = "1", features = ["derive"] }
serde_json = "1"

# Database (SQLite)
rusqlite = { version = "0.31", features = ["bundled"] }

# Error handling
thiserror = "1"
anyhow = "1"

# Async runtime (if needed)
tokio = { version = "1", features = ["full"] }

[dev-dependencies]
# Testing utilities
tempfile = "3"
```

## Key Patterns

### Inventory Item Example

```rust
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct InventoryItem {
    pub id: u64,
    pub name: String,
    pub quantity: u32,
    pub category: Option<String>,
    pub unit_price: f64,
}
```

### Result Type Pattern

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum InventoryError {
    #[error("Item not found: {0}")]
    ItemNotFound(u64),
    #[error("Database error: {0}")]
    DatabaseError(#[from] rusqlite::Error),
    #[error("Invalid quantity: {0}")]
    InvalidQuantity(i32),
}

pub type Result<T> = std::result::Result<T, InventoryError>;
```

## AI Assistant Notes

### When Working on This Project

1. **Check current state first**: Always verify what files exist before making changes
2. **Follow Rust idioms**: Use pattern matching, iterators, and ownership correctly
3. **Test your changes**: Ensure `cargo check` passes before committing
4. **Maintain consistency**: Follow existing code style if source files exist
5. **Document public APIs**: Add doc comments to public functions and types

### Common Tasks

- **Adding a feature**: Create appropriate modules, update `mod.rs` files, add tests
- **Fixing a bug**: Write a test that reproduces the bug first, then fix
- **Refactoring**: Ensure tests pass before and after changes
- **Adding dependencies**: Update `Cargo.toml`, document why the dependency is needed

### Things to Avoid

- Don't use `unwrap()` or `expect()` without good reason
- Don't ignore clippy warnings
- Don't commit unformatted code
- Don't break existing tests
- Don't add unnecessary dependencies

## File Locations Reference

| Purpose | Location |
|---------|----------|
| Package manifest | `Cargo.toml` |
| Main entry point | `src/main.rs` |
| Library root | `src/lib.rs` |
| Unit tests | Same file as code |
| Integration tests | `tests/` |
| Examples | `examples/` |
| Benchmarks | `benches/` |
| Build scripts | `build.rs` |

## Links and Resources

- [Rust Book](https://doc.rust-lang.org/book/)
- [Rust by Example](https://doc.rust-lang.org/rust-by-example/)
- [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/)
- [Clippy Lints](https://rust-lang.github.io/rust-clippy/master/index.html)
- [Cargo Book](https://doc.rust-lang.org/cargo/)
