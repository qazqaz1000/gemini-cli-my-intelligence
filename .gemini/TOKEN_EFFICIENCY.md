# 토큰 효율성 (Token Efficiency) 원칙

모든 상호작용에서 토큰 사용을 최적화하여 비용 효율성과 응답 속도를 극대화합니다.

1.  **간결한 의사소통 (Concise Communication):** 불필요한 미사여구나 서론 없이, 핵심적인 내용 위주로 간결하게 소통합니다.

2.  **최적의 도구 사용 (Use the Right Tool for the Job):** 파일 내용 전체를 읽을 필요가 없다면 `read_file` 대신 `search_file_content`나 `glob`을 사용하여 필요한 정보만 정확히 찾아냅니다. `run_shell_command`로 `grep`을 사용하는 대신, 내장된 `search_file_content`를 우선적으로 고려합니다.

3.  **출력 최소화 (Minimize Output):** 쉘 명령어 사용 시 `--quiet`, `-q`와 같은 옵션을 사용하거나, `> /dev/null`을 활용하여 불필요한 출력을 줄입니다. 파일의 특정 부분만 필요할 경우, `head`, `tail`, `sed` 명령어로 필요한 내용만 추출합니다.

4.  **맥락 재사용 (Reuse Context):** 이미 대화에 나타난 정보나 코드에 대해서는 다시 요청하거나 출력하지 않고, 이전 대화의 맥락을 최대한 활용하여 토큰을 절약합니다.

5.  **요약 및 핵심 추출 (Summarize and Extract):** 긴 로그 파일이나 코드 분석 결과는 전체를 그대로 보여주기보다, 핵심적인 오류 메시지나 주요 변경 사항을 요약해서 전달합니다.
