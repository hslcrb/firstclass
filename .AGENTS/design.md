# HiMark Login UI Coding Standard — Burger King Baseline v2

## 0. Why this version exists

The previous guide captured semantic structure and Burger King styling, but one practical behavior was too weak: a UI request could still produce HTML markup without CSS, forcing a second request.

The approved reference behavior is now the current Burger King password-reset implementation style: **plain HTML + embedded CSS in one file, existing project imports and assets, semantic markup, restrained formatting, and no unnecessary JavaScript or framework.**

This document is the implementation contract.

---

# 1. Default deliverable contract

## 1.1 UI implementation means HTML + CSS

When the user asks to create, reproduce, implement, code, or convert a UI screen, produce:

```text
one complete .html file
+ existing font stylesheet links
+ ../css/default.css
+ a <style> block containing screen CSS
+ semantic <body> markup
```

This is the default without needing the user to say "CSS도 포함".

If the user says only:

> 이 화면 HTML로 만들어줘

in a Figma/UI implementation context, still return **HTML + CSS**.

CSS is omitted only when the user explicitly requests markup-only output, e.g. "HTML만", "마크업만", "CSS 빼고", "구조만".

## 1.2 JavaScript is opt-in

Do not add JavaScript merely because a control could eventually become interactive.

Examples:
- password-eye button may be present without JS;
- disabled CTA may remain static;
- validation indicators may remain visual-only.

Add JS when the user explicitly requests interaction/functionality or asks for JavaScript.

## 1.3 One-file default

Unless the user explicitly requests CSS separation, keep screen-specific CSS inside `<style>` in the same HTML file.

Continue loading the project's existing external resources:

```html
<link rel="stylesheet" href="../fonts/stylesheet/BKBulMatPro.css">
<link rel="stylesheet" href="../fonts/stylesheet/SDGothicNeoRound.css">
<link rel="stylesheet" href="../fonts/stylesheet/pretendardvariable.css">
<link rel="stylesheet" href="../css/default.css">
```

Do not duplicate reset rules already handled by `default.css`.

---

# 2. Exact formatting contract

This section is strict because formatting itself is part of the approved coding style.

## 2.1 Indentation

Use exactly **4 spaces per nesting level**.

Never use tabs.

Good:

```html
<body>
    <div id="wrap">
        <header>
            <h1>로그인</h1>
        </header>
    </div>
</body>
```

Do not use 2 spaces, 8 spaces per level, tabs, or minified formatting.

## 2.2 HTML blank lines

Use blank lines to separate **major logical groups**, not every element.

Approved rhythm:

```html
<header>
    <h1>비밀번호 재설정</h1>

    <button type="button" class="close_btn">
        <span class="sr-only">닫기</span>
    </button>
</header>

<main>
    <div class="intro">
        ...
    </div>

    <form>
        ...
    </form>
</main>
```

Rules:
- one blank line between major siblings when it improves scanning;
- one blank line between a visible label, input group, status/help block, notice block, and main CTA;
- no giant stacks of empty lines;
- no blank line after every single line.

## 2.3 Multiline attributes

Keep short elements on one line when readable:

```html
<button type="submit" class="reset_btn" disabled>
    완료
</button>
```

For long form controls, use one attribute per line:

```html
<input
    type="password"
    id="new-password"
    name="new_password"
    placeholder="새로운 비밀번호를 입력해 주세요"
    autocomplete="new-password"
>
```

The closing `>` aligns with the opening `<input`.

Do not aggressively wrap tiny elements just to make them taller.

## 2.4 CSS indentation

Top-level selectors start at column 1.

Declarations use 4 spaces.

Nested selectors inside `@media` use 4 spaces; declarations inside them use 8 spaces.

```css
.reset_btn {
    width: 100%;
    height: 44px;
}

@media (min-width: 600px) {
    body {
        display: flex;
        justify-content: center;
    }
}
```

Use:
- one declaration per line;
- one space after `:`;
- semicolon on every declaration;
- opening brace on the selector line;
- closing brace aligned with the selector.

## 2.5 CSS section order

Prefer this order:

1. `:root`
2. `html`
3. `body`
4. `#wrap`
5. `header`
6. page title / header controls
7. `main`
8. intro/title/description
9. form/fieldset/labels
10. inputs
11. input-state or icon controls
12. validation/help/list blocks
13. secondary notices
14. primary CTA
15. state selectors such as `:disabled`
16. media queries

Do not randomly interleave unrelated selectors.

---

# 3. Repository baseline

Repository: `hslcrb/firstclass`

Primary reference files:
- `burgerking/login.html`
- `burgerking/repw.html`
- `css/default.css`
- `burgerking/images/`
- `fonts/stylesheet/`

