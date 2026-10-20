# PROJECT_NAME

<!-- kit-setup: replace this file's placeholders by running /kit-setup, then delete these comments. Keep the file under ~100 lines; every line loads into every session. -->

ONE_LINE_DESCRIPTION

## Stack

<!-- e.g. Java 21 (plain sockets, no framework) · Next.js 15 App Router · PostgreSQL 16 -->
- STACK

## Commands

<!-- Exact commands, verified to run. test-runner and the skills read this section. -->
- Install: `INSTALL_CMD`
- Dev: `DEV_CMD`
- Build: `BUILD_CMD`
- Test (all): `TEST_CMD`
- Test (one): `TEST_ONE_CMD`
- Lint: `LINT_CMD`
- Format: `FORMAT_CMD`
- Typecheck: `TYPECHECK_CMD`

## Layout

<!-- Only what Claude can't infer quickly from the tree: entry points, generated dirs not to edit, where tests live. -->
- LAYOUT

## Conventions

<!-- Only rules that differ from the language's defaults or that Claude got wrong before. -->
- CONVENTIONS

## Gotchas

<!-- Required env vars, services that must be running, slow or flaky tests, ports. -->
- GOTCHAS

## How we work

- Talk to me in Vietnamese. Write code, comments, commit messages and docs in English.
- Big or unclear work: `/spec` first, then `/feature <spec>`. Bugs: `/fix`. Before committing: `/ship`.
- If the diff fits in one sentence, skip the plan and just do it.
- Prove that work is done with evidence: the command you ran and its result. Never say "should work".
- Use the `test-runner` subagent for test or build runs with long output, `reviewer` before committing, `security-reviewer` when touching auth, input parsing, SQL, shell or network code, and `docs-researcher` for library questions.
- Follow the patterns already in the codebase. Don't add a dependency, change public APIs or touch unrelated code without asking.
- When compacting, keep the list of modified files, the active spec path, the test commands and any failing tests.
