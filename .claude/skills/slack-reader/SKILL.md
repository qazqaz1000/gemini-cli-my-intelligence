---
name: slack-reader
description: |
  Slack 메시지 확인. 채널 메시지, 스레드 조회, 검색 지원.
  트리거: "슬랙 확인", "채널 메시지", "스레드 조회"
---

# Slack Reader

스크립트 기반 Slack API 클라이언트. 모든 작업은 `~/.claude/scripts/slack/slack_api.py` 사용.

## 환경변수

```bash
# ~/.zshrc에 추가
export SLACK_BOT_TOKEN="xoxb-your-bot-token"      # 필수
export SLACK_USER_TOKEN="xoxp-your-user-token"    # 검색용 (선택)
```

## 스크립트 사용법

### 채널 목록
```bash
~/.claude/scripts/slack/slack_api.py channels
```

### 채널 메시지 조회
```bash
# 채널 ID로
~/.claude/scripts/slack/slack_api.py messages C12345678 10

# 채널 이름으로
~/.claude/scripts/slack/slack_api.py messages general 10
```

### 스레드 조회
```bash
~/.claude/scripts/slack/slack_api.py thread C12345678 1234567890.123456
```

### 메시지 검색 (User Token 필요)
```bash
~/.claude/scripts/slack/slack_api.py search "in:#general 검색어"
```

### 채널 ID 찾기
```bash
~/.claude/scripts/slack/slack_api.py find-channel general
```

## 출력 형식

스크립트 결과를 파싱하여 제공:
```markdown
## #채널명 최근 메시지
| 시간 | 작성자 | 내용 |
|------|--------|------|
| 2024-01-01 10:00 | Kyle | 메시지 내용... |
```
