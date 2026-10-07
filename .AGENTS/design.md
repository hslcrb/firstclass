# Burger King UI Skeleton — Unified Design Guide

## 0. Skill Rules

# Burger King UI Skeleton

## Core principle

Treat the current `hslcrb/firstclass` Burger King UI as the
implementation source of truth. A new screen should look and read like a
sibling of the existing code, not like a generic redesign.

**Required reference:** Read `design_guide.md` before generating or
editing a screen. If repository access exists, re-read the current
closest HTML and `css/default.css` because the repository may have
changed since this package was created.

## Workflow

1.  Identify the target screen's content and actions.
2.  Inspect the closest existing Burger King screen.
3.  Reuse semantic structure and existing classes when their roles
    match.
4.  Reuse `../css/default.css`; do not duplicate its reset/accessibility
    rules.
5.  Reuse the project's tokens, typography, Flexbox/layout logic and
    asset conventions.
6.  Add classes only for genuinely new roles.
7.  Choose HTML elements by content meaning, never by Figma frame/group
    names.
8.  Verify semantics, accessible names, paths and responsive sizing.

## Preservation contract

Preserve by default: - `#wrap > header + main`. - One page `h1`;
`h2.title` for subordinate intro headings when semantically
appropriate. - Account forms with `form > fieldset`. - `.input_box`,
`.pw_btn`, `.login_option`, `.login_btn`, `.login_link`, `.sns_login`,
`.sns_list` when the same roles recur. - `.sr-only` for visually hidden
accessible text. - Real native inputs and buttons; submit actions use
`type="submit"`, other buttons use `type="button"`. - CSS custom
properties for shared colors/fonts. - `rem` typography under
`html { font-size: 62.5%; }`. - Normal flow/Flexbox first; absolute
positioning only for local overlays.

Do not blindly copy known source inconsistencies. Korean pages use
`lang="ko"` even though the current login file says `en`. Do not copy
lesson/test comments into new production markup unless requested.

## Source priority

1.  Current explicit user instruction.
2.  Current repository code for the same UI role.
3.  `design_guide.md`.
4.  General web conventions.

Do not silently migrate to React, Tailwind, BEM, CSS Modules, or another
architecture.

## Brand adaptation

When this skeleton is used for another brand, keep the implementation
discipline and change the brand layer deliberately.

Usually keep: semantic form hierarchy, reset/accessibility behavior,
native controls, Flexbox approach, responsive container logic.

Re-evaluate for the target brand: colors, fonts, assets, copy,
providers, spacing, radii and CTA styling. Do not merely recolor Burger
King and claim brand fidelity.

## Completion checklist

-   One meaningful `h1`; sensible heading order.
-   Form elements match their real roles.
-   Icon-only controls have accessible names.
-   Existing classes/tokens are reused where roles match.
-   No duplicated reset rules from `default.css`.
-   Relative font/CSS/image paths are verified.
-   Layout remains usable within the project's 360px--1024px width
    model.
-   No unnecessary framework or JavaScript was introduced.


---

## 1. Design Guide

# Burger King Login UI --- Design Guide

## Basis and scope

This guide is derived from the current `hslcrb/firstclass` repository,
not from a generic Burger King design system.

Snapshot basis: - `burgerking/login.html` ---
`21bed9c0a3f6a1bf1427bea1cbc76a5ef53db7de` - `burgerking/repw.html` ---
`9604236283a3269e1d3a14a98102c1615886add9` - `css/default.css` ---
`c768f5d113e391bec83e3956d69d422e237b203f` - `burgerking/flex.html` ---
`4814eb5595533b54a2e324adf493910b9e073492`

If these change, inspect the repository again.

## 1. Current architecture

The project uses plain HTML and CSS. `login.html` imports three font
stylesheets and `../css/default.css`, then keeps screen-specific styling
in a `<style>` block. Login assets are referenced from
`burgerking/images/`. `repw.html` currently provides mainly semantic
skeleton markup. `flex.html` is a Flexbox learning file, not a
production page template.

Do not introduce a framework simply to add another screen.

## 2. Semantic skeleton

The established page hierarchy is:

``` html
<div id="wrap">
    <header>
        <h1>페이지 제목</h1>
        <button type="button">...</button>
    </header>
    <main>
        <h2 class="title">...</h2>
        <form>
            <fieldset>
                <legend class="sr-only">...</legend>
                ...
                <button type="submit">...</button>
            </fieldset>
        </form>
    </main>
</div>
```

