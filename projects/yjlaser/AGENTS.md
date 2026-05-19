# YJLaser Project Agent Instructions

이 저장소에서는 글로벌 `global-orchestrator` 워크플로우를 먼저 따른다.
이 파일은 YJLaser에 특화된 어댑터다. 공통 절차는 글로벌 하네스가 담당하고,
이 프로젝트 파일은 컨텍스트 로딩, 검증 명령, 위험 작업, 리뷰 라우팅을
정의한다.

## 답변과 커밋

- 모든 사용자 응답은 한글로 작성한다.
- 커밋 메시지는 한글로 작성한다.
- 코드 주석, 변수명, 기술 용어는 영어를 허용한다.

## 작업 전 컨텍스트

작업 전 아래 순서로 필요한 문서만 읽는다.

1. `CLAUDE.md`
2. `docs/context-map.md`
3. `docs/agent-workflow.md`
4. 변경 대상 하위 프로젝트의 README/설정/테스트 문서
5. 관련 업무 문서: `docs/workflow.md`, `docs/architecture.md`, `docs/conventions.md`

## 글로벌 하네스 연결

- 비 trivial 작업은 `intake → prompt-quality-check → clarify/brainstorm → plan → recommend-plan-review → execute → verify → review → learning → final` 흐름을 따른다.
- fast path는 작은 작업으로 판단되어도 사용자 승인 없이는 사용하지 않는다.
- 계획이 필요한 작업은 구현 전에 `docs/agent-workflow.md` 기준으로 GStack 계획 리뷰를 추천하고 사용자 승인을 받는다.
- 구현 후에는 `docs/verification-matrix.md`에 맞는 검증을 실행한다.
- 비 trivial 작업은 구현자와 리뷰어 역할을 분리한다. 별도 reviewer agent를 쓸 수 없으면 fresh-context 리뷰 패스를 수행하고 그 한계를 보고한다.

## 절대 Fast Path 금지

아래 작업은 항상 full workflow와 명시적 사용자 승인 게이트를 사용한다.

- 프로덕션 배포, Railway/Vercel 설정 변경
- Supabase 프로덕션 DB, Cloudflare R2 프로덕션 버킷 작업
- Prisma migration deploy 또는 destructive migration
- Popbill FAX/MMS/Email 실제 발송
- LGU+ 외부웹하드 실제 업로드/삭제/동기화 변경
- 고객 도면, 거래처 정보, API 키, Doppler secret 처리
- 인증, 권한, 관리자 로그인, public API 변경

상세 기준은 `docs/risk-gates.md`를 따른다.

## 검증 기준

변경 경로별 필수 검증은 `docs/verification-matrix.md`를 따른다.
검증을 실행하지 못하면 최종 보고에 이유와 남은 리스크를 명시한다.

## 문서 동기화

- 코드 변경이 업무 흐름, 아키텍처, 운영 절차, 위험 작업 기준을 바꾸면 관련 문서를 함께 업데이트한다.
- 큰 기능이나 구조 변경은 구현 전 스펙/계획 문서를 남긴다.
- 반복 가능한 교훈은 글로벌 learning 또는 프로젝트 문서로 승격한다.
