#!/bin/sh

if [[ $# < 2 ]]; then
    echo Usage: git-author-rewrite.sh OLD_EMAIL NEW_EMAIL
    exit
fi

git filter-branch --env-filter '

OLD_EMAIL='"$1"'
CORRECT_NAME="Kevin Kredit"
CORRECT_EMAIL='"$2"'

if [ "$GIT_COMMITTER_EMAIL" = "$OLD_EMAIL" ]; then
    export GIT_COMMITTER_NAME="$CORRECT_NAME"
    export GIT_COMMITTER_EMAIL="$CORRECT_EMAIL"
fi

if [ "$GIT_AUTHOR_EMAIL" = "$OLD_EMAIL" ]; then
    export GIT_AUTHOR_NAME="$CORRECT_NAME"
    export GIT_AUTHOR_EMAIL="$CORRECT_EMAIL"
fi

' --tag-name-filter cat -- --branches --tags
