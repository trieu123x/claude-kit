---
name: kit-setup
description: One-time setup of the starter kit for this project. Detects the stack and real commands, fills in CLAUDE.md, adds safe allow rules, and optionally adds a format-on-edit hook. Run after installing the kit or when the stack changes.
disable-model-invocation: true
argument-hint: "[short description of the project, for an empty repo]"
---

Set up the Claude starter kit for this project. Work through these steps in order and show the user what you will change before you write it.

User notes: $ARGUMENTS

## 0. Merge kit files into existing ones

The installer never overwrites files the project already had. Instead it saves the kit's versions next to them:
- `.claude/CLAUDE.kit-template.md`: merge its sections (above all, "How we work") into the existing `CLAUDE.md`. Keep the project's existing content, and drop anything duplicated or contradictory after asking which to keep.
- `.claude/settings.kit.json`: merge its `permissions.deny`, `permissions.ask` and `hooks.PreToolUse` guard entry into the existing `.claude/settings.json`. Don't remove the project's own rules. The result must be valid JSON.

Delete each sidecar file once it's merged. If neither exists, skip this step.

## 1. Understand the project

- Read the README, manifests (`package.json`, `pom.xml`, `build.gradle*`, `settings.gradle*`, `pyproject.toml`, `requirements*.txt`, `go.mod`, `Cargo.toml`, `*.csproj`, `composer.json`, `Gemfile`), `Makefile`/`justfile`, `docker-compose*.yml`, CI workflows (`.github/workflows/*`), and the top two levels of the tree.
- For a monorepo, list each package or app and its stack.
- **Empty or near-empty repo:** don't guess. Use AskUserQuestion to ask about the language, framework, database, package manager and test framework, then fill CLAUDE.md from the answers and mark commands as "not verified yet".

## 2. Find and verify the commands

For each of Install, Dev, Build, Test (all), Test (one), Lint, Format and Typecheck:
- Take the command from CI config or manifest scripts. CI shows what actually runs.
- Run each one that is quick and side-effect free (build, test, lint, typecheck) to confirm it works. Ask before running anything slow, anything that needs services, or anything that writes outside the repo. Don't start the dev server.
- For "Test (one)", give the real syntax for running a single test file or test name with this test framework.
- Drop any line that doesn't apply. Don't keep placeholders.

## 3. Fill in CLAUDE.md

Replace every placeholder in `CLAUDE.md` and remove the `<!-- -->` guidance comments. Rules:
- Keep it short, under ~100 lines. Include only what Claude can't work out by reading code: exact commands, non-default conventions, gotchas, generated directories not to edit, required env var *names* (never values).
- Keep the "How we work" section as it is, unless the user asks for changes.
- If a CLAUDE.md or AGENTS.md already had project content before the kit was installed, merge it in. Don't drop it.
- For conventions that only matter in part of the tree (for example, only in `frontend/`), offer to put them in `.claude/rules/<name>.md` with `paths:` frontmatter instead.

## 4. Permissions

In `.claude/settings.json`, add `permissions.allow` rules for the verified build, test, lint, format and typecheck commands, so they run without prompts. Use the narrowest pattern that works, for example `"Bash(npm run test *)"` or `"Bash(./gradlew test *)"`, and add a matching `PowerShell(...)` rule when the command also runs from PowerShell on Windows. Don't touch the existing `deny`/`ask` rules or the guard hook.

## 5. Optional: format on edit

If the project has a formatter that can format one file quickly (Prettier, Black, gofmt, rustfmt, Spotless, ktlint), ask the user whether to add a PostToolUse hook that formats each file after Claude edits it. If they agree, add it to `.claude/settings.json` under `hooks.PostToolUse` with matcher `Edit|Write`. Use exec form (`"command"` plus `"args"`) where possible, and keep the hook from failing on files the formatter doesn't handle.

## 6. Report

Show:
- the detected stack,
- each command and whether you verified it (✅ ran OK / ⚠️ not run / ❌ failed, with the error),
- the files you changed,
- anything the user should fill in by hand.

Then suggest committing `CLAUDE.md` and `.claude/`.
