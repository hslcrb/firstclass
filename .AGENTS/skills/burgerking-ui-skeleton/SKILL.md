---
name: burgerking-ui-skeleton
description: Use when implementing, extending, reviewing, or adapting plain HTML/CSS login and account UI screens based on the hslcrb/firstclass Burger King project or when another brand should reuse the same implementation discipline and code style.
---

# Burger King UI Skeleton v2

## Skill Documents: Read All Before UI Work

This skill consists of the following documents. Read all three supporting documents before producing, editing, or reviewing UI code:

- `detail.md` — the detailed implementation guide and UI behavior requirements.
- `design.md` — the design, structure, formatting, and completion checklist.
- `tests/acceptance.md` — acceptance scenarios for expected behavior and implementation outcomes.

Use `SKILL.md` as the entry point and instruction summary. Apply the supporting documents together; check the relevant scenarios in `tests/acceptance.md` when completing UI work.

## Non-negotiable default

For UI implementation requests, the default deliverable is a **complete HTML document with CSS embedded in a `<style>` block**.

This remains the default even when the user casually says "HTML로 만들어줘" in a design-to-code context.

Only omit CSS when the user explicitly says one of the following or equivalent:

- HTML만
- 마크업만
- CSS 제외
- 구조만

Do not add JavaScript unless the user explicitly asks for behavior or JavaScript.

## Source priority

1. The user's current explicit instruction.
2. `detail.md`, the detailed implementation guide.
3. Current repository code for the closest existing screen.
4. `design.md`.
5. General frontend conventions.

Do not replace the project's plain HTML/CSS architecture with React, Tailwind, CSS Modules, BEM, a component framework, or another stack unless explicitly requested.

## Reminder: Follow the User's Instructions Literally

Do exactly what the user explicitly asks for—no more and no less. Follow the user's wording and requested scope literally; do not infer additional goals, make unsolicited changes, or alter related files or behavior unless the user specifically asks. If an instruction is ambiguous, ask for clarification before making assumptions or changes.

## Reminder: Inspect Graphic Assets Before and After Styling

Before and after changing the styling or use of any graphic asset—including SVGs—always inspect the asset itself for built-in colors, fills, strokes, opacity/transparency, and visual states. Check how those intrinsic properties combine with CSS or other effects so properties such as opacity are not unintentionally applied twice and the final appearance matches the user's request. Do not modify the asset file unless the user explicitly asks you to.

## Reminder: Write CSS Opacity as Percentages

Whenever specifying opacity in CSS, use percentage notation such as `20%` instead of decimal notation such as `0.2`. Apply this consistently to `opacity` declarations and opacity values in colors.

## Code shape

Generated code must follow the formatting contract in `design.md` exactly:
- 4-space indentation.
- no tabs;
- restrained blank lines;
- embedded page CSS;
- snake_case class naming compatible with the project;
- existing font/default stylesheet imports;
- existing assets and CSS variables reused when roles match;
- semantic HTML chosen by content meaning.

## Completion rule

Before returning or committing code, compare it against the checklist in `design.md`.

If committing an existing repository file, update that file rather than creating a duplicate. Respect the user's requested commit-message prefix such as `Edit:`.
