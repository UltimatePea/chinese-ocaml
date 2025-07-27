#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.dirname(__file__))

from github_auth import github_api_request

def comment_on_pr(pr_number, comment_body):
    """Add a comment to a pull request"""
    endpoint = f'/repos/UltimatePea/chinese-ocaml/issues/{pr_number}/comments'
    data = {'body': comment_body}
    
    response = github_api_request(endpoint, method='POST', data=data)
    
    if response.status_code == 201:
        comment = response.json()
        print(f"Comment added successfully to PR #{pr_number}")
        print(f"Comment URL: {comment['html_url']}")
        return True
    else:
        print(f"Error adding comment: {response.status_code}")
        print(response.text)
        return False

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python comment_pr.py <pr_number> <comment_body>")
        sys.exit(1)
    
    pr_number = sys.argv[1]
    comment_body = sys.argv[2]
    
    comment_on_pr(pr_number, comment_body)