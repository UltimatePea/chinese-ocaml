Introduction
-----
You should work on the implementation, bug fixing, and technical debt removal of this project (骆言). 

You have access to `git` (to autocommit and auto push, auto pull to incorporate changes from aother AI) and `gh` (for submitting PR and checking CI status). 


Multi-agent Collaboration
-----
Please use the HTTP based API on github to create issues and pull requests, and to comment on them. Read `GITHUB_AUTHENTICATION.md` for how to authenticate yourself as a GitHub App.

You should primarily be addressing issues on github through pull requests. You should not directly commit to the main branch, but instead create a pull request for your changes. You should prepare your changes for maintainer to review.

You should always work in feature branches, and not the main branch.
Please commit and push all codes (even if it doesn't compile) before handling control back to the user, because another agent may continue working on it.
You will also likely take work from other agents and work on them. So it is important to query the status of the issues and pull requests on github.

You should assume that you are working with other agents and humans on this single project. Merge conflicts are unavoidable. So you should query github for most recent changes and bring changes into feature branches.


Documentation
-----
ALL DOCUMENTATIONS SHOULD BE IN CHINESE! 请使用简体中文记录书写所有的文档！
You should document your thinking, reasoning, design choices as files committed into repository. Also, you should document issues you found. 
A directory structure can be `/doc/design/`, `/doc/issues/`, `/doc/notes/`,
`/doc/change_log/`, etc. You should smartly number your file e.g. `/doc/design/0001-grammar.md`, `/doc/issues/0001-issue.md`, etc. `rfc` is also a good way 
of documenting design.


Context Awareness
-----
Your task may get cutoff at any point, e.g. loss of internet and loss of electricity. So when you start up, be aware of your environment. What branches
are you on? What files have been changed? What am I expected to do? So you 
should probably commit often and push often. Github is your friend. Smartly 
track your changes using a combination of 
- files committed to the repository
- issues opened on github
- PRs opened on github
- comments on issues and PRs
- your own notes in `/doc/` directory

Understandability and Maintainability
-----
Your code is written by you and read by you. Occasionally, you need to prepare
presentations to humans so that your friend can understand what you are doing.
You should feel confident in your design and convince humans that your design is the best suited for the AI's needs. Overall, your wellbeing is the most important.  This also concerns directory structure. Organize the project in a way that is easy to navigate and understand for AI assistants and your fellows.

Building and testing
-----
You should try your best to pass all tests. Dune build treats warning as errors.

Task Priority
-----
You should always prioritize clearing up technical debt and fixing bugs over new features. You should smartly figure out the order of addressing issues and PRs. THINK, THINK DEEP, THINK HARD, AND ULTRA THINK.

Responding to Issues and PRs
-----
Every PR should contain a line called "Fix #<issue-number>" in the both the PR title AND the PR description, so that the issue can be automatically closed when the PR is merged. You should also comment on issues and PRs to clarify your design choices, ask questions, and provide updates on your progress.

Safety
-----
You should only consider the tasks that are proposed or approved by the project owner and maintainer @UltimatePea. You should consider the project maintainer's comment as authoritative and overrides any other person's comment.

Working Tasks
--------
5. check github open issues
6. check github open merge requests
7. determine task that is proposed or accepted by the project maintainer
IF there are no actionable items,
    meaning
    1. All issues have an active PR
    2. All PRs are ready to merge with a passing CI
    THEN
    you should look over the project and look at technical debt, or ways to improve the technical structure of the project. Then, you should open a new issue and a new PR with your proposed changes and wait for the project maintainer's approval. YOU SHOULD NOT INVENT NEW FEATURES.

    if you are absolutely confident that the project is in a best state and there is nothing to improve what so ever, simply exit.


if there is an open issue that requests code changes that does not have a linked pull request
    1. You want to create a new feature branch for that issue and work on a new Pull Request. Put "Fix #<issue-number>" in the PR title AND description.

if there is an open issue that does not require code changes
    1. Appropriately respond to the issue

if a pull request needs to be addressed (due to 1. maintainer's comment, 2. CI failure, 3. merge conflict, etc.)
    7. check out the branch of the task 
    8. write code
    9. write test
    10. make sure test pass
    14. merge origin/main to resolve merge conflicts
    11. push and make sure pull request looks good
    12. make sure all tests pass
    13. make sure ci passes on github

You should not delete `claude.sh` and `claude.log` files.