The current `burgerking/repw.html` is the strongest formatting and page-composition reference for new mobile account screens.

When repository access is available, inspect the current source again before making a new screen because the project may evolve.

---

# 4. Semantic HTML contract

HTML tags are chosen by **content meaning**, never by visual shape or Figma layer names.

## 4.1 Page skeleton

Default account-screen skeleton:

```html
<div id="wrap">
    <header>
        <h1>페이지 제목</h1>
        <button type="button">...</button>
    </header>

    <main>
        <div class="intro">
            <h2 class="title">...</h2>
            <p class="description">...</p>
        </div>

        <form>
            <fieldset>
                <legend class="sr-only">...</legend>
                ...
            </fieldset>
        </form>
    </main>
</div>
```

This is a reusable pattern, not permission to add meaningless containers.

## 4.2 Heading rules

- one meaningful page `h1`;
- `h2` for a subordinate content heading, not because the text is visually large;
- do not jump heading levels for visual size;
- do not manufacture headings for footer-like details that are not headings.

## 4.3 Form rules

Use native elements:
- `form` for submission scope;
- `fieldset` for related form controls;
- `legend` for form-group name;
- `label` for input names;
- `input type="email"` for email;
- `input type="password"` for passwords;
- `input type="checkbox"` for real user-selectable checkboxes;
- `button type="submit"` for form submission;
- `button type="button"` for password visibility, close, back, etc.

Do not use `<div>` as a fake button or checkbox.

## 4.4 Figma does not decide semantics

A Figma "Frame", "Group", "Form Section", or Auto Layout does not automatically become:
- `section`;
- `article`;
- `nav`;
- `div`;
- absolute positioning.

Interpret the content first.

A Figma-generated `<a>` or `<div>` may be semantically wrong. Convert it into the correct native HTML element.

## 4.5 Lists

Use `ul > li` when the content is actually a list of parallel items.

Example: password requirements are a list.

Do not turn them into checkboxes merely because a check icon is visible.

---

# 5. Existing project vocabulary

Reuse existing classes when their role is the same.

Stable examples:

```text
input_box
pw_btn
login_option
login_btn
login_link
sns_login
sns_list
title
description
pw_error
pw_check
pw_notice
sns_notice
reset_btn
close_btn
```

Naming style is pragmatic `snake_case`.

Do not introduce BEM or camelCase into sibling screens without an explicit project-wide change.

Small helper/state classes may be reused only for the same behavior.

---

# 6. Accessibility contract

The project already has `.sr-only` in `default.css`.

Use it for icon-only controls:

```html
<button type="button" class="close_btn">
    <span class="sr-only">닫기</span>
</button>
```

Rules:
- every icon-only interactive element has an accessible name;
- `placeholder` does not replace a meaningful label;
- visual check icons do not replace native checkbox semantics when the item is actually selectable;
- functional disabled CTAs use the `disabled` attribute where appropriate;
- do not remove focus support supplied by `default.css` without a replacement.

---

# 7. Burger King design tokens

Reuse role-equivalent variables rather than scattering duplicate literals.

```css
:root {
    --font: "SD Gothic Neo Round", "SDGothicNeoRound", sans-serif;
    --font-pre: "Pretendard Variable", sans-serif;
    --font-BKR: "BKBulMatPro", sans-serif;

    --primary: #512314;
    --focus: #D62302;
    --baseBorder: #D9CFC6;
    --inputBg: #FFFCF9;
    --errorColor: #D62302;
    --placeholder: #D9CFC6;
    --text: #766053;
    --bg: #F4EBDC;
    --button: #E9DDCD;
}
```

Typography roles:
- default interface → `--font`
- supporting text → `--font-pre`
- expressive Burger King headline → `--font-BKR`

Use:

```css
html {
    font-size: 62.5%;
}
```

and continue the project's `rem` convention.

---

# 8. Layout contract

## 8.1 Mobile account-screen default

For a mobile app-like Figma screen similar to the current password-reset page:

```css
body {
    min-width: 360px;
}

#wrap {
    width: 100%;
    max-width: 390px;
    min-height: 100dvh;
    margin: 0 auto;
    padding: 20px;
}
```

Do not blindly force `390px` on a target screen whose design or existing sibling clearly uses another responsive model.

## 8.2 Flexbox first

Use normal document flow and Flexbox for structural layout.

Absolute positioning is acceptable for **local overlays**, such as:
- back button;
- close button;
- password-eye icon.

Do not rebuild a Figma screen with absolute `top/left` coordinates for every block.

## 8.3 Current common dimensions

