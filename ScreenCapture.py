# Added to Git for handover
# UNTESTED CODE!!!!!
# This is the first script to generate the Test Runs Report from our pipeline, when e.g. a release is set to "released": true
# This code can be used before sending out the mail template with mailmerge.
# Specifically, before sending out with the Deployment templates ./templates/layouts/Deployment<Single/Multiple>Market.html,
# as they require manual work:
# * generating XRay Test Run report, (done by this script)
# * manually take screenshot, (done by this script)
# * copy/paste in Outlook mail, (can be done by mailmerge facilities in this repo)
# * copy/paste Jira Release URL, (work in progress, see ./actions/client/milesMail.sh

# In progress:
# * getting screenshots w headless browser & Python, (done by this script)
# * save screenshot to $DIR/../../images/releaseName folder under the name image001.png (done by this script)
# * getting assigned users from Jira tests (REST) + mail address
# * getting jira release URL
# * update 'right' (=see ./actions/client/milesMail.sh)mail database CSV file in $DIR/../../templatedata folder
# * re-use the ./actions/client/milesMail.sh script to tell pipeline after push what mail to send.
# * cleanup useless cat's


from selenium import webdriver
from selenium.webdriver.firefox.options import Options
from selenium.common.exceptions import NoSuchElementException
import datetime


def screencapture(capturepath: str,
                  projectkey: str,
                  fixversion: str):
    baseurl = "https://atc.bmwgroup.net/jira/secure/XrayReport!default.jspa?selectedReportKey=xray-report-testruns&selectedProjectKey=" + projectkey + "&filterScope=filter&fixVersion=" + fixversion

    options = Options()
    options.add_argument('-headless')

    e = datetime.datetime.now()
    print("before webdriver (WD) instantiation: %s:%s:%s" % (e.hour, e.minute, e.second))

    driver = webdriver.Firefox(options=options)

    e = datetime.datetime.now()
    print("WD instantiated: %s:%s:%s" % (e.hour, e.minute, e.second))

    driver.get(baseurl)
    try:
        # Click the "Generate Report" button
        # Todo: check existance of the button first
        generatebt = driver.find_elements(by="xpath", value="//*[@id='raven-load-testruns-requirement-converage-report']")
        driver.execute_script("click();", generatebt[0])

        # Click the "Load all" button
        # Todo: check existence of the button first
        loadallbt = driver.find_elements(by="xpath", value="//*[@id='load-all-bt']")
        driver.execute_script("click();", loadallbt[0])

        driver.get_full_page_screenshot_as_file(capturepath)

        driver.close()
    except NoSuchElementException:
        driver.close()
        return False
    return True

# URLs Needed  & Xpath to use
# Base URL https://atc.bmwgroup.net/jira/secure/XrayReport!default.jspa?selectedReportKey=xray-report-testruns&selectedProjectKey=MILES4ALL&filterScope=filter&fixVersion=2023+W19+Release+BE
#
# Generate button, from the above page
# //*[@id="raven-load-testruns-requirement-converage-report"]

# Load all link  (first check existence!)
# //*[@id="load-all-bt"]
#
