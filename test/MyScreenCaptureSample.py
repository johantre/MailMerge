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


from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC

class MyClass:
    def screencapture(self, capturepath, projectkey, fixversion):
        baseurl = "https://developer.atlassian.com/cloud/jira/platform/rest/v3/api-group-jql/#api-group-jql"

        options = Options()
        # uncomment once working & pipeline execution run
        # options.add_argument('-headless')

        e = datetime.datetime.now()
        print("before webdriver (WD) instantiation: %s:%s:%s" % (e.hour, e.minute, e.second))

        driver = webdriver.Firefox(options=options)

        e = datetime.datetime.now()
        print("WD instantiated: %s:%s:%s" % (e.hour, e.minute, e.second))

        driver.get(baseurl)
        driver.maximize_window()
        wait = WebDriverWait(driver, 5)

        try:
            # Click away Garbage "Get started"
            element = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[2]/div[2]/div/div[2]/div/div/section/div[2]/div/button/span')))
            element.click()

            # Click away Garbage "Skip"
            element = wait.until(EC.element_to_be_clickable((By.XPATH, '/html/body/div[2]/div[2]/div[3]/div/div/div/div[2]/div/div[2]/button/span')))
            element.click()

            # Click intended button "Show child properties"
            element = wait.until(EC.element_to_be_clickable((By.XPATH, '//*[@id="root"]/div/div[3]/div[2]/div/div/div[2]/div[1]/div[6]/div/div/div/button')))
            element.click()

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

myclass = MyClass()
MyClass.screencapture(myclass, "TestJiraScreenshotPage.png", "ddd", "")

#myTest = RecorderTest()

#myTest.test_recording()

#myTest.open("https://stackoverflow.com/q/75652543/7058266")
#myTest.click('button:contains("Accept all cookies")')
#myTest.sleep(3)
