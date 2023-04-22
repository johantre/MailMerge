DIR=$(dirname "$0")
source "$DIR/../../lib/lib.sh"
source "$DIR/../../lib/pipelib.sh"

export DIR

init

gitPull

initJiraCredentials

updateJiraRelease

gitCommit "$0" "previous client commit"

gitPush

