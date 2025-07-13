#!/usr/bin/env python3

import os
import sys
import json
import subprocess
import time
import logging
import asyncio
from typing import List, Dict, Optional, Any
from dataclasses import dataclass
from pathlib import Path

from github_auth import get_installation_token

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

@dataclass
class Issue:
    number: int
    title: str
    body: str
    state: str
    user: str
    assignee: Optional[str] = None
    labels: List[str] = None

@dataclass
class PullRequest:
    number: int
    title: str
    body: str
    state: str
    head_ref: str
    base_ref: str
    user: str
    mergeable: Optional[bool] = None
    draft: bool = False

@dataclass
class WorktreeInfo:
    path: str
    branch: str
    commit: str

@dataclass
class RunningTask:
    process: subprocess.Popen
    worktree_path: str
    issue_number: Optional[int]
    pr_number: Optional[int]
    start_time: float

class GitHubAPI:
    def __init__(self, repo_owner: str = "UltimatePea", repo_name: str = "chinese-ocaml"):
        self.repo_owner = repo_owner
        self.repo_name = repo_name
        self.base_url = f"https://api.github.com/repos/{repo_owner}/{repo_name}"
        self.token = get_installation_token()
    
    def _make_request(self, method: str, endpoint: str, data: Optional[Dict] = None) -> Dict:
        import requests
        
        url = f"{self.base_url}{endpoint}"
        headers = {
            "Authorization": f"token {self.token}",
            "Accept": "application/vnd.github+json",
            "Content-Type": "application/json"
        }
        
        if method.upper() == "GET":
            response = requests.get(url, headers=headers)
        elif method.upper() == "POST":
            response = requests.post(url, headers=headers, json=data)
        elif method.upper() == "PATCH":
            response = requests.patch(url, headers=headers, json=data)
        else:
            raise ValueError(f"Unsupported method: {method}")
        
        response.raise_for_status()
        return response.json()
    
    def get_open_issues(self) -> List[Issue]:
        data = self._make_request("GET", "/issues?state=open&sort=created&direction=asc")
        issues = []
        for item in data:
            if 'pull_request' not in item:
                issues.append(Issue(
                    number=item['number'],
                    title=item['title'],
                    body=item['body'] or '',
                    state=item['state'],
                    user=item['user']['login'],
                    assignee=item['assignee']['login'] if item['assignee'] else None,
                    labels=[label['name'] for label in item['labels']]
                ))
        return issues
    
    def get_open_pull_requests(self) -> List[PullRequest]:
        data = self._make_request("GET", "/pulls?state=open&sort=created&direction=asc")
        prs = []
        for item in data:
            prs.append(PullRequest(
                number=item['number'],
                title=item['title'],
                body=item['body'] or '',
                state=item['state'],
                head_ref=item['head']['ref'],
                base_ref=item['base']['ref'],
                user=item['user']['login'],
                mergeable=item.get('mergeable'),
                draft=item['draft']
            ))
        return prs
    
    def create_pull_request(self, title: str, body: str, head: str, base: str = "main") -> Dict:
        data = {"title": title, "body": body, "head": head, "base": base}
        try:
            return self._make_request("POST", "/pulls", data)
        except Exception as e:
            print(f"Failed to create PR: {e}")
            print(f"PR data: {data}")
            raise
    
    def get_pr_comments(self, pr_number: int) -> List[Dict]:
        return self._make_request("GET", f"/issues/{pr_number}/comments")

