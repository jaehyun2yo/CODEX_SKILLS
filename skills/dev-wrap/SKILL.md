---
name: dev-wrap
description: Development session wrap-up — commits changes, updates progress/features/changelog, prepares for next session handoff. Auto-triggers on wrap-up keywords. Triggers on "마무리", "끝", "done", "wrap up", "세션 정리", "오늘 여기까지", "커밋하고 끝", "정리해줘", "세션 끝", "마무리하자".
---

# Dev Wrap — 개발 세션 마무리

세션 종료 전에 모든 변경을 정리하고 다음 세션을 위한 핸드오프를 준비한다.

---

## Step 1: 변경 사항 파악

```bash
# 미커밋 변경 확인
git status --short 2>/dev/null
git diff --stat 2>/dev/null

# 이번 세션 커밋 확인
git log --oneline --since="4 hours ago" 2>/dev/null || git log --oneline -10 2>/dev/null
```

---

## Step 2: 미커밋 변경 커밋

미커밋 변경이 있으면:

1. `git diff` 로 변경 내용 파악
2. 변경 내용에 맞는 커밋 메시지 작성
3. 즉시 커밋 (사용자 확인 불필요)

여러 주제의 변경이 섞여있으면 자동으로 분리 커밋.

---

## Step 3: 문서 업데이트

docs/ 구조가 있으면 자동 업데이트. 없으면 건너뜀.

### 3.1 progress.txt

```
### 세션 #NNN — YYYY-MM-DD
- **작업 내용**: [이번 세션에서 한 것 요약]
- **완료한 것**: [완료된 항목들]
- **다음에 할 것**: [이어서 해야 할 것]
- **이슈**: [발견된 문제, 없으면 "없음"]
- **관련 커밋**: [커밋 해시 나열]
```

기존 내용 위에 새 항목을 추가 (최신이 위로).

### 3.2 features-list.md

이번 세션에서 완료된 항목:
- `FAILING` → `PASSING` (완료 시)
- `FAILING` → `IN_PROGRESS` (작업 시작했지만 미완료)

### 3.3 CHANGELOG.md

변경이 사용자에게 의미 있는 수준이면 추가:
- **추가**: 새 기능
- **수정**: 버그 수정
- **변경**: 기존 동작 변경

---

## Step 4: 문서 커밋

문서 업데이트를 별도 커밋:
```
docs: update progress and features-list for session #NNN
```

---

## Step 5: 세션 종료 리포트

```
## 세션 마무리 완료

### 이번 세션 요약
- 커밋: N개
- 변경 파일: N개
- 완료 항목: [항목들]

### 다음 세션에서 할 것
1. [가장 중요한 다음 작업]
2. [그 다음]

### 미해결 이슈
- [있으면 나열, 없으면 "없음"]
```

---

## Rules
1. **docs/ 없어도 동작** — 커밋만이라도 정리
2. **자동 커밋** — 사용자 확인 없이 즉시 커밋 (민감 파일만 경고)
3. **세션 번호 자동 증가** — progress.txt에서 마지막 번호 읽어서 +1
4. **날짜는 절대 날짜** (YYYY-MM-DD) 사용
5. **리포트는 간결하게** — 10줄 이내
6. **민감 파일 제외** — .env, credentials 등은 커밋 목록에서 경고
7. **후속 브랜치 생성 금지** — 마무리 중 새 작업 브랜치를 만들지 않는다. 다음 작업용 브랜치가 필요하면 새 세션에서 `work-session-routing`을 사용해 `main`/`master` 기준으로 만든다.
