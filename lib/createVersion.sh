DIR=$(dirname "$0")
source "$DIR/lib.sh"

init

initJiraCredentials

jiraReleaseName="$1"
jiraReleaseDate="$2"

createJiraRelease "$jiraReleaseName" "$jiraReleaseDate";