class GitManager:
    def __init__(self, base_path: str = "/home/zc/chinese-ocaml-worktrees"):
        self.base_path = Path(base_path)
        self.main_repo_path = self.base_path / "chinese-ocaml"
    
    def _run_git_command(self, command: List[str], cwd: Optional[str] = None) -> subprocess.CompletedProcess:
        if cwd is None:
            cwd = str(self.main_repo_path)
        
        result = subprocess.run(["git"] + command, cwd=cwd, capture_output=True, text=True)
        if result.returncode != 0:
            raise subprocess.CalledProcessError(result.returncode, command, result.stdout, result.stderr)
        return result
    
    def pull_main(self):
        print("Pulling latest changes from origin/main")
        self._run_git_command(["pull", "origin", "main"])
    
    def list_worktrees(self) -> List[WorktreeInfo]:
        result = self._run_git_command(["worktree", "list", "--porcelain"])
        worktrees = []
        
        lines = result.stdout.strip().split('\n')
        i = 0
        while i < len(lines):
            if lines[i].startswith('worktree '):
                path = lines[i][9:]
                branch = ""
                commit = ""
                
                i += 1
                while i < len(lines) and not lines[i].startswith('worktree '):
                    if lines[i].startswith('branch '):
                        branch = lines[i][7:]
                    elif lines[i].startswith('HEAD '):
                        commit = lines[i][5:]
                    i += 1
                
                worktrees.append(WorktreeInfo(path=path, branch=branch, commit=commit))
            else:
                i += 1
        
        return worktrees
    
    def create_worktree(self, branch_name: str, issue_number: Optional[int] = None) -> str:
        worktree_path = self.base_path / branch_name
        
        if worktree_path.exists():
            print(f"Using existing worktree: {worktree_path}")
            return str(worktree_path)
        
        print(f"Creating new worktree: {worktree_path} with branch: {branch_name}")
        self._run_git_command(["worktree", "add", str(worktree_path), "-b", branch_name])
        return str(worktree_path)
    
    def remove_worktree(self, path: str):
        self._run_git_command(["worktree", "remove", path])

class TaskSpawner:
    def __init__(self, base_path: str = "/home/zc/chinese-ocaml-worktrees"):
        self.base_path = Path(base_path)
        self.running_tasks: List[RunningTask] = []
    
    def spawn_worker_agent(self, worktree_path: str, pr_number: int) -> RunningTask:
        prompt = f"Work on PR #{pr_number} in this worktree"
        print(f"Spawning worker for PR #{pr_number} in {worktree_path}")
        
        # Create log file in worktree
        local_log = Path(worktree_path) / "claude.log"
        
        # Use tee to bifurcate output to both pipes and local log
        process = subprocess.Popen(
            ["bash", "-c", f"claude '{prompt}' -p --verbose --output-format stream-json 2>&1 | tee -a {local_log}"],
            cwd=worktree_path,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True
        )
        
        task = RunningTask(
            process=process,
            worktree_path=worktree_path,
            issue_number=None,
            pr_number=pr_number,
            start_time=time.time()
        )
        
        self.running_tasks.append(task)
        return task
    
    def check_running_tasks(self):
        completed_tasks = []
        
        # Print status of running tasks
        if self.running_tasks:
            print("Running workers:")
            for task in self.running_tasks:
                duration = time.time() - task.start_time
                print(f"  - PR #{task.pr_number} in {task.worktree_path} (running {duration:.0f}s)")
        
        for task in self.running_tasks:
            if task.process.poll() is not None:
                stdout, stderr = task.process.communicate()
                # stderr is empty since we redirected to stdout
                
                print(f"Task completed for PR #{task.pr_number} (exit code: {task.process.returncode})")
                
                log_content = f"Starting a new iteration... {time.strftime('%Y-%m-%d %H:%M:%S')}\n"
                log_content += f"\n--- Task Agent Completed ---\n"
                log_content += f"Worktree: {task.worktree_path}\n"
                log_content += f"PR: {task.pr_number}\n"
                log_content += f"Exit Code: {task.process.returncode}\n"
                log_content += f"Duration: {time.time() - task.start_time:.2f}s\n"
                log_content += f"STDOUT:\n{stdout}\n"
                log_content += f"STDERR:\n{stderr}\n"
                log_content += f"--- End Task Agent ---\n"
                
                with open("claude.log", "a") as f:
                    f.write(log_content)
                
                completed_tasks.append(task)
        
        for task in completed_tasks:
            self.running_tasks.remove(task)
        
        return len(completed_tasks)
    
    def get_running_count(self) -> int:
        return len(self.running_tasks)

