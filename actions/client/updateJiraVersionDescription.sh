DIR=$(dirname "$0")
source "$DIR/../../lib/lib.sh"

export DIR

init

gitPullClient

# update jira release date properties w new Version name
# (deployment pipe does the rest)

while true; do

  read -r -p "$(echo -e "Type your jira release name to update its description : ")" jiraReleaseName;

  existingReleaseName=$(getJiraReleaseName "$jiraReleaseName") ;

  if [[ -z $existingReleaseName ]];
  then read -r -p "$(echo -e "Release w name: $jiraReleaseName does not exist. Try again? (Y/N):")" tryAgain;
    if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
  else
    read -r -p "$(echo -e "Type your new release description : ")" newJiraReleaseDescription;

    updateJiraReleaseDescription "$jiraReleaseName" "$newJiraReleaseDescription";
    break;
  fi
done

gitCommit "$0"

gitPushClient

