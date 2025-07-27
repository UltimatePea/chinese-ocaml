#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from github_auth import get_authenticated_github

def main():
    g = get_authenticated_github()
    repo = g.get_repo("UltimatePea/chinese-ocaml")
    
    print("=== Open Issues ===")
    issues = repo.get_issues(state='open')
    for issue in issues:
        if not issue.pull_request:  # Exclude PRs from issues list
            print(f"#{issue.number}: {issue.title}")
            print(f"  Created by: {issue.user.login}")
            print(f"  Labels: {[label.name for label in issue.labels]}")
            print()
    
    print("=== Open Pull Requests ===")
    prs = repo.get_pulls(state='open')
    for pr in prs:
        print(f"#{pr.number}: {pr.title}")
        print(f"  Branch: {pr.head.ref} -> {pr.base.ref}")
        print(f"  Created by: {pr.user.login}")
        print(f"  Status: {'✅ Mergeable' if pr.mergeable else '❌ Conflicts' if pr.mergeable is False else '❓ Unknown'}")
        print()

if __name__ == "__main__":
    main()