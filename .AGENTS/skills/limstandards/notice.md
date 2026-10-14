# 파리바게뜨 UI 서체 변경 공지

## 변경 시점

파리바게뜨 로그인 UI 모작 프로젝트에서 사용하는 서체 정책은 **2026년 10월 8일 오후 4시경(KST)**부터 변경되었다.

기존에는 `parisbagutte/` 아래 화면 대부분이 `PBGothic`을 기본 서체로 상속했지만, 이 시점부터는 **제목용 파리바게뜨 서체와 본문·UI용 프리텐다드 베리어블을 함께 사용하는 체계**로 운영한다.

---

## 적용 범위

이 규칙은 `parisbagutte/` 폴더 아래의 모든 HTML 화면에 적용한다.

현재 적용 대상은 다음과 같다.

- `login.html`
- `login2.html`
- `login3.html`
- `login4.html`
- `repw.html`
- `repw2.html`
- `register1.html`
- `register2.html`
- `register3.html`
- `settings.html`

앞으로 같은 폴더에 새 HTML 화면을 만들 때도 이 정책을 기본값으로 사용한다.

---

## 핵심 서체 정책

### 1. 일반 본문과 UI 텍스트

페이지의 기본 서체는 `Pretendard Variable`이다.

다음과 같은 요소는 모두 프리텐다드 베리어블을 사용한다.

- 입력값과 placeholder
- 폼 label
- 설명 문구와 안내 문구
- 오류 메시지
- 비밀번호 조건과 주의 문구
- 체크박스·동의 항목 문구
- 버튼 텍스트
- 일반 링크
- 로그인 옵션
- 환경 설정의 개별 설정 항목
- 버전 정보와 로그아웃

각 요소에 이미 지정되어 있던 `font-weight`는 그대로 유지한다. 예를 들어 기존의 `400`은 프리텐다드 400으로, `700`은 프리텐다드 700으로 사용한다. 서체를 바꾼다는 이유로 굵기를 임의로 평준화하거나 모두 같은 굵기로 바꾸지 않는다.

### 2. 제목과 헤더 역할의 텍스트

페이지와 주요 콘텐츠의 제목은 기존 파리바게뜨 서체인 `PBGothic`을 유지한다.

HTML 구조상 기본 기준은 `h1`, `h2`이다.

대표적인 예시는 다음과 같다.

- `PARIS BAGUETTE`
- `회원가입`
- `환경 설정`
- `비밀번호 재설정`
- `환영합니다 / 파리바게뜨입니다.`
- `새로운 비밀번호를 / 입력해주세요`
- `Heart Place / 파리바게뜨 서비스 이용약관에 / 동의해주세요.`
- 환경 설정 화면의 `로그인`, `편리 기능`, `앱 푸시 설정`, `서비스 동의` 같은 섹션 제목

시각적으로 글씨가 크다는 이유만으로 예외를 추가하지 않는다. 콘텐츠 의미가 페이지 또는 주요 영역의 제목인지 먼저 확인한다.

---

## HTML과 CSS 구현 기준

각 파리바게뜨 HTML은 다음 순서로 서체 스타일시트를 불러온다.

```html
<link rel="stylesheet" href="../fonts/stylesheet/PBGothic.css">
<link rel="stylesheet" href="../fonts/stylesheet/pretendardvariable.css">
<link rel="stylesheet" href="../css/default.css">
```

페이지의 기본 본문 서체는 다음처럼 지정한다.

```css
body {
    font-family: "Pretendard Variable", sans-serif;
}
```

제목 요소는 파리바게뜨 서체를 다시 명시한다.

```css
h1,
h2 {
    font-family: var(--font);
}
```

현재 파리바게뜨 HTML의 `:root`에서 `--font`는 아래 값을 유지한다.

```css
--font: "PBGothic", sans-serif;
```

`default.css`의 폼 요소에는 `font: inherit`이 적용되어 있으므로 `input`, `button`, `textarea`, `select`도 body의 프리텐다드 베리어블과 해당 요소의 기존 굵기를 상속한다.

---

## 변경 시 지켜야 할 점

- 제목이 아닌 요소에 `PBGothic`을 다시 지정하지 않는다.
- `h1`, `h2`의 파리바게뜨 서체를 프리텐다드로 덮어쓰지 않는다.
- 기존 `font-weight` 값을 이유 없이 변경하지 않는다.
- 서체 변경과 관계없는 크기, 색상, 간격, 레이아웃, 문구는 함께 수정하지 않는다.
- 새 화면에서도 우선 의미에 따라 제목과 일반 UI 텍스트를 구분한다.
- 제목처럼 보이더라도 실제로 label, 버튼, 안내문 또는 설정 항목이라면 프리텐다드를 사용한다.

---

## 작업 전후 확인 항목

파리바게뜨 HTML을 만들거나 수정한 뒤 다음을 확인한다.

1. `PBGothic.css`와 `pretendardvariable.css`가 모두 연결되어 있는가?
2. body의 기본 서체가 `Pretendard Variable`인가?
3. `h1`, `h2`가 `PBGothic`을 유지하는가?
4. 입력창, 버튼, label, 문구, 링크가 프리텐다드를 상속하는가?
5. 기존의 400·700 등 굵기 대비가 유지되는가?
6. 서체 변경 외의 디자인이 의도치 않게 달라지지 않았는가?

이 공지는 파리바게뜨 UI 화면의 서체 선택이 다시 전부 `PBGothic`으로 되돌아가는 것을 방지하기 위한 프로젝트 규칙이다.
