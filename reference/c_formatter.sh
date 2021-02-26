#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1
CONFIG_FILE=./.astylerc

# Keep EXCLUDE_DIRS up to date with the astyle config
# Add dirs using "/dir1/\|/dir2/" and so on
EXCLUDE_DIRS="/bin/"

print_help() {
    echo "
Helper script to use astyle. Usage:
    run             : run astyle on current directory
    git             : run astyle on unstaged files in git
    [list of files] : run astyle on named files
"
    exit 2
}

run_astyle() {
    astyle --options="$CONFIG_FILE" --suffix=none --formatted --preserve-date --ignore-exclude-errors-x "$@"
}

run_astyle_on_files() {
    for f in "$@"; do
        [ -f "$f" ] && run_astyle "$f"
    done
}

case $1 in
    'run')
        echo "Running astyle on current directory..."
        run_astyle -R "./*.c" "./*.h"
        ;;
    'staged')
        echo "Running astyle on staged files in git..."
        # shellcheck disable=SC2046
        run_astyle_on_files $(git diff --cached --name-only | \
                                xargs -I '{}' realpath --relative-to=. "$(git rev-parse --show-toplevel)"/'{}' | \
                                grep "\.c\|\.h" | grep -v "$EXCLUDE_DIRS")
        ;;
    *)
        if [ -f "$1" ]; then
            # If first arg is a file, assume all are
            run_astyle_on_files "$@"
        else
            print_help
        fi
        ;;
esac
