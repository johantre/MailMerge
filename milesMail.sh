RED='\033[0;31m';
NC='\033[0m';
NOTRACE=false;

while getopts "hn" option; do
   case $option in
      h) # display Help
        echo "Syntax: milesMail [-h|n]"
        echo "options:"
        echo "-h: this help."
        echo "-n: Send System Unavailable mail without git trace, with runtime parameters distributed."
        break;;
      n)
        NOTRACE=true;
        break;;
   esac
done

while true; do
  tryAgain="Y";
  read -p "$(echo -e "type letter code of market: "$RED"(BE,NL,BE-NL)"$NC":")" marketName
  if  [ "$marketName" != "BE-NL" ] && [ "$marketName" != "BE" ] && [ "$marketName" != "NL" ]; then
    read -p "$(echo -e "Invalid input: "$RED$marketName$NC" Usage: "$RED"(BE,NL,BE-NL)"$NC". Try again? "$RED"(Y/N)"$NC":")" tryAgain;
      if [ $tryAgain != "Y" ]; then exit 0; fi
  else
    tryAgain="";
  fi

  if [ "$tryAgain" != "Y" ]; then
    read -p "$(echo -e "type the template respective number: Deployment"$RED"(1)"$NC", Deployment Approval"$RED"(2)"$NC", System Unavailable"$RED"(3)"$NC", System Available Again"$RED"(4)"$NC":")" templateNumber
    if  [ "$templateNumber" != "1" ] && [ "$templateNumber" != "2" ] && [ "$templateNumber" != "3" ] && [ "$templateNumber" != "4" ]; then
      read -p "$(echo -e "Invalid input: "$RED$templateNumber$NC" Usage: Deployment Approval, Deployment, System Unavailable, System Available Again "$RED"(1,2,3,4)"$NC". Try again? "$RED"(Y/N)"$NC":")" tryAgain;
        if [ $tryAgain != "Y" ]; then exit 0; fi
    else
      if  [ "$templateNumber" == "3" ] && [ "$NOTRACE" == true ]; then
        reason="";
        date="";
        fromTime="";
        toTime="";
        printf $RED"The folling arguments will be parsed into your Unavailability mail "$NC"\n";
        read -p "$(echo -e "The systems will be unavailable due to:"$RED"(type reason of unavailability)"$NC)" reason;
        read -p "$(echo -e "The systems will be unavailable on date:"$RED"(type date of unavailability)"$NC)" date;
        read -p "$(echo -e "from:"$RED"(type starting time of unavailability)"$NC)" fromTime;
        read -p "$(echo -e "to:"$RED"(type ending time of unavailability)"$NC)" toTime;
      fi
      tryAgain="";
    fi
  fi

  if [ "$tryAgain" != "Y" ]; then
    if  [ "$marketName" == "BE-NL" ] && ([ "$templateNumber" == "3" ] || [ "$templateNumber" == "4" ]); then
      read -p "$(echo -e "Invalid market-template combination: "$RED$marketName$NC" cannot be combined with templateNumber "$RED$templateNumber$NC". Try again? "$RED"(Y/N)"$NC":")" tryAgain;
        if [ $tryAgain != "Y" ]; then exit 0; fi
    else
        break
    fi
  fi
done

if [ "$marketName" == "BE-NL" ]; then
    templateMultiplier="Multiple";
else
    templateMultiplier="Single";
fi

case $templateNumber in
  1) databaseName="Deployment Approval" ;
    templateName="Deployment"$templateMultiplier"Market" ;;
  2) databaseName="Deployment" ;
    templateName="Deployment"$templateMultiplier"Market" ;;
  3) if [ "$NOTRACE" == true ]; then
       databaseName="System UnavailableParam" ;
     else
       databaseName="System Unavailable" ;
     fi
    templateName="SystemAvailability" ;;
  4) databaseName="System Available Again" ;
    templateName="SystemAvailability" ;;
  *) ;;
esac

if [[ ($templateNumber == 1 || $templateNumber == 2)]]; then
  systemName="Miles PROD SF1-" ;
else
  systemName="Miles INT SF1-" ;
fi

#Assembling it all, substitute variables if $NOTRACE
databasePath="$systemName$marketName $databaseName.csv";
if [ "$templateNumber" == "3" ] && [ "$NOTRACE" == true ]; then
  cat "$databasePath" | sed -e "s#\${reason}#""$reason""#" | sed -e "s#\${date}#""$date""#" | sed -e "s#\${fromTime}#""$fromTime""#" | sed -e "s#\${toTime}#""$toTime""#" > temp.csv
  #reset databasePath tot temp.csv w substituted content
  databasePath="temp.csv";
fi
templatePath="templates/$templateName.html";

mailmerge --no-dry-run --template "$templatePath" --database "$databasePath";

if [ "$templateNumber" == "3" ] && [ "$NOTRACE" == true ]; then
  rm temp.csv;
fi
