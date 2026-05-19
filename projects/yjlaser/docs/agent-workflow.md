# AI 작업 워크플로우 어댑터

YJLaser는 여러 하위 프로젝트를 가진 업무 자동화 모노레포다. 글로벌
`global-orchestrator`가 공통 절차를 담당하고, 이 문서는 YJLaser에서 어떤
리뷰와 검증을 선택할지 정한다.

## 기본 흐름

```text
요청 접수
→ 프롬프트 품질/모호성/위험도 확인
→ 브레인스토밍 또는 사용자 승인 fast path
→ 계획 수립
→ GStack 계획 리뷰 추천 및 사용자 승인
→ 구현
→ 검증
→ 독립 리뷰
→ Compound/GStack learning 판단
→ 완료 보고
```

## 계획 리뷰 추천 매핑

계획이 필요한 작업은 구현 전에 아래 기준으로 리뷰를 추천한다.

| 작업 유형 | 추천 리뷰 | 기준 |
|---|---|---|
| 일반 코드, 백엔드, 아키텍처, 리팩토링 | `gstack-plan-eng-review` | 구조, 테스트, 데이터 흐름, 구현 가능성이 핵심일 때 |
| 웹 UI, 화면 흐름, 사용자 경험 | `gstack-plan-design-review` | 레이아웃, 상호작용, 시각 품질, 사용성 판단이 있을 때 |
| 설치, 개발환경, CLI, 테스트/CI, 배포 절차 | `gstack-plan-devex-review` | 다른 PC/개발자가 재현해야 하는 절차일 때 |
| 제품 범위, 우선순위, 업무 가치, 단계 나누기 | `gstack-plan-ceo-review` | 무엇을 먼저 만들지 또는 범위가 적절한지 판단해야 할 때 |
| 여러 하위 프로젝트, DB/보안/배포 포함, 큰 기능 | `gstack-autoplan` | 여러 관점 리뷰가 필요한 작업일 때 |

사용자에게는 아래 형식으로 묻는다.

```text
추천하는 계획 리뷰는 `<skill>`입니다. 이유는 <reason>입니다.
이 리뷰를 먼저 진행할까요?
```

## 작업 유형별 기본 경로

| 작업 | 기본 경로 |
|---|---|
| 새 기능/동작 변경 | 브레인스토밍 → 계획 → 계획 리뷰 추천 → 구현 |
| 버그 수정 | 문제 재현/디버깅 → 테스트 계획 → 구현 → 검증 |
| UI 변경 | 브레인스토밍 → `gstack-plan-design-review` 추천 → 구현 → 브라우저 QA |
| DB/Prisma 변경 | 브레인스토밍 → `gstack-plan-eng-review` 또는 `gstack-autoplan` 추천 → 마이그레이션 안전성 검토 |
| 인증/API 변경 | 브레인스토밍 → 보안/API 계약 리뷰 포함 → 테스트 |
| 배포/운영 변경 | 위험 게이트 → `gstack-plan-devex-review` 또는 deployment review |
| 문서만 수정 | 범위가 명확하면 fast path 제안 가능, 그래도 사용자 승인 필요 |

## 완료 보고 형식

최종 보고에는 다음을 포함한다.

- 변경 파일
- 실행한 검증과 결과
- 실행하지 못한 검증과 이유
- 리뷰 방식: 별도 reviewer agent, GStack/Compound 리뷰, 또는 fresh-context 리뷰
- 남은 리스크
- learning/artifact 기록 여부
