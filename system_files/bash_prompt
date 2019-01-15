# Set config variables first
GIT_PROMPT_ONLY_IN_REPO=0

GIT_PROMPT_FETCH_REMOTE_STATUS=0   # uncomment to avoid fetching (better performance)
GIT_PROMPT_IGNORE_SUBMODULES=1     # uncomment to avoid searching for changed files in submodules
#GIT_PROMPT_SHOW_UPSTREAM=1         # uncomment to show upstream tracking branch
GIT_PROMPT_SHOW_UNTRACKED_FILES=no # (no|normal|all); determines counting of untracked files
#GIT_PROMPT_SHOW_CHANGED_FILES_COUNT=0 # uncomment to avoid printing the number of changed files
#GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh # uncomment to support Git older than 1.7.10

# set custom prompt start and end sequences
Time12a="\$(date +%H:%M)"
GIT_PROMPT_START="[_LAST_COMMAND_INDICATOR_${Time12a}] \[\033[32;1m\]\u@\H\[\033[31;1m\] [\w]\[\033[35;1m\]\[\033[0m\]"
GIT_PROMPT_END="\[\033[34;1m\]\n\$ \[\033[0m\]"

# use custom theme specified in file GIT_PROMPT_THEME_FILE (default ~/.git-prompt-colors.sh)
GIT_PROMPT_THEME=Custom
GIT_PROMPT_THEME_FILE=~/.git-prompt-colors.sh
# GIT_PROMPT_THEME=Default_Ubuntu # use named theme

source ~/.bash-git-prompt/gitprompt.sh
