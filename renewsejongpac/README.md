# renewsejongpac — firstclass 디렉터리

이 폴더는 [hslcrb/renewsejongpac](https://github.com/hslcrb/renewsejongpac)의 **Git 이력을 복사하지 않는 파일 스냅샷**을 위한 위치입니다.

> **현재는 부분 부트스트랩입니다. 전체 소스 코드 동기화 및 독립 빌드가 끝나지 않았습니다.**

자세한 진행 상황은 [BOOTSTRAP_STATUS.md](BOOTSTRAP_STATUS.md)를 확인하세요.

## 새 동기화 방식

원본 저장소의 `scripts/sync-firstclass.sh`가 Git의 추적 파일을 `git archive`로 내보내고, 이 폴더에 별도의 스냅샷 커밋으로 반영합니다. 로컬에서 `bash scripts/install-firstclass-hook.sh`를 실행한 이후에는 원본 `post-commit` 훅으로 **firstclass의 `chatgpt-extrahigh/*` 작업 브랜치에 직접 push**합니다.

- **CI / GitHub Actions 기반 미러를 사용하지 않습니다.**
- firstclass의 다른 상위 폴더는 유지합니다.
- 원본 과거 커밋 이력은 전달하지 않습니다.
- `main` 병합은 검증 후 merge commit으로 별도 수행합니다.

실제 전체 파일 전송을 완료하기 전에는 이 디렉터리를 완전한 미러라고 설명하지 않습니다.

이 UI는 학습과 리뉴얼 작업을 위한 것으로 세종문화회관의 공식 운영 웹사이트가 아닙니다.
