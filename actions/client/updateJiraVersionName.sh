DIR=$(dirname "$0")
source "$DIR/../../lib/lib.sh"

export DIR

init

gitPullClient

# update jira release date properties w new Version name
# (deployment pipe does the rest)

while true; do

  read -r -p "$(echo -e "$GREEN Type your jira release name to update $NC: ")" jiraReleaseName;

  existingReleaseName=$(getJiraReleaseName "$jiraReleaseName") ;

  if [[ -z $existingReleaseName ]];
  then read -r -p "$(echo -e "$GREEN Release w name: $jiraReleaseName does not exist. Try again? $RED(Y/N) $NC: ")" tryAgain;
    if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
  else
    read -r -p "$(echo -e "$GREEN Type your new release name $NC: ")" newJiraReleaseName;

    updateJiraReleaseName "$jiraReleaseName" "$newJiraReleaseName";
    break;
  fi
done

gitCommit "$0" "$jiraReleaseName"

gitPushClient

