DIR=$(dirname "$0")
source "$DIR/lib/lib.sh"

init

gitPull

# update jira release released field
# (deployment pipe does the rest)

while true; do

  read -r -p "$(echo -e "Type your jira release name to release : ")" jiraReleaseName;

  existingReleaseName=$(getJiraReleaseName "$jiraReleaseName") ;

  if [[ -z $existingReleaseName ]];
  then read -r -p "$(echo -e "Release w name: $jiraReleaseName does not exist. Try again? (Y/N):")" tryAgain;
    if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
  else
    releaseJiraRelease "$jiraReleaseName";
    break;
  fi
done

#gitCommit "$0"

#gitPush

