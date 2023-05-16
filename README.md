This repo serves 2 purposes.  
* Jira Release editor
* MailMerge 

Both are implemented around a GH Actions pipeline, found in the .github/workflows folder.
Both can be used with or without each other.  Future will tell how this repo will evolve. 

# Jira Release editor

## Source of existence
In Atlassian Jira applying CRUD operations on a release in Jira is not possible without having the role of Project Administrator.
At the moment of writing this is a Defect that is gathering interest for quite some years now.
To overcome this, this part of the repo is created.

What this part of the repo provides functionality for, is to allow normal users to request this repo to for a CRUD operation.
This happens in a interactive way, through command line asking for arguments that are needed for these CRUD operations.
Behind the scenes, these scripts do locally a git-commit of the users request, and finish that off with a git-push.

The benefits:
* Jira version manipulations are been tracked now.
* The need to give people Project Administrator rights in order to manipulate Jira Versions became due.\
  From now on, people can use these client scripts and are able to manipulate Jira Versions without the need for the "Project Administrator" role. The user that will do the actual manipulations in Jira is a technical QQ-account.

## Pre-req's
* Having a GitHub account.
* Having this repo on your local machine.  (Clone this repo to your local machine.)
  * Many explanations can be found in the corporate Confluence and the Developer Portal.
* Having a Linux terminal available to run these client scripts.
  * Git Bash is an example, this can be found as Git for Windows in the WUSS.
  * An even better and more user friendly choice is IntelliJ Community edition, which contains several types of terminals.
  * Top notch, is of course having a Linux machine. There everything is available.
* No additional Git knowledge required, apart from the concept how Git works. (commit locally, push to remote)

## Manual Usage
* Go to the folder where the client scripts are:\
  **$cd ./actions/client**
* Show the client scripts\
  **$ls -lst**  to see the client scripts if you don't know the by heart.
  * Or look with IntelliJ in the folder structure, which will provide more insights.
* Type **$bash**  (with the space after)
* Start typing now the first letters of your script + hit the Tab button; e.g. 'new'+Tab.\
  This is standard autocomplete functionality in Linux: you'll see the full name of the script.\Finish off by smashing the Enter key. \other examples:
  * 'bash rel'+Tab -> $bash releaseJiraVersion.sh
  * 'bash ar'+Tab -> $bash archiveJiraVersion.sh
  * 'bash unA'+Tab -> $bash unArchiveJiraVersion.sh
  * 'bash unR'+Tab -> $bash unReleaseJiraVersion.sh
  * 'bash upd'+Tab -> $bash updateJiraVersion  + Type further 'D'+Tab -> $bash updateJiraVersionDescription.sh
  * 'bash upd'+Tab -> $bash updateJiraVersion  + Type further 'N'+Tab -> $bash updateJiraVersionName.sh
  * 'bash upd'+Tab -> $bash updateJiraVersion  + Type further 'R'+Tab -> $bash updateJiraVersionReleaseDate.sh

The client scripts will guide you through all needed information.
Once finished, you'll find the GitHub Actions pipeline doing the rest for you: update/create the Jira Version as you requested.

## File structure

### Scripts Folders
[./actions/client](./actions/client) is the location of all client scripts. They are all interactive, and ask you for the needed input. There is some checking in it as well, e.g. the right data format, already existing Jira versions etc...\
[./actions/server](./actions/server) contains the heavy fork lifting. These are the scripts that are launched by the pipeline and to the actual Jira operations for you, but with a technical QQ-account.

[./actions/server/createRequestedVersions.sh](./actions/server/createRequestedVersions.sh) Does what it suggests it does.\
Create requested versions, which is triggered from client script [./actions/client/newJiraVersion.sh](./actions/client/newJiraVersion.sh).

[./actions/server/updateChangedVersion.sh](./actions/server/updateChangedVersion.sh) Does what it suggests it does.\
Update versions, which is triggered from client scripts:
* [./actions/client/archiveJiraVersion.sh](./actions/client/archiveJiraVersion.sh)
* [./actions/client/releaseJiraVersion.sh](./actions/client/releaseJiraVersion.sh)
* [./actions/client/unArchiveJiraVersion.sh](./actions/client/unArchiveJiraVersion.sh)
* [./actions/client/unReleaseJiraVersion.sh](./actions/client/unReleaseJiraVersion.sh)
* [./actions/client/updateJiraVersionDescription.sh](./actions/client/updateJiraVersionDescription.sh)
* [./actions/client/updateJiraVersionName.sh](./actions/client/updateJiraVersionName.sh)
* [./actions/client/updateJiraVersionReleaseDate.sh](./actions/client/updateJiraVersionReleaseDate.sh)

