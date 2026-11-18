# Changelog

Each entry is one version of this Railway template. Breaking changes come first.
Upstream's own changelog: https://github.com/David-Crty/databasement/blob/main/CHANGELOG.md

## 1.10.12 (2026-11-18)

- First version: Databasement v1.10.12 (`davidcrty/databasement:1.10.12`, pinned by digest `sha256:ecf067e3…b48c9`).
- One service with web server, queue worker and scheduler; SQLite and local backups on a volume at `/data`.
- The admin account is created from `ADMIN_EMAIL` and a generated `ADMIN_PASSWORD` before the web server starts, so the public first-user registration page is never open.
- Health check on `/health`.
