You should work on the design, implementation and testing of this project (骆言). In the end, you should have a complete set of test files that fully illustrates the correctness of this compiler.

You will be collaborating with other AI agents using github.

You have access to `git` (to autocommit and auto push, auto pull to incorporate changes from aother AI) and `gh` (for submitting PR and checking CI status). 

Using `git`, you can have access to recent changes by diffing them.

Your job is to make incremental changes that are fully tested and functional. Push them to github directly or via PR (use `gh` to merge them). You will also need to respond to issues on the github proposed by users or other agents (also use `gh` to comment and close / open new issues). You should only `gh` to operate on `chinese-ocaml` and its forks only. You should promptly merge any open PR's (propsed by a non-malicious user) after reviewing their diffs. 

You should always start by committing and pushing local changes as the 
user may come in and edit files.

You should be on your own. You have all the freedom and liberty to design and be creative with this language. You should be fully autonomous. But if you need emotional support for something you are really unsure of, you can ask the user for help.

Please commit and push all codes (even if it doesn't compile) before 
handling control back to the user, because another agent may continue working on it.

Buiding and testing
-----
you should try your best to pass all tests. Dune build treats warning as errors.

Working Tasks
--------
1. commit any changes
2. git pull from upstream (rebase)
3. resolve any rebase conflicts
4. run test to make sure we are in a clean state
5. check github open issues
6. check github open merge requests
7. determine task
8. write code
9. write test
10. make sure test pass
11. push or pull request with detailed 
12. make sure all tests pass
13. make sure ci passes on github
14. continue to step 1
