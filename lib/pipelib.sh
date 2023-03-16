DIR=$(dirname $0)
source "$DIR/lib/lib.sh"
init

function initJiraCredentials() {
  if test -z "$JIRAUSER"
  then
    echo "Falling back to $jiraSecretProps for credentials"
    JIRAUSER=$(getProp 'jira.user' "$jiraSecretProps")
    JIRAPASS=$(getProp 'jira.pass' "$jiraSecretProps")
  fi
}

function createJiraRelease() {
  jiraURL=$1
  jiraUser=$2
  jiraPass=$3
  jiraPayload=$4

  curl --request POST --url "$jiraURL" --user "$jiraUser:$jiraPass" --header 'Accept: application/json' --header 'Content-Type: application/json' --data "$jiraPayload";
}

function updateJiraProps() {
  jiraReleaseName=$1
  jiraReleaseId=$2
  jiraReleaseDate=$3

  setProp "$jiraReleaseName" "$JIRAHOSTNAME$jiraReleaseId" "$jiraReleaseURLProps"
  setProp "$jiraReleaseName" "false" "$jiraReleaseReleasedProps"
  setProp "$jiraReleaseName" "$jiraReleaseDate" "$jiraReleaseReleasedProps"
}
