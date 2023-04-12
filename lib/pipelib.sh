function initJiraCredentials() {
  jiraProps="$DIR/../../env/prod.jira.properties"
  jiraSecretProps="$DIR/../../env/local.jira.secret.properties"
  jiraReleaseURLProps="$DIR/../../env/prod.jira.releases.url.properties"
  jiraReleaseDateProps="$DIR/../../env/prod.jira.releases.releasedate.properties"

  JIRAHOSTNAME=$(getPropValue 'jira.host' "$jiraProps")
  JIRAPROJECT=$(getPropValue "jira.project.name" "$jiraProps")
  JIRAPROJECTID=$(getPropValue "jira.project.id" "$jiraProps")

  jiraRestURL="$JIRAHOSTNAME""rest/api/2/version/";
  jiraVersionURL="$JIRAHOSTNAME""projects/$JIRAPROJECT/versions/";
  jiraRestVersionsURL="$JIRAHOSTNAME""rest/api/2/project/$JIRAPROJECTID/versions/"

  if test -z "$JIRAUSER"
  then
    echo "Falling back to local $jiraSecretProps for credentials"
    JIRAUSER=$(getPropValue 'jira.user' "$jiraSecretProps")
    JIRAPASS=$(getPropValue 'jira.pass' "$jiraSecretProps")
  fi

  export JIRAUSER;
  export JIRAPASS;
  export JIRAHOSTNAME;
  export JIRAPROJECTID;
  export jiraRestURL;
  export jiraVersionURL;
  export jiraReleaseURLProps;
  export jiraReleaseDateProps;
}

# CRUD Property files
# ===================
function updateJiraURLProp() {
  jiraReleaseName=$1
  jiraReleaseId=$2

  setPropValue "$jiraReleaseName" "$jiraVersionURL$jiraReleaseId" "$jiraReleaseURLProps"
}

# Bare calls to manipulate Jira and called from within pipeline
# =============================================================
function createJiraReleases() {
  echo "the release date props file: -->$jiraReleaseDateProps<--"
  lineCount=0;
  while read -r line; do
    jiraReleaseName=$(echo "$line" |cut -d'=' -f1 ||echo "::error::Nothing found in ${jiraReleaseDateProps}" exit 1 ;)
    jiraReleaseDate=$(echo "$line" |cut -d'=' -f2 ||echo "::error::Nothing found in ${jiraReleaseDateProps}" exit 1 ;)
    ((lineCount++));
    echo "Creating $jiraReleaseName w date : $jiraReleaseDate line count : $lineCount";
    createJiraRelease "$jiraReleaseName" "$jiraReleaseDate"
  done < "$jiraReleaseDateProps";

  echo "And the line count is : -->$lineCount<--"
  #cleanup requested releases
  sed -i "1,$lineCount d" "$jiraReleaseDateProps";
  #reflush releases payload file
  getAllJiraReleases "$jiraRestVersionsURL" "$JIRAUSER" "$JIRAPASS" | "$jqCmd" . > "$jiraReleaseJson";
}

function createJiraRelease() {
  jiraReleaseName="$1"
  jiraReleaseDate="$2"

  jiraReleasePayloadTemplate='{ "description": " ", "name": "", "archived": false, "released": false, "releaseDate": "", "project": "", "projectId": "" }';

  # shellcheck disable=SC2016
  jiraReleasePayload=$(echo "$jiraReleasePayloadTemplate" \
    | "$jqCmd" -c --arg relName "$jiraReleaseName" '.name = $relName' \
    | "$jqCmd" -c --arg relDate "$jiraReleaseDate" '.releaseDate = $relDate' \
    | "$jqCmd" -c --arg relProj "$JIRAPROJECT" '.project = $relProj' \
    | "$jqCmd" -c --arg relProjId "$JIRAPROJECTID" '.projectId = $relProjId' );

  echo "$jiraRestURL $JIRAUSER $JIRAPASS $jiraReleasePayload";

  jsonResponse=$(postJiraRelease "$jiraRestURL" "$JIRAUSER" "$JIRAPASS" "$jiraReleasePayload");
  echo "Version created : $jsonResponse";

  jiraErrors=$(grep -q -c '"errorMessages"' <<< "$jsonResponse");
  shellErrors=$(grep -q -c '"error"' <<< "$jsonResponse");

  if [[ ( $jiraErrors ) || ( $shellErrors  ) ]]; then
    echo "$jsonResponse";
    exit 1;
  else
    jiraReleaseId=$(echo "$jsonResponse" | "$jqCmd" -c -r '.id');
    updateJiraURLProp "$jiraReleaseName" "$jiraReleaseId";
  fi
}

