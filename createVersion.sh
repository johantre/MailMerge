DIR=$(dirname "$0")
source "$DIR/lib/lib.sh"
source "$DIR/lib/pipelib.sh"

init

initJiraCredentials

jiraReleaseName="$1"
jiraReleaseDate="$2"

createJiraRelease "$jiraReleaseName" "$jiraReleaseDate";
