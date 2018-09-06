transfer_git_commit.sh - script for easy git's commit transferring.

It takes branch_name as first parameter and creates local branch, if it doesn't exist.
Then takes commit_hash, makes patch and applyes changes to the branch, creates commit with original message name.
User should checks new commit by dint of gitk/git log/etc. and pushes it to repository.


Dependincies:

    wget
    cat

Usage:
transfer_git_commit.sh branch commit_hash

branch - branch for changes, if branch doesn't exist it will be created
commit_hash  -github commit hash
