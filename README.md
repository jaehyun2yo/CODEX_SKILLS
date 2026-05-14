# CODEX_SKILLS

Codex에서 사용하는 개인/글로벌 스킬 모음입니다.

## 포함된 스킬

| 스킬 | 위치 | 설명 |
|---|---|---|
| `work-session-routing` | `skills/work-session-routing` | 작업 시작/마무리 요청을 현재 브랜치 작업과 worktree 격리 작업으로 라우팅합니다. 비단순 작업은 새 브랜치를 현재 HEAD가 아니라 `origin/main` -> `origin/master` -> `main` -> `master` 순서의 기준 브랜치에서 만들도록 지시합니다. |
| `using-git-worktrees` | `skills/using-git-worktrees` | 비단순 기능/버그/리팩토링 작업을 격리 worktree에서 시작하도록 안내합니다. 수동 fallback 명령은 반드시 `git worktree add "$path" -b "$BRANCH_NAME" "$BASE_REF"` 형태로 실행해 현재 브랜치에서 잘못 분기하지 않도록 합니다. |
| `dev-start` | `skills/dev-start` | 개발 세션 시작 시 git 상태, 최근 진행 기록, 미해결 작업을 요약하고 다음 작업 진입을 돕습니다. 새 브랜치나 worktree가 필요한 비단순 작업은 `work-session-routing`을 통해 `main`/`master` 기준으로 시작하도록 연결합니다. |
| `dev-wrap` | `skills/dev-wrap` | 세션 마무리 시 변경 사항, 커밋, 진행 문서 업데이트, 다음 세션 핸드오프를 정리합니다. 마무리 중 새 후속 브랜치를 만들지 않고, 다음 세션에서 `work-session-routing`으로 분기하도록 제한합니다. |

## 브랜치 기준 정책

새 격리 작업 브랜치는 사용자가 명시하지 않는 한 현재 체크아웃된 브랜치에서 만들지 않습니다.

기준 브랜치 선택 순서:

1. `origin/main`
2. `origin/master`
3. `main`
4. `master`

위 기준 브랜치가 없으면 작업을 멈추고 사용자에게 어떤 base branch를 쓸지 물어봐야 합니다.

## 설치 참고

이 repo의 `skills/` 아래 폴더를 사용하는 환경의 스킬 디렉터리에 복사해서 사용합니다.

예시:

```powershell
Copy-Item -Recurse -Force .\skills\work-session-routing "$env:USERPROFILE\.codex\skills\work-session-routing"
Copy-Item -Recurse -Force .\skills\dev-start "$env:USERPROFILE\.agents\skills\dev-start"
Copy-Item -Recurse -Force .\skills\dev-wrap "$env:USERPROFILE\.agents\skills\dev-wrap"
```

`using-git-worktrees`는 Superpowers 플러그인 스킬의 수정본이므로, 사용하는 Superpowers 설치/캐시 위치에 맞게 반영해야 합니다.
