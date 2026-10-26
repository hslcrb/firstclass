# 세종문화회관 리뉴얼(renewsejongpac) 포털 페이지 구현 및 연동 보고서

- **작성일자**: 2026-10-26
- **문서 위치**: `docs/renewsejongpac-portal.md`
- **대상 파일**:
  - `renewsejongpac/index.html` (신규 생성)
  - `index.html` (메인 포트폴리오 인덱스 수정)

---

## 1. 개요 및 배경

본 작업은 `firstclass` 포트폴리오 저장소 내 세종문화회관 반응형 리뉴얼 프로젝트(`renewsejongpac`)로의 공식 진입점을 제공하기 위해 단독 포털 웹페이지를 구현하고, 루트 `index.html`과 상호 연결하는 작업입니다.

과거 중복 소스 폴더 철회 및 정리 이후, 공식 공개 스냅샷 저장소(`renewsejongpac-open`)와 실제 라이브 서비스(`https://renewsejongpac.rhee.life/`)로 사용자를 원활하게 안내할 수 있도록 정돈된 2개 둥근(Border-Radius) 버튼 중심의 진입 화면을 구축했습니다.

---

## 2. 주요 사양 및 요구사항 구현

### 2.1 UI 및 디자인 사양
- **화면 구조**:
  - 중앙 정렬된 미니멀하고 세련된 카드 레이아웃 (`.portal-container`, `max-width: 440px`)
  - 시맨틱 마크업 (`<main>`, `<header>`, `<h1>`, `<nav>`, `<a role="link">`)
- **버튼 디자인**:
  - `border-radius: 9999px`의 둥근 알약형(Pill) 버튼 2개
  - 데스크톱 및 태블릿 환경에서는 가로 배치(Row), 좁은 모바일 화면에서는 세로(Column) 반응형 자동 전환
  - 시각적 마이크로 인터랙션: Hover 시 상단 미세 이동(`translateY(-1px)`), Active 시 원위치, Focus 시 외곽 링(`:focus-visible`)
- **타이포그래피 및 폰트**:
  - 로컬 웹폰트 `PretendardVariable.woff2` (`C:\Users\hi\Documents\firstclass\fonts\PretendardVariable.woff2`) 연동
  - 상대 경로 `../fonts/PretendardVariable.woff2`를 통해 `@font-face`로 로드하여 외부 CDN 의존 없이 안정적으로 렌더링

### 2.2 링크 및 내비게이션 동작
| 버튼명 | 이동 대상 URL | 창 전환 모드 | 용도 |
| :--- | :--- | :--- | :--- |
| **깃허브 방문** | `https://github.com/hslcrb/renewsejongpac-open` | 현재 창 이동 (`_self`) | 세종문화회관 리뉴얼 공식 무이력 공개 스냅샷 저장소 |
| **라이브 사이트 방문** | `https://renewsejongpac.rhee.life/` | 현재 창 이동 (`_self`) | 실제 배포된 리뉴얼 라이브 웹사이트 |

*사용자 명시 조건에 따라 두 링크 모두 `target="_blank"` 속성을 배제하고 현재 창에서 그대로 이동하도록 구성했습니다.*

---

## 3. 코드 컨벤션 및 규칙 준수 (`limsflex`)

1. **들여쓰기 및 포맷**:
   - HTML 및 `<style>` 내부 CSS 모두 엄격한 **4칸 들여쓰기 (4-space)** 준수.
   - 탭 문자 미사용.
2. **클래스 네이밍**:
   - `kebab-case` 명명 규칙 준수 (`portal-container`, `portal-header`, `portal-title`, `btn-link`, `btn-github`, `btn-live`).
3. **독립 HTML 기본 산출물 원칙**:
   - 외부 프레임워크나 자바스크립트 없이 완전한 순수 HTML5 문서 구조 및 `<head>` 내 `<style>` 블록 내장.
   - 공통 자산 연동:
     - 파비콘: `<link rel="icon" type="image/svg+xml" href="../shared/favicon.svg">`
     - 공통 리셋: `<link rel="stylesheet" href="../css/default.css">`
     - 폰트 스타일시트: `<link rel="stylesheet" href="../fonts/stylesheet/pretendardvariable.css">`
4. **CSS 명세**:
   - CSS 불투명도 및 알파값에 `%` 표기 적용 (예: `rgb(15 23 42 / 8%)`, `rgb(30 58 138 / 35%)`).

---

## 4. 메인 인덱스(`index.html`) 연동 내역

루트 포트폴리오 목록인 `index.html` 하단에 신규 세션을 추가하여 `renewsejongpac/index.html`로 직관적인 이동이 가능하도록 구성했습니다.

```html
<!-- index.html 추가 내역 -->
<h2>세종문화회관 리뉴얼</h2><br>
<a href="renewsejongpac/index.html">세종문화회관 리뉴얼 바로가기</a><br>
```

---

## 5. 변경 파일 요약

```text
firstclass/
├── docs/
│   └── renewsejongpac-portal.md       # 본 작업 상세 기술 문서
├── renewsejongpac/
│   └── index.html                     # 신규 포털 화면 (둥근 버튼 2개 + Pretendard)
└── index.html                         # 세종문화회관 리뉴얼 링크 추가
```

---

## 6. 작업 결과 검증

- [x] `renewsejongpac/index.html` 파일 생성 및 4칸 들여쓰기/웹표준 검증
- [x] Pretendard Variable 가변 웹폰트 경로 연결 검증
- [x] 깃허브 방문 버튼 URL (`https://github.com/hslcrb/renewsejongpac-open`) 설정 완료
- [x] 라이브 사이트 방문 버튼 URL (`https://renewsejongpac.rhee.life/`) 설정 완료
- [x] 두 링크 모두 현재 창(`_self`) 이동 속성 확인
- [x] 루트 `index.html`에 진입 링크 연결 완료
- [x] `docs/renewsejongpac-portal.md` 상세 문서화 완료
