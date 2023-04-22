DIR=$(dirname "$0")
source "$DIR/../../lib/lib.sh"

export DIR

init

gitPullClient

# add jira release & releaseDate to jira release date properties
# (deployment pipe does the rest)
while true; do

  read -r -p "$(echo -e "$GREEN Type your new jira release name $RED(e.g. MY Release W03) $NC: ")" jiraReleaseName;

  existingReleaseName=$(getJiraReleaseName "$jiraReleaseName") ;
  existingStagedReleaseDate=$(getPropValue "$jiraReleaseName" "$jiraReleaseDateProps") ;

  if [ -z "$existingStagedReleaseDate" ];
  then
    if [ -z "$existingReleaseName" ];
    then
      while true; do

        read -r -p "$(echo -e "$GREEN Type your jira release date in the right format. $RED(YYYY-MM-DD e.g. 2023-12-01) $NC: ")" jiraReleaseDate;

        if jiraReleaseDate=$(date -d "$jiraReleaseDate" +'%Y'-'%m'-'%d');
        then
          setPropValue "$jiraReleaseName" "$jiraReleaseDate" "$jiraReleaseDateProps";

          gitCommit "$0" "$jiraReleaseName"

          gitPushClient
          break;
        else read -r -p "$(echo -e "$GREEN Incorrect date format for: $jiraReleaseDate. Format is$RED YYYY-MM-DD. (e.g. 2023-12-01)$NC  Try again? $RED(Y/N) $NC: ")" tryAgain;
          if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
        fi;
      done
      break;
    else read -r -p "$(echo -e "$GREEN Release w name: $jiraReleaseName already exists. Try again? $RED(Y/N) $NC: ")" tryAgain;
      if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
    fi ;
  else read -r -p "$(echo -e "$GREEN Release w name: $jiraReleaseName is already staged to be created. Try again? $RED(Y/N) $NC: ")" tryAgain;
    if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
  fi ;
done