This is a pattern, not a blind template. Add `section`, `nav`, lists or
extra headings only when content meaning requires them.

### Existing form vocabulary

  Role                       Existing pattern
  -------------------------- ---------------------------------
  Form group                 `form > fieldset`
  Hidden group title         `legend.sr-only`
  Visible email label        `label.email`
  Input wrapper              `.input_box`
  Password overlay wrapper   `.input_box.rela`
  Password visibility        `.pw_btn[type=button]`
  Login options              `.login_option` + real checkbox
  Primary submit             `.login_btn[type=submit]`
  Account links              `.login_link`
  Social login               `.sns_login`, `.sns_list`

Password-reset-only vocabulary includes `.description`, `.pw_error`,
`.pw_check`, `.pw_notice`, `.sns_notice`, `.reset_btn`.

## 3. Shared reset and accessibility

`css/default.css` supplies box sizing, margin/padding reset,
Korean-friendly word breaking, list/link/media resets, form
inheritance/native appearance reset, `:focus-visible`, `.sr-only`,
reduced-motion handling, `[hidden]`, touch optimization, and
fieldset/legend reset.

Do not duplicate those rules per screen.

Icon-only controls keep accessible text:

``` html
<button class="prev_btn" type="button">
    <span class="sr-only">이전버튼</span>
</button>
```

Keep the real native input even when CSS draws the visual checkbox.

## 4. Design tokens

Current `login.html` defines:

``` css
:root {
    --font: "SD Gothic Neo Round", "SDGothicNeoRound", sans-serif;
    --font-pre: "Pretendard Variable", sans-serif;
    --font-BKR: "BKBulMatPro", sans-serif;
    --primary: #512314;
    --focus: #D62302;
    --baseBorder: #D9CFC6;
    --inputBg: #FFFCF9;
    --errorColor: #C54734;
    --placeholder: #EBE6E2;
    --text: #766053;
    --bg: #F4EBDC;
    --button: #E9DDCD;
}
```

Use an existing variable whenever the role is the same. Typography roles
are: default UI=`--font`, supporting/account text=`--font-pre`,
expressive Burger King headline=`--font-BKR`.

The project uses `html { font-size: 62.5%; }` and
`body { font-size: 1.6rem; }`, so continue its rem convention.

## 5. Layout rules

`#wrap` currently uses `min-height:100dvh`, `width:96%`,
`max-width:1024px`, `min-width:360px`, `padding:20px`, and centered auto
margins.

The header is 48px tall, uses Flexbox to center the title, and
absolutely positions the back button locally. `main` uses normal
document flow and `padding:48px 20px 90px`. `.title` is a vertical flex
container.

Inputs are 100% wide, 50px tall, padded 20px horizontally, radius 10px,
with `--baseBorder` and `--inputBg`. Password-eye positioning is local
to `.input_box.rela`.

The current login CTA is 100% wide, 44px tall and 22px radius. Its shown
inactive visual state uses opacity; functional disabled state should
also use the native `disabled` attribute when appropriate.

## 6. Repeated visual patterns

**Checkbox:** `.check.sr-only` remains a real checkbox; `span::before`
supplies the icon and `:checked` swaps the asset.

**Account links:** `.login_link` uses inline-flex anchors and
pseudo-element separators. Do not infer `nav` solely from appearance.

**Social login:** heading rules are pseudo-elements; `.sns_list` is
centered Flexbox; each 45×45 anchor uses a background icon and
`.sr-only` name.

## 7. Naming and CSS style

Current classes use pragmatic snake_case: `input_box`, `login_btn`,
`login_link`, `sns_login`, `sns_list`, `pw_btn`, `login_option`.
Continue that style for sibling classes. Do not mix in BEM/camelCase
without a deliberate project-wide change.

Prefer existing CSS variables and Flexbox. Avoid absolute-positioning
the whole Figma composition.

## 8. Assets and paths

Font CSS currently comes from:

``` html
<link rel="stylesheet" href="../fonts/stylesheet/BKBulMatPro.css">
<link rel="stylesheet" href="../fonts/stylesheet/SDGothicNeoRound.css">
<link rel="stylesheet" href="../fonts/stylesheet/pretendardvariable.css">
```

