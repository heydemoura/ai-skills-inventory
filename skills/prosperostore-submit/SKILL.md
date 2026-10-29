---
name: prosperostore-submit
description: Submit a native PS5 homebrew app to the ProsperoStore catalog — list a new app, update a listed app to a new release, or reserve a title ID — by writing its apps/<TITLEID>.json record and opening matching pull requests on both darkxex/ps5-homebrew-catalog (official, prosperostore.net) and heydemoura/ps5-homebrew-catalog (mirror). Use when asked to publish, list, submit, release or update a PS5 app in ProsperoStore or the PS5 homebrew catalog.
metadata: {"openclaw":{"emoji":"🎮","requires":{"bins":["gh","git","python3"]}}}
---

# ProsperoStore App Submission

[ProsperoStore](https://github.com/darkxex/ProsperoStore) is the native PS5 app store. It installs
apps from a **catalog**: a GitHub repository holding one small JSON record per app, built into a
store API on GitHub Pages. The catalog stores no binaries; each record points at a `.zip` the
developer attached to a GitHub release, pinned by sha256.

Every submission goes to **both** catalogs, with the identical record:

| Catalog | Role | Store reads it from |
| --- | --- | --- |
| `darkxex/ps5-homebrew-catalog` | Official; maintainers review and merge; feeds prosperostore.net | `https://prosperostore.net/api/v1/` (signed) |
| `heydemoura/ps5-homebrew-catalog` | Fork/mirror; same tooling, plus a fork-aware deploy | `https://heydemoura.github.io/ps5-homebrew-catalog/api/v1/` (unsigned) |

On the console, the mirror is added under **Settings → Catalogs → Add a catalog** as
`heydemoura/ps5-homebrew-catalog`, with **Verify custom catalog signatures** off. Where both
catalogs list the same title ID, the official one wins and the store hides the duplicate.

The authoritative rules live in the official catalog's docs; read them in the workspace clone
when something here is unclear or seems out of date: `docs/submitting.md`, `docs/metadata.md`,
`docs/versioning.md`, `docs/artifact-formats.md`, `docs/review-policy.md`,
`docs/maintainers/listing-runbook.md` and `.github/PULL_REQUEST_TEMPLATE.md`.

## Rules

- **One app per pull request, and the PR changes only `apps/<id>.json`.** Anything else fails
  the submission check.
- **The record must be byte-identical in both catalogs.** The mirror merges the official catalog
  regularly; differing copies of the same file conflict. Any change asked for on one PR goes to
  both (re-run `open`, below).
- **Never download, unzip or run release files.** The sha256 is GitHub's own digest of the asset;
  "native" is judged from the repository's `sce_sys/param.json`. The catalog tooling never
  downloads artifacts either.
- **Never merge, approve or close** the pull requests, and never replace a listed release asset
  (its sha256 would stop matching; that is treated as a security incident). Open the PRs and stop.
- **Listing someone else's app** (`source_repo` not owned by the GitHub account opening the PR):
  allowed, but it gets a warning and the `third-party` label, and only a maintainer can merge it.
  `author` must name the real developer. Don't contact the developer or open issues on their repo.
- **Stop and report instead of guessing** on any stop condition (see
  [Stop conditions](#stop-conditions)). A skipped app is fine; a wrong listing isn't.
- Confirm with the user before running `open` without `--dry-run`: it pushes branches and opens
  public pull requests.

## Helper script

`scripts/catalog-submit.sh` (bash, needs `git`, `gh` logged in to github.com, `python3` ≥ 3.10)
keeps a workspace at `~/.cache/prosperostore-submit` (`PROSPERO_WORKDIR`) with the official
catalog in `catalog/` and the mirror's `main` as a worktree in `mirror/`. It runs the catalogs'
own tooling (`python3 -m catalog …`, standard library only).

| Command | Does |
| --- | --- |
| `setup` | Clone or refresh both catalogs and reset both worktrees to their `main`. Run first; it also says when the mirror is behind. |
| `draft <owner/repo> [--tag T] [--asset A]` | Print the record GitHub can prove (title ID, name, version, URLs, sha256, icon, license, author) with **Blockers**, **To do** and **Facts**. Exits 1 when there are blockers. |
| `check <record.json>` | Copy the record into each catalog and run `catalog check` (offline format and uniqueness) and `catalog verify <id>` (release, tag, sha256 digest, icon, license, contentVersion). |
| `open <record.json> --message M --body F [--dry-run]` | Commit the record on `listing/<id>` (from official `main`) and `listing/<id>-mirror` (from mirror `main`), push both to the submitter's fork, and open one PR per catalog. Re-running pushes a follow-up commit to the same branches; open PRs update. |

The record file name **is** the record id: `PPSA01234.json`, or `PPSA01234-<owner>.json` for a
shared title ID. Keep records outside the workspace clones, e.g. in `$PROSPERO_WORKDIR/records/`.

Branches are pushed to `<login>/ps5-homebrew-catalog` (any repo in the catalog's fork network;
override with `PROSPERO_PUSH_REPO`), forking the official catalog if needed. For the mirror's
owner that is the mirror itself, which is fine.

## Workflow

### 1. Work out what is being submitted

- **New listing**, **update** (a listed app moves to a newer release) or **reservation** (hold a
  title ID for an unreleased app; see [Reservations](#reservations)).
- Who will open the PR (`gh api user --jq .login`) and whether that account owns `source_repo`.
- Whether the app is already listed: after `setup`, look for `apps/<TITLEID>*.json` in
  `$PROSPERO_WORKDIR/catalog/apps/` and `$PROSPERO_WORKDIR/mirror/apps/`, and search by repo:
  `grep -l '"source_repo": "https://github.com/<owner>/<repo>"' "$PROSPERO_WORKDIR"/catalog/apps/*.json`.
- For an update, first check for an open bot PR: the official catalog's daily job usually
  proposes new releases itself (`gh pr list -R darkxex/ps5-homebrew-catalog --search <TITLEID>`).
  If one is open there, submit only to the mirror if it lacks the update, and say so.

### 2. Make sure the app's repository qualifies

The catalog needs all of these; `draft` reports what's missing:

- **Native PS5 app**: its own title with `eboot.bin` and `sce_sys/param.json`. ELF payloads, PS4
  packages (`CUSA…`), backports, ROMs and web pages are out of scope.
- **Public GitHub repository** with the source, ideally with a `LICENSE` GitHub detects.
- **Published GitHub release** (pre-release OK; not a draft) **tagged with the app's version**
  (`v1.2.0`, `01.000.005`; never `latest`/`nightly`/`release`).
- **One `.zip` of the app folder** attached to it, with `<TITLEID>/` at the top of the archive
  (`.ffpkg`/`.ffpfsc` images aren't accepted). Recommended asset name: `<TITLEID>.zip`.
- **`contentVersion` in `sce_sys/param.json`** committed at the tag, format `NN.NNN.NNN`, raised in
  every release; consoles use it to see updates. Missing or unraised is a warning, not a blocker.
- **Title ID**: four uppercase letters + five digits (`PPSA01234`; custom prefixes like `FAKE77031`
  OK; not `CUSA`/`NPXS`; not `PPSA99999`, the boilerplate default). It must match
  `titleId` in `param.json` and stay the same for the app's whole life.
- **Square icon** (PNG/JPEG/WebP, 512×512 recommended, ≥ 256, ≤ 2 MiB) at a URL pinned to a tag
  or commit; `sce_sys/icon0.png` in the repo at the tag is the usual choice.

When you are helping the developer and can change their repo, fix gaps there before submitting:
raise `contentVersion` and commit it, build from that commit, tag it, publish the release with the
zip and release notes ("what changed" first, `###` headings and flat bullets; images, links and
HTML are dropped). `docs/versioning.md` has the checklist.

### 3. Draft the record

```sh
S=<this skill's directory>/scripts/catalog-submit.sh
"$S" setup
"$S" draft <owner>/<repo>                                  # newest release, pre-releases included
"$S" draft <owner>/<repo> --tag <tag> --asset <file.zip>   # pick a release or the app's own file
```

Any **blocker** is a stop condition, except "already listed" when you are doing an update (then
edit the existing record instead). Work through every **To do** item.

### 4. Write the record

Write `$PROSPERO_WORKDIR/records/<id>.json`: UTF-8, two-space indent, the field order below,
trailing newline. For an update, start from a copy of the listed `apps/<id>.json` and change only
`version`, `artifact_url`, `sha256` and, if it moved, `icon_url`.

```json
{
  "titleid": "PPSA01234",
  "name": "Example App",
  "kind": "app",
  "category": "utilities",
  "description": "One short sentence about the app.",
  "license": "GPL-3.0",
  "author": "Example Dev",
  "version": "1.2.0",
  "source_repo": "https://github.com/example/example-app",
  "artifact_url": "https://github.com/example/example-app/releases/download/v1.2.0/PPSA01234.zip",
  "sha256": "<64 lowercase hex characters>",
  "icon_url": "https://raw.githubusercontent.com/example/example-app/v1.2.0/sce_sys/icon0.png"
}
```

Keep the drafted `titleid`, `version`, `source_repo`, `artifact_url`, `sha256`, `icon_url` and
`license`. Decide the judgment fields:

| Field | How to decide |
| --- | --- |
| `name` | `titleName` from `param.json`. Unique in the catalog (case-insensitive); a derivative must not contain a listed app's name. |
| `kind` | `game` for games, `tool` for utilities/system tools, `app` for everything else (players, emulators, clients). |
| `category` | The shelf people would look in first: `console-ports`, `pc-ports`, `homebrew-games`, `emulators`, `streaming`, `video`, `music`, `ai`, `utilities`, `tools`, `showcases`. |
| `description` | One factual plain-text sentence, ≤ 200 characters, from the README. No marketing, emoji, Markdown or claims the README doesn't make. |
| `author` | How the developer credits themselves (README, release notes). |
| `license` | GitHub's SPDX id. If GitHub detects none, the SPDX id the README states for the project's own code (quote it in the PR); if none anywhere, stop. |

Exact field limits, optional `internalOnly` and `icon_member`, shared title IDs and text rules are
in [references/record-format.md](references/record-format.md).

### 5. Validate in both catalogs

```sh
"$S" check "$PROSPERO_WORKDIR/records/<id>.json"
```

Errors must be fixed before opening PRs (the message table in
[references/record-format.md](references/record-format.md#check-failures) says how).
Warnings (third-party, contentVersion) are allowed but must be mentioned in the PR body.

### 6. Write the PR body and open the pull requests

Write the body from [references/pr-bodies.md](references/pr-bodies.md): the catalog's PR template
for the developer's own app, or the evidence body for a third-party listing. The same body and
title go to both catalogs. Titles follow the catalog's history:
`List <name> by <author>`, `Update <name> to <version>`, `Reserve <TITLEID>: <name>`.

```sh
"$S" open "$PROSPERO_WORKDIR/records/<id>.json" --message "List <name> by <author>" \
  --body "$PROSPERO_WORKDIR/records/<id>.md" --dry-run   # review what it will do
"$S" open "$PROSPERO_WORKDIR/records/<id>.json" --message "List <name> by <author>" \
  --body "$PROSPERO_WORKDIR/records/<id>.md"             # after the user confirms
```

### 7. Follow the checks, then stop

```sh
gh pr checks <number> -R darkxex/ps5-homebrew-catalog --watch
gh pr checks <number> -R heydemoura/ps5-homebrew-catalog --watch
```

- **Validate submission** must pass; its job summary lists every problem. **Scan the release**
  reports what the zip can do outside the sandbox; mention its verdict in the PR if notable.
- On the mirror, jobs that need the official catalog's bot app (the `third-party` label, bump
  auto-merge) can fail or skip for missing secrets; that's expected there.
- To fix something, edit the record and re-run `check` and `open` with a message like
  `Fix <field> for <TITLEID>`; both PRs get the same commit.
- Report both PR URLs, the check results and anything a reviewer must judge. Don't merge.

After the official PR merges, the daily release job keeps the listing on the newest release as long
as the asset name keeps its shape (`app-0.5.0.zip` → `app-0.6.0.zip`) and `icon_url` is pinned.

## Reservations

A title ID for an unreleased app: same twelve fields, with `source_repo`, `artifact_url`,
`sha256` and `icon_url` set to `null` (`version` and `license` may be `null`). It belongs to the
account that opens the PR, at most 5 per account, refreshed at least every 180 days. `check` still
validates it; `verify` skips the release checks until it becomes a release. Skip `draft` (there is
no release) and title the PRs `Reserve <TITLEID>: <name>`. To release it later, fill every field
in a new PR from the same account, which must also own `source_repo`.

## Stop conditions

Report to the user instead of opening PRs when:

- `draft` lists a blocker (other than "already listed" during an update), or `check` reports errors.
- The app is published only outside GitHub releases, or the release tag isn't a version.
- The main file is a payload (`.elf`, `.bin`, `.lua`), a PS4 package, or a `.ffpkg`/`.ffpfsc` image.
- No license is stated anywhere.
- The title ID is already listed by a different project (sharing it needs `<TITLEID>-<owner>.json`
  and the user's decision; a unique title ID is better).
- The repository is a fork or repackage of another developer's app, or a listed app with only a new
  name, theme, icon or settings.
- The app is for piracy, ships commercial content, or its README asks not to be redistributed.
- The repository is archived with no recent release.
