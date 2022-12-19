# MailMerge
Simple templates to send from cli, or in automation.\
This project had built all needed templates to use with [mailmerge](https://github.com/awdeorio/mailmerge).\
It consists out of **templates** and **databases**.\
Databases are the files with variable content to send.\

In the templates the variable names are used with {{}}, e.g. {{variableName}}.\
The **variables names** are found in the database headers.

E.g.  1 template can be used in conjunction with several possible databases.\
(only 1 at the time) See [Manual Usage](#manual-usage) section below for combo's.   

# Pre-req's
* Python runtime installed (this can be done as one of your steps of your pipeline)
* credentials of a team mailbox.  (not mandatory)
* mailmerge installed. (see [https://github.com/awdeorio/mailmerge](https://github.com/awdeorio/mailmerge)) on cli: $ pip install mailmerge\
And you're off to get started!
  
# Manual Usage
Below some explanation how this project is to be used
* In terminal cli
  - root of the project call: mailmerge --no-dry-run --template "path to template" --database "path to databasename"
  - e.g. mailmerge --no-dry-run --template [templates/DeploymentSingleMarket.html](./templates/DeploymentSingleMarket.html) --database [Miles PROD SF1-NL Deployment Approval.csv](.Miles%20PROD%20SF1-NL%20Deployment%20Approval.csv)
  - Check out [https://github.com/awdeorio/mailmerge](https://github.com/awdeorio/mailmerge) for extensive usage.
  - type mailmerge --help for options.  
* Setup your smtp mailserver in [mailmerge_server.conf](mailmerge_server.conf) 

* What template to use with which database?  Basically you have 3 templates and can be used in conjuction with the csv's below them.
  - [SystemAvailability.html](./templates/SystemAvailability.html) for notifying systems of a market are unavailable, or available again. 
    - [Miles INT SF1-BE System Unavailable.csv](Miles%20INT%20SF1-BE%20System%20Unavailable.csv) 
    - [Miles INT SF1-BE System Available Again.csv](Miles%20INT%20SF1-BE%20System%20Available%20Again.csv)
    - [Miles INT SF1-NL System Unavailable.csv](Miles%20INT%20SF1-NL%20System%20Unavailable.csv)
    - [Miles INT SF1-NL System Available Again.csv](Miles%20INT%20SF1-NL%20System%20Available%20Again.csv)
  - [DeploymentSingleMarket.html](./templates/DeploymentSingleMarket.html) for asking market rep of 1 market for approval or to notify requesters a deploy happened.  
    - [Miles PROD SF1-BE Deployment.csv](Miles%20PROD%20SF1-BE%20Deployment.csv)
    - [Miles PROD SF1-BE Deployment Approval.csv](Miles%20PROD%20SF1-BE%20Deployment%20Approval.csv)
    - [Miles PROD SF1-NL Deployment.csv](Miles%20PROD%20SF1-NL%20Deployment.csv)
    - [Miles PROD SF1-NL Deployment Approval.csv](Miles%20PROD%20SF1-NL%20Deployment%20Approval.csv)
  - [DeploymentMultipleMarket.html](./templates/DeploymentMultipleMarket.html) for asking market reps of both markets for approval or to notify requesters a deploy happened.
    - [Miles PROD SF1-BE-NL Deployment Approval.csv](Miles%20PROD%20SF1-BE-NL%20Deployment%20Approval.csv)
    - [Miles PROD SF1-BE-NL Deployment.csv](Miles%20PROD%20SF1-BE-NL%20Deployment.csv)

# File structure
Below the file structure to understand the remaining template snippets
- [SystemAvailability.html](./templates/SystemAvailability.html) inherits from 
  - [Notification.html](./templates/layouts/Notification.html) which is the base of all notifications.\
  It has got all images on board to be shown for a notification mail.\
  On its turn this inherits from 
    - [BaseTemplate.html](./templates/layouts/BaseTemplate.html) which serves all mail communication needs like to, from, cc, subject fields etc.
- [DeploymentSingleMarket.html](./templates/DeploymentSingleMarket.html) inherits from
  - [Deployment.html](./templates/layouts/Notification.html) which is the base of all deployment related mail communication.\
  On its turn this inherits from
    - [ActionRequired.html](./templates/layouts/ActionRequired.html) which is the base of all action required mail communication.\
    It has got all images on board to be shown for a action required mail.\
    On its turn this inherits from
      - [BaseTemplate.html](./templates/layouts/BaseTemplate.html) which serves all mail communication needs like to, from, cc, subject fields etc.
- [DeploymentMultipleMarket.html](./templates/DeploymentMultipleMarket.html) inherits from
  - [Deployment.html](./templates/layouts/Notification.html) which is the base of all deployment related mail communication.\
  On its turn this inherits from
    - [ActionRequired.html](./templates/layouts/ActionRequired.html) which is the base of all action required mail communication.\
    It has got all images on board to be shown for a action required mail.\
    On its turn this inherits from
      - [BaseTemplate.html](./templates/layouts/BaseTemplate.html) which serves all mail communication needs like to, from, cc, subject fields etc.