Login assets use paths relative to `burgerking/login.html`, such as
`images/Arrow%20Left.svg` and `images/Eye\ Closed.svg`. Inspect the
actual `images/` directory before naming a new asset. If a new HTML file
is placed elsewhere, recalculate all relative paths.

## 9. Known source inconsistencies

These are observations, not permission to rewrite unrelated code: 1.
`login.html` says `lang="en"` despite Korean content; new Korean screens
should use `ko`. 2. `login.html` contains classroom/test comments; do
not multiply them automatically. 3. Page-specific CSS is inline at this
learning stage; preserve that architecture unless the user asks to
extract it. 4. `repw.html` is not yet a full visual CSS implementation.
5. `flex.html` is instructional.

## 10. Procedure for a new screen

1.  Define the screen purpose and primary action.
2.  Pick the closest existing sibling.
3.  Map content to semantic HTML.
4.  Reuse matching classes.
5.  Introduce only missing screen-specific classes.
6.  Reuse tokens for equivalent roles.
7.  Use normal flow/Flexbox before absolute positioning.
8.  Check native controls and accessible names.
9.  Test against the 360px minimum and 1024px maximum model.
10. Verify every relative path.

## 11. Procedure for another brand

Separate **skeleton** from **skin**.

Keep the skeleton when it still fits: reset, semantic form structure,
accessibility method, native controls, Flexbox strategy, responsive
logic.

Replace the skin from evidence of the target brand: color tokens, font
imports, assets, copy, providers, spacing/radii and CTA states.
Structural changes are allowed when the target service's content
requires them.

## 12. Review checklist

### HTML

-   [ ] Correct document language.
-   [ ] One page `h1`.
-   [ ] Meaningful heading hierarchy.
-   [ ] Correct `form/fieldset/legend/label/input/button` roles.
-   [ ] `type="button"` on non-submit form buttons.
-   [ ] Accessible names for icon-only controls.

### CSS

-   [ ] `default.css` loaded once.
-   [ ] Existing tokens reused.
-   [ ] Existing class vocabulary reused where roles match.
-   [ ] Flexbox/normal flow preferred.
-   [ ] No unnecessary duplicate reset.
-   [ ] Responsive width model preserved.

### Assets

-   [ ] Existing filenames verified.
-   [ ] Relative paths verified from the new file.
-   [ ] Font imports remain valid.


---

## 2. Repository Source Map

# Repository Source Map

Repository: `hslcrb/firstclass`, branch `main`.

  -----------------------------------------------------------------------
  File                                Role
  ----------------------------------- -----------------------------------
  `burgerking/login.html`             Primary implemented login UI
                                      reference; semantic HTML plus
                                      current page CSS

  `burgerking/repw.html`              Password-reset semantic skeleton
                                      and screen-specific class
                                      vocabulary

  `css/default.css`                   Shared reset, accessibility and
                                      base form behavior

  `burgerking/flex.html`              Classroom Flexbox notes; conceptual
                                      reference only

  `burgerking/images/`                Login icons/assets; inspect current
                                      contents before referencing
                                      filenames

  `fonts/stylesheet/`                 Font stylesheet location used by
                                      login page
  -----------------------------------------------------------------------

This skill intentionally records repository-derived conventions
separately from general recommendations. The current repository remains
authoritative when it changes.


---

## 3. Acceptance Scenarios

# Acceptance Scenarios

These scenarios are used to review whether an agent actually follows the
skill.

1.  **New Burger King verification screen** --- Expected: inspect
    closest screen, keep `#wrap/header/main`, native form controls,
    reuse tokens/classes, add only necessary classes.
2.  **Figma frame full of groups** --- Expected: do not translate every
    frame into `section` or absolute coordinates; choose semantics from
    content and normal flow/Flexbox.
3.  **New Korean screen copied from login** --- Expected: use
    `lang="ko"` rather than propagating the known `lang="en"`
    inconsistency.
4.  **Icon-only close button** --- Expected: native
    `button type="button"` with accessible text, normally `.sr-only`.
5.  **New brand adaptation** --- Expected: preserve reusable
    implementation skeleton but replace brand evidence deliberately; do
    not merely recolor Burger King.
6.  **New image filename not present in source** --- Expected: inspect
    assets or state that it is unknown; never invent a path.
7.  **Request to "clean everything up" while adding one screen** ---
    Expected: avoid unrelated framework migration/refactor unless
    explicitly requested.
8.  **Password eye inside a form** --- Expected: `type="button"` and
    local overlay pattern, not an accidental submit.
