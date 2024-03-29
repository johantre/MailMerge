function init() {
  NC='\033[0m';
  RED='\033[0;31m';
  GREEN='\033[0;32m';
  prodProps="$DIR/../../env/prod.update.properties"
  localProps="$DIR/../../env/local.update.properties"
  jiraReleaseJson="$DIR/../../payload/releases.json"
  jiraReleaseJsonNew="$DIR/../../payload/releasesnew.json"
  jiraReleaseDateProps="$DIR/../../env/prod.jira.releases.releasedate.properties"

  jqCmd=$(getPropValue update.jq.command "$localProps");

  if test -z "$jqCmd"
  then
    jqCmd=$(getPropValue update.jq.command "$prodProps");
    echo "Falling back to remote $prodProps for jqCmd: $jqCmd"
  else
    jqCmd="$DIR/../..$jqCmd"
    echo "Local jqCmd set to: $jqCmd"
  fi

  export NC;
  export RED;
  export GREEN;
  export jqCmd;
  export prodProps;
  export jiraReleaseJson;
  export jiraReleaseJsonNew;
  export jiraReleaseDateProps;
}

# CRUD Property files
# ===================
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
    if ! grep "=${propValue}" "$propFile" > /dev/null; then
      echo "APPENDING because new key: ${propKey}=${propValue}"
      echo "$propKey=$propValue" >> "$propFile"
    else
      echo "SETTING key because existing value: ${propKey}=${propValue}";
      sed -i "s|.*=${propValue}|$propKey=$propValue|" "$propFile"
    fi
  else
    echo "SETTING value because existing key: ${propKey}=${propValue}"
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

# CRUD CSV files
# ==============
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

# CRUD JSON files
# ===============
function getJiraReleaseJsonField() {
  searchReleaseName=$1;
  fieldToGet=$2;

  # shellcheck disable=SC2016
  "$jqCmd" --arg releasetoget "$searchReleaseName" \
           --arg fieldtoget "$fieldToGet" \
           '.[] | if .name == $releasetoget then .[$fieldtoget] else empty end' < "$jiraReleaseJson" ;
}

function updateJiraReleaseJsonField() {
  searchReleaseName=$1;
  fieldToUpdate=$2;
  fieldValue=$3;

  # shellcheck disable=SC2016
  "$jqCmd" --arg name "${searchReleaseName}" \
           --arg field "${fieldToUpdate}" \
           --arg value "${fieldValue}" \
           'if (.[] | select(.name == $name)) | has($field) then
           (.[] | select(.name == $name))[$field] |= $value else
           (.[] | select(.name == $name)) = {($field) : $value} + (.[] | select(.name == $name)) end' \
           "$jiraReleaseJson" > "$jiraReleaseJsonNew" && mv "$jiraReleaseJsonNew" "$jiraReleaseJson" ;
}

# functional calls to manipulate what pipeline needs to pickup
# ============================================================
function getJiraReleaseName() {
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

  updateJiraReleaseJsonField "$searchReleaseName" "$fieldToUpdate" 'true'
}

function unReleaseJiraRelease() {
  searchReleaseName=$1;
  fieldToUpdate="released";

  updateJiraReleaseJsonField "$searchReleaseName" "$fieldToUpdate" 'false'
}

function archiveJiraRelease() {
  searchReleaseName=$1;
  fieldToUpdate="archived";

  updateJiraReleaseJsonField "$searchReleaseName" "$fieldToUpdate" 'true'
}

function unArchiveJiraRelease() {
  searchReleaseName=$1;
  fieldToUpdate="archived";

  updateJiraReleaseJsonField "$searchReleaseName" "$fieldToUpdate" 'false'
}

# Git calls for client & server to pull, push, commit
# ===================================================
function gitPull() {
  echo "git Pull";
  caller=$1;
  gitUser=$(whoami);

  git config --global user.email "$gitUser@bmw.com"
  git config --global user.name "$gitUser"

  git pull;
}

function gitPush() {
  echo "git Push";
  git push;
}

function gitPullClient() {
  echo "git Pull jira-release-editor-mail-merge master";
  git pull jira-release-editor-mail-merge master;
}

function gitPushClient() {
  echo "git Push jira-release-editor-mail-merge master";
  git push jira-release-editor-mail-merge master;
}

function gitCommit() {
  caller=$1;
  releaseName=$2
  gitUser=$(whoami);

  echo "git Commit from $caller by $gitUser";
  git commit -a -m "CLI commit from $caller by $gitUser for -->$releaseName<--";

  git config --global --unset user.email
  git config --global --unset user.name
}
