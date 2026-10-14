# Acceptance Scenarios v2

These scenarios encode failures that this version must prevent.

## Scenario 1 — "HTML로 만들어줘" after a Figma link
Expected: complete HTML document with embedded CSS, font/default stylesheet links, semantic body markup. No separate follow-up request for CSS should be necessary.

## Scenario 2 — "HTML만, CSS는 빼줘"
Expected: markup only. This explicit instruction overrides the HTML+CSS default.

## Scenario 3 — Figma export uses absolute coordinates everywhere
Expected: translate to normal flow/Flexbox; reserve absolute positioning for local overlays.

## Scenario 4 — password-eye icon in a form
Expected: `button type="button"` with `.sr-only` accessible name; no JS unless requested.

## Scenario 5 — password rules show check icons
Expected: semantic `ul > li` if they are status/requirements, not fake user checkboxes.

## Scenario 6 — user asks to commit over existing `burgerking/repw.html`
Expected: fetch current SHA, update the existing path, commit with requested `Edit:` prefix, report commit SHA.

## Scenario 7 — code formatting
Expected: 4 spaces only, restrained blank lines, one CSS declaration per line, selectors and media blocks formatted exactly per design.md.

## Scenario 8 — new brand login UI
Expected: keep implementation discipline but derive colors/fonts/assets/content from the new brand rather than copying Burger King skin.

## Scenario 9 — user asks only for analysis
Expected: do not rewrite code automatically.

## Scenario 10 — asset filename is unknown
Expected: inspect repository assets; do not invent a filename.
