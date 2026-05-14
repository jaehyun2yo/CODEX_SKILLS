---
name: dev-start
description: Development session initializer — reads progress, checks pending tasks, shows git state, suggests next work. Auto-triggers on session start or coding start keywords. Triggers on "개발 시작", "코딩 시작", "시작하자", "start coding", "start dev", "작업 시작", "뭐하고 있었지", "이어서 개발", "어디까지 했지".
---

# Dev Start — 개발 세션 시작

세션 시작 시 프로젝트 상태를 파악하고 다음 작업을 제안한다.

---

## Step 1: 프로젝트 상태 수집

```bash
# Git 상태
git status --short 2>/dev/null
git log --oneline -5 2>/dev/null
git branch --show-current 2>/dev/null

# 진행 기록 (있으면)
head -30 docs/progress.txt 2>/dev/null || echo "NO_PROGRESS"

# 미해결 항목 (있으면)
grep -A 1 "FAILING\|IN_PROGRESS\|미해결\|진행 중" docs/features-list.md 2>/dev/null || echo "NO_FEATURES_LIST"

# 미커밋 변경
git diff --stat 2>/dev/null
```

---

## Step 2: 상태 리포트

수집한 정보를 간결하게 정리해서 보여준다:

```
## 세션 시작 — [프로젝트명]

**브랜치**: main
**미커밋 변경**: 3 files
**최근 커밋**: [최근 3개 요약]

### 이전 세션 요약
[progress.txt 최신 항목]

### 미해결 작업
- [🔴 우선순위 높음] ...
- [🟡 진행 중] ...

### 추천 다음 작업
→ [가장 우선순위 높은 항목 또는 이전 세션에서 "다음에 할 것"으로 남긴 것]
```

---

## Step 3: 미커밋 변경 처리

미커밋 변경이 있으면 먼저 처리:

1. `git diff --stat` 으로 변경 파일 확인
2. 사용자에게 물어보기: **"미커밋 변경이 있습니다. 커밋할까요, 스태시할까요, 그대로 이어서 할까요?"**
3. 사용자 선택에 따라 처리

---

## Step 4: 작업 진입

사용자가 작업을 선택하면:
1. 관련 spec이 있으면 읽기 (있는 경우에만)
2. 관련 코드 위치 Grep으로 파악
3. 바로 코딩 시작하지 말고 간단한 계획 확인

비단순 작업이라 새 브랜치나 worktree가 필요하면 직접 현재 브랜치에서 분기하지 말고 `work-session-routing`을 사용한다. 새 격리 브랜치는 사용자가 명시하지 않는 한 현재 HEAD가 아니라 `main`/`master` 기준에서 만든다.

사용자가 바로 코딩하겠다고 하면 즉시 시작.

---

## Rules
- docs/progress.txt, docs/features-list.md가 없어도 동작 — git 상태만으로도 충분
- 파일이 없으면 "없음"으로 표시하고 넘어감, 생성을 강요하지 않음
- 전체 리포트는 20줄 이내로 압축
- 사용자가 이미 할 일을 말했으면 리포트 생략하고 바로 진행
