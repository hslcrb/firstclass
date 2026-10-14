# 스킬 저장소와 자동 동기화

`firstclass`는 공개 저장소이며, 아래 두 스킬은 각각 별도의 비공개 저장소다. 스킬 파일은 기존 경로에 있고 부모 저장소는 서브모듈 커밋 포인터를 기록한다. 전환 이전에 공개된 파일 이력은 유지된다.

| 현재 경로 | 비공개 저장소 | 작업 브랜치 |
| --- | --- | --- |
| `.AGENTS/skills/limstandards` | [hslcrb/limstandards](https://github.com/hslcrb/limstandards) | `main` |
| `.AGENTS/skills/limsflex` | [hslcrb/limsflex](https://github.com/hslcrb/limsflex) | `main` |

## 다른 컴퓨터에서 최초 한 번 설정

세 저장소에 접근할 수 있는 GitHub 계정으로 Git 인증을 준비한다. 새 복제본은 다음처럼 받는다.

```sh
git clone --recurse-submodules https://github.com/hslcrb/firstclass.git
cd firstclass
```

저장소 루트에서 환경에 맞는 설치 명령을 한 번 실행한다.

Windows PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .AGENTS/sync-skills.ps1 -Install
```

macOS·Linux·Windows Git Bash:

```sh
sh .AGENTS/install-skill-sync.sh
```

실제 동기화 로직은 동일한 POSIX shell 코드다. Windows 실행기는 Git for Windows에 포함된 `sh.exe`를 찾는다. Python·Node.js는 필요하지 않다. 설치는 저장소별 Git 설정에만 적용하며, 이미 초기화한 스킬 파일을 다시 만들지 않는다. 안전하게 처리할 수 없는 기존 훅 설정이나 작업 상태는 덮어쓰지 않고 안내한다.

설치는 `main`의 추적·푸시 대상을 `origin/main`으로 맞춘다. 필요한 main fetch 매핑은 기존 규칙을 보존하면서 추가하고, 작업 전에도 해당 추적 설정을 확인한다. 전역 Git 설정은 변경하지 않는다.

Git은 복제할 때 추적된 훅을 자동 활성화하지 않는다. 따라서 **컴퓨터·복제본마다 설치가 한 번 필요하다**. 설치 스크립트는 다시 실행할 수 있다. GitHub 웹 편집이나 훅을 건너뛰는 클라이언트까지 로컬 훅이 실행되는 것은 아니다.

## 평소에는 일반 commit·push

`firstclass`의 `main`에서 평소 사용하는 Git·IDE의 commit·push를 실행한다.

- commit 전에 세 저장소를 모두 `fetch --prune`한다. 원격 변경을 확인한 다음, 변경된 두 스킬의 내용을 각 저장소에 커밋하고 부모의 서브모듈 포인터를 stage한다. 부모의 다른 stage 선택은 유지한다.
- 각 스킬 내부 변경은 해당 스킬 저장소 전체를 대상으로 커밋한다. 부모의 커밋 메시지는 그대로 사용하고, 일반 훅이 만드는 스킬 커밋에는 동기화용 메시지를 사용한다.
- push 전에도 세 저장소를 다시 fetch한다. 먼저 두 스킬의 커밋을 푸시하고, 성공하면 부모의 포인터를 푸시한다. push 훅은 부모에 새 커밋을 만들거나 커밋되지 않은 파일을 몰래 추가하지 않는다.
- fetch는 원격 참조를 갱신하며, 작업 파일을 자동으로 merge·rebase하지 않는다. 원격이 앞서거나 이력이 갈라지면 먼저 정리하도록 중단한다. 네트워크·인증 문제로 fetch가 실패해도 진행을 중단한다.

두 스킬만 수정한 경우에도 부모에서 commit하면 훅이 해당 변경과 포인터를 준비한다. 별도로 복제한 스킬 저장소만 사용하는 경우에는 그 복제본에 부모가 없으므로, 세 저장소 동기화는 `firstclass` 복제본에서 실행한다.

## 기존 일괄 명령도 사용 가능

Windows에서 명시적인 메시지로 두 스킬과 관리 파일만 함께 처리하려면 다음 명령을 사용한다.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .AGENTS/sync-skills.ps1 -Message 'Edit: 스킬 수정'
```

이 명령도 먼저 세 저장소를 fetch한다. 두 스킬과 동기화 설정 파일만 부모 커밋에 포함하며, 부모에 무관한 staged 변경이 있으면 먼저 중단한다. 메시지는 UTF-8 파일로 전달해 한글·따옴표·다중행을 보존한다.

## 실패 후 계속하기

세 저장소의 전송은 순차 처리된다. 중간에 실패하면 일부 저장소는 이미 갱신됐을 수 있으며, 만들어진 로컬 커밋은 보존한다. 안내된 원격 변경·인증·네트워크 문제를 해결한 다음 같은 push 또는 일괄 명령을 다시 실행한다. 변경이 없으면 중복 커밋을 만들지 않는다. 강제 푸시·reset·clean·자동 stash는 사용하지 않는다.

Git의 훅 동작은 [공식 훅 문서](https://git-scm.com/docs/githooks), fetch 동작은 [공식 fetch 문서](https://git-scm.com/docs/git-fetch)를 따른다.
