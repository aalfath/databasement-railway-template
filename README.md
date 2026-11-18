# Databasement on Railway

This repo packages [Databasement](https://github.com/David-Crty/databasement), an open-source (MIT) database backup manager with a web UI, as a Railway template.

- **App:** Databasement **v1.10.12**, official image `davidcrty/databasement:1.10.12`, pinned by digest in the [`Dockerfile`](Dockerfile).
- **Services:** one web service (FrankenPHP web server, queue worker and scheduler in one container).
- **Storage:** a Railway volume at `/data` holds the SQLite application database (`/data/database.sqlite`: users, servers, schedules, snapshot records) and the local backup volume (`/data/backups`).
- **Health check:** `/health`.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `APP_KEY` | `${{secret(32)}}` | Laravel encryption key. Encrypts stored credentials and, by default, encrypted backups. Never change it after the first deploy without following upstream's key-rotation steps. |
| `APP_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL used in links. |
| `ADMIN_EMAIL` | `admin@databasement.local` | Login email of the first admin, created on the first boot only. |
| `ADMIN_PASSWORD` | `${{secret(24)}}` | Password of the first admin, created on the first boot only. Read it in the service's Variables tab. |
| `PORT` | `2226` | Port the web server listens on. |

Everything else is fixed in the `Dockerfile` (SQLite on `/data`, production mode, queue worker and scheduler on). Optional upstream settings such as `APP_DISPLAY_TIMEZONE`, `BACKUP_ENCRYPTION_KEY`, SMTP or OAuth/OIDC can be added as variables later: see the [configuration docs](https://david-crty.github.io/databasement/self-hosting/configuration).

## Why the start script

Upstream makes the first visitor to `/register` the super admin. On a public Railway domain that would be whoever finds the URL first. [`railway-start.sh`](railway-start.sh) runs the migrations and [`railway-bootstrap.php`](railway-bootstrap.php) creates the admin from `ADMIN_EMAIL` and `ADMIN_PASSWORD` before the web server starts, so registration is already closed when the domain goes live. It also adds upstream's demo backup (a daily backup of Databasement's own database to the local `/data/backups` volume). It then hands over to the image's own entrypoint unchanged.

## Updates

Each new Databasement release is a commit to `main` here that bumps the pinned image and adds a [`CHANGELOG.md`](CHANGELOG.md) entry. Railway then shows an "update available" notice in projects deployed from this template, and you choose when to apply it. Migrations run automatically on start. Read the changelog first: breaking changes are listed at the top of each entry.
