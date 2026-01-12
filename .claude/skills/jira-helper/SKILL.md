---
name: jira-helper
description: |
  Jira 티켓/이슈 관리. 티켓 조회, 댓글 작성, JQL 검색 지원.
  트리거: "티켓 확인", "이슈 조회", "PK-XXXXX 확인"
---

# Jira Helper

스크립트 기반 Jira API 클라이언트. 모든 작업은 `~/.claude/scripts/jira/jira_api.py` 사용.

## 환경변수 확인

작업 전 환경변수 설정 확인:
```bash
~/.claude/scripts/jira/jira_api.py get PK-1
```

에러 발생 시 안내:
```bash
# ~/.zshrc에 추가
export JIRA_BASE_URL="https://kidsnote.atlassian.net"
export JIRA_EMAIL="your-email@kidsnote.com"
export JIRA_API_TOKEN="your-api-token"
```

## 스크립트 사용법

### 티켓 조회
```bash
~/.claude/scripts/jira/jira_api.py get PK-12345
```

### JQL 검색
```bash
# 기본 (최대 10개)
~/.claude/scripts/jira/jira_api.py search "assignee=currentUser() AND status != Done"

# 개수 지정
~/.claude/scripts/jira/jira_api.py search "project=PK AND updated >= -7d" 20
```

### 댓글 조회/작성
```bash
# 조회
~/.claude/scripts/jira/jira_api.py comments PK-12345

# 작성
~/.claude/scripts/jira/jira_api.py add-comment PK-12345 "댓글 내용"
```

### 상태 전환 가능 목록
```bash
~/.claude/scripts/jira/jira_api.py transitions PK-12345
```

### 하위 티켓 조회
```bash
# 기본 (최대 100개)
~/.claude/scripts/jira/jira_api.py subtasks PK-12345

# 개수 지정
~/.claude/scripts/jira/jira_api.py subtasks PK-12345 50
```

### 상태별 요약
```bash
# 하위 티켓들의 상태별 그룹핑 및 통계
~/.claude/scripts/jira/jira_api.py status-summary PK-12345
```

출력 예시:
- 상태별 티켓 개수 및 비율
- 각 상태별 티켓 목록 (키, 제목, 담당자, 우선순위)

### 담당자별 부하 분석
```bash
# 하위 티켓들의 담당자별 작업 부하 및 리스크 분석
~/.claude/scripts/jira/jira_api.py assignee-workload PK-12345
```

출력 예시:
- 담당자별 총 티켓 수
- 상태별 분포
- 미완료 티켓 수
- 리스크 레벨 (High: 5개 이상, Medium: 3-4개, Low: 2개 이하)

## 자주 쓰는 JQL

| 목적 | JQL |
|------|-----|
| 내 미완료 티켓 | `assignee=currentUser() AND status NOT IN (Done, Closed, 완료)` |
| 최근 7일 업데이트 | `project=PK AND updated >= -7d` |
| 현재 스프린트 | `project=PK AND sprint in openSprints()` |

## 출력 형식

스크립트 결과를 파싱하여 사용자에게 표 형식으로 제공:
```markdown
## 티켓: PK-XXXXX
| 항목 | 내용 |
|------|------|
| **제목** | ... |
| **상태** | ... |
| **담당자** | ... |
```
