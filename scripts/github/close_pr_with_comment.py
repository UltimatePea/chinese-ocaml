#!/usr/bin/env python3

import sys
import argparse
from github_auth import github_api_request

def close_pr_with_comment(pr_number, close_reason):
    """Close a PR with a comment explaining the reason"""
    
    # Add comment explaining the closure
    comment_data = {
        'body': close_reason
    }
    
    comment_response = github_api_request(
        f'/repos/UltimatePea/chinese-ocaml/issues/{pr_number}/comments',
        method='POST',
        data=comment_data
    )
    
    if comment_response.status_code == 201:
        print(f"Comment added to PR #{pr_number}")
    else:
        print(f"Failed to add comment: {comment_response.status_code}")
        print(comment_response.text)
        return False
    
    # Close the PR
    close_data = {
        'state': 'closed'
    }
    
    close_response = github_api_request(
        f'/repos/UltimatePea/chinese-ocaml/pulls/{pr_number}',
        method='PATCH',
        data=close_data
    )
    
    if close_response.status_code == 200:
        print(f"PR #{pr_number} closed successfully")
        return True
    else:
        print(f"Failed to close PR: {close_response.status_code}")
        print(close_response.text)
        return False

def main():
    parser = argparse.ArgumentParser(description='Close a PR with explanatory comment')
    parser.add_argument('pr_number', type=int, help='PR number to close')
    parser.add_argument('--reason', required=True, help='Reason for closing the PR')
    
    args = parser.parse_args()
    
    success = close_pr_with_comment(args.pr_number, args.reason)
    if not success:
        sys.exit(1)

if __name__ == '__main__':
    main()