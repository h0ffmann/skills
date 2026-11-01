---
name: loco
description: "Write, review or debug a Loco app (loco-rs, Rails for Rust): controllers, Sea-ORM models, migrations, workers, tasks and mailers. Use for AppContext, cargo loco, or a Loco app on a NixOS host."
---

# loco

Loco is Rails for Rust. When you are not sure how a thing works, the answer is almost always
"the way Rails does it".

## Three rules

1. **Generate, then edit.** `cargo loco generate <thing>` writes the file and its wiring: the
   `mod` lines, the routes, the worker registration. Rust has no autoload. Wiring by hand gives
   code that exists but nothing reaches.
2. **Use the batteries.** Loco has an ORM, a queue, a scheduler, a mailer, tasks, storage, a
   cache and a test harness. Do not add a crate for one of these.
3. **Fat model, slim controller.** Finders and creation go on `impl Model`. State changes go on
   `impl ActiveModel`. A handler parses, calls one or two model methods, and renders.

## AppContext

Handlers get `State(ctx): State<AppContext>`.

| Field | Use |
|---|---|
| `ctx.db` | the Sea-ORM `DatabaseConnection` |
| `ctx.config` | the typed `config/<env>.yaml`, the only source of settings |
| `ctx.mailer` | the mailer transport |
| `ctx.storage` | file storage |
| `ctx.cache` | the cache |
| `ctx.queue_provider` | the background queue |
| `ctx.shared_store` | a typed slot for shared state, filled in `Hooks::after_context` |
| `ctx.environment` | the current environment |

## Files

```
src/app.rs              Hooks: routes, workers, tasks, seeds, initializers
src/controllers/        thin handlers and routes()
src/models/_entities/   generated from the schema, never edited by hand
src/models/<name>.rs    the domain logic
src/views/              response types. An entity never goes on the wire
src/workers/            BackgroundWorker implementations
src/tasks/              Task implementations (the rake tasks)
migration/src/          Sea-ORM migrations
config/<env>.yaml       all settings, with middleware and the scheduler
tests/requests/         request tests
```

## Steps

1. Generate the scaffold, model, controller, worker or task.
2. Write the migration. Run it. Generate the entities again from the schema.
3. Put the logic in the model. Keep the handler thin.
4. Write a request test for each route and a model test for each rule.
5. Run `cargo loco doctor`, `cargo test`, `cargo clippy -- -D warnings` and `cargo fmt --check`.

## On the VPS

- Package the app in its own flake. The host declares it as a service with SQLite in
  `/var/lib/<app>`, a daily `sqlite3 .backup`, and nginx with ACME in front.
- Secrets go in an env file on the box, never in the repository.
- Harden the service with `systemd-hardening`. A merge deploys it (see `nixos-vps`).
