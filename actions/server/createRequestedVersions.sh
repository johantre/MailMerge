DIR=$(dirname "$0")
source "$DIR/../../lib/lib.sh"
source "$DIR/../../lib/pipelib.sh"

export DIR

init

gitPullClient

initJiraCredentials

createJiraReleases

gitCommitClient

gitPush