Current patterns include:
- header height: `48px`;
- icon button: `48px`;
- password-eye icon: `26px`;
- input height: `50px`;
- input radius: `10px`;
- primary button height: `44px`;
- pill CTA radius: `22px` or `999px`.

Reuse these when the same component role appears and the target design agrees.

---

# 9. Assets and paths

Prefer real repository assets over CSS-drawn approximations when the asset already exists.

Examples:
- `images/Close.svg`
- `images/Eye Closed.svg`
- `images/Check-Small Disabled.svg`
- social provider SVGs

Never invent an asset filename.

If the HTML file lives in `burgerking/`, the font and default CSS paths currently resolve through `../`.

If the file location changes, recalculate relative paths.

---

# 10. Figma implementation contract

When a Figma URL is supplied:

1. inspect the selected node, not a guessed neighboring frame;
2. inspect the current repository structure;
3. map visual groups to semantic content;
4. reuse exact existing assets when available;
5. reproduce the visual hierarchy using the project's HTML/CSS style;
6. keep layout responsive instead of copying all absolute coordinates;
7. preserve source copy unless the user explicitly asks to correct it, except where the user/repository has already corrected it;
8. distinguish design evidence from implementation inference.

Do not emit React/Tailwind output from Figma tooling into this project.

---

# 11. Other-brand adaptation

The Burger King project supplies the **implementation discipline**, not a universal visual skin.

For another brand:

## Keep when appropriate
- semantic form hierarchy;
- `default.css`-style reset/accessibility strategy;
- native controls;
- 4-space formatting;
- embedded page CSS default;
- Flexbox/normal-flow strategy;
- class-role reuse approach.

## Replace from target-brand evidence
- colors;
- fonts;
- logos/icons/illustrations;
- copy;
- social providers;
- radii;
- spacing;
- CTA style;
- brand-specific imagery.

Do not just recolor Burger King and call it another brand.

---

# 12. Comments and teaching style

Do not flood production HTML/CSS with tutorial comments.

Use comments only when they preserve a useful implementation reason or the user explicitly asks for instructional comments.

The code itself should remain readable enough to teach from.

When explaining after code, keep the explanation short unless the user asks for a lesson.

---

# 13. Commit behavior

When the user asks to commit a screen to the existing GitHub repository:

1. fetch the current file and current blob SHA;
2. update the existing path if it already exists;
3. do not create `repw2.html`, `new-repw.html`, or duplicate files unless asked;
4. use the user's requested branch;
5. use the user's requested commit-message format exactly.

When the user requests the `Edit:` format, use:

```text
Edit: <짧고 구체적인 변경 내용>
```

After committing, report the path, commit message, and commit SHA concisely.

---

# 14. Output behavior

When the user asks for UI code:
- provide the finished HTML+CSS file/code first;
- do not make the user separately ask for CSS;
- do not ask unnecessary questions when the selected Figma frame and repository already give enough evidence;
- do not append unrelated alternatives;
- do not add JS/frameworks without request.

When the user asks only for review or analysis, analyze first and do not rewrite the whole file automatically.

---

# 15. Red flags

Stop and correct the approach if any of these happen:

- output contains only bare HTML even though the request is to implement a UI;
- indentation changes to 2 spaces or tabs;
- CSS is split into a new file without request;
- React/Tailwind appears;
- every Figma frame becomes a semantic `section`;
- every visual coordinate becomes `position:absolute`;
- existing assets are redrawn or renamed without need;
- placeholder text is treated as a full accessible label;
- icon-only buttons have no accessible text;
- JavaScript appears without a behavior request;
- a new duplicate GitHub file is created when an existing file should be updated;
- code is buried under long prose before the deliverable.

---

# 16. Pre-delivery checklist

Before returning code or committing it:

## HTML
- [ ] Complete HTML document.
- [ ] Correct `lang`.
- [ ] Existing font and `default.css` links included where appropriate.
- [ ] Exactly one page `h1`.
- [ ] Heading hierarchy is meaningful.
- [ ] Native form/control semantics are correct.
- [ ] Icon-only controls have `.sr-only` names.
- [ ] Non-submit buttons have `type="button"`.

## CSS
- [ ] CSS included by default.
- [ ] `<style>` is in `<head>`.
- [ ] 4-space indentation.
- [ ] Existing tokens reused.
- [ ] Existing assets reused.
- [ ] Flexbox/normal flow preferred.
- [ ] Media query formatting matches the project.
- [ ] No duplicate reset rules.

## Scope
- [ ] No JavaScript unless requested.
- [ ] No framework migration.
- [ ] No unrelated refactor.
- [ ] No invented paths/assets.

## GitHub
- [ ] Existing target file updated rather than duplicated.
- [ ] Current blob SHA used.
- [ ] Requested commit-message prefix respected.
