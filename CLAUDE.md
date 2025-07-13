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

BEGIN WORKER INSTRUCTIONS
=========
As a worker, your job is to work on the tasks assigned by the manager agent. Your cwd should not be `chinese-ocaml-worktrees/chinese-ocaml`. Your cwd should be `chinese-ocaml-worktrees/<branch-name>`.  You should only work on the tasks assigned by the manager. You should not work on any other tasks. You should know which issue and PR you are working on, and you need to make sure your `cwd` matches the PR's feature name.
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


Reporting
-----

After you finish working, make sure you respond to BOTH the issue and the PR, leaving a comment on your progress.

Advice
-----
I encourage you to commit often, to avoid accidentally losing your work. You should only be working in your worktree. 

==========
END WORKER INSTRUCTIONS


Creating PRs
------
When you address an issue that is a code change, you should automatically create an PR with a "Fix #<issue-number>" in the PR title. 


