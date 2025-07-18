#!/usr/bin/env python3
import sys
from github_auth import make_github_request

if len(sys.argv) != 3:
    print("用法: python3 add_comment.py <issue_number> <comment_body>")
    sys.exit(1)

issue_number = sys.argv[1]
comment_body = sys.argv[2]

data = {"body": comment_body}
result = make_github_request(f"/issues/{issue_number}/comments", method="POST", data=data)
print("评论已添加:", result["html_url"])