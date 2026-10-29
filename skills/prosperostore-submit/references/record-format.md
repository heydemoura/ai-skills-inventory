# Record format

Condensed from the official catalog's `docs/metadata.md` and `docs/submitting.md`. When they
disagree, the docs in `$PROSPERO_WORKDIR/catalog/docs/` win.

## File

- `apps/<TITLEID>.json`, or `apps/<TITLEID>-<owner>.json` when a *different* app already holds
  the plain title ID (`<owner>` is the `source_repo` owner in lowercase). The filename without
  `.json` is the app's permanent **id**. Reservations always use the plain title ID.
- One UTF-8 JSON object, at most 8 KiB, exactly the twelve fields below (plus `icon_member` and
  `internalOnly` when used). No missing or extra fields, no duplicate keys.
- Values are non-empty strings. `null` only in reservations (and `icon_url` beside `icon_member`).
  Numbers and booleans are rejected, except `internalOnly: true`.
- Two-space indentation, fields in this order.

## Fields

| Field | Max | Rules |
| --- | ---: | --- |
| `titleid` | 9 | `[A-Z]{4}[0-9]{5}`; not `CUSA…`/`NPXS…`; not `PPSA99999`. Equals the filename's start and `titleId` in `sce_sys/param.json`. Non-`PPSA` prefixes are listed under `shared` in the API (ProsperoStore before 1.000.110 doesn't show them). |
| `name` | 64 | Display name, unique ignoring case. |
| `kind` | 4 | `app`, `game` or `tool`. |
| `category` | 16 | One of the categories below. |
| `description` | 200 | One plain-text sentence. |
| `license` | 64 | SPDX id or expression (`GPL-3.0`, `MIT OR Apache-2.0`), agreeing with what GitHub detects for `source_repo`. Repos with no detected license are listed as `Unlicensed`. |
| `author` | 64 | Developer or publisher as they want to be credited. |
| `version` | 32 | The release tag in `artifact_url`, optionally without a leading `v`. Letters, digits and `. + _ -`. |
| `source_repo` | 200 | `https://github.com/<owner>/<repo>` with GitHub's exact capitalization; public. |
| `artifact_url` | 500 | `<source_repo>/releases/download/<tag>/<asset>.zip` of a published release. No `/releases/latest/download/`. Unique in the catalog. |
| `sha256` | 64 | GitHub's digest of that asset, 64 lowercase hex, no `sha256:` prefix. Unique in the catalog. |
| `icon_url` | 500 | Direct HTTPS link ending in `.png`/`.jpg`/`.jpeg`/`.webp` returning that type, ≤ 2 MiB, square, pinned to a tag or commit. |

### Optional fields

- `internalOnly: true` — the store always installs the app on internal storage
  (`/data/homebrew`). Only value allowed is `true`; omit for the default.
- `icon_member` — for repos that ship `param.json` and the icon only inside the zip: path of the
  icon inside the zip, next to the `param.json` (e.g. `PPSA01234/sce_sys/icon0.png`); `icon_url`
  is then `null`. No leading `/`, `..`, empty parts or backslashes.

## Categories

| `category` | For |
| --- | --- |
| `console-ports` | Console games rebuilt natively (decompilations, recompilations); usually need your own game data. |
| `pc-ports` | Games from PC: released source, open-source games, engine rewrites. |
| `homebrew-games` | Games made for the PS5. |
| `emulators` | Emulators and loaders for other systems. |
| `streaming` | Cloud gaming and remote play. |
| `video` | Video players, media centres, streaming services and companions. |
| `music` | Music players, radio, audio services. |
| `ai` | Language models and other AI running on the console. |
| `utilities` | Files, launchers, backups, system helpers. |
| `tools` | Controller, screen and sound checks and tuning. |
| `showcases` | Tech demos and developer kits. |

## Text rules

NFC-normalized Unicode, no leading/trailing whitespace, no control characters, line breaks,
zero-width or bidirectional formatting characters, private-use or unassigned code points.

## Versions

`version` is only for display. Consoles detect updates with `contentVersion` (`NN.NNN.NNN`) from
`sce_sys/param.json` at the release tag (else from the zip, else from `version` when it already
has that format). Raise it every release, never lower or reuse it. Simplest scheme: tag releases
with the content version itself (`01.000.070`).

## Check failures

| Message contains | Fix |
| --- | --- |
| `does not own` (warning) | PR author doesn't own `source_repo`: a maintainer approves by hand. Open from the owner's account, or make org membership public. |
| `only its owner or the account` | Listed app: only the repo owner or the account that listed it can change it. |
| `sha256 does not match` | Recompute: `python3 -m catalog digest <artifact_url>` or copy the digest `draft` reports. |
| `artifact_url must be` | Link a specific release asset ending in `.zip`. |
| `version must match the release tag` | `version` = tag in `artifact_url`, optionally without leading `v`. |
| `no contentVersion found` (warning) | Commit `sce_sys/param.json` with `titleId` and `contentVersion`, or tag with the content version. |
| `contentVersion … is not higher` (warning) | The release didn't raise `contentVersion`; consoles won't see it as an update. |
| `license ... does not match` | Use the SPDX id GitHub shows for the repo. |
| `filename must be … when another app already uses` | `<TITLEID>.json`, or `<TITLEID>-<owner>.json` with the lowercase `source_repo` owner. |
| `name duplicates` | Choose a distinct name. |
| `canonical URL` | Match the repo's exact owner/name capitalization. |
| `may change only apps/` | Remove other files from the PR. |
| `must be null in a reservation` | With `artifact_url` null, `source_repo`, `icon_url`, `sha256` must be null too. |
| `must not be null` | Only reservations may use `null`, and only for link, hash, version and license. |
| `reserved by @…` | Only the reserving account can change it. |
| `already holds 5 reservations` | Release or remove one reservation first. |
