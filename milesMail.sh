RED='\033[0;31m';
NC='\033[0m';

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
    read -p "$(echo -e "type the template respective number: Deployment, Deployment Approval, System Unavailable, System Available Again "$RED"(1,2,3,4)"$NC":")" templateNumber
    if  [ "$templateNumber" != "1" ] && [ "$templateNumber" != "2" ] && [ "$templateNumber" != "3" ] && [ "$templateNumber" != "4" ]; then
      read -p "$(echo -e "Invalid input: "$RED$templateNumber$NC" Usage: Deployment Approval, Deployment, System Unavailable, System Available Again "$RED"(1,2,3,4)"$NC". Try again? "$RED"(Y/N)"$NC":")" tryAgain;
        if [ $tryAgain != "Y" ]; then exit 0; fi
    else
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
  3) databaseName="System Unavailable" ;
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

#Assembling it all
templatePath="templates/$templateName.html";
databasePath="$systemName$marketName $databaseName.csv";

echo -e "the database path will be: ${RED}$databasePath${NC}";
echo -e "the template path will be: ${RED}$templatePath${NC}";
mailmerge --no-dry-run --template "$templatePath" --database "$databasePath";
