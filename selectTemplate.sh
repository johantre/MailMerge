if [[ $1 == *"System"* ]]; then
  template="SystemAvailability.html"
elif [[ $1 == *"Deployment"* && $1 == *"BE-NL"* ]]; then
  template="DeploymentMultipleMarket.html"
elif [[ $1 == *"Deployment"* && $1 != *"BE-NL"* ]]; then
  template="DeploymentSingleMarket.html"
else
  template="Wrong code convention parameter database file!!"
fi;
#echo "The template for $1 is $template"

mailmerge --no-dry-run --template templates/"$template" --database "$1" <<< $MAILPASS


echo "$template"