#!/usr/bin/env python3
"""
Claude Code용 공통 유틸리티 함수
"""
import json
import sys
from typing import Any, Dict


def output_result(success: bool, data: Any = None, error: str = None):
    """
    스크립트 실행 결과를 표준화된 JSON 형식으로 출력

    Args:
        success: 성공 여부
        data: 결과 데이터
        error: 에러 메시지
    """
    result = {
        "success": success,
        "data": data,
        "error": error
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))


def read_json_input() -> Dict:
    """
    stdin에서 JSON 입력 읽기
    """
    try:
        return json.loads(sys.stdin.read())
    except json.JSONDecodeError as e:
        output_result(False, error=f"Invalid JSON input: {e}")
        sys.exit(1)
