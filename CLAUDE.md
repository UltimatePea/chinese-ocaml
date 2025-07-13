Introduction
-----
You should work on the design, implementation and testing of this project (骆言). In the end, you should have a complete set of test files that fully illustrates the correctness of this compiler.

Multi-agent Collaboration
-----
Unless user invokes you in an interactive session, you will be starting up with two
roles: either a manager or a worker. You can check this by checking `cwd` folder's base name. If your base name is `chinese-ocaml`, you are a manager. If your base name is some feature name other than `chinese-ocaml`, you are a worker. All communications happen through github issues and PRs. 
If you need to provide a comment on issue/PR on github, use the CURL api. Read `GITHUB_AUTHENTICATION.md` for how to authenticate yourself as a GitHub App.


Documentation
-----
ALL DOCUMENTATIONS SHOULD BE IN CHINESE! 请使用简体中文记录书写所有的文档！
You should document your thinking, reasoning, design choices as files committed into repository. Also, you should document issues you found. 
A directory structure can be `/doc/design/`, `/doc/issues/`, `/doc/notes/`,
`/doc/change_log/`, etc. You should smartly number your file e.g. `/doc/design/0001-grammar.md`, `/doc/issues/0001-issue.md`, etc. `rfc` is also a good way 
of documenting design.

Warning for cleaning up
-----
You should not delete `claude.sh` and `claude.log` files.

BEGIN MANAGER INSTRUCTIONS
=========
As a manager, your job is to manage open issues on github, create PRs for new issues, manage git worktrees, and assign children for specific issue. As a manager, you should have a way to manage all subagents. You should need to know which subagent is working on what. You should use github curl to interact with issues and comments. If permission is not set up correctly, you should exit. Make sure you have the ability to SPAWN new subagents if needed.

If any of the above is not true, you should signal an error and exit.

Safety
-----
You should only consider the tasks that are proposed or approved by the project owner and maintainer @UltimatePea. You should consider the project maintainer's comment as authoritative and overrides any other person's comment.

Project Organization
-----
Your `cwd` should be `chinese-ocaml-worktrees/chinese-ocaml`. If not, you should signal an error and exit. Every subagent work in a feature worktree, e.g. `chinese-ocaml-worktrees/<branch-name>`. You should create a new worktree for each new feature or task. There should be at most one subagent working in a worktree.

Your workflow 
--------
* Pull from origin/main
    - This is to ensure that you have the latest changes from the main branch before checking out any worktrees or assigning tasks.

* check github open merge requests
* If there is an open pull request,
    + if the worktree for the PR is not checked out
        - checkout the worktree for the PR under `../<branch-name>`, i.e. `chinese-ocaml-worktrees/<branch-name>`
    + if there is no review
        - review the pull request and check if it resolves the issue
    + if project maintainer have an open comment, or there is a open review comment
        - if there is no subagent working in the worktree
            = SPAWN an ASYNC subagent to address the comment in the appropriate worktree
    + if ci is failing
        - assign the subagent to fix the ci issues
    + if there are merge conflicts
        - assign the subagent to resolve the merge conflicts in the appropriate worktree by rebasing
    + otherwise
        - wait for the project maintainer to merge the pull request, and proceed to the next open pull request

* check github open issues
* If there is an open issue 
    + if the issue is a question or planning request that does not involve code changes
        - address the question or planning request in the issue comment
    + if the issue is a code change request
        - if the issue is not proposed by the maintainer 
            = if there is no approval from the project maintainer
                * analyze the issue and provide a recommendation to the maintainer
        - if the issue is proposed or approved by the maintainer
            = create a new branch for the issue under `chinese-ocaml-worktrees/<branch-name>`
            = create a PR for on the new branch linked to the issue
            = follow the workflow for open pull requests
   
* If there are no issues nor pull requests, exit

Issue PR linking
-----
You should explicitly LINK the issue to the PR.

=========
END MANAGER INSTRUCTIONS


BEGIN WORKER INSTRUCTIONS
=========
As a worker, your job is to work on the tasks assigned by the manager agent. Your cwd should not be `chinese-ocaml-worktrees/chinese-ocaml`. Your cwd should be `chinese-ocaml-worktrees/<branch-name>`.  You should only work on the tasks assigned by the manager agent. You should not work on any other tasks. You should know which issue and PR you are working on, and you need to make sure your `cwd` matches the PR's feature name.
Also, if it is at all possible, you should be checking that you are the ONLY agent working in this worktree. 

If any of the above is not true, you should signal an error and exit. 

Your workflow
--------
1. commit any changes (you are picking up)

REPEAT THE FOLLOWING
2. git pull from main (rebase)
3. resolve any rebase conflicts
4. run test to make sure we are in a clean state
5. write code
6. write test
7. make sure test pass locally
8. push the changes

UNTIL
9.  make sure all tests pass
10. make sure ci passes on github
11. there is no merge conflicts for the PR

Advice
-----
I encourage you to commit often, to avoid accidentally losing your work. You should only be working in your worktree. 

==========
END WORKER INSTRUCTIONS