function updateJiraRelease() {
  changedJsonPayload=$(getJsonChanged);
  echo "changedJsonPayload from getJsonChanged = $changedJsonPayload";

  shellErrors=$(grep -q -c '"error"' <<< "$jsonResponse");
  echo "shell error count: $shellErrors";

  if [[ ( $shellErrors  ) ]]; then
    echo "$changedJsonPayload";
    exit 1;
  else
    jiraReleasePayloadTemplate='{ "description": "", "name": "", "archived": "", "released": "", "releaseDate": "" }';

    relId=$("$jqCmd" -r '.id' <<< "$changedJsonPayload");
    name=$("$jqCmd" -r '.name' <<< "$changedJsonPayload");
    releaseDate=$("$jqCmd" -r '.releaseDate' <<< "$changedJsonPayload");
    description=$("$jqCmd" -r '.description' <<< "$changedJsonPayload");
    archived=$("$jqCmd" -r '.archived' <<< "$changedJsonPayload");
    released=$("$jqCmd" -r '.released' <<< "$changedJsonPayload");

    # shellcheck disable=SC2016
    jiraReleasePayload=$(echo "$jiraReleasePayloadTemplate" \
      | "$jqCmd" -c --arg name "$name" '.name = $name' \
      | "$jqCmd" -c --arg releaseDate "$releaseDate" '.releaseDate = $releaseDate' \
      | "$jqCmd" -c --arg description "$description" '.description = $description' \
      | "$jqCmd" -c --arg archived "$archived" '.archived = $archived' \
      | "$jqCmd" -c --arg released "$released" '.released = $released' );

    jsonResponse=$(putJiraRelease "$jiraRestURL$relId" "$JIRAUSER" "$JIRAPASS" "$jiraReleasePayload");
    echo "Version updated : $jsonResponse";

    jiraErrors=$(grep -q -c '"errorMessages"' <<< "$jsonResponse");
    shellErrors=$(grep -q -c '"error"' <<< "$jsonResponse");

    if [[ ( $jiraErrors ) || ( $shellErrors  ) ]]; then
      echo "$jsonResponse";
      exit 1;
    else
      updateJiraURLProp "$name" "$relId"; #relName could have been changed as well!
      #reflush releases payload file
      getAllJiraReleases "$jiraRestVersionsURL" "$JIRAUSER" "$JIRAPASS" | "$jqCmd" . > "$jiraReleaseJson";
    fi
  fi
}

function putJiraRelease() {
  jiraURL=$1
  jiraUser=$2
  jiraPass=$3
  jiraPayload=$4

  curl --request PUT --url "$jiraURL" --user "$jiraUser:$jiraPass" --header 'Accept: application/json' --header 'Content-Type: application/json' --data "$jiraPayload";
}

function postJiraRelease() {
  jiraURL=$1
  jiraUser=$2
  jiraPass=$3
  jiraPayload=$4

  curl --request POST --url "$jiraURL" --user "$jiraUser:$jiraPass" --header 'Accept: application/json' --header 'Content-Type: application/json' --data "$jiraPayload";
}

function getAllJiraReleases() {
  jiraURL=$1
  jiraUser=$2
  jiraPass=$3

  curl --request GET  --url "$jiraURL" --user "$jiraUser:$jiraPass"
}

function getJsonChanged() {
  toLine=$(git diff -U0 HEAD^ -- "$jiraReleaseJson" | grep -o '\+.* @@' | sed -En 's/\+(.*) @@/\1/p');
  echo "from within getJsonChanged. Tail args: toLine = ->$toLine<-"
  echo "from within getJsonChanged. Tail args: jiraReleaseJson = ->$jiraReleaseJson<-"

  tailToLineResponse="$(tail +"$toLine" "$jiraReleaseJson")"

  echo "from within getJsonChanged. tailToLineResponse : ->$tailToLineResponse<-"

  while read -r line
  do
    closingBraceFound=$(echo "$line" | grep "}")

    if [[ -n $closingBraceFound ]];
    then
      fromLine="$toLine"
      break;
    fi;
    ((toLine++))
  done <<< "$tailToLineResponse"

  headFromLineResponse="$(head -n "$toLine" "$jiraReleaseJson" | tac )"
  echo "This is the head from line response : $headFromLineResponse"

  while read -r line
  do
    openingBraceFound=$(echo "$line" | grep "{")
    if [[ -n $openingBraceFound ]];
    then
     break;
    fi;
    ((fromLine--))
  done <<< "$headFromLineResponse"

  head -n "$toLine" "$jiraReleaseJson" | tail +"$fromLine" | sed 's#[}],#}#'
}