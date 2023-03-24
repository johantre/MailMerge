function init() {
  prodProps="$DIR/env/prod.update.properties"
  jiraReleaseJson="$DIR/payload/releases.json"

  export jiraReleaseJson;
  export prodProps;

  shopt -s expand_aliases;

  alias jq="source $(getPropValue "update.jq.command" "$prodProps")";
  echo "alias done! $(getPropValue "update.jq.command" "$prodProps")"
}

function initJiraCredentials() {
  if test -z "$JIRAUSER"
  then
    echo "Falling back to $jiraSecretProps for credentials"
    JIRAUSER=$(getPropValue 'jira.user' "$jiraSecretProps")
    JIRAPASS=$(getPropValue 'jira.pass' "$jiraSecretProps")
  fi

  jiraProps="$DIR/env/prod.jira.properties"
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
}


function updateJiraProps() {
  jiraReleaseName=$1

  setPropValue "$jiraReleaseName" "$JIRAHOSTNAME$jiraReleaseId" "$jiraReleaseURLProps"
  setPropValue "$jiraReleaseName" "false" "$jiraReleaseReleasedProps"
  setPropValue "$jiraReleaseName" "$jiraReleaseDate" "$jiraReleaseReleasedProps"
}

function createJiraRelease() {

  jiraReleasePayloadTemplate='{ "description": "", "name": "", "archived": true, "released": false, "releaseDate": "", "project": "", "projectId": "" }';

  echo "template : $jiraReleasePayloadTemplate"
  echo "name : $jiraReleaseName"
  echo "date : $jiraReleaseDate"
  echo "project : $JIRAPROJECT"
  echo "projectId $JIRAPROJECTID"

  jqCmd=$(getPropValue update.jq.command "$prodProps");

  jiraReleasePayload=$(echo "$jiraReleasePayloadTemplate" \
    | "$jqCmd" -c --arg relName "$jiraReleaseName" '.name = $relName' \
    | "$jqCmd" -c --arg relDate "$jiraReleaseDate" '.releaseDate = $relDate' \
    | "$jqCmd" -c --arg relProj "$JIRAPROJECT" '.project = $relProj' \
    | "$jqCmd" -c --arg relProjId "$JIRAPROJECTID" '.projectId = $relProjId' );

  echo "$JIRAHOSTNAME $JIRAUSER $JIRAPASS $jiraReleasePayload"

  jsonResponse=$(postJiraRelease "$JIRAHOSTNAME" "$JIRAUSER" "$JIRAPASS" "$jiraReleasePayload");
  #jsonResponse='{"self": "https://atc.bmwgroup.net/jira/rest/api/2/version/243832", "id": "666","description": "the number of the beast","name": "Lou-Cypher","archived": "fal" }'
  echo "And the response is : $jsonResponse"

  if echo "$jsonResponse" | grep -q '"errorMessages"'; then
    echo "$jsonResponse";
    exit 1;
  else
    "$jqCmd" --arg newrelease "$jsonResponse" '. += [$newrelease]' ./payload/testreleases.json

    jiraReleaseId=$(echo "$jsonResponse" | "$jqCmd" -c -r '.id');
  #  updateJiraProps "$jiraReleaseName" "$jiraReleaseId" "$jiraReleaseDate"
  fi

}


function postJiraRelease() {
  jiraURL=$1
  jiraUser=$2
  jiraPass=$3
  jiraPayload=$4

  curl --request POST --url "$jiraURL" --user "$jiraUser:$jiraPass" --header 'Accept: application/json' --header 'Content-Type: application/json' --data "$jiraPayload";
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
  echo "git Pull";
  git pull mail-merge master;
}

function gitPush() {
  echo "git Push";
  git push mail-merge;
}

function gitCommit() {
  caller=$1;
  gitUser=$(whoami);
  echo "git Commit from $caller by $gitUser";
  git commit -a -m "CLI commit performed from $caller by $gitUser";
}
