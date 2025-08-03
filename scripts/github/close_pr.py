#!/usr/bin/env python3

import sys
import os
sys.path.append(os.path.dirname(__file__))

from github_auth import github_api_request

def close_pr(pr_number):
    """Close a pull request"""
    endpoint = f'/repos/UltimatePea/chinese-ocaml/pulls/{pr_number}'
    data = {'state': 'closed'}
    
    response = github_api_request(endpoint, method='PATCH', data=data)
    
    if response.status_code == 200:
        pr = response.json()
        print(f"PR #{pr_number} closed successfully")
        print(f"PR URL: {pr['html_url']}")
        return True
    else:
        print(f"Failed to close PR #{pr_number}. Status: {response.status_code}")
        print(f"Response: {response.text}")
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python close_pr.py <pr_number>")
        sys.exit(1)
    
    pr_number = sys.argv[1]
    close_pr(pr_number)