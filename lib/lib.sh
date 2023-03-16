function init() {
  prodProps="$DIR/env/prod.update.properties"
  jiraProps="$DIR/env/prod.jira.properties"
  jiraReleaseJson="$DIR/payload/releases.json"
  jiraSecretProps="$DIR/env/prod.jira.secret.properties"
  jiraReleaseDateProps="$DIR/env/prod.jira.releases.releasedate.properties"

  JIRAPROJECT=$(getPropValue "jira.project.name" "$jiraProps")
  JIRAHOSTNAME=$(getPropValue 'jira.host' "$jiraProps")
  JIRAPROJECTID=$(getPropValue "jira.project.id" "$jiraProps")

  export JIRAUSER;
  export JIRAPASS;
  export JIRAPROJECT;
  export JIRAHOSTNAME;
  export JIRAPROJECTID;
  export jiraReleaseJson;
  export prodProps;

  shopt -s expand_aliases;

  alias jq="source $(getPropValue "update.jq.command" $prodProps)";
  echo "alias done! $(getPropValue "update.jq.command" $prodProps)"
}

function getPropValue() {
  propKey=$1
  propFile=$2

  grep --no-messages "$propKey" "$propFile"|cut -d'=' -f2||echo "::error::Variable ${propKey} not set" && exit 0 ;
}

function setPropValue() {
  propKey="$1"
  propValue="$2"
  propFile="$3"

  if ! grep -R "^[#]*\s*${propKey}=.*" "$propFile" > /dev/null; then
    echo "APPENDING because new key ${propKey}"
    echo "$propKey=$propValue" >> "$propFile"
  else
    echo "SETTING because existing ${propKey}"
    sed -i "s|^[#]*\s*${propKey}=.*|$propKey=$propValue|" "$propFile"
  fi
}

function updatePropKey() {
  propKey="$1"
  newPropKey="$2"
  propFile="$3"

  propValue=$(getPropValue "$propKey" "$propFile")

  if ! grep -R "^[#]*\s*${propKey}=.*" "$propFile" > /dev/null; then
    echo "KEY ${propKey} not found"
  else
    echo "update existing ${propKey} to new ${newPropKey} w same value ${propValue}"
    sed -i "s|^[#]*\s*${propKey}=.*|$newPropKey=$propValue|" "$propFile"
  fi
}

function getCSVFieldValue() {
  fieldCount=$1;
  file=$2;

  i=0;
  while read -r line
  do
    if [[ $i == 1 ]]; then echo $(cut -d',' -f$fieldCount <<< $line); fi;
    i=$((i+1));
  done < "$file";
}

function replaceCSVField() {
  fieldCount=$1;
  toReplaceBy=$2;
  file=$3;

  toBeReplaced=$(getCSVFieldValue "$fieldCount" "$file");

  sed -i "2 s/${toBeReplaced}/\"${toReplaceBy}\"/g" "$file";
}

function getJiraReleaseName() {
  searchReleaseName=$1;
  fieldToGet="name"

  getJiraReleaseJsonField "$searchReleaseName" "$fieldToGet";
}

function newJiraRelease() {
  searchReleaseName=$1;
  fieldToGet="name"

  getJiraReleaseJsonField "$searchReleaseName" "$fieldToGet";
}

function updateJiraReleaseName() {
  searchReleaseName=$1;
  fieldToUpdate="name"
  newReleaseName=$2;

  updateJiraReleaseJsonField "$searchReleaseName" "$fieldToUpdate" "$newReleaseName"
}

function updateJiraReleaseDate() {
  searchReleaseName=$1;
  fieldToUpdate="releaseDate";
  newReleaseDate=$2;

  updateJiraReleaseJsonField "$searchReleaseName" "$fieldToUpdate" "$newReleaseDate"
}

function updateJiraReleaseDescription() {
  searchReleaseName=$1;
  fieldToUpdate="description";
  newReleaseDescription=$2;

  updateJiraReleaseJsonField "$searchReleaseName" "$fieldToUpdate" "$newReleaseDescription"
}

function releaseJiraRelease() {
  searchReleaseName=$1;
  fieldToUpdate="released";

  updateJiraReleaseJsonField "$searchReleaseName" "$fieldToUpdate" true
}

function unReleaseJiraRelease() {
  searchReleaseName=$1;
  fieldToUpdate="released";

  updateJiraReleaseJsonField "$searchReleaseName" "$fieldToUpdate" 'false'
}

function archiveJiraRelease() {
  searchReleaseName=$1;
  fieldToUpdate="archived";

  updateJiraReleaseJsonField "$searchReleaseName" "$fieldToUpdate" true
}

function unArchiveJiraRelease() {
  searchReleaseName=$1;
  fieldToUpdate="archived";

  updateJiraReleaseJsonField "$searchReleaseName" "$fieldToUpdate" false
}

function getJiraReleaseJsonField() {
  searchReleaseName=$1;
  fieldToGet=$2;

  jqCmd=$(getPropValue update.jq.command "$prodProps");

  cat "$jiraReleaseJson" | "$jqCmd" --arg releasetoget "$searchReleaseName" \
                                    --arg fieldtoget "$fieldToGet" \
                                    '.[] | if .name == $releasetoget then .[$fieldtoget] else empty end' ;
}

function updateJiraReleaseJsonField() {
  searchReleaseName=$1;
  fieldToUpdate=$2;
  fieldValue=$3;

  jqCmd=$(getPropValue "update.jq.command" "$prodProps")

  "$jqCmd" --arg name "$searchReleaseName" \
           --arg field "$fieldToUpdate" \
           --arg value "$fieldValue" \
           '(.[] | select(.name == $name))[$field] |= $value' \
           "$jiraReleaseJson" > ./payload/newreleases.json && mv ./payload/newreleases.json "$jiraReleaseJson";
}

function gitPull() {
  echo "git Pull"
#  git pull;
}

function gitPush() {
  echo "git Push"
#  git push;
}

function gitCommit() {
  echo "git Commit"
#  git commit;
}