class ProjectManager:
    def __init__(self):
        current_dir = Path.cwd()
        expected_dir = Path("/home/zc/chinese-ocaml-worktrees/chinese-ocaml")
        
        if current_dir != expected_dir:
            sys.exit(1)
        
        self.github = GitHubAPI()
        self.git = GitManager()
        self.spawner = TaskSpawner()
        self.maintainer = "UltimatePea"
    
    def create_pr_for_issue(self, issue: Issue) -> str:
        branch_name = f"issue-{issue.number}"
        print(f"Creating PR for issue #{issue.number}: {issue.title}")
        
        # Check if PR already exists for this issue
        prs = self.github.get_open_pull_requests()
        for pr in prs:
            if pr.head_ref == branch_name:
                print(f"PR already exists for issue #{issue.number} (PR #{pr.number})")
                return self.git.create_worktree(branch_name, issue.number)
        
        worktree_path = self.git.create_worktree(branch_name, issue.number)
        
        # Create empty commit
        print(f"Creating empty commit for branch {branch_name}")
        subprocess.run(["git", "commit", "--allow-empty", "-m", f"WIP: Issue #{issue.number}"], cwd=worktree_path, check=True)
        subprocess.run(["git", "push", "-u", "origin", branch_name], cwd=worktree_path, check=True)
        
        pr_title = f"Fix issue #{issue.number}: {issue.title}"
        pr_body = f"Fixes #{issue.number}"
        print(f"Creating GitHub PR: {pr_title}")
        pr_response = self.github.create_pull_request(pr_title, pr_body, branch_name)
        print(f"Created PR #{pr_response['number']}")
        
        return worktree_path
    
    def handle_open_pull_requests(self):
        prs = self.github.get_open_pull_requests()
        print(f"Checking {len(prs)} open PRs")
        worktrees = self.git.list_worktrees()
        
        for pr in prs:
            # Check if there's already a running task for this PR
            pr_has_running_task = any(
                task.pr_number == pr.number 
                for task in self.spawner.running_tasks
            )
            
            if pr_has_running_task:
                print(f"Skipping PR #{pr.number}: already has a running task")
                continue
            
            # Check last comment
            comments = self.github.get_pr_comments(pr.number)
            if comments:
                last_comment = comments[-1]
                last_commenter = last_comment['user']['login']
                
                # If last comment is from ClaudeAI-V1, skip
                if last_commenter == "ClaudeAI-V1":
                    print(f"Skipping PR #{pr.number}: last comment from ClaudeAI-V1")
                    continue
            
            print(f"Found PR #{pr.number} needing attention: {pr.title}")
            
            # Find or create worktree
            worktree_path = None
            for wt in worktrees:
                if wt.branch == pr.head_ref:
                    worktree_path = wt.path
                    break
            
            if not worktree_path:
                worktree_path = self.git.create_worktree(pr.head_ref)
            
            self.spawner.spawn_worker_agent(worktree_path, pr_number=pr.number)
    
    def handle_open_issues(self):
        issues = self.github.get_open_issues()
        print(f"Checking {len(issues)} open issues")
        
        # Get existing PRs to check for duplicates
        prs = self.github.get_open_pull_requests()
        
        for issue in issues:
            if issue.assignee != "UltimatePea":
                print(f"Rejecting issue #{issue.number}: assignee is '{issue.assignee}', not 'UltimatePea'")
                continue
            
            # Check if PR already exists for this issue
            branch_name = f"issue-{issue.number}"
            pr_exists = any(pr.head_ref == branch_name for pr in prs)
            
            if pr_exists:
                print(f"Skipping issue #{issue.number}: PR already exists")
                continue
            
            print(f"Found assigned issue #{issue.number}: {issue.title}")
            self.create_pr_for_issue(issue)
    
    def run_main_workflow(self):
        print("Starting manager workflow")
        
        while True:
            print(f"\n--- Manager Loop (Running tasks: {self.spawner.get_running_count()}) ---")
            
            # Check running tasks
            completed = self.spawner.check_running_tasks()
            if completed > 0:
                print(f"Completed {completed} tasks, {self.spawner.get_running_count()} still running")
            
            # Check GitHub PRs and issues
            self.git.pull_main()
            self.handle_open_pull_requests()
            self.handle_open_issues()
            
            print("Waiting 10 seconds before next check...")
            time.sleep(10)

def main():
    try:
        manager = ProjectManager()
        manager.run_main_workflow()
    except Exception as e:
        logger.error(f"Manager failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()