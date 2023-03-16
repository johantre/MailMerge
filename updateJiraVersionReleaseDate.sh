DIR=$(dirname $0)
source "$DIR/lib/lib.sh"
init

gitPull

# Update releaseDate to properties
# (deployment pipe does the rest)
while true; do

  read -r -p "$(echo -e "Type your jira release name to update its release date : ")" jiraReleaseName;

  existingReleaseName=$(getJiraReleaseName "$jiraReleaseName") ;

  if [ -z "$existingReleaseName" ];
  then read -r -p "$(echo -e "Release w name: $jiraReleaseName does not exist. Try again? (Y/N):")" tryAgain;
    if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
  else
    while true; do

      read -r -p "$(echo -e "Type your new release date you like to replace in release $existingReleaseName : ")" newJiraReleaseDate;

      if newJiraReleaseDate=$(date -d "$newJiraReleaseDate" +'%Y'-'%m'-'%d');
      then
        updateJiraReleaseDate "$jiraReleaseName" "$newJiraReleaseDate";
        exit 0;
      else
        read -r -p "$(echo -e "Incorrect date format for: $newJiraReleaseDate. Format is YYYY-MM-DD. (e.g. 2023-12-01)  Try again? (Y/N) : ")" tryAgain;
        if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
      fi;
    done
  fi
done

# Git stage?

gitCommit

gitPush

