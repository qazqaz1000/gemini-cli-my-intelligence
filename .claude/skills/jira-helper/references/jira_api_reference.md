# Jira REST API Reference

## Base URL
```
https://kidsnote.atlassian.net/rest/api/3
```

## 인증
Basic Auth: `email:api_token` (Base64 인코딩)

## 주요 엔드포인트

### Issue (티켓)

| 작업 | Method | Endpoint |
|-----|--------|----------|
| 티켓 조회 | GET | `/issue/{issueIdOrKey}` |
| 티켓 생성 | POST | `/issue` |
| 티켓 수정 | PUT | `/issue/{issueIdOrKey}` |
| 티켓 삭제 | DELETE | `/issue/{issueIdOrKey}` |
| 상태 전환 | POST | `/issue/{issueIdOrKey}/transitions` |
| 전환 목록 | GET | `/issue/{issueIdOrKey}/transitions` |

### Comment (댓글)

| 작업 | Method | Endpoint |
|-----|--------|----------|
| 댓글 목록 | GET | `/issue/{issueIdOrKey}/comment` |
| 댓글 작성 | POST | `/issue/{issueIdOrKey}/comment` |
| 댓글 수정 | PUT | `/issue/{issueIdOrKey}/comment/{id}` |
| 댓글 삭제 | DELETE | `/issue/{issueIdOrKey}/comment/{id}` |

### Search (검색)

| 작업 | Method | Endpoint |
|-----|--------|----------|
| JQL 검색 | GET/POST | `/search` |

## 자주 사용하는 JQL 쿼리

```jql
# 내 담당 미완료 티켓
assignee = currentUser() AND status != Done

# 특정 프로젝트의 진행중 티켓
project = PK AND status = "In Progress"

# 최근 7일 업데이트된 티켓
project = PK AND updated >= -7d

# 특정 스프린트
project = PK AND sprint in openSprints()

# 텍스트 검색
project = PK AND text ~ "검색어"
```

## 응답 필드 (Issue)

```json
{
  "key": "PK-12345",
  "fields": {
    "summary": "제목",
    "description": { "content": [...] },
    "status": { "name": "In Progress" },
    "assignee": { "displayName": "이름" },
    "reporter": { "displayName": "이름" },
    "priority": { "name": "High" },
    "created": "2024-01-01T00:00:00.000+0000",
    "updated": "2024-01-02T00:00:00.000+0000"
  }
}
```

## 댓글 작성 Body 형식 (Atlassian Document Format)

```json
{
  "body": {
    "type": "doc",
    "version": 1,
    "content": [
      {
        "type": "paragraph",
        "content": [
          {
            "type": "text",
            "text": "댓글 내용"
          }
        ]
      }
    ]
  }
}
```

## 필드 수정 요청

```json
{
  "fields": {
    "summary": "새 제목",
    "description": {
      "type": "doc",
      "version": 1,
      "content": [
        {
          "type": "paragraph",
          "content": [{"type": "text", "text": "새 설명"}]
        }
      ]
    }
  }
}
```

## HTTP 상태 코드

| 코드 | 의미 |
|-----|-----|
| 200 | 성공 |
| 201 | 생성됨 |
| 204 | 성공 (응답 없음) |
| 400 | 잘못된 요청 |
| 401 | 인증 실패 |
| 403 | 권한 없음 |
| 404 | 리소스 없음 |
