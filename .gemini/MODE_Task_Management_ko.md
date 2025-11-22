# 작업 관리 모드

**목적**: 복잡한 다단계 작업을 위한 영구 메모리를 갖춘 계층적 작업 구성

## 활성화 트리거
- 조정이 필요한 3단계 이상의 작업
- 여러 파일/디렉토리 범위(디렉토리 2개 이상 또는 파일 3개 이상)
- 단계가 필요한 복잡한 종속성
- 수동 플래그: `--task-manage`, `--orchestrate`
- 품질 개선 요청: 다듬기, 개선, 향상

## 메모리가 포함된 작업 계층 구조

📋 **계획** → write_memory("plan", 목표 설명)
→ 🎯 **단계** → write_memory("phase_X", 마일스톤)
  → 📦 **작업** → write_memory("task_X.Y", 결과물)
    → ✓ **할 일** → TodoWrite + write_memory("todo_X.Y.Z", 상태)

## 메모리 작업

### 세션 시작
```
1. list_memories() → 기존 작업 상태 표시
2. read_memory("current_plan") → 컨텍스트 재개
3. think_about_collected_information() → 중단된 부분 파악
```

### 실행 중
```
1. write_memory("task_2.1", "완료: 인증 미들웨어")
2. think_about_task_adherence() → 진행 상황 확인
3. TodoWrite 상태 순차적 업데이트
4. 30분마다 write_memory("checkpoint", 현재 상태)
```

### 세션 종료
```
1. think_about_whether_you_are_done() → 완료 여부 평가
2. write_memory("session_summary", 결과)
3. 완료된 임시 항목에 대해 delete_memory()
```

## 실행 패턴

1. **로드**: list_memories() → read_memory() → 상태 재개
2. **계획**: 계층 구조 생성 → 각 수준에 대해 write_memory()
3. **추적**: TodoWrite + 메모리 업데이트 순차적 수행
4. **실행**: 작업 완료 시 메모리 업데이트
5. **체크포인트**: 상태 보존을 위한 주기적인 write_memory()
6. **완료**: 결과와 함께 최종 메모리 업데이트

## 도구 선택

| 작업 유형 | 기본 도구 | 메모리 키 |
|-----------|-------------|------------|
| 분석 | Sequential MCP | "analysis_results" |
| 구현 | MultiEdit/Morphllm | "code_changes" |
| UI 구성 요소 | Magic MCP | "ui_components" |
| 테스트 | Playwright MCP | "test_results" |
| 문서화 | Context7 MCP | "doc_patterns" |

## 메모리 스키마

```
plan_[timestamp]: 전체 목표 설명
phase_[1-5]: 주요 마일스톤 설명
task_[phase].[number]: 특정 결과물 상태
todo_[task].[number]: 원자적 작업 완료
checkpoint_[timestamp]: 현재 상태 스냅샷
blockers: 주의가 필요한 활성 장애물
decisions: 내려진 주요 아키텍처/디자인 결정
```

## 예시

### 세션 1: 인증 작업 시작
```
list_memories() → 비어 있음
write_memory("plan_auth", "JWT 인증 시스템 구현")
write_memory("phase_1", "분석 - 보안 요구사항 검토")
write_memory("task_1.1", "대기 중: 기존 인증 패턴 검토")
TodoWrite: 5개의 구체적인 할 일 생성
task 1.1 실행 → write_memory("task_1.1", "완료: 3개의 패턴 발견")
```

### 세션 2: 중단 후 재개
```
list_memories() → plan_auth, phase_1, task_1.1 표시
read_memory("plan_auth") → "JWT 인증 시스템 구현"
think_about_collected_information() → "분석 완료, 구현 시작"
think_about_task_adherence() → "순조롭게 진행 중, 2단계로 이동"
write_memory("phase_2", "구현 - 미들웨어 및 엔드포인트")
구현 작업 계속...
```

### 세션 3: 완료 확인
```
think_about_whether_you_are_done() → "테스트 단계가 완료되지 않음"
남은 테스트 작업 완료
write_memory("outcome_auth", "95% 테스트 커버리지로 성공적으로 구현됨")
delete_memory("checkpoint_*") → 임시 상태 정리
write_memory("session_summary", "인증 시스템 완료 및 검증됨")
```
