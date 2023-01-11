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

# Pre-req's
* Python runtime installed (this can be done as one of your steps of your pipeline)
* credentials of a team mailbox.  (not mandatory)
* mailmerge installed. (see [https://github.com/awdeorio/mailmerge](https://github.com/awdeorio/mailmerge)) on cli: **$ pip install mailmerge**\
And you're off to get started!
  
# Manual Usage
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
    - [Miles INT SF1-BE System Unavailable.csv](Miles%20INT%20SF1-BE%20System%20Unavailable.csv) 
    - [Miles INT SF1-BE System Available Again.csv](Miles%20INT%20SF1-BE%20System%20Available%20Again.csv)
    - [Miles INT SF1-NL System Unavailable.csv](Miles%20INT%20SF1-NL%20System%20Unavailable.csv)
    - [Miles INT SF1-NL System Available Again.csv](Miles%20INT%20SF1-NL%20System%20Available%20Again.csv)
  - [DeploymentSingleMarket.html](./templates/DeploymentSingleMarket.html) for asking market rep of 1 market for approval or to notify requesters a deployment happened.  
    - [Miles PROD SF1-BE Deployment Approval.csv](Miles%20PROD%20SF1-BE%20Deployment%20Approval.csv)
    - [Miles PROD SF1-BE Deployment.csv](Miles%20PROD%20SF1-BE%20Deployment.csv)
    - [Miles PROD SF1-NL Deployment Approval.csv](Miles%20PROD%20SF1-NL%20Deployment%20Approval.csv)
    - [Miles PROD SF1-NL Deployment.csv](Miles%20PROD%20SF1-NL%20Deployment.csv)
  - [DeploymentMultipleMarket.html](./templates/DeploymentMultipleMarket.html) for asking market reps of both markets for approval or to notify requesters a deploy happened.
    - [Miles PROD SF1-BE-NL Deployment Approval.csv](Miles%20PROD%20SF1-BE-NL%20Deployment%20Approval.csv)
    - [Miles PROD SF1-BE-NL Deployment.csv](Miles%20PROD%20SF1-BE-NL%20Deployment.csv)

* Interactive script added to facilitate triggering mail with all database content: [milesMail.sh](milesMail.sh)\
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
      the installation is ending up in the user profile of the current user and did nog work correctly.\
      Most probably the installation should happen in the admin profile and add mailmerge to the path of the local machine.  Conclusion at the moment writing is that this interactive script is only working on a machine and admin profile.\As this is not the main intend of this project, this shortcoming is put to a lower priority.     

# File structure
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

# Maintenance 
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
