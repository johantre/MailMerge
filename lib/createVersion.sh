DIR=$(dirname $0)
source "$DIR/lib/lib.sh"
source "$DIR/lib/pipelib.sh"

init

initJiraCredentials

jiraReleaseName="$1"
jiraReleaseDate="$2"

jiraReleasePayloadTemplate='{ "description": "", "name": "", "archived": true, "released": false, "releaseDate": "", "project": "", "projectId": "" }';

jiraReleasePayload=$(echo "$jiraReleasePayloadTemplate" \
  | jq -c --arg relName "$jiraReleaseName" '.name = $relName' \
  | jq -c --arg relDate "$jiraReleaseDate" '.releaseDate = $relDate' \
  | jq -c --arg relProj "$JIRAPROJECT" '.project = $relProj' \
  | jq -c --arg relProjId "$JIRAPROJECTID" '.projectId = $relProjId' );

echo "$JIRAHOSTNAME $JIRAUSER $JIRAPASS $jiraReleasePayload"

jsonResponse=$(createJiraRelease "$JIRAHOSTNAME" "$JIRAUSER" "$JIRAPASS" "$jiraReleasePayload");

if echo "$jsonResponse" | grep -q '"errorMessages"'; then
  echo "$jsonResponse";
  exit 1;
else
  jiraReleaseId=$(echo "$jsonResponse" | jq -c -r '.id');
#  updateJiraProps "$jiraReleaseName" "$jiraReleaseId" "$jiraReleaseDate"
fi
