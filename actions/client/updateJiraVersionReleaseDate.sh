DIR=$(dirname "$0")
source "$DIR/../../lib/lib.sh"

export DIR

init

gitPullClient

# Update releaseDate to properties
# (deployment pipe does the rest)
while true; do

  read -r -p "$(echo -e "$GREEN Type your jira release name to update its release date $NC: ")" jiraReleaseName;

  existingReleaseName=$(getJiraReleaseName "$jiraReleaseName") ;

  if [ -z "$existingReleaseName" ];
  then read -r -p "$(echo -e "$GREEN Release w name: $jiraReleaseName does not exist. Try again? $RED(Y/N) $NC: ")" tryAgain;
    if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
  else
    while true; do

      read -r -p "$(echo -e "$GREEN Type your new release date you like to replace in release $existingReleaseName $NC: ")" newJiraReleaseDate;

      if newJiraReleaseDate=$(date -d "$newJiraReleaseDate" +'%Y'-'%m'-'%d');
      then
        updateJiraReleaseDate "$jiraReleaseName" "$newJiraReleaseDate";

        gitCommit "$0" "$jiraReleaseName"

        gitPushClient
        exit 0;
      else
        read -r -p "$(echo -e "$GREEN Incorrect date format for: $newJiraReleaseDate. Format is YYYY-MM-DD. (e.g. 2023-12-01)  Try again? $RED(Y/N) $NC: ")" tryAgain;
        if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
      fi;
    done
  fi
done

