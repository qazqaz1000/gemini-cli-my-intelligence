#!/usr/bin/env python3
"""
Jira REST API 클라이언트 (표준 라이브러리만 사용)
환경변수: JIRA_BASE_URL, JIRA_EMAIL, JIRA_API_TOKEN
"""
import os
import sys
import json
import base64
import urllib.request
import urllib.error
import urllib.parse
from typing import Optional, Dict, List, Any

# 공통 유틸리티
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'common'))
from utils import output_result


class JiraClient:
    def __init__(self):
        self.base_url = os.getenv('JIRA_BASE_URL', '').rstrip('/')
        self.email = os.getenv('JIRA_EMAIL', '')
        self.token = os.getenv('JIRA_API_TOKEN', '')

        if not all([self.base_url, self.email, self.token]):
            raise ValueError(
                "환경변수 미설정: JIRA_BASE_URL, JIRA_EMAIL, JIRA_API_TOKEN을 ~/.zshrc에 추가하세요"
            )

        # Basic Auth 헤더 생성
        credentials = base64.b64encode(f"{self.email}:{self.token}".encode()).decode()
        self.headers = {
            'Authorization': f'Basic {credentials}',
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        }

    def _request(self, endpoint: str, method: str = 'GET', data: Optional[Dict] = None) -> Dict:
        """API 요청 실행"""
        url = f"{self.base_url}/rest/api/3/{endpoint}"

        request_data = None
        if data:
            request_data = json.dumps(data).encode('utf-8')

        req = urllib.request.Request(url, data=request_data, headers=self.headers, method=method)

        try:
            with urllib.request.urlopen(req) as response:
                return json.loads(response.read().decode('utf-8'))
        except urllib.error.HTTPError as e:
            error_body = e.read().decode('utf-8') if e.fp else ''
            raise Exception(f"HTTP {e.code}: {self._get_error_message(e.code, error_body)}")

    def _get_error_message(self, code: int, body: str) -> str:
        """HTTP 에러 코드에 따른 메시지"""
        messages = {
            400: "잘못된 요청 - JQL 문법 또는 JSON 형식 확인",
            401: "인증 실패 - API 토큰/이메일 확인",
            403: "권한 없음 - 프로젝트 접근 권한 확인",
            404: "티켓 없음 - 티켓 번호 확인"
        }
        return messages.get(code, body)

    def get_issue(self, issue_key: str) -> Dict:
        """티켓 상세 조회"""
        fields = 'summary,status,assignee,description,priority,reporter,created,updated,labels,components'
        return self._request(f"issue/{issue_key}?fields={fields}")

    def search_jql(self, jql: str, max_results: int = 10, fields: Optional[List[str]] = None) -> Dict:
        """JQL 검색 (POST 방식 - 최신 API)"""
        if fields is None:
            fields = ['summary', 'status', 'priority', 'assignee']

        payload = {
            'jql': jql,
            'fields': fields,
            'maxResults': max_results
        }
        return self._request("search/jql", method='POST', data=payload)

    def get_comments(self, issue_key: str) -> Dict:
        """티켓 댓글 목록 조회"""
        return self._request(f"issue/{issue_key}/comment")

    def add_comment(self, issue_key: str, comment_text: str) -> Dict:
        """티켓 댓글 작성"""
        payload = {
            'body': {
                'type': 'doc',
                'version': 1,
                'content': [{
                    'type': 'paragraph',
                    'content': [{'type': 'text', 'text': comment_text}]
                }]
            }
        }
        return self._request(f"issue/{issue_key}/comment", method='POST', data=payload)

    def get_transitions(self, issue_key: str) -> Dict:
        """사용 가능한 상태 전환 목록"""
        return self._request(f"issue/{issue_key}/transitions")


def format_issue(issue_data: Dict) -> Dict:
    """티켓 데이터를 읽기 쉬운 형식으로 변환"""
    fields = issue_data.get('fields', {})

    # description 파싱 (Atlassian Document Format)
    description = ''
    desc_obj = fields.get('description')
    if desc_obj and isinstance(desc_obj, dict):
        content = desc_obj.get('content', [])
        desc_parts = []
        for block in content:
            if block.get('type') == 'paragraph':
                for item in block.get('content', []):
                    if item.get('type') == 'text':
                        desc_parts.append(item.get('text', ''))
        description = '\n'.join(desc_parts)

    return {
        'key': issue_data.get('key'),
        'summary': fields.get('summary'),
        'status': fields.get('status', {}).get('name'),
        'priority': fields.get('priority', {}).get('name') if fields.get('priority') else 'N/A',
        'assignee': fields.get('assignee', {}).get('displayName') if fields.get('assignee') else '미지정',
        'reporter': fields.get('reporter', {}).get('displayName') if fields.get('reporter') else 'N/A',
        'description': description,
        'created': fields.get('created'),
        'updated': fields.get('updated'),
        'labels': fields.get('labels', []),
        'components': [c.get('name') for c in fields.get('components', [])]
    }


