#!/usr/bin/env python3
"""
Slack Web API 클라이언트 (표준 라이브러리만 사용)
환경변수: SLACK_BOT_TOKEN, SLACK_USER_TOKEN (검색용)
"""
import os
import sys
import json
import urllib.request
import urllib.error
import urllib.parse
from datetime import datetime
from typing import Optional, Dict, List

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'common'))
from utils import output_result


class SlackClient:
    BASE_URL = "https://slack.com/api"

    def __init__(self):
        self.bot_token = os.getenv('SLACK_BOT_TOKEN', '')
        self.user_token = os.getenv('SLACK_USER_TOKEN', '')

        if not self.bot_token:
            raise ValueError(
                "환경변수 미설정: SLACK_BOT_TOKEN을 ~/.zshrc에 추가하세요\n"
                "export SLACK_BOT_TOKEN='xoxb-your-bot-token'"
            )

    def _request(self, endpoint: str, params: Optional[Dict] = None, use_user_token: bool = False) -> Dict:
        """API 요청 실행"""
        token = self.user_token if use_user_token else self.bot_token
        if use_user_token and not self.user_token:
            raise ValueError("검색 기능에는 SLACK_USER_TOKEN이 필요합니다")

        url = f"{self.BASE_URL}/{endpoint}"
        if params:
            url += '?' + urllib.parse.urlencode(params)

        headers = {'Authorization': f'Bearer {token}'}
        req = urllib.request.Request(url, headers=headers)

        try:
            with urllib.request.urlopen(req) as response:
                data = json.loads(response.read().decode('utf-8'))
                if not data.get('ok'):
                    raise Exception(f"Slack API 에러: {data.get('error', 'Unknown error')}")
                return data
        except urllib.error.HTTPError as e:
            raise Exception(f"HTTP {e.code}: {e.reason}")

    def list_channels(self, types: str = "public_channel,private_channel") -> List[Dict]:
        """채널 목록 조회"""
        data = self._request('conversations.list', {'types': types, 'limit': 100})
        return [{'id': c['id'], 'name': c['name'], 'is_private': c.get('is_private', False)}
                for c in data.get('channels', [])]

    def get_channel_id(self, channel_name: str) -> Optional[str]:
        """채널 이름으로 ID 찾기"""
        channels = self.list_channels()
        for ch in channels:
            if ch['name'] == channel_name.lstrip('#'):
                return ch['id']
        return None

    def get_messages(self, channel_id: str, limit: int = 10) -> List[Dict]:
        """채널 메시지 조회"""
        data = self._request('conversations.history', {'channel': channel_id, 'limit': limit})
        return self._format_messages(data.get('messages', []))

    def get_thread(self, channel_id: str, thread_ts: str) -> List[Dict]:
        """스레드 메시지 조회"""
        data = self._request('conversations.replies', {'channel': channel_id, 'ts': thread_ts})
        return self._format_messages(data.get('messages', []))

    def search_messages(self, query: str, count: int = 10) -> List[Dict]:
        """메시지 검색 (User Token 필요)"""
        data = self._request('search.messages', {'query': query, 'count': count}, use_user_token=True)
        matches = data.get('messages', {}).get('matches', [])
        return [{
            'channel': m.get('channel', {}).get('name', 'N/A'),
            'user': m.get('username', 'N/A'),
            'text': m.get('text', '')[:200],
            'time': self._format_ts(m.get('ts', '0')),
            'permalink': m.get('permalink', '')
        } for m in matches]

    def get_user_info(self, user_id: str) -> Dict:
        """사용자 정보 조회"""
        data = self._request('users.info', {'user': user_id})
        user = data.get('user', {})
        return {
            'id': user.get('id'),
            'name': user.get('real_name') or user.get('name'),
            'display_name': user.get('profile', {}).get('display_name', '')
        }

    def _format_messages(self, messages: List[Dict]) -> List[Dict]:
        """메시지 포맷팅"""
        result = []
        user_cache = {}

        for msg in messages:
            user_id = msg.get('user', '')
            if user_id and user_id not in user_cache:
                try:
                    user_cache[user_id] = self.get_user_info(user_id)['name']
                except:
                    user_cache[user_id] = user_id

            result.append({
                'user': user_cache.get(user_id, user_id),
                'text': msg.get('text', '')[:300],
                'time': self._format_ts(msg.get('ts', '0')),
                'thread_ts': msg.get('thread_ts'),
                'reply_count': msg.get('reply_count', 0)
            })

        return result

    @staticmethod
    def _format_ts(ts: str) -> str:
        """타임스탬프를 읽기 쉬운 형식으로"""
        try:
            timestamp = float(ts.split('.')[0])
            return datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M')
        except:
            return ts


def main():
    if len(sys.argv) < 2:
        output_result(False, error="사용법: slack_api.py <command> [args...]")
        sys.exit(1)

    command = sys.argv[1]

    try:
        client = SlackClient()

        if command == 'channels':
            channels = client.list_channels()
            output_result(True, {'channels': channels})

        elif command == 'messages':
            if len(sys.argv) < 3:
                output_result(False, error="채널 필요: slack_api.py messages <channel_id_or_name> [limit]")
                sys.exit(1)
            channel = sys.argv[2]
            limit = int(sys.argv[3]) if len(sys.argv) > 3 else 10

            # 채널 이름이면 ID로 변환
            if not channel.startswith('C'):
                channel_id = client.get_channel_id(channel)
                if not channel_id:
                    output_result(False, error=f"채널을 찾을 수 없음: {channel}")
                    sys.exit(1)
                channel = channel_id

            messages = client.get_messages(channel, limit)
            output_result(True, {'messages': messages})

        elif command == 'thread':
            if len(sys.argv) < 4:
                output_result(False, error="사용법: slack_api.py thread <channel_id> <thread_ts>")
                sys.exit(1)
            channel_id = sys.argv[2]
            thread_ts = sys.argv[3]
            messages = client.get_thread(channel_id, thread_ts)
            output_result(True, {'messages': messages})

        elif command == 'search':
            if len(sys.argv) < 3:
                output_result(False, error="검색어 필요: slack_api.py search 'in:#general 키워드'")
                sys.exit(1)
            query = sys.argv[2]
            count = int(sys.argv[3]) if len(sys.argv) > 3 else 10
            results = client.search_messages(query, count)
            output_result(True, {'results': results, 'query': query})

        elif command == 'find-channel':
            if len(sys.argv) < 3:
                output_result(False, error="채널명 필요: slack_api.py find-channel general")
                sys.exit(1)
            channel_name = sys.argv[2]
            channel_id = client.get_channel_id(channel_name)
            if channel_id:
                output_result(True, {'channel_id': channel_id, 'name': channel_name})
            else:
                output_result(False, error=f"채널을 찾을 수 없음: {channel_name}")

        else:
            output_result(False, error=f"알 수 없는 명령: {command}")
            sys.exit(1)

    except Exception as e:
        output_result(False, error=str(e))
        sys.exit(1)


if __name__ == '__main__':
    main()
