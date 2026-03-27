# Release Gem

Cut a new release for a gem in the craftos monorepo. This skill handles version bumps, changelog updates, branch creation, and PR filing so the GitHub Actions release workflow can publish to RubyGems.

## Arguments

$ARGUMENTS — the gem name and version, e.g. `yarn_skein 0.3.0`. If omitted or incomplete, detect from context (unreleased changelog entries, recent commits).

## Steps

### 1. Parse arguments

Extract `<gem_name>` and `<version>` from the arguments.

Valid gem names live under `gems/` — currently: `fiber_units`, `fiber_gauge`, `yarn_skein`, `fiber_pattern`.

If the gem name is missing, ask which gem to release.

If the version is missing, read the gem's current `version.rb` and `CHANGELOG.md` and infer the next version:
- If `[Unreleased]` has `### Added` entries → bump **minor**
- If `[Unreleased]` has only `### Fixed` / `### Changed` entries → bump **patch**
- Propose the inferred version and ask the user to confirm before proceeding.

### 2. Validate preconditions

Before making any changes, verify:

1. The working tree is clean (`git status --porcelain` is empty). If not, warn and stop.
2. The gem directory `gems/<gem_name>` exists.
3. The gem's `CHANGELOG.md` has content under `## [Unreleased]` (otherwise there's nothing to release).
4. The tag `<gem_name>-v<version>` does not already exist.
5. A branch `release/<gem_name>-v<version>` does not already exist locally or on origin.

If any check fails, report the issue and stop.

### 3. Create release branch

```
git checkout -b release/<gem_name>-v<version> main
```

### 4. Bump version

Edit `gems/<gem_name>/lib/<gem_name>/version.rb` — change the `VERSION` constant to the new version string.

### 5. Update changelog

Edit `gems/<gem_name>/CHANGELOG.md`:

1. Move all content under `## [Unreleased]` into a new section `## [<version>] - <today's date YYYY-MM-DD>` inserted immediately after the empty `## [Unreleased]` heading.
2. Leave the `## [Unreleased]` section with no content (just the heading, followed by a blank line, then the new version section).

### 6. Run tests

Run the gem's test suite to make sure everything passes:

```
cd gems/<gem_name> && bundle exec rake test
```

If tests fail, report the failure and stop — do NOT commit broken code.

### 7. Commit

Stage only files under `gems/<gem_name>/` and commit:

```
git add gems/<gem_name>/lib/<gem_name>/version.rb gems/<gem_name>/CHANGELOG.md
git commit -m "chore(<gem_name>): release v<version>"
```

### 8. Push and create PR

```
git push -u origin release/<gem_name>-v<version>
```

Create a PR targeting `main` using `gh pr create`:

- **Title:** `release(<gem_name>): v<version>`
- **Body:**

```
## Summary

Release `<gem_name>` v`<version>`.

### Changes

<paste the changelog entries for this version here>

## Checklist

- [x] Version bumped in `version.rb`
- [x] Changelog updated with release date
- [x] `[Unreleased]` section is empty
- [x] Tests pass
- [x] Branch follows `release/<gem>-v<version>` convention

> Merging this PR will trigger the release workflow to publish to RubyGems and create a GitHub release.
```

### 9. Report

Print the PR URL and a summary of what was done.

## Important

- Only touch files in the target gem's directory. The release workflow enforces single-gem PRs.
- Always use today's date for the changelog heading.
- Never force-push the release branch.
- If anything goes wrong after the branch is created, tell the user what happened and how to clean up (delete the branch) rather than silently recovering.
