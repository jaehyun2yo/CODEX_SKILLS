# CODEX_SKILLS

개인 Codex 워크플로우 설정 저장소입니다.

Superpowers, gstack, Compound Engineering을 함께 쓰는 현재 작업 환경에서
반복해서 유지해야 하는 설정만 저장합니다. 업스트림 플러그인 저장소나 빌드
산출물은 이 저장소에 포함하지 않습니다.

## 핵심 원칙

이 설정의 가장 중요한 규칙은 **개발과 검수를 분리하는 것**입니다.

- 기획하거나 구현한 에이전트가 자기 작업의 최종 검수자가 되면 안 됩니다.
- 가능한 경우 별도 reviewer agent가 요구사항, diff, 테스트, 회귀 위험,
  유지보수성을 독립적으로 검토해야 합니다.
- Critical 또는 Important 리뷰 이슈는 구현자가 수정하고, 리뷰어가 다시
  확인해야 완료로 볼 수 있습니다.
- 별도 에이전트를 쓸 수 없는 환경에서는 그 제한을 명시하고 fresh-context
  리뷰 패스를 수행해야 합니다.
- 독립 검수 전에는 완료, 머지, 배포, 다음 주요 작업 진행을 하지 않습니다.

## 포함 내용

- Superpowers 및 Compound Engineering marketplace 등록
- Codex용 Compound Engineering agents 설치
- gstack을 `~/.gstack/repos/gstack`에 설치 또는 업데이트
- gstack 및 Compound Engineering skills를 `~/.codex/skills`에 연결
- 커스텀 `global-orchestrator` skill 설치
- 커스텀 `superpowers-compound-review-loop` skill 설치
- 전역 `~/AGENTS.md`에 개발/검수 분리 규칙과 Superpowers 리뷰 후처리 훅 설치
- Codex 전용 `~/.codex/AGENTS.md`에 Claude 호환 tool map과 역할 분리 규칙 설치

## 설치

PowerShell에서 실행합니다.

```powershell
git clone https://github.com/jaehyun2yo/CODEX_SKILLS.git
cd CODEX_SKILLS
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1
```

설치 후 Codex를 재시작해야 새 skills와 AGENTS 지침이 로드됩니다.

## 새 데스크탑에 AI로 전체 적용시키는 프롬프트

새 Windows 데스크탑에서 Codex에게 아래 프롬프트를 그대로 전달합니다.

```text
이 데스크탑에 jaehyun2yo CODEX_SKILLS 글로벌 AI 하네스를 전체 적용해줘.

목표:
- https://github.com/jaehyun2yo/CODEX_SKILLS.git 저장소를 로컬에 클론하거나, 이미 있으면 최신으로 업데이트한다.
- PowerShell 설치 스크립트 `scripts/install.ps1`를 실행한다.
- Superpowers, GStack, Compound Engineering, 커스텀 global-orchestrator, superpowers-compound-review-loop 스킬이 Codex에서 로드되도록 설정한다.
- `~/.codex/AGENTS.md`와 `~/AGENTS.md`에 글로벌 워크플로우 지침이 적용되었는지 확인한다.
- 설치 후 검증 결과와 재시작 필요 여부를 보고한다.

권장 경로:
- 저장소 위치: `C:\Users\<사용자>\OneDrive\Desktop\dev\projects\CODEX_SKILLS`
- CODEX_HOME 기본값: `C:\Users\<사용자>\.codex`

작업 절차:
1. 현재 OS, PowerShell, git, codex, bun, bunx, python 사용 가능 여부를 확인한다.
2. 저장소가 없으면 `git clone https://github.com/jaehyun2yo/CODEX_SKILLS.git`로 클론한다.
3. 저장소가 있으면 `git pull --ff-only`로 최신화한다.
4. `powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1`를 실행한다.
5. 설치 검증 실패 시 원인을 읽고 수정 가능한 항목은 수정한 뒤 재실행한다.
6. 기존 사용자 설정이나 AGENTS 파일을 삭제하지 말고, 스크립트가 만든 백업을 보존한다.
7. 마지막에 설치된 스킬, 적용된 AGENTS 위치, 실패/스킵된 항목, Codex 재시작 필요 여부를 한글로 보고한다.

주의:
- 실제 프로젝트 파일은 수정하지 않는다.
- 프로덕션 배포, secret 변경, 외부 API 호출 같은 위험 작업은 하지 않는다.
- 설치 중 오류가 나면 추측하지 말고 명령 출력 기준으로 원인을 설명한다.
```

## 커스텀 파일

현재 직접 관리하는 커스텀 레이어는 아래 파일들입니다.

```text
skills/global-orchestrator/
skills/superpowers-compound-review-loop/
templates/AGENTS.global.md
templates/AGENTS.codex.md
scripts/install.ps1
```

vendored Superpowers, gstack, Compound Engineering skill 파일을 직접 수정하지
않습니다. 업스트림 패키지는 독립적으로 업데이트하고, 로컬 워크플로우
커스터마이징은 이 저장소의 템플릿과 커스텀 skill에만 둡니다.

## 설치 검증

설치 스크립트는 다음 항목을 확인합니다.

- `~/.codex/config.toml`이 TOML로 정상 파싱되는지
- `ce-compound` skill 존재 여부
- `gstack-review` skill 존재 여부
- `global-orchestrator` skill 존재 여부
- `superpowers-compound-review-loop` skill 존재 여부
- Compound Engineering agents 존재 여부

## 운영 흐름

일반적인 비 trivial 작업은 아래 순서로 진행합니다.

```text
요청 접수
→ 프롬프트 품질/모호성/위험도 확인
→ 브레인스토밍 또는 사용자 승인 fast path
→ 계획 수립
→ 구현
→ 검증
→ 별도 reviewer agent 검수 또는 fresh-context 리뷰
→ Compound/GStack learning 판단
→ 완료 보고
```

`global-orchestrator`는 이 순서를 공통 하네스로 강제합니다. 작은 작업은
fast path로 처리할 수 있지만, 매번 사용자 승인을 먼저 받아야 합니다.

Superpowers 리뷰 사이클에서 실제 문제가 발견되거나 재사용할 교훈이 생기면
`superpowers-compound-review-loop`가 Compound Engineering의 `ce-compound`
또는 `ce-compound-refresh` 흐름으로 기록합니다.