### Underlying scripts
* [./lib/lib.sh](./lib/lib.sh) contains all boilerplate scripts used in the **client** scripts.
* [./lib/pipelib.sh](./lib/pipelib.sh) contains all boilerplate scripts used in the **server** scripts.

# MailMerge
Simple templates to send from cli, or in automation.\
This project has built all needed templates to use with [mailmerge](https://github.com/awdeorio/mailmerge).\
It consists out of **templates (.html)** and **databases (.csv)**.\
Templates are built for the [Jinja2](https://pypi.org/project/Jinja2/) template engine used by [mailmerge](https://github.com/awdeorio/mailmerge).\
Databases are the files with variable content parsed into the templates to send. 

In the templates the variable names are used with {{}}, e.g. {{variableName}}.\
The **variables names** are found in the database headers.

E.g.  1 template can be used in conjunction with several possible databases.\
(only 1 at the time) See [Manual Usage](#manual-usage) section below for combo's.   

## Pre-req's
* Python runtime installed (this can be done as one of your steps of your pipeline)
* credentials of a team mailbox.  (not mandatory)
* mailmerge installed. (see [https://github.com/awdeorio/mailmerge](https://github.com/awdeorio/mailmerge)) on cli: **$ pip install mailmerge**\
And you're off to get started!

## Manual Usage
Below some explanation how this project is to be used
* In terminal cli
  - root of the project call: **mailmerge --no-dry-run --template "path to template" --database "path to databasename"**
  - e.g. **mailmerge --no-dry-run --template [templates/DeploymentSingleMarket.html](./templates/DeploymentSingleMarket.html) --database [Miles PROD SF1-NL Deployment Approval.csv](Miles%20PROD%20SF1-NL%20Deployment%20Approval.csv)**
  - Check out [https://github.com/awdeorio/mailmerge](https://github.com/awdeorio/mailmerge) for extensive usage.
  - type mailmerge --h for options.  
* Set up your smtp mailserver in [mailmerge_server.conf](./env/mailmerge_server.conf) 
* Deployment mail templates like [DeploymentSingleMarket.html](./templates/DeploymentSingleMarket.html) and [DeploymentMultipleMarket.html](./templates/DeploymentMultipleMarket.html) have the possibility to attach an image of the test run report.\
Include those image by leaving them in a folder with the name of your release with the **standard name "image001.png"**.\
Adapt your database to refer to the right release you're mailing for.\
The mail template will pick them up and include them in the mail.\
  (e.g.[2022 W42 Release BE](./images/2022%20W42%20Release%20BE) with the image name [image001.png](./images/2022%20W42%20Release%20BE/image001.png))

* What template to use with which database?  Basically you have 3 templates and can be used in conjunction with the csv's below them.
  - [SystemAvailability.html](./templates/SystemAvailability.html) for notifying systems of a market are unavailable, or available again. 
    - [Miles INT SF1-BE System Unavailable.csv](./templatedata/Miles%20INT%20SF1-BE%20System%20Unavailable.csv) 
    - [Miles INT SF1-BE System Available Again.csv](./templatedata/Miles%20INT%20SF1-BE%20System%20Available%20Again.csv)
    - [Miles INT SF1-NL System Unavailable.csv](./templatedata/Miles%20INT%20SF1-NL%20System%20Unavailable.csv)
    - [Miles INT SF1-NL System Available Again.csv](./templatedata/Miles%20INT%20SF1-NL%20System%20Available%20Again.csv)
  - [DeploymentSingleMarket.html](./templates/DeploymentSingleMarket.html) for asking market rep of 1 market for approval or to notify requesters a deployment happened.  
    - [Miles PROD SF1-BE Deployment Approval.csv](./templatedata/Miles%20PROD%20SF1-BE%20Deployment%20Approval.csv)
    - [Miles PROD SF1-BE Deployment.csv](./templatedata/Miles%20PROD%20SF1-BE%20Deployment.csv)
    - [Miles PROD SF1-NL Deployment Approval.csv](./templatedata/Miles%20PROD%20SF1-NL%20Deployment%20Approval.csv)
    - [Miles PROD SF1-NL Deployment.csv](./templatedata/Miles%20PROD%20SF1-NL%20Deployment.csv)
  - [DeploymentMultipleMarket.html](./templates/DeploymentMultipleMarket.html) for asking market reps of both markets for approval or to notify requesters a deploy happened.
    - [Miles PROD SF1-BE-NL Deployment Approval.csv](./templatedata/Miles%20PROD%20SF1-BE-NL%20Deployment%20Approval.csv)
    - [Miles PROD SF1-BE-NL Deployment.csv](./templatedata/Miles%20PROD%20SF1-BE-NL%20Deployment.csv)

* Interactive script added to facilitate triggering mail with all database content: [milesMail.sh](./actions/client/milesMail.sh)\
Usage on cli: $ **bash milesMail.sh**\
The script asks you for input parameters to determine which mail you like to use. Is the mail for: 
  - Letter code of market: <font color='red'>**(BE,NL,BE-NL)**</font>:
  - Deployment Approval<font color='red'>**(1)**</font>, Deployment<font color='red'>**(2)**</font>, System Unavailable<font color='red'>**(3)**</font>, System Available Again<font color='red'>**(4)**</font>:
  - Combination of sending system (Un)Available (<font color='red'>**3 or 4**</font>) for multiple markets (<font color='red'>**BE-NL**</font>) is not possible and fed back through cli response.
  - By default, the script takes **the content of the _database csv's_.**\
  Exception for template <font color='red'>**(3)**</font> (System Unavailable):\
  Choosing template <font color='red'>**(3)**</font> using the **-n** option the user will be asked content to parse into the target mail.\
  Like this, it is always possible to send out a **System Unavailable** mail at any time, but with parameterized content.\
  Content parameters:
    - reason of the System Unavailable.
    - date of the System Unavailable.
    - start time of the System Unavailable.
    - end time of the System Unavailable.\
    \
    Usage: $ **bash milesMail.sh -n**\
    check out [SystemAvailability.html](./templates/SystemAvailability.html) to see where these parameters fit in.
    - Take into account the usage of the above is by exception. The purpose is to adapt the database csv's, commit & push them, and have an automated mail sent for you.
    - Prereq's for this to work: see [Pre-Req's](#pre-reqs) section.
      - At the moment of writing, after installing Python through WUSS\
      installing mailmerge through **$ pip install mailmerge** with admin rights,\
      the installation is ending up in the user profile of the current user and did not work correctly.\
      Most probably the installation should happen in the admin profile and add mailmerge to the path of the local machine.\
      Conclusion at the moment writing is that this interactive script is only working on a machine and admin profile.\
      As this is not the main intend of this project, this shortcoming is put to a lower priority.     

## File structure
Below the file structure to understand the remaining template snippets
- [SystemAvailability.html](./templates/SystemAvailability.html) inherits from 
  - [Notification.html](./templates/layouts/Notification.html) which is the base of all notifications.\
  It has got all images on board to be shown for a notification mail.\
  On its turn this inherits from 
    - [BaseTemplate.html](./templates/layouts/BaseTemplate.html) which serves all mail communication needs like\
    to, from, cc, subject fields etc.
- [DeploymentSingleMarket.html](./templates/DeploymentSingleMarket.html) inherits from
  - [Deployment.html](./templates/layouts/Notification.html) which is the base of all deployment related mail communication.\
  On its turn this inherits from
    - [ActionRequired.html](./templates/layouts/ActionRequired.html) which is the base of all action required mail communication.\
    It has got all images on board to be shown for an action required mail.\
    On its turn this inherits from
      - [BaseTemplate.html](./templates/layouts/BaseTemplate.html) which serves all mail communication needs like\
      to, from, cc, subject fields etc.
- [DeploymentMultipleMarket.html](./templates/DeploymentMultipleMarket.html) inherits from
  - [Deployment.html](./templates/layouts/Notification.html) which is the base of all deployment related mail communication.\
  On its turn this inherits from
    - [ActionRequired.html](./templates/layouts/ActionRequired.html) which is the base of all action required mail communication.\
    It has got all images on board to be shown for an action required mail.\
    On its turn this inherits from
      - [BaseTemplate.html](./templates/layouts/BaseTemplate.html) which serves all mail communication needs like\
      to, from, cc, subject fields etc.

## Maintenance 
* Templates can be added, changed etc.\
However, the purpose isn't changing the templates but rather the databases.\
With this it becomes possible to add mail communication as part of your releases.
* CSV's are a brittle file format.\
To make it a little more robust for field content, all fields are surrounded with double quotes.\
Using ',' within the CSV fields doesn't harm anymore and becomes usable now. (e.g. multiple mail addresses)\
For this reason, **avoid using Excel as editor for changing these database files**.\
Locale in the west is mostly using ';' as a delimiter.\
Opening the csv databases with Excel and saving 
  * removes your double quotes ' " '  !!!
  * replaces comma's ',' by semicolon ';'.!!\
  Plenty of good editors are out there better suitable for the job.\
  IntelliJ, Notepad++, UltraEdit to name a few. 
* Ideas future usage: 
  * Using your commit message as a field for the templates. 
  * Having your approval reply mail triggering a pipeline. 
  * Having your mail sent when a pipeline is (successfully) finished. 

