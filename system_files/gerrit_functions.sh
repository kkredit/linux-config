# shellcheck disable=SC2148,1090

if [[ ! -f ~/.gerritrc ]]; then
    return 0
fi

source ~/.gerritrc

if [[ -z "$GERRITUSER" ]] || [[ -z "$GERRITSRVR" ]] ||
    [[ -z "$GERRITPORT" ]] || [[ -z "$GERRITWEBPORT" ]]
then
    echo "NOTE: ~/.gerritrc must have the following:"
    echo "   export GERRITUSER=username (e.g. kevinkredit)"
    echo "   export GERRITSRVR=server (e.g. gerritcodereview)"
    echo "   export GERRITPORT=port (e.g. 29418)"
    echo "   export GERRITWEBPORT=port (e.g. 8080)"
    return 1
fi

function list_contains() {
    # Grabbed this from: https://stackoverflow.com/questions/8063228/how-do-i-check-if-a-variable-exists-in-a-list-in-bash
    local item="$1"
    local list="$2"
    if [[ $list =~ (^|[[:space:]])"$item"($|[[:space:]]) ]] ; then
        # yes, list include item
        result=0
    else
        result=1
    fi
    return $result
}

alias gerrit_shell="ssh \$GERRITUSER@\$GERRITSRVR"

function gerrit_ssh (){
    ssh -p "$GERRITPORT" "$GERRITUSER"@"$GERRITSRVR" "$@"
}

function gerrit_ssh_cmd (){
    gerrit_ssh gerrit "$@"
}

function git_current_change_id (){
    git show -s | grep -Po '(?<=Change-Id: ).+'
}

function git_log_change_ids (){
    if [[ $# != 2 ]]; then
        echo "Error: enter 'git_log_change_ids LATEST_COMMIT FOR_BRANCH'"
        return 1
    fi
    git log gerrit/"$2".."$1" | grep -Po '(?<=Change-Id: ).+'
}

function gerrit_query_current (){
    gerrit_ssh_cmd query "$(git_current_change_id)"
}

function gerrit_current_project (){
    gerrit_query_current | grep -Po '(?<=project: ).+'
}

function gerrit_ls_groups () {
    gerrit_ssh_cmd ls-groups
}

function gerrit_set_review_group (){
    if [[ $# != 3 ]]; then
        echo "Error: enter 'gerrit_set_review_group GROUP LATEST_COMMIT FOR_BRANCH'"
        return 1
    fi
    local group=$1
    local current_project gerrit_groups
    current_project=$(gerrit_current_project)
    gerrit_groups=$(gerrit_ls_groups)

    if list_contains "$group" "$gerrit_groups"; then
        echo "Setting $group to review $current_project"
        gerrit_ssh_cmd set-reviewers --project "$current_project" --add "$group" "$(git_log_change_ids "$2" "$3")"
    else
        echo "$group does not exist in the groups returned"
        echo "The following exist:"
        for g in $gerrit_groups
        do
            echo "Group [$g] exists"
        done
    fi
}

function gerrit_get_commit_hooks(){
    GIT_TOP=$(git rev-parse --show-toplevel)
    scp -p -P "$GERRITPORT" "$GERRITUSER"@"$GERRITSRVR":hooks/commit-msg "$GIT_TOP"/.git/hooks/commit-msg
    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        echo "Successfully downloaded gerrit commit message hook"
    else
        echo "Error downloading gerrit commit message hook"
    fi
}

function gerrit_rm_commit_hook() {
    GIT_TOP=$(git rev-parse --show-toplevel)
    rm -f "$GIT_TOP"/.git/hooks/commit-msg
    echo "Deleted gerrit commit message hook"
}

function gerrit_setup() {
    if [[ $# != 1 ]]; then
        echo "Error: enter the Gerrit server project path"
        return 1
    fi
    gerrit_get_commit_hooks
    git remote add gerrit http://"$GERRITSRVR":"$GERRITWEBPORT"/"$1"
    # shellcheck disable=SC2181
    if [ $? -ne 0 ]; then
        echo "Error adding gerrit remote"
        return 1
    else
        echo "Successfully added gerrit remote"
    fi
    git fetch gerrit
}

function gerrit_setup_repo() {
    repo forall -c "\
        PROJ=$(git remote show -n "$(git remote show -n | head -1)" | grep Fetch | \
               rev | cut -d/ -f -2 | rev); \
        gerrit_setup $PROJ"
}

function gerrit_teardown() {
    gerrit_rm_commit_hook
    git remote remove gerrit
    echo "Removed gerrit remote"
}

function gerrit_teardown_repo() {
    repo forall -c gerrit_teardown
}

function gpush() {
    if [[ $# != 4 ]]; then
        echo "Error: enter 'gpush COMMIT BRANCH TOPIC GROUP"
        return 1
    fi
    git push gerrit "$1":refs/for/"$2"%topic="$3"
    gerrit_set_review_group "$4" "$1" "$2"
}
