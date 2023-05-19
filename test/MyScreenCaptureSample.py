# Added to Git for handover
# TESTED & WORKING code!  Not working in BMW environment however...
# Currently, Python isn't properly configured, and cannot run from IntelliJ environment.
# Interpreting isn't working properly:  Firefox Webdriver isn't correct version, as it's complaining about an existing method: get_full_page_screenshot_as_file
# Use this as example after installing Python properly.

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
        # driver = webdriver.Chrome()

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

            # full page screenshot for Firefox
            driver.get_full_page_screenshot_as_file(capturepath)
            # window screenshot for Chrome
            # driver.get_screenshot_as_file(capturepath)

            driver.close()
        except NoSuchElementException:
            driver.close()
            return False
        return True


myclass = MyClass()
myclass.screencapture("TestJiraScreenshotPage.png", "MILES4ALL", "2023 W19 Release BE")
