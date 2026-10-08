---
name: burgerking-ui-skeleton
description: Use when implementing, extending, reviewing, or adapting plain HTML/CSS login and account UI screens based on the hslcrb/firstclass Burger King project or when another brand should reuse the same implementation discipline and code style.
---

# Burger King UI Skeleton v2

Read `detail.md` before producing or editing UI code.

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
2. Current repository code for the closest existing screen.
3. `detail.md`.
4. General frontend conventions.

Do not replace the project's plain HTML/CSS architecture with React, Tailwind, CSS Modules, BEM, a component framework, or another stack unless explicitly requested.

## Code shape

Generated code must follow the formatting contract in `detail.md` exactly:
- 4-space indentation.
- no tabs;
- restrained blank lines;
- embedded page CSS;
- snake_case class naming compatible with the project;
- existing font/default stylesheet imports;
- existing assets and CSS variables reused when roles match;
- semantic HTML chosen by content meaning.

## Completion rule

Before returning or committing code, compare it against the checklist in `detail.md`.

If committing an existing repository file, update that file rather than creating a duplicate. Respect the user's requested commit-message prefix such as `Edit:`.
