# renewsejongpac 공개 스냅샷 — 현재 상태 (2026-10-26)

> **부분 스냅샷 / NOT A FULL MIRROR / NOT DEPLOYMENT-READY**

## 무엇이 반영되었나?

- 원본: [hslcrb/renewsejongpac](https://github.com/hslcrb/renewsejongpac) (비공개 저장소)
- 공개 대상: [hslcrb/firstclass/renewsejongpac](https://github.com/hslcrb/firstclass/tree/main/renewsejongpac)
- 최초 부트스트랩 브랜치는 검색 대화 UI, HTML/CSS/JS 진입점, 일부 v5 소스, 서드파티 Swiper/AOS 정적 파일 및 검사 파일 **26개**를 독립적인 **새 Git 커밋으로** 옮겼습니다.
- 이 디렉터리에 원본의 `.git`이나 원본 Git 커밋 이력은 담지 않았습니다. 현재는 **전체 프로젝트 파일을 복제한 상태가 아니며**, 누락된 모듈·에셋·구성 파일이 많아 이 스냅샷만으로 앱이 독립 빌드된다고 주장하지 않습니다.

## 자동 동기화 설계 및 차단 사항

- 원본 저장소 `.github/workflows/firstclass-source-mirror.yml`이 **원본 main 업데이트 → 파일 스냅샷 추출 → firstclass 전용 chatgpt-extrahigh/* 브랜치 → PR → merge commit** 흐름을 정의합니다.
- 독립 커밋만 생성하므로 원본 이력은 전송되지 않습니다. 수동 작업 브랜치의 푸시에서는 미러링이 실행되지 않도록 원본 main 푸시만 트리거합니다.
- **남은 설정:** 원본 GitHub Actions 시크릿 `FIRSTCLASS_SYNC_TOKEN`(공개 대상 저장소에 Contents/Pull requests 쓰기 권한이 있는 fine-grained PAT)이 필요합니다.
- **확인된 외부 장애:** 원본 GitHub Actions 기록에 `startup_failure` / `BuildFailed` / 0 jobs가 반복됩니다. 테스트 또는 자동 미러 작업이 실제로 시작됐다고 확인할 수 없으며, Actions 권한·실행 정책·계정 청구 상태 점검이 필요합니다.
- 따라서 **완전 미러 성공, 자동 푸시 정상 작동, 실제 사이트 배포 및 종단간 테스트 통과를 주장하지 않습니다.**

## 공개 범위 점검

- 비공개 원본을 **공개** firstclass로 복사하므로 모든 파일을 무조건 내보내면 위험합니다.
- 현재 자동화는 `.git/`, `.codex/`, `.opencode/`, `.env*`, `node_modules/`, `.next/`, 개인키 확장자와 DB 파일 등을 제외하고 PEM 키 마커·90MiB 이상 파일을 차단합니다.
- 이것은 **완전한 비밀정보/개인정보 스캐너가 아닙니다**. 범위를 넓히기 전에 민감한 구성·제3자 라이선스·내부 기록에 대한 감사를 거쳐야 합니다.
- 공개 부트스트랩에서 선택적으로 복제한 소스 텍스트는 주요 토큰/개인키 패턴을 점검했으나, 이는 안전성을 보증하지 않습니다.

## 잔여 작업

1. 원본 Actions가 `startup_failure` 없이 동작하도록 환경을 복구합니다.
2. 사용자 측에서 원본 저장소 시크릿 `FIRSTCLASS_SYNC_TOKEN`을 설정합니다. **토큰 값을 채팅이나 Git에 공유하지 마세요.**
3. 원본의 `docs/firstclass-mirror.md`를 따라 미러 실행, 대상 PR/merge, 전체 파일 목록 및 누락·공개 민감 정보 감사를 완료합니다.
4. 검증 성공 후에만 **전체 코드 미러 완료** 상태로 변경합니다.

이 상태 문서는 자동 미러의 `rsync --delete` 과정에서 제거될 수 있습니다. 향후 원본에서 완전 스냅샷을 공급하면 부트스트랩 경고가 교체되는 것은 정상입니다.
