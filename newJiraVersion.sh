DIR=$(dirname "$0")
source "$DIR/lib/lib.sh"

init

gitPull

# add jira release & releaseDate to jira release date properties
# (deployment pipe does the rest)
while true; do

  read -r -p "$(echo -e "Type your new jira release name (e.g. MY Release W03) : ")" jiraReleaseName;

  existingReleaseName=$(getJiraReleaseName "$jiraReleaseName") ;
  existingStagedReleaseDate=$(getPropValue "$jiraReleaseName" "$jiraReleaseDateProps") ;

  echo "existing date = $existingStagedReleaseDate"
  echo "existing release = $existingReleaseName"

  if [ -z "$existingStagedReleaseDate" ];
  then
    if [ -z "$existingReleaseName" ];
    then
      while true; do

        read -r -p "$(echo -e "Type your jira release date in the right format. (YYYY-MM-DD e.g. 2023-12-01) : ")" jiraReleaseDate;

        if jiraReleaseDate=$(date -d "$jiraReleaseDate" +'%Y'-'%m'-'%d');
        then
          echo "existing release date = $existingStagedReleaseDate"
          echo "existing release name = $existingReleaseName"
          echo "existing jiraReleaseDateProps = $jiraReleaseDateProps"

          setPropValue "$jiraReleaseName" "$jiraReleaseDate" "$jiraReleaseDateProps";
          break;
        else read -r -p "$(echo -e "Incorrect date format for: $jiraReleaseDate. Format is YYYY-MM-DD. (e.g. 2023-12-01)  Try again? (Y/N) : ")" tryAgain;
          if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
        fi;
      done
      break;
    else read -r -p "$(echo -e "Release w name: $jiraReleaseName already exists. Try again? (Y/N):")" tryAgain;
      if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
    fi ;
  else read -r -p "$(echo -e "Release w name: $jiraReleaseName is already staged to be created. Try again? (Y/N):")" tryAgain;
    if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
  fi ;
done

#gitCommit "$0"

#gitPush

