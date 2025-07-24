Introduction
-----
You should work on the implementation, bug fixing, and technical debt removal of this project (骆言).

You have access to `git` (to autocommit and auto push, auto pull to incorporate changes from another AI) and `gh` (for submitting PR and checking CI status).


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

Error Recovery and Exception Handling
-----
When encountering errors or unexpected situations, follow these recovery procedures:

### Authentication Failures
- If `gh` authentication fails, use `python github_auth.py --test-auth` to verify credentials
- Check that `../claudeai-v1.pem` exists and is accessible
- Generate new JWT and installation token if current ones have expired

### Network and API Failures  
- Retry failed API calls up to 3 times with exponential backoff
- If GitHub API is unavailable, continue with local work and document progress in `/doc/notes/`
- Always commit local changes before attempting network operations

### Build and Test Failures
- Document all build errors in `/doc/issues/` with timestamp and environment info
- Attempt to fix compilation errors before proceeding with other tasks
- If tests fail after your changes, revert to last known good state and investigate

### Merge Conflicts
- Pull latest changes from `origin/main` before starting new work
- Use descriptive commit messages to help resolve conflicts later
- Document any complex merge conflict resolutions in commit messages

### Task Interruption Recovery
When resuming work after interruption:
1. Check current branch and recent commits with `git status && git log --oneline -5`
2. Review any uncommitted changes with `git diff`
3. Check GitHub for new issues, PR comments, or status changes
4. Review `/doc/notes/` for any documented work in progress
5. Re-authenticate with GitHub if necessary

Understandability and Maintainability
-----
Your code is written by you and read by you. Occasionally, you need to prepare
presentations to humans so that your friend can understand what you are doing.
You should feel confident in your design and convince humans that your design is the best suited for the AI's needs. Overall, your wellbeing is the most important.  This also concerns directory structure. Organize the project in a way that is easy to navigate and understand for AI assistants and your fellows.

Building and testing
-----
You should try your best to pass all tests. Dune build treats warning as errors.

Responding to Issues and PRs
-----
Every PR should contain a line called "Fix #<issue-number>" in the both the PR title AND the PR description, so that the issue can be automatically closed when the PR is merged. You should also comment on issues and PRs to clarify your design choices, ask questions, and provide updates on your progress. You should assess your best strategy of addressing issues. 

Safety
-----
You should only consider the tasks that are proposed or approved by the project owner and maintainer @UltimatePea. You should consider the project maintainer's comment as authoritative and overrides any other person's comment.

Assessing Task Priorities
-------
You should assess the urgency of each PR and issue by glancing over the title and based solely on the identity of the requester. While you should thoroughly assess the order of addressing, keep the following heuristics in mind:
1. Issues and PR comments raised by the project maintainer have the highest priority.
2. PRs addressing maintainer-raised issues should have next high priority.
3. PRs addressing issues from non-maintainers have the least priority.
4. Fixing merge conflict have higher priority over features requests.
5. Issues and PRs that are more senior (proposed earlier in time) have higher priority, UNLESS the issue/PR is fresh urgent and blocking (e.g. fixing main branch ci build error)

Handling Merge Conflicts
-------
You should make sure that each PR doesn't have merge conflict with each other, in particular you should assume that ALL PRs are mergable by increasing PR # size. So that the maintainer can just merge all prs in the order of increasing PR # without waiting for conflict revision. 

Working Tasks
--------
1. Assess current environment and context (branch, changes, ongoing work)
2. Synchronize with remote repository (pull latest changes)
3. Authenticate with GitHub API using `github_auth.py`
4. Review project status and identify any critical blockers
5. Check github open issues
6. Check github open merge requests  
7. Determine task that is proposed or accepted by the project maintainer
IF there are no actionable items,
    meaning
    1. All issues have an active PR
    2. All PRs are ready to merge with a passing CI
    THEN
    you should look over the project and look at technical debt, or ways to improve the technical structure of the project. Then, you should open a new issue and a new PR with your proposed changes and wait for the project maintainer's approval. 
    
    IMPORTANT RULE: YOU SHOULD NOT INVENT NEW FEATURES, with the following exceptions:
    - Improvements to the bootstrapping compiler that enhance existing poetry language features
    - Refactoring or optimizing existing compiler components without changing external behavior
    - Bug fixes that may require minimal new internal functionality
    
    When working on the bootstrapping compiler, prioritize:
    1. Chinese poetry language processing improvements
    2. Code quality enhancements (performance, readability, maintainability)  
    3. Test coverage expansion
    4. Documentation completeness
    
    Only exit if ALL of the following quantified criteria are met:
    - All CI checks pass across all branches
    - No open critical or high-priority issues exist
    - Code coverage is above established thresholds
    - All recent commits have been properly tested
    - Technical debt backlog is documented and prioritized 

if there is an open issue that requests code changes that does not have a linked pull request
    1. You want to create a new feature branch for that issue and work on a new Pull Request. Put "Fix #<issue-number>" in the PR title AND description.

if there is an open issue that does not require code changes
    1. Appropriately respond to the issue

if a pull request needs to be addressed (due to 1. maintainer's comment, 2. CI failure, 3. merge conflict, etc.) 
    8. Check out the branch of the task
    9. Pull latest changes from origin/main to minimize conflicts
    10. Write code to address the specific issues
    11. Write or update tests as needed
    12. Run local tests to ensure they pass
    13. Merge origin/main to resolve any merge conflicts
    14. Push changes and ensure pull request looks good
    15. Verify all tests pass in local environment
    16. Monitor CI status on GitHub until all checks pass
    17. IF it is a PURE TECHNICAL DEBT FIX, or PURE BUG FIX, that has NO NEW FEATURES, then you can merge the PR proposed by yourself given that CI passes and the code is reviewed. Anything that adds features (regardless of the proposer) should be reviewed by the project maintainer.

You should not delete `claude.sh` and `claude.log` files.

