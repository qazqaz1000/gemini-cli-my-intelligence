# Claude Code 스크립트 모음

토큰 절약을 위한 실행 가능 스크립트 모음입니다.

## 최적화 효과

| 항목 | 최적화 전 | 최적화 후 | 절감 |
|------|----------|----------|------|
| Agents + Skills | ~6,944 단어 | ~3,152 단어 | **55%** |
| References | ~11,028 단어 | 필요시만 로드 | **90%** |
| **총 토큰** | ~24,000 | ~4,200 | **82%** |

## 디렉토리 구조

```
scripts/
├── android/
│   ├── build.sh       # 빌드 및 에러 파싱
│   ├── ktlint.sh      # ktlint 검사/수정
│   ├── run_test.sh    # 테스트 실행
│   └── review.sh      # 셀프 리뷰 자동화
├── git/
│   └── get_base_branch.sh  # PR base branch 결정
├── jira/
│   └── jira_api.py    # Jira REST API 클라이언트
├── slack/
│   └── slack_api.py   # Slack Web API 클라이언트
└── common/
    └── utils.py       # 공통 유틸리티
```

## 스크립트 사용법

### Android

```bash
# 빌드
~/.claude/scripts/android/build.sh              # 기본 빌드
~/.claude/scripts/android/build.sh --lint       # lint + 빌드
~/.claude/scripts/android/build.sh classnote    # 다른 flavor

# 테스트
~/.claude/scripts/android/run_test.sh -m app    # app 모듈 테스트
~/.claude/scripts/android/run_test.sh -m app "*.FeatureViewModelTest"

# 리뷰
~/.claude/scripts/android/review.sh             # 셀프 리뷰

# ktlint
~/.claude/scripts/android/ktlint.sh             # format
~/.claude/scripts/android/ktlint.sh -c          # check only
```

### Git

```bash
# PR base branch 결정
~/.claude/scripts/git/get_base_branch.sh
```

### Jira

```bash
# 티켓 조회
~/.claude/scripts/jira/jira_api.py get PK-12345

# JQL 검색
~/.claude/scripts/jira/jira_api.py search "assignee=currentUser()"

# 댓글
~/.claude/scripts/jira/jira_api.py comments PK-12345
~/.claude/scripts/jira/jira_api.py add-comment PK-12345 "댓글 내용"
```

### Slack

```bash
# 채널 목록
~/.claude/scripts/slack/slack_api.py channels

# 메시지 조회
~/.claude/scripts/slack/slack_api.py messages general 10

# 검색 (User Token 필요)
~/.claude/scripts/slack/slack_api.py search "in:#general 키워드"
```

## 원칙

1. **단일 책임**: 각 스크립트는 하나의 명확한 작업만 수행
2. **표준 출력**: JSON 형식으로 결과 반환 (Python)
3. **에러 처리**: 모든 예외를 catch하고 명확한 에러 메시지 제공
4. **실행 권한**: `chmod +x`로 실행 가능하게 설정

## 환경변수 설정

`~/.zshrc`에 추가:

```bash
# Jira
export JIRA_BASE_URL="https://kidsnote.atlassian.net"
export JIRA_EMAIL="your-email@kidsnote.com"
export JIRA_API_TOKEN="your-api-token"

# Slack
export SLACK_BOT_TOKEN="xoxb-your-bot-token"
export SLACK_USER_TOKEN="xoxp-your-user-token"  # 검색용
```
