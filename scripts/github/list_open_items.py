#!/usr/bin/env python3

import sys
import json
from github_auth import github_api_request

def list_open_issues():
    """List all open issues"""
    print("=== Open Issues ===")
    response = github_api_request('/repos/UltimatePea/chinese-ocaml/issues?state=open&per_page=100')
    
    if response.status_code == 200:
        issues = response.json()
        if not issues:
            print("No open issues found.")
            return []
        
        for issue in issues:
            if 'pull_request' not in issue:  # Skip PRs
                print(f"Issue #{issue['number']}: {issue['title']}")
                print(f"  Created: {issue['created_at']}")
                print(f"  Updated: {issue['updated_at']}")
                print(f"  State: {issue['state']}")
                print(f"  Author: {issue['user']['login']}")
                if issue.get('assignee'):
                    print(f"  Assignee: {issue['assignee']['login']}")
                if issue.get('labels'):
                    labels = [label['name'] for label in issue['labels']]
                    print(f"  Labels: {', '.join(labels)}")
                print()
        return issues
    else:
        print(f"Error getting issues: {response.status_code}")
        print(response.text)
        return []

def list_open_prs():
    """List all open pull requests"""
    print("=== Open Pull Requests ===")
    response = github_api_request('/repos/UltimatePea/chinese-ocaml/pulls?state=open&per_page=100')
    
    if response.status_code == 200:
        prs = response.json()
        if not prs:
            print("No open pull requests found.")
            return []
        
        for pr in prs:
            print(f"PR #{pr['number']}: {pr['title']}")
            print(f"  Created: {pr['created_at']}")
            print(f"  Updated: {pr['updated_at']}")
            print(f"  State: {pr['state']}")
            print(f"  Author: {pr['user']['login']}")
            print(f"  Branch: {pr['head']['ref']} -> {pr['base']['ref']}")
            print(f"  URL: {pr['html_url']}")
            print()
        return prs
    else:
        print(f"Error getting PRs: {response.status_code}")
        print(response.text)
        return []

if __name__ == '__main__':
    issues = list_open_issues()
    print("\n" + "="*50 + "\n")
    prs = list_open_prs()