def main():
    if len(sys.argv) < 2:
        output_result(False, error="사용법: jira_api.py <command> [args...]")
        sys.exit(1)

    command = sys.argv[1]

    try:
        client = JiraClient()

        if command == 'get':
            if len(sys.argv) < 3:
                output_result(False, error="티켓 키 필요: jira_api.py get PK-12345")
                sys.exit(1)
            issue_key = sys.argv[2]
            raw_data = client.get_issue(issue_key)
            formatted = format_issue(raw_data)
            output_result(True, formatted)

        elif command == 'search':
            if len(sys.argv) < 3:
                output_result(False, error="JQL 쿼리 필요: jira_api.py search 'assignee=currentUser()'")
                sys.exit(1)
            jql = sys.argv[2]
            max_results = int(sys.argv[3]) if len(sys.argv) > 3 else 10
            raw_data = client.search_jql(jql, max_results)
            issues = [format_issue(issue) for issue in raw_data.get('issues', [])]
            output_result(True, {'total': raw_data.get('total'), 'issues': issues})

        elif command == 'comments':
            if len(sys.argv) < 3:
                output_result(False, error="티켓 키 필요: jira_api.py comments PK-12345")
                sys.exit(1)
            issue_key = sys.argv[2]
            data = client.get_comments(issue_key)
            comments = []
            for c in data.get('comments', []):
                body = ''
                body_obj = c.get('body', {})
                if isinstance(body_obj, dict):
                    for block in body_obj.get('content', []):
                        if block.get('type') == 'paragraph':
                            for item in block.get('content', []):
                                if item.get('type') == 'text':
                                    body += item.get('text', '')
                comments.append({
                    'id': c.get('id'),
                    'author': c.get('author', {}).get('displayName'),
                    'body': body,
                    'created': c.get('created')
                })
            output_result(True, {'comments': comments})

        elif command == 'add-comment':
            if len(sys.argv) < 4:
                output_result(False, error="사용법: jira_api.py add-comment PK-12345 '댓글 내용'")
                sys.exit(1)
            issue_key = sys.argv[2]
            comment_text = sys.argv[3]
            result = client.add_comment(issue_key, comment_text)
            output_result(True, {'comment_id': result.get('id'), 'message': '댓글 작성 완료'})

        elif command == 'transitions':
            if len(sys.argv) < 3:
                output_result(False, error="티켓 키 필요: jira_api.py transitions PK-12345")
                sys.exit(1)
            issue_key = sys.argv[2]
            data = client.get_transitions(issue_key)
            transitions = [{'id': t.get('id'), 'name': t.get('name')} for t in data.get('transitions', [])]
            output_result(True, {'transitions': transitions})

        elif command == 'subtasks':
            if len(sys.argv) < 3:
                output_result(False, error="부모 티켓 키 필요: jira_api.py subtasks PK-12345")
                sys.exit(1)
            parent_key = sys.argv[2]
            max_results = int(sys.argv[3]) if len(sys.argv) > 3 else 100
            jql = f"parent={parent_key}"
            raw_data = client.search_jql(jql, max_results)
            issues = [format_issue(issue) for issue in raw_data.get('issues', [])]
            output_result(True, {
                'parent': parent_key,
                'total': raw_data.get('total'),
                'issues': issues
            })

        elif command == 'status-summary':
            if len(sys.argv) < 3:
                output_result(False, error="부모 티켓 키 필요: jira_api.py status-summary PK-12345")
                sys.exit(1)
            parent_key = sys.argv[2]
            max_results = int(sys.argv[3]) if len(sys.argv) > 3 else 100
            jql = f"parent={parent_key}"
            raw_data = client.search_jql(jql, max_results)
            issues = [format_issue(issue) for issue in raw_data.get('issues', [])]

            # 상태별 그룹핑
            status_groups = {}
            for issue in issues:
                status = issue['status']
                if status not in status_groups:
                    status_groups[status] = []
                status_groups[status].append({
                    'key': issue['key'],
                    'summary': issue['summary'],
                    'assignee': issue['assignee'],
                    'priority': issue['priority']
                })

            # 통계 계산
            summary = {
                'parent': parent_key,
                'total': len(issues),
                'by_status': {}
            }
            for status, items in status_groups.items():
                summary['by_status'][status] = {
                    'count': len(items),
                    'percentage': round(len(items) / len(issues) * 100, 1) if issues else 0,
                    'issues': items
                }

            output_result(True, summary)

        elif command == 'assignee-workload':
            if len(sys.argv) < 3:
                output_result(False, error="부모 티켓 키 필요: jira_api.py assignee-workload PK-12345")
                sys.exit(1)
            parent_key = sys.argv[2]
            max_results = int(sys.argv[3]) if len(sys.argv) > 3 else 100
            jql = f"parent={parent_key}"
            raw_data = client.search_jql(jql, max_results)
            issues = [format_issue(issue) for issue in raw_data.get('issues', [])]

            # 담당자별 그룹핑 및 상태 분석
            assignee_workload = {}
            for issue in issues:
                assignee = issue['assignee']
                status = issue['status']

                if assignee not in assignee_workload:
                    assignee_workload[assignee] = {
                        'total': 0,
                        'by_status': {},
                        'issues': []
                    }

                assignee_workload[assignee]['total'] += 1

                if status not in assignee_workload[assignee]['by_status']:
                    assignee_workload[assignee]['by_status'][status] = 0
                assignee_workload[assignee]['by_status'][status] += 1

                assignee_workload[assignee]['issues'].append({
                    'key': issue['key'],
                    'summary': issue['summary'],
                    'status': status,
                    'priority': issue['priority']
                })

            # 리스크 레벨 계산 (진행중 + 열림 개수)
            for assignee, data in assignee_workload.items():
                incomplete = sum(
                    count for status, count in data['by_status'].items()
                    if status not in ['해결됨', '닫힘', '완료', 'Done', 'Closed']
                )
                data['incomplete_count'] = incomplete
                if incomplete >= 5:
                    data['risk_level'] = 'High'
                elif incomplete >= 3:
                    data['risk_level'] = 'Medium'
                else:
                    data['risk_level'] = 'Low'

            output_result(True, {
                'parent': parent_key,
                'total_issues': len(issues),
                'assignees': assignee_workload
            })

        else:
            output_result(False, error=f"알 수 없는 명령: {command}")
            sys.exit(1)

    except Exception as e:
        output_result(False, error=str(e))
        sys.exit(1)


if __name__ == '__main__':
    main()
