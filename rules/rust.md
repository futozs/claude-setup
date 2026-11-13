---
paths:
  - "**/*.rs"
  - "**/Cargo.toml"
---
# Rust

- `cargo clippy -- -D warnings`, `cargo fmt`, and `cargo test` clean before done.
- Errors: `thiserror` in libraries, `anyhow` in binaries; `?` over `unwrap()`/`expect()` outside tests and truly-impossible cases.
- Borrow instead of clone unless ownership is needed; no `unsafe` without a `// SAFETY:` comment explaining the invariant.
