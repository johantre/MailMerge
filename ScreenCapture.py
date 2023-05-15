# Added to Git for handover
# UNTESTED CODE!!!!!
# This is the first script to generate the Test Runs Report from our pipeline, when e.g.

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
