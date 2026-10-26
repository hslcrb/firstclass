# firstclass 공개 미러 운영 가이드

## 의도와 범위

원본: [hslcrb/renewsejongpac](https://github.com/hslcrb/renewsejongpac) (**비공개**)  
대상: [hslcrb/firstclass/renewsejongpac](https://github.com/hslcrb/firstclass/tree/main/renewsejongpac) (**공개**)

이 자동화는 **Git history mirror가 아닌 파일 snapshot mirror**입니다. 원본 `.git`은 복사하지 않습니다. `firstclass`에는 별도의 `chore: ...` 동기화 커밋과 최종 merge commit만 생성됩니다. 원본 개발 브랜치의 개별 커밋은 전달되지 않습니다.

## 브랜치 및 이벤트 정책

- 원본 `main`이 리뷰 후 `--no-ff`로 병합되어 푸시될 때만 자동으로 동작합니다. 기능 브랜치 작업·푸시 도중에는 공개하지 않습니다.
- GitHub Actions는 원본의 **shallow checkout**과 대상 `main`의 별도 checkout을 사용합니다.
- 대상에 `chatgpt-extrahigh/mirror-renewsejongpac-<run-id>` 브랜치를 만들고 새 파일만 추가·수정·삭제합니다.
- PR을 생성한 다음 GitHub의 `merge` 방식으로 **merge commit**을 남깁니다. 요구된 리뷰 조건 또는 보호 규칙 때문에 자동 병합이 거부되면 PR이 남아 수동 검토할 수 있습니다.
- 동일한 파일 스냅샷이면 새 PR·커밋을 생성하지 않습니다.

브랜치 안에 브랜치를 문자 그대로 중첩 생성할 수는 없습니다. Git branch는 커밋 참조이므로 현재 프로젝트는 `chatgpt-extrahigh/` 네임스페이스 아래 **부모 브랜치를 기반으로 후속 브랜치를 생성하는 연속 분기**를 사용합니다. 메인에 일시적으로 직접 커밋하는 방식은 사용하지 않습니다.

## 필수 한 번 설정

원본 `renewsejongpac` 저장소에 GitHub Actions 시크릿을 생성합니다.

1. GitHub 개인 설정 → Developer settings → Personal access tokens → Fine-grained tokens로 이동합니다.
2. 토큰의 Repository access를 **hslcrb/firstclass** 한 개로 제한하고, `Contents: Read and write`, `Pull requests: Read and write`를 허용합니다.
3. `renewsejongpac` → Settings → Secrets and variables → Actions → New repository secret에서 이름을 정확히 `FIRSTCLASS_SYNC_TOKEN`으로 설정합니다.
4. `renewsejongpac` → Actions에서 워크플로 실행 제한 또는 결제/계정 상태를 점검합니다.
5. 원본 `main`에 다음 merge commit을 푸시하거나 `Sync renewed Sejong source to firstclass`의 `Run workflow`를 실행합니다.
6. `firstclass`의 PR 및 `renewsejongpac/` 디렉터리 파일이 실제 생성됐는지 확인합니다.

토큰의 **값을 소스코드·커밋·채팅에 붙여넣지 마세요.** 연결된 GitHub 앱만으로는 Actions 저장소 시크릿을 설정할 권한이 없으므로 이 단계는 사용자 측 설정이 필요합니다.

## 공개 전 보호 정책

자동 공개이므로 아래 항목은 복사하지 않습니다.

- `.git/`: 원본 커밋 이력·Git 메타데이터
- `.codex/`, `.opencode/`: 대화 로그·내부 작업 기록 및 대용량 생성 데이터
- `.env*`: 환경변수 실제값과 환경 파일
- `node_modules/`, `.next/`: 로컬/캐시 빌드 흔적
- `*.pem`, `*.key`, `*.p12`, `*.pfx`, SSH 개인키, `*.sqlite`, `*.db`

대상 트리에 **90MiB 초과 파일 또는 PEM 개인키 마커**가 발견되면 공개를 중단합니다. 이 검사는 최소 안전망이며 토큰·개인정보 노출을 완전히 보장해서 탐지하는 도구는 아닙니다. 원본이 비공개이고 대상이 공개라는 점을 고려해 소스와 자산 라이선스를 점검하세요.

비공개 내역까지 한 번에 복사하도록 `--exclude` 목록을 무분별하게 지우지 않습니다. 민감한 자료를 별도로 공개해야 한다면 사전에 감사와 독립적인 승인을 받아야 합니다.

## 상태 / Status (2026-10-26)

- 워크플로 정의: `.github/workflows/firstclass-source-mirror.yml` 작성.
- 실행: 아직 검증되지 않음. `FIRSTCLASS_SYNC_TOKEN` 설정 여부를 확인하지 못함.
- 작업 시작 시 관측된 기존 GitHub Actions 실행: `conclusion=startup_failure`, `path=BuildFailed`, **0 jobs**. 소스 빌드나 미러링 자체가 실행되기 전의 실패입니다.
- 진단: 워크플로 YAML, GitHub Actions 권한·정책 및 청구 상태를 확인해야 합니다. 해당 기록만으로 원인을 단정할 수 없습니다.
- 동기화가 되지 않았다면 `firstclass/renewsejongpac/`에 모든 파일이 있다고 주장하지 않습니다.

## 수동 검증

```bash
# 원본: 다음 명령으로 전체 tracked 파일 수를 먼저 확인
git ls-files | wc -l

# 원본: 스냅샷 제외 목록을 적용한 rsync dry-run
rsync -an --delete --delete-excluded \
  --exclude='.git/' --exclude='.codex/' --exclude='.opencode/' \
  --exclude='.env*' --exclude='node_modules/' --exclude='.next/' \
  ./ /path/to/firstclass/renewsejongpac/

# 대상: 원본 이력이 아니라 미러 커밋만 보여야 함
git -C /path/to/firstclass log --oneline -- renewsejongpac/
```

## 철회 및 복구

공개 미러에 실수로 비밀 자료를 반영한 경우, **파일 삭제만으로 이미 공개된 Git 이력이 소거되지 않습니다.** 즉시 관련 비밀값을 폐기·재발급하고, 공개 범위와 이력 삭제 문제를 별도로 대응해야 합니다. 자동 동기화를 중단하려면 원본의 워크플로를 수정·비활성화하고 PAT를 폐기하세요.
