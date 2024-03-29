# Added to Git for handover
# UNTESTED CODE after refactoring folder structure !!!!!
# This is a working interactive script to generate the right database file _name_ containing the right parameters to launch
# with the mail template with for example the Test Runs Report from our pipeline, when e.g. a release is set to "released": true
# This code can be used to tell the pipeline what mail should be sent, by telling what database is touched.

# In progress:
# * getting screenshots w headless browser & Python, (see ../../ScreenCapture.py)
# * save screenshot to $DIR/../../images/releaseName folder under the name image001.png (see ../../ScreenCapture.py)
# * getting assigned users from Jira tests (REST) + mail address
# * getting jira release URL
# * update 'right' (=see ./actions/client/milesMail.sh)mail database CSV file in $DIR/../../templatedata folder
# * re-use this script to tell pipeline after push what mail to send.
# * cleanup useless cat's

DIR=$(dirname "$0")
templateFolder="$DIR/../../templates"
templateDataFolder="$DIR/../../templatedata"
mailConfigProperties="$DIR/../../env/mailmerge_server.conf"

RED='\033[0;31m';
NC='\033[0m';
TRACE=true;

while getopts "hn" option; do
   case $option in
      h) # display Help
        echo "Syntax: milesMail [-h|n]"
        echo "options:"
        echo "-h: this help."
        echo "-n: Send System Unavailable mail without git trace, with runtime parameters distributed."
        exit 0;;
      n)
        TRACE=false;
        break;;
      *)
        echo "invalid option.  Use [-h|n] instead or -h for more info."
        exit 0;;
   esac
done

while true; do
  read -r -p "$(echo -e "type letter code of market: $RED(BE,NL,BE-NL)$NC:")" marketName
  case $marketName in
    BE-NL|BE|NL)
      read -r -p "$(echo -e "type the template respective number: Deployment Approval$RED(1)$NC, Deployment$RED(2)$NC, System Unavailable$RED(3)$NC, System Available Again$RED(4)$NC:")" templateNumber;
      case $templateNumber in
        1|2|3|4)
            if  [ "$marketName" == "BE-NL" ] && ( [ "$templateNumber" == "3" ] || [ "$templateNumber" == "4" ] ); then
              read -r -p "$(echo -e "Invalid market-template combination: $RED$marketName$NC cannot be combined with templateNumber $RED$templateNumber$NC. Try again? $RED(Y/N)$NC:")" tryAgain;
              if [[ "$tryAgain" != [yY] ]]; then exit 0; fi;
            else
              templateMultiplier="Single";
              if [ "$marketName" == "BE-NL" ]; then
                  templateMultiplier="Multiple";
              fi
              case $templateNumber in
                1) databaseName="Deployment Approval" ;
                  templateName="Deployment"$templateMultiplier"Market" ;;
                2) databaseName="Deployment" ;
                  templateName="Deployment"$templateMultiplier"Market" ;;
                3) if [ "$TRACE" == false ]; then
                      reason="";
                      date="";
                      fromTime="";
                      toTime="";
                      printf $RED"The following arguments will be parsed into your Unavailability mail"$NC"\n";
                      read -r -p "$(echo -e "The systems will be unavailable due to:$RED(type reason of unavailability)$NC")" reason;
                      read -r -p "$(echo -e "The systems will be unavailable on date:$RED(type date of unavailability)$NC")" date;
                      read -r -p "$(echo -e "from:$RED(type starting time of unavailability)$NC")" fromTime;
                      read -r -p "$(echo -e "to:$RED(type ending time of unavailability)$NC")" toTime;
                      databaseName="System UnavailableParam" ;
                   else
                      databaseName="System Unavailable" ;
                   fi
                  templateName="SystemAvailability" ;;
                4) databaseName="System Available Again" ;
                  templateName="SystemAvailability" ;;
              esac
              break ;
            fi ;;
        *)
          read -r -p "$(echo -e "Invalid input: $RED$templateNumber$NC Usage: type respective number:Deployment Approval$RED(1)$NC, Deployment$RED(2)$NC, System Unavailable$RED(3)$NC, System Available Again$RED(4)$NC:. Try again? $RED(Y/N)$NC:")" tryAgain;
          if [[ "$tryAgain" != [yY] ]]; then exit 0; fi ;;
      esac;;
    *)
      read -r -p "$(echo -e "Invalid input: $RED$marketName$NC Usage: $RED(BE,NL,BE-NL)$NC. Try again? $RED(Y/N)$NC:")" tryAgain;
      if [[ "$tryAgain" != [yY] ]]; then exit 0; fi ;;
  esac
done

echo "the winning combo is: $templateNumber and marketName: $marketName";

if [[ ($templateNumber == 1 || $templateNumber == 2)]]; then
  systemName="Miles PROD SF1-" ;
else
  systemName="Miles INT SF1-" ;
fi

#Assembling it all, substitute variables if $TRACE is false.
#databasePath = "$templateDataFolder / $systemName $marketName $databaseName.csv";
databasePath="$templateDataFolder/$systemName$marketName $databaseName.csv";
if [ "$templateNumber" == "3" ] && [ "$TRACE" == false ]; then
  cat "$databasePath" | sed -e "s#\${reason}#""$reason""#" | sed -e "s#\${date}#""$date""#" | sed -e "s#\${fromTime}#""$fromTime""#" | sed -e "s#\${toTime}#""$toTime""#" > temp.csv
  #reset databasePath tot temp.csv w substituted content
  databasePath="temp.csv";
fi
templatePath="$templateFolder/$templateName.html";

echo "$templatePath"
echo "$databasePath"
mailmerge --no-dry-run --template "$templatePath" --database "$databasePath" --config "$mailConfigProperties";

if [ "$templateNumber" == "3" ] && [ "$TRACE" == false ]; then
  rm temp.csv;
fi
