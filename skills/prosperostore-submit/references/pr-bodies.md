# Pull request bodies

The same title and body go to both catalogs. Fill every placeholder from `draft`'s **Facts** and
`check`'s output; don't leave template comments in. Tick a checkbox only when it is true, and
explain any box left unticked.

## The developer's own app (or an update)

The official catalog's `.github/PULL_REQUEST_TEMPLATE.md`, filled in. Re-read it in
`$PROSPERO_WORKDIR/catalog/.github/` in case it changed.

```markdown
**Title ID:** PPSA01234
**New listing, update or reservation:** new
**What the app does:** <one or two sentences for the reviewer>
**Category:** <category>
**Fork or derivative of an app in the catalog?** no
**Is `source_repo` yours?** yes

- [x] The app is a native PS5 app (its own title with `eboot.bin` and `sce_sys/`), not a payload, PS4 package or backport.
- [x] I am opening this PR from the account that owns `source_repo` (or I am a public member of the owning organization), or I answered "no" above and understand a maintainer must approve it by hand.
- [x] The artifact is a `.zip` of the app folder, the only format accepted at the moment ([artifact formats](https://github.com/darkxex/ps5-homebrew-catalog/blob/main/docs/artifact-formats.md)) whose app uses this title ID.
- [x] For a release: the artifact is attached to a published GitHub release, and `version` is that release's tag (optionally without a leading `v`).
- [x] For a release: `sha256` is the digest of the exact asset in `artifact_url`, and I won't replace that asset.
- [x] For a release: `contentVersion` in my repository's `sce_sys/param.json` is in the `01.000.070` format and higher than my previous release's, so consoles see updates ([App versions](https://github.com/darkxex/ps5-homebrew-catalog/blob/main/docs/versioning.md)).
- [x] The record's `category` is the shelf people would look in first ([categories](https://github.com/darkxex/ps5-homebrew-catalog/blob/main/docs/metadata.md#categories)).
- [x] I have the right to distribute this build under the stated license (for another developer's repository: its license allows redistribution).
- [x] If it builds on an app in the catalog, it is a distinct app (not only a new name, theme or icon) and its name doesn't include that app's name.
- [x] I have read the [review policy](https://github.com/darkxex/ps5-homebrew-catalog/blob/main/docs/review-policy.md).

The same record is submitted to darkxex/ps5-homebrew-catalog and heydemoura/ps5-homebrew-catalog.
```

## Someone else's app (third-party listing)

From the catalog's listing runbook. Every judgment field needs evidence a reviewer can check.

```markdown
Adds <name> (`<TITLEID>`) from <source_repo>.

**Native PS5 app:** `sce_sys/param.json` at `<tag>` has titleId `<TITLEID>` and
titleName `<titleName>`; the release notes/README say to install it by <quote>.

**Release:** <tag> (<release or pre-release>, published <date>), file `<file>`,
GitHub digest `<sha256>`.

**Judgment fields:**
- kind: <kind>, because <reason>
- category: <category>, because <reason>
- description: from the README's <section>
- author: <author>, as credited in <where>
- license: <license>, <"detected by GitHub" or the README quote>

**Publisher:** opened from @<login>, who doesn't own <source_repo>; a maintainer approves it by hand.

**Notes for the reviewer:** <anything unusual: pre-release only, missing or unraised
contentVersion, several param.json files, mixed third-party licenses, …>

The same record is submitted to darkxex/ps5-homebrew-catalog and heydemoura/ps5-homebrew-catalog.
```

## Reservation

```markdown
**Title ID:** PPSA01234
**New listing, update or reservation:** reservation
**What the app does:** <one or two sentences>
**Category:** <category>
**Fork or derivative of an app in the catalog?** no

Reserves the title ID for an unreleased app; `source_repo`, `artifact_url`, `sha256` and
`icon_url` are null. The same record is submitted to darkxex/ps5-homebrew-catalog and
heydemoura/ps5-homebrew-catalog.
```
