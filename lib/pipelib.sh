function initJiraCredentials() {
  jiraProps="$DIR/../../env/prod.jira.properties"
  jiraSecretProps="$DIR/../../env/prod.jira.secret.properties"
  jiraReleaseDateProps="$DIR/../../env/prod.jira.releases.releasedate.properties"

  JIRAHOSTNAME=$(getPropValue 'jira.host' "$jiraProps")
  JIRAPROJECT=$(getPropValue "jira.project.name" "$jiraProps")
  JIRAPROJECTID=$(getPropValue "jira.project.id" "$jiraProps")

  if test -z "$JIRAUSER"
  then
    echo "Falling back to $jiraSecretProps for credentials"
    JIRAUSER=$(getPropValue 'jira.user' "$jiraSecretProps")
    JIRAPASS=$(getPropValue 'jira.pass' "$jiraSecretProps")
  fi

  export JIRAUSER;
  export JIRAPASS;
  export JIRAPROJECT;
  export JIRAHOSTNAME;
  export JIRAPROJECTID;
  export jiraReleaseDateProps
}

# bare calls to manipulate Jira and called from within pipeline
# =============================================================
function createJiraRelease() {
  jiraReleaseName="$1"
  jiraReleaseDate="$2"

  jiraReleasePayloadTemplate='{ "description": "", "name": "", "archived": false, "released": false, "releaseDate": "", "project": "", "projectId": "" }';

#  echo "user : $JIRAUSER"
#  echo "pass : $JIRAPASS"
#  echo "hostname : $JIRAHOSTNAME"
#  echo "project : $JIRAPROJECT"
#  echo "projectId : $JIRAPROJECTID"
#  echo "name : $jiraReleaseName"
#  echo "date : $jiraReleaseDate"
#  echo "template : $jiraReleasePayloadTemplate"

  jqCmd=$(getPropValue update.jq.command "$prodProps");

  # shellcheck disable=SC2016
  jiraReleasePayload=$(echo "$jiraReleasePayloadTemplate" \
    | "$jqCmd" -c --arg relName "$jiraReleaseName" '.name = $relName' \
    | "$jqCmd" -c --arg relDate "$jiraReleaseDate" '.releaseDate = $relDate' \
    | "$jqCmd" -c --arg relProj "$JIRAPROJECT" '.project = $relProj' \
    | "$jqCmd" -c --arg relProjId "$JIRAPROJECTID" '.projectId = $relProjId' );

  echo "$JIRAHOSTNAME $JIRAUSER $JIRAPASS $jiraReleasePayload"

  jsonResponse=$(postJiraRelease "$JIRAHOSTNAME" "$JIRAUSER" "$JIRAPASS" "$jiraReleasePayload");
  echo "And the response is : $jsonResponse"

  if echo "$jsonResponse" | grep -q '"errorMessages"'; then
    echo "$jsonResponse";
    exit 1;
  else
    # maybe not better to extract that completely from Jira?
    # update releaseURL property file
    # clean releaseDateProp file after creation
    # shellcheck disable=SC2016
    # "$jqCmd" --arg newrelease "$jsonResponse" '. += [$newrelease]' "$jiraReleaseJsonNew"

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
  #echo "curl --request POST --url $jiraURL --user $jiraUser:$jiraPass --header 'Accept: application/json' --header 'Content-Type: application/json' --data $jiraPayload";
}

function getJsonChanged() {
  toLine="$1"

  while read -r line
  do
    closingBraceFound=$(echo "$line" | grep "}")

    if [[ -n $closingBraceFound ]];
    then
      fromLine="$toLine"
      break;
    fi;
    ((toLine++))
  done <<< "$(tail +"$toLine" "$jiraReleaseJson")"

  while read -r line
  do
    openingBraceFound=$(echo "$line" | grep "{")
    if [[ -n $openingBraceFound ]];
    then
     break;
    fi;
    ((fromLine--))
  done <<< "$(head -n "$toLine" "$jiraReleaseJson" | tac )"

  head -n "$toLine" "$jiraReleaseJson" | tail +"$fromLine" | sed 's#[}],#}#'
}