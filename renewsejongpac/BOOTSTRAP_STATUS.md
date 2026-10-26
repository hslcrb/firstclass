# renewsejongpac → firstclass 상태 보고서

**2026-10-26 · PARTIAL MIRROR · 자동 푸시 준비됨 / 실제 전체 전송 미완료**

## 확인된 사실

- 원본: [hslcrb/renewsejongpac](https://github.com/hslcrb/renewsejongpac) — 비공개 저장소.
- 대상: [hslcrb/firstclass/renewsejongpac](https://github.com/hslcrb/firstclass/tree/main/renewsejongpac) — 공개 저장소의 하위 폴더.
- 원본 `main`의 Git API 트리: 디렉터리 제외 **58,147개 blob**.
- firstclass `main`의 `renewsejongpac/`에는 일부 부트스트랩 파일만 있음. **전체 스냅샷이 아니며 독립적인 앱 빌드 완료도 아님.**
- 기존 부트스트랩에는 v5 Deep Chat 검색 관련 파일과 Swiper/AOS 정적 에셋 일부가 포함됨.
- 원본 Git 이력은 firstclass로 전송하지 않음.

## CI 없이 동기화하는 현재 방식

이전의 GitHub Actions 기반 미러링은 사용하지 않습니다. 원본에서 `firstclass-source-mirror.yml` 제거 작업을 진행했고, **로컬 Git post-commit 훅 + `git archive` + 별도 대상 저장소 커밋/푸시** 방식으로 교체했습니다.

1. 원본 개발 PC에서 훅을 **한 번 설치**: `bash scripts/install-firstclass-hook.sh`
2. 원본 커밋 직후 현재 커밋의 추적 파일 전체를 `git archive`로 추출.
3. firstclass의 **`renewsejongpac/` 폴더만** 복사하고 `chatgpt-extrahigh/mirror-renewsejongpac-*` 브랜치에 독립 커밋·푸시.
4. 검증 후 firstclass `main`에는 별도 merge commit으로 병합.

**Git remote만 추가하는 것으로는 하위 디렉터리로 직접 push할 수 없습니다.** 훅은 표준 Git `post-commit`을 사용합니다. `post-push`는 표준 Git 훅이 아닙니다.

## 완료 / 미완료

| 항목 | 상태 |
| --- | --- |
| 원본의 스냅샷 푸시 스크립트 | 작성 및 로컬 모의 원격 검증 |
| 원본의 자동 커밋 훅 및 설치 스크립트 | 작성 |
| 원본에서 CI 미러 제거 | 작업 브랜치에 반영 |
| 실제 개발 PC에 훅 설치 | 사용자 로컬 환경에서 수행 필요 |
| 원본 전체 추적 파일의 firstclass 실제 푸시 | **미완료** |
| 전체 파일 동등성·빌드 검사 | **미완료** |

원본 저장소의 [동기화 운영 가이드](https://github.com/hslcrb/renewsejongpac/blob/main/docs/firstclass-mirror.md)에 설치법, dry-run, 장애 대응 방법을 기록했습니다. 실제 대상의 전체 스냅샷 전송이 검증되기 전에는 완료로 표시하지 않습니다.
