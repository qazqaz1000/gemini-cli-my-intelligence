# Slack Web API Reference

## Base URL
```
https://slack.com/api
```

## 인증
Header: `Authorization: Bearer {token}`

## 토큰 종류

| 토큰 | 접두사 | 용도 |
|-----|-------|-----|
| Bot Token | `xoxb-` | 봇 기능 (채널 읽기/쓰기) |
| User Token | `xoxp-` | 사용자 권한 (검색 등) |

## 주요 엔드포인트

### Conversations (채널/DM)

| 작업 | Method | Endpoint |
|-----|--------|----------|
| 채널 목록 | GET | `conversations.list` |
| 채널 정보 | GET | `conversations.info` |
| 메시지 목록 | GET | `conversations.history` |
| 스레드 조회 | GET | `conversations.replies` |
| 내 채널 목록 | GET | `users.conversations` |

### Search (검색) - User Token 필요

| 작업 | Method | Endpoint |
|-----|--------|----------|
| 메시지 검색 | GET | `search.messages` |
| 파일 검색 | GET | `search.files` |

### Users (사용자)

| 작업 | Method | Endpoint |
|-----|--------|----------|
| 사용자 정보 | GET | `users.info` |
| 사용자 목록 | GET | `users.list` |

## 필요 스코프 (Bot Token)

```
channels:history    - 공개 채널 메시지 읽기
channels:read       - 공개 채널 정보 읽기
groups:history      - 비공개 채널 메시지 읽기
groups:read         - 비공개 채널 정보 읽기
im:history          - DM 메시지 읽기
im:read             - DM 정보 읽기
users:read          - 사용자 정보 읽기
```

## 필요 스코프 (User Token - 검색용)

```
search:read         - 메시지/파일 검색
```

## 파라미터

### conversations.history
| 파라미터 | 필수 | 설명 |
|---------|-----|-----|
| channel | O | 채널 ID |
| limit | X | 반환 개수 (기본 100, 최대 1000) |
| oldest | X | 시작 타임스탬프 |
| latest | X | 끝 타임스탬프 |

### conversations.replies
| 파라미터 | 필수 | 설명 |
|---------|-----|-----|
| channel | O | 채널 ID |
| ts | O | 부모 메시지 타임스탬프 |

### search.messages
| 파라미터 | 필수 | 설명 |
|---------|-----|-----|
| query | O | 검색어 |
| count | X | 반환 개수 |
| sort | X | score, timestamp |

## 검색 쿼리 문법

```
# 채널 지정
in:#channel-name 검색어

# 사용자 지정
from:@username 검색어

# 날짜 범위
after:2024-01-01 before:2024-01-31

# 조합
in:#general from:@kyle after:2024-01-01 키워드
```

## 응답 형식

### conversations.history
```json
{
  "ok": true,
  "messages": [
    {
      "type": "message",
      "user": "U12345678",
      "text": "메시지 내용",
      "ts": "1234567890.123456",
      "thread_ts": "1234567890.123456",
      "reply_count": 5
    }
  ],
  "has_more": true
}
```

### 타임스탬프 변환
```bash
# Unix timestamp를 읽기 쉬운 형식으로
date -r ${ts%.*}
```

## HTTP 상태 코드

Slack API는 항상 200을 반환하고 `ok` 필드로 성공 여부 판단:
```json
{"ok": true, ...}   // 성공
{"ok": false, "error": "channel_not_found"}  // 실패
```
